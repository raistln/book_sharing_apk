import 'package:flutter/material.dart';

enum CoachMarkId {
  discoverShareBook,
  discoverFilterChips,
  bookDetailRequestLoan,
  groupManageInvitations,
}

enum CoachMarkSequence {
  discover,
  detail,
}

enum CoachMarkContentPosition {
  auto,
  above,
  below,
}

extension CoachMarkIdStorage on CoachMarkId {
  String get storageKey => switch (this) {
        CoachMarkId.discoverShareBook => 'discover_share',
        CoachMarkId.discoverFilterChips => 'discover_filters',
        CoachMarkId.bookDetailRequestLoan => 'detail_request',
        CoachMarkId.groupManageInvitations => 'groups_manage_invites',
      };
}

class CoachMarkConfig {
  const CoachMarkConfig({
    required this.id,
    required this.title,
    required this.description,
    this.contentPosition = CoachMarkContentPosition.auto,
    this.cornerRadius = 16,
    this.highlightPadding = const EdgeInsets.all(8),
    this.barrierDismissible = false,
    this.primaryActionLabel,
    this.secondaryActionLabel,
  });

  final CoachMarkId id;
  final String title;
  final String description;
  final CoachMarkContentPosition contentPosition;
  final double cornerRadius;
  final EdgeInsets highlightPadding;
  final bool barrierDismissible;
  final String? primaryActionLabel;
  final String? secondaryActionLabel;

  CoachMarkConfig copyWith({
    String? title,
    String? description,
    CoachMarkContentPosition? contentPosition,
    double? cornerRadius,
    EdgeInsets? highlightPadding,
    bool? barrierDismissible,
    String? primaryActionLabel,
    String? secondaryActionLabel,
  }) {
    return CoachMarkConfig(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      contentPosition: contentPosition ?? this.contentPosition,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      highlightPadding: highlightPadding ?? this.highlightPadding,
      barrierDismissible: barrierDismissible ?? this.barrierDismissible,
      primaryActionLabel: primaryActionLabel ?? this.primaryActionLabel,
      secondaryActionLabel: secondaryActionLabel ?? this.secondaryActionLabel,
    );
  }
}

typedef CoachMarkRectResolver = Rect? Function();

typedef CoachMarkEnabledResolver = bool Function();

class CoachMarkTargetRegistration {
  const CoachMarkTargetRegistration({
    required this.resolver,
    required this.config,
    this.isEnabled,
  });

  final CoachMarkRectResolver resolver;
  final CoachMarkConfig config;
  final CoachMarkEnabledResolver? isEnabled;

  bool get enabled => isEnabled?.call() ?? true;
}

class CoachMarkDisplay {
  const CoachMarkDisplay({
    required this.id,
    required this.config,
    required this.targetRect,
  });

  final CoachMarkId id;
  final CoachMarkConfig config;
  final Rect targetRect;
}

class CoachMarkState {
  const CoachMarkState({
    this.active,
    this.queue = const [],
    this.isVisible = false,
    this.sequence,
    this.isProcessing = false,
  });

  final CoachMarkDisplay? active;
  final List<CoachMarkId> queue;
  final bool isVisible;
  final CoachMarkSequence? sequence;
  final bool isProcessing;

  CoachMarkState copyWith({
    CoachMarkDisplay? active,
    ValueGetter<CoachMarkDisplay?>? activeSetter,
    List<CoachMarkId>? queue,
    bool? isVisible,
    CoachMarkSequence? sequence,
    ValueGetter<CoachMarkSequence?>? sequenceSetter,
    bool? isProcessing,
  }) {
    return CoachMarkState(
      active: activeSetter != null ? activeSetter() : active ?? this.active,
      queue: queue ?? this.queue,
      isVisible: isVisible ?? this.isVisible,
      sequence:
          sequenceSetter != null ? sequenceSetter() : sequence ?? this.sequence,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

const Map<CoachMarkSequence, List<CoachMarkId>> coachMarkSequences = {
  CoachMarkSequence.discover: [
    CoachMarkId.discoverShareBook,
    CoachMarkId.discoverFilterChips,
  ],
  CoachMarkSequence.detail: [
    CoachMarkId.bookDetailRequestLoan,
    CoachMarkId.groupManageInvitations,
  ],
};

const Map<CoachMarkId, CoachMarkConfig> defaultCoachMarkConfigs = {
  CoachMarkId.discoverShareBook: CoachMarkConfig(
    id: CoachMarkId.discoverShareBook,
    title: 'Comparte tus libros',
    description:
        'Publica ejemplares para que tu grupo pueda solicitarlos rápidamente.',
    primaryActionLabel: 'Siguiente',
  ),
  CoachMarkId.discoverFilterChips: CoachMarkConfig(
    id: CoachMarkId.discoverFilterChips,
    title: 'Filtra resultados',
    description:
        'Usa estos filtros para ver libros de grupos o propietarios concretos.',
    primaryActionLabel: 'Siguiente',
  ),
  CoachMarkId.bookDetailRequestLoan: CoachMarkConfig(
    id: CoachMarkId.bookDetailRequestLoan,
    title: 'Solicita un préstamo',
    description:
        'Desde aquí puedes pedir prestar el libro y coordinar la entrega.',
    primaryActionLabel: 'Siguiente',
  ),
  CoachMarkId.groupManageInvitations: CoachMarkConfig(
    id: CoachMarkId.groupManageInvitations,
    title: 'Gestiona invitaciones',
    description:
        'Invita a nuevas personas o revisa solicitudes pendientes de tu grupo.',
    primaryActionLabel: 'Listo',
  ),
};
