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
    var invitation = await _groupDao.findInvitationByCode(code);
    invitation ??= await _fetchAndCacheInvitationByCode(
      code,
      accessToken: accessToken,
    );

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

  Future<GroupInvitation?> _fetchAndCacheInvitationByCode(
    String code, {
    String? accessToken,
  }) async {
    DateTime? parseDateTime(dynamic value) {
      if (value is String && value.isNotEmpty) {
        return DateTime.tryParse(value);
      }
      return null;
    }

    bool parseBool(dynamic value) {
      if (value is bool) {
        return value;
      }
      if (value is num) {
        return value != 0;
      }
      if (value is String) {
        final normalized = value.toLowerCase();
        return normalized == 'true' ||
            normalized == 't' ||
            normalized == '1';
      }
      return false;
    }

    final uri = await _buildUri(
      '/rest/v1/group_invitations',
      {
        'code': 'eq.$code',
        'limit': '1',
        'select':
            'id,group_id,inviter_id,accepted_user_id,role,code,status,expires_at,responded_at,created_at,updated_at,'
            'group:groups(id,name,description,owner_id,created_at,updated_at),'
            'inviter:local_users!group_invitations_inviter_id_fkey(id,username,is_deleted,created_at,updated_at)',
      },
    );

    final response = await _client.get(
      uri,
      headers: await _headers(accessToken: accessToken),
    );

    if (response.statusCode >= 300) {
      throw GroupPushException(
        'Error ${response.statusCode}: ${response.body}',
        response.statusCode,
      );
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! List) {
      return null;
    }

    Map<String, dynamic>? record;
    for (final item in decoded) {
      if (item is Map<String, dynamic>) {
        record = item;
        break;
      }
    }

    if (record == null) {
      return null;
    }

    final remoteId = record['id'] as String?;
    final groupRemoteId = record['group_id'] as String?;
    final inviterRemoteId = record['inviter_id'] as String?;
    final status = (record['status'] as String?) ?? 'pending';
    final role = (record['role'] as String?) ?? 'member';
    final acceptedRemoteId = record['accepted_user_id'] as String?;
    final expiresAt = parseDateTime(record['expires_at']);
    final respondedAt = parseDateTime(record['responded_at']);
    final createdAt = parseDateTime(record['created_at']);
    final updatedAt = parseDateTime(record['updated_at']);

    if (remoteId == null ||
        groupRemoteId == null ||
        inviterRemoteId == null ||
        expiresAt == null) {
      return null;
    }

    final groupJson = record['group'] as Map<String, dynamic>?;
    final inviterJson = record['inviter'] as Map<String, dynamic>?;

    if (groupJson == null || inviterJson == null) {
      return null;
    }

    final groupName = groupJson['name'] as String?;
    if (groupName == null || groupName.isEmpty) {
      return null;
    }

    final groupDescription = groupJson['description'] as String?;
    final groupOwnerRemoteId = groupJson['owner_id'] as String?;
    final groupCreatedAt = parseDateTime(groupJson['created_at']);
    final groupUpdatedAt = parseDateTime(groupJson['updated_at']);

    final inviterUsername = inviterJson['username'] as String?;
    if (inviterUsername == null || inviterUsername.isEmpty) {
      return null;
    }

    final inviterIsDeleted = parseBool(inviterJson['is_deleted']);
    final inviterCreatedAt = parseDateTime(inviterJson['created_at']);
    final inviterUpdatedAt = parseDateTime(inviterJson['updated_at']);

    final now = DateTime.now();

    final invitation = await _db.transaction(() async {
      var inviter = await _userDao.findByRemoteId(inviterRemoteId);
      if (inviter == null) {
        final userId = await _userDao.insertUser(
          LocalUsersCompanion.insert(
            uuid: inviterRemoteId,
            username: inviterUsername,
            remoteId: Value(inviterRemoteId),
            isDeleted: Value(inviterIsDeleted),
            isDirty: const Value(false),
            syncedAt: Value(now),
            createdAt: Value(inviterCreatedAt ?? now),
            updatedAt: Value(inviterUpdatedAt ?? inviterCreatedAt ?? now),
          ),
        );
        inviter = (await _userDao.getById(userId))!;
      } else if (!inviter.isDirty) {
        await _userDao.updateUserFields(
          userId: inviter.id,
          entry: LocalUsersCompanion(
            username: Value(inviterUsername),
            remoteId: Value(inviterRemoteId),
            isDeleted: Value(inviterIsDeleted),
            isDirty: const Value(false),
            syncedAt: Value(now),
            updatedAt: Value(inviterUpdatedAt ?? inviter.updatedAt),
          ),
        );
        inviter = (await _userDao.getById(inviter.id))!;
      }

      int? ownerUserId;
      if (groupOwnerRemoteId != null) {
        final owner = await _userDao.findByRemoteId(groupOwnerRemoteId);
        ownerUserId = owner?.id;
      }

      final ownerUserIdValue = ownerUserId != null
          ? Value(ownerUserId)
          : const Value<int?>.absent();
      final ownerRemoteValue = groupOwnerRemoteId != null
          ? Value(groupOwnerRemoteId)
          : const Value<String?>.absent();

      var group = await _groupDao.findGroupByRemoteId(groupRemoteId);
      if (group == null) {
        final groupId = await _groupDao.insertGroup(
          GroupsCompanion.insert(
            uuid: groupRemoteId,
            remoteId: Value(groupRemoteId),
            name: groupName,
            description: groupDescription != null
                ? Value(groupDescription)
                : const Value.absent(),
            ownerUserId: ownerUserIdValue,
            ownerRemoteId: ownerRemoteValue,
            isDirty: const Value(false),
            isDeleted: const Value(false),
            syncedAt: Value(now),
            createdAt: Value(groupCreatedAt ?? now),
            updatedAt: Value(groupUpdatedAt ?? groupCreatedAt ?? now),
          ),
        );
        group = (await _groupDao.findGroupById(groupId))!;
      } else if (!group.isDirty) {
        await _groupDao.updateGroupFields(
          groupId: group.id,
          entry: GroupsCompanion(
            name: Value(groupName),
            description: groupDescription != null
                ? Value(groupDescription)
                : const Value.absent(),
            ownerUserId: ownerUserIdValue,
            ownerRemoteId: ownerRemoteValue,
            isDeleted: const Value(false),
            isDirty: const Value(false),
            syncedAt: Value(now),
            updatedAt: Value(groupUpdatedAt ?? group.updatedAt),
          ),
        );
        group = (await _groupDao.findGroupById(group.id))!;
      }

      int? acceptedUserId;
      if (acceptedRemoteId != null) {
        final acceptedUser = await _userDao.findByRemoteId(acceptedRemoteId);
        acceptedUserId = acceptedUser?.id;
      }

      final acceptedUserIdValue = acceptedUserId != null
          ? Value(acceptedUserId)
          : const Value<int?>.absent();
      final acceptedUserRemoteValue = acceptedRemoteId != null
          ? Value(acceptedRemoteId)
          : const Value<String?>.absent();
      final respondedAtValue = respondedAt != null
          ? Value(respondedAt)
          : const Value<DateTime?>.absent();

      final invitationUpdate = GroupInvitationsCompanion(
        uuid: Value(remoteId),
        remoteId: Value(remoteId),
        groupId: Value(group.id),
        groupUuid: Value(group.uuid),
        inviterUserId: Value(inviter.id),
        inviterRemoteId: Value(inviterRemoteId),
        acceptedUserId: acceptedUserIdValue,
        acceptedUserRemoteId: acceptedUserRemoteValue,
        role: Value(role),
        code: Value(code),
        status: Value(status),
        expiresAt: Value(expiresAt),
        respondedAt: respondedAtValue,
        isDirty: const Value(false),
        isDeleted: const Value(false),
        syncedAt: Value(now),
        createdAt: Value(createdAt ?? now),
        updatedAt: Value(updatedAt ?? now),
      );

      final existingInvitation =
          await _groupDao.findInvitationByRemoteId(remoteId) ??
              await _groupDao.findInvitationByCode(code);

      if (existingInvitation != null) {
        await _groupDao.updateInvitation(
          invitationId: existingInvitation.id,
          entry: invitationUpdate,
        );
        return (await _groupDao.findInvitationById(existingInvitation.id))!;
      }

      final invitationId = await _groupDao.insertInvitation(
        GroupInvitationsCompanion.insert(
          uuid: remoteId,
          remoteId: Value(remoteId),
          groupId: group.id,
          groupUuid: group.uuid,
          inviterUserId: inviter.id,
          inviterRemoteId: Value(inviterRemoteId),
          acceptedUserId: acceptedUserIdValue,
          acceptedUserRemoteId: acceptedUserRemoteValue,
          role: Value(role),
          code: code,
          status: Value(status),
          expiresAt: expiresAt,
          respondedAt: respondedAtValue,
          isDirty: const Value(false),
          isDeleted: const Value(false),
          syncedAt: Value(now),
          createdAt: Value(createdAt ?? now),
          updatedAt: Value(updatedAt ?? createdAt ?? now),
        ),
      );
      return (await _groupDao.findInvitationById(invitationId))!;
    });

    if (invitation.status != 'pending') {
      return null;
    }

    return invitation;
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
