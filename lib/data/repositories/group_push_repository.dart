import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../local/database.dart';
import '../local/group_dao.dart';
import '../local/user_dao.dart';
import '../../services/supabase_config_service.dart';

class GroupPushException implements Exception {
  GroupPushException(this.message, [this.statusCode]);

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'GroupPushException(${statusCode ?? 'local'}): $message';
}

class GroupPushRepository {
  GroupPushRepository({
    required GroupDao groupDao,
    required UserDao userDao,
    SupabaseConfigService? configService,
    http.Client? client,
    Uuid? uuid,
  })  : _groupDao = groupDao,
        _userDao = userDao,
        _configService = configService ?? const SupabaseConfigService(),
        _client = client ?? http.Client(),
        _uuid = uuid ?? const Uuid();

  final GroupDao _groupDao;
  final UserDao _userDao;
  final SupabaseConfigService _configService;
  final http.Client _client;
  final Uuid _uuid;

  AppDatabase get _db => _groupDao.attachedDatabase;

  Future<void> dispose() async {
    _client.close();
  }

  Future<SupabaseConfig> _loadConfig() => _configService.loadConfig();

  Future<String> _requireAccessToken({bool useServiceRole = false}) async {
    final config = await _loadConfig();
    final fallbackToken = config.authToken(useServiceRole: useServiceRole);

    if (config.url.isEmpty || fallbackToken.isEmpty) {
      throw GroupPushException(
        'Configura Supabase antes de sincronizar.',
      );
    }
    return fallbackToken;
  }

  Future<Map<String, String>> _headers({String? accessToken}) async {
    final config = await _loadConfig();
    final useServiceRole = accessToken == null;
    final token = accessToken ?? await _requireAccessToken(useServiceRole: true);
    final apiKey = useServiceRole
        ? config.authToken(useServiceRole: true)
        : config.anonKey;
    return {
      'apikey': apiKey,
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Prefer': 'return=minimal',
    };
  }

  Future<Uri> _buildUri(String path, [Map<String, String>? query]) async {
    final config = await _loadConfig();
    return Uri.parse('${config.url}$path').replace(queryParameters: query);
  }

  Future<Group> createGroup({
    required String name,
    String? description,
    required LocalUser owner,
    String? accessToken,
  }) async {
    final now = DateTime.now();

    final ownerRecord = await _userDao.getById(owner.id);
    if (ownerRecord == null || ownerRecord.remoteId == null) {
      throw GroupPushException('El usuario debe tener remoteId antes de crear un grupo.');
    }

    final groupUuid = _uuid.v4();
    final ownerMemberUuid = _uuid.v4();

    return _db.transaction(() async {
      final groupId = await _groupDao.insertGroup(
        GroupsCompanion.insert(
          uuid: groupUuid,
          remoteId: Value(groupUuid),
          name: name,
          description:
              description != null ? Value(description) : const Value.absent(),
          ownerUserId: Value(owner.id),
          ownerRemoteId: Value(ownerRecord.remoteId!),
          isDirty: const Value(false),
          isDeleted: const Value(false),
          syncedAt: Value(now),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      final group = (await _groupDao.findGroupById(groupId))!;

      await _groupDao.insertMember(
        GroupMembersCompanion.insert(
          uuid: ownerMemberUuid,
          remoteId: Value(ownerMemberUuid),
          groupId: group.id,
          groupUuid: group.uuid,
          memberUserId: owner.id,
          memberRemoteId: Value(ownerRecord.remoteId!),
          role: const Value('admin'),
          isDirty: const Value(false),
          isDeleted: const Value(false),
          syncedAt: Value(now),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      await _post(
        path: '/rest/v1/groups',
        body: {
          'id': group.uuid,
          'name': name,
          'description': description,
          'owner_id': ownerRecord.remoteId,
          'created_at': now.toIso8601String(),
        },
        accessToken: accessToken,
      );

      await _post(
        path: '/rest/v1/group_members',
        body: {
          'id': ownerMemberUuid,
          'group_id': group.uuid,
          'user_id': ownerRecord.remoteId,
          'role': 'admin',
          'created_at': now.toIso8601String(),
        },
        accessToken: accessToken,
      );

      return group;
    });
  }

  Future<void> updateGroup({
    required Group group,
    required String name,
    String? description,
    String? accessToken,
  }) async {
    final now = DateTime.now();

    await _groupDao.updateGroupFields(
      groupId: group.id,
      entry: GroupsCompanion(
        name: Value(name),
        description:
            description != null ? Value(description) : const Value.absent(),
        isDirty: const Value(false),
        syncedAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    await _patch(
      path: '/rest/v1/groups?id=eq.${group.remoteId ?? group.uuid}',
      body: {
        'name': name,
        'description': description,
        'updated_at': now.toIso8601String(),
      },
      accessToken: accessToken,
    );
  }

  Future<void> deleteGroup({
    required Group group,
    String? accessToken,
  }) async {
    await _groupDao.softDeleteGroup(
      groupId: group.id,
      timestamp: DateTime.now(),
    );

    await _delete(
      path: '/rest/v1/groups?id=eq.${group.remoteId ?? group.uuid}',
      accessToken: accessToken,
    );
  }

  Future<void> transferOwnership({
    required Group group,
    required LocalUser newOwner,
    String? accessToken,
  }) async {
    final now = DateTime.now();

    await _groupDao.updateGroupFields(
      groupId: group.id,
      entry: GroupsCompanion(
        ownerUserId: Value(newOwner.id),
        ownerRemoteId: newOwner.remoteId != null
            ? Value(newOwner.remoteId)
            : const Value.absent(),
        updatedAt: Value(now),
        syncedAt: Value(now),
        isDirty: const Value(false),
      ),
    );

    await _patch(
      path: '/rest/v1/groups?id=eq.${group.remoteId ?? group.uuid}',
      body: {
        'owner_id': newOwner.remoteId,
        'updated_at': now.toIso8601String(),
      },
      accessToken: accessToken,
    );
  }

  Future<GroupMember> addMember({
    required Group group,
    required LocalUser user,
    required String role,
    String? accessToken,
  }) async {
    final now = DateTime.now();

    final localUser = await _userDao.getById(user.id);
    if (localUser == null || localUser.remoteId == null) {
      throw GroupPushException('El usuario debe estar sincronizado antes de unirse al grupo.');
    }

    final memberRemoteUuid = _uuid.v4();

    return _db.transaction(() async {
      final existing = await _groupDao.findMember(
        groupId: group.id,
        userId: user.id,
      );
      if (existing != null && !existing.isDeleted) {
        throw GroupPushException('El usuario ya es miembro del grupo.');
      }

      await _groupDao.insertMember(
        GroupMembersCompanion.insert(
          uuid: memberRemoteUuid,
          remoteId: Value(memberRemoteUuid),
          groupId: group.id,
          groupUuid: group.uuid,
          memberUserId: user.id,
          memberRemoteId: Value(localUser.remoteId!),
          role: Value(role),
          isDirty: const Value(false),
          isDeleted: const Value(false),
          syncedAt: Value(now),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      final member = (await _groupDao.findMemberByRemoteId(memberRemoteUuid))!;

      await _post(
        path: '/rest/v1/group_members',
        body: {
          'id': memberRemoteUuid,
          'group_id': group.remoteId ?? group.uuid,
          'user_id': localUser.remoteId,
          'role': role,
          'created_at': now.toIso8601String(),
        },
        accessToken: accessToken,
      );

      return member;
    });
  }

  Future<void> updateMemberRole({
    required GroupMember member,
    required String role,
    String? accessToken,
  }) async {
    final now = DateTime.now();

    await _groupDao.updateMemberFields(
      memberId: member.id,
      entry: GroupMembersCompanion(
        role: Value(role),
        isDirty: const Value(false),
        syncedAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    await _patch(
      path: '/rest/v1/group_members?id=eq.${member.remoteId ?? member.uuid}',
      body: {
        'role': role,
        'updated_at': now.toIso8601String(),
      },
      accessToken: accessToken,
    );
  }

  Future<void> removeMember({
    required GroupMember member,
    String? accessToken,
  }) async {
    final now = DateTime.now();

    await _groupDao.softDeleteMember(
      memberId: member.id,
      timestamp: now,
    );

    await _patch(
      path: '/rest/v1/group_members?id=eq.${member.remoteId ?? member.uuid}',
      body: {
        'is_deleted': true,
        'updated_at': now.toIso8601String(),
      },
      accessToken: accessToken,
    );
  }

  Future<GroupInvitation> createInvitation({
    required Group group,
    required LocalUser inviter,
    String role = 'member',
    DateTime? expiresAt,
    String? accessToken,
  }) async {
    final now = DateTime.now();
    final expiry = expiresAt ?? now.add(const Duration(days: 7));
    final invitationUuid = _uuid.v4();
    final code = _uuid.v4();

    final inviterRecord = await _userDao.getById(inviter.id);
    if (inviterRecord == null || inviterRecord.remoteId == null) {
      throw GroupPushException('El anfitrión no tiene remoteId.');
    }

    final invitationId = await _groupDao.insertInvitation(
      GroupInvitationsCompanion.insert(
        uuid: invitationUuid,
        remoteId: Value(invitationUuid),
        groupId: group.id,
        groupUuid: group.uuid,
        inviterUserId: inviter.id,
        inviterRemoteId: Value(inviterRecord.remoteId!),
        role: Value(role),
        code: code,
        status: const Value('pending'),
        expiresAt: expiry,
        isDirty: const Value(false),
        isDeleted: const Value(false),
        syncedAt: Value(now),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    final invitation = (await _groupDao.findInvitationById(invitationId))!;

    await _post(
      path: '/rest/v1/group_invitations',
      body: {
        'id': invitation.uuid,
        'group_id': group.remoteId ?? group.uuid,
        'inviter_id': inviterRecord.remoteId,
        'role': role,
        'code': code,
        'status': 'pending',
        'expires_at': expiry.toIso8601String(),
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      accessToken: accessToken,
    );

    return invitation;
  }

  Future<void> cancelInvitation({
    required GroupInvitation invitation,
    String? accessToken,
  }) async {
    final now = DateTime.now();

    await _groupDao.updateInvitation(
      invitationId: invitation.id,
      entry: GroupInvitationsCompanion(
        status: const Value('cancelled'),
        respondedAt: Value(now),
        isDirty: const Value(false),
        syncedAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    await _patch(
      path: '/rest/v1/group_invitations?id=eq.${invitation.remoteId ?? invitation.uuid}',
      body: {
        'status': 'cancelled',
        'responded_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      },
      accessToken: accessToken,
    );
  }

  Future<GroupInvitation> respondInvitation({
    required GroupInvitation invitation,
    required Group group,
    required LocalUser user,
    required String newStatus,
    String? accessToken,
  }) async {
    final now = DateTime.now();

    return _db.transaction(() async {
      await _groupDao.updateInvitation(
        invitationId: invitation.id,
        entry: GroupInvitationsCompanion(
          status: Value(newStatus),
          acceptedUserId:
              newStatus == 'accepted' ? Value(user.id) : const Value.absent(),
          acceptedUserRemoteId:
              newStatus == 'accepted' && user.remoteId != null
                  ? Value(user.remoteId)
                  : const Value.absent(),
          respondedAt: Value(now),
          isDirty: const Value(false),
          syncedAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      if (newStatus == 'accepted') {
        await addMember(
          group: group,
          user: user,
          role: invitation.role,
          accessToken: accessToken,
        );
      }

      await _patch(
        path:
            '/rest/v1/group_invitations?id=eq.${invitation.remoteId ?? invitation.uuid}',
        body: {
          'status': newStatus,
          'accepted_user_id': newStatus == 'accepted' ? user.remoteId : null,
          'responded_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        },
        accessToken: accessToken,
      );

      return (await _groupDao.findInvitationById(invitation.id))!;
    });
  }

  Future<GroupInvitation> acceptInvitationByCode({
    required String code,
    required LocalUser user,
    String? accessToken,
  }) async {
    final invitation = await _groupDao.findInvitationByCode(code);
    if (invitation == null) {
      throw GroupPushException('Código de invitación no válido.');
    }

    final now = DateTime.now();
    if (invitation.expiresAt.isBefore(now)) {
      await _groupDao.updateInvitation(
        invitationId: invitation.id,
        entry: GroupInvitationsCompanion(
          status: const Value('expired'),
          respondedAt: Value(now),
          isDirty: const Value(false),
          syncedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
      throw GroupPushException('La invitación ha expirado.');
    }

    final group = await _groupDao.findGroupById(invitation.groupId);
    if (group == null) {
      throw GroupPushException('El grupo ya no está disponible.');
    }

    return respondInvitation(
      invitation: invitation,
      group: group,
      user: user,
      newStatus: 'accepted',
      accessToken: accessToken,
    );
  }

  Future<void> _post({
    required String path,
    required Map<String, dynamic> body,
    String? accessToken,
  }) async {
    final uri = await _buildUri(path);
    final response = await _client.post(
      uri,
      headers: await _headers(accessToken: accessToken),
      body: jsonEncode(body),
    );

    if (response.statusCode >= 300) {
      throw GroupPushException(
        'Error ${response.statusCode}: ${response.body}',
        response.statusCode,
      );
    }
  }

  Future<void> _patch({
    required String path,
    required Map<String, dynamic> body,
    String? accessToken,
  }) async {
    final uri = await _buildUri(path);
    final response = await _client.patch(
      uri,
      headers: await _headers(accessToken: accessToken),
      body: jsonEncode(body),
    );

    if (response.statusCode >= 300) {
      throw GroupPushException(
        'Error ${response.statusCode}: ${response.body}',
        response.statusCode,
      );
    }
  }

  Future<void> _delete({
    required String path,
    String? accessToken,
  }) async {
    final uri = await _buildUri(path);
    final response = await _client.delete(
      uri,
      headers: await _headers(accessToken: accessToken),
    );

    if (response.statusCode >= 300) {
      throw GroupPushException(
        'Error ${response.statusCode}: ${response.body}',
        response.statusCode,
      );
    }
  }
}
