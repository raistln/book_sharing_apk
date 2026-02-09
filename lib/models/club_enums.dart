enum ClubFrequency {
  semanal('semanal', 'Semanal', 7),
  quincenal('quincenal', 'Quincenal', 15),
  mensual('mensual', 'Mensual', 30),
  personalizada('personalizada', 'Personalizada', null);

  const ClubFrequency(this.value, this.label, this.defaultDays);

  final String value;
  final String label;
  final int? defaultDays;

  static ClubFrequency fromString(String value) {
    return ClubFrequency.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ClubFrequency.mensual,
    );
  }
}

enum ClubVisibility {
  privado('privado', 'Privado'),
  publico('publico', 'Público');

  const ClubVisibility(this.value, this.label);

  final String value;
  final String label;

  static ClubVisibility fromString(String value) {
    return ClubVisibility.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ClubVisibility.privado,
    );
  }
}

enum ClubMemberRole {
  dueno('dueño', 'Dueño'),
  admin('admin', 'Administrador'),
  miembro('miembro', 'Miembro');

  const ClubMemberRole(this.value, this.label);

  final String value;
  final String label;

  static ClubMemberRole fromString(String value) {
    return ClubMemberRole.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ClubMemberRole.miembro,
    );
  }

  bool get isOwner => this == ClubMemberRole.dueno;
  bool get isAdmin =>
      this == ClubMemberRole.admin || this == ClubMemberRole.dueno;
}

enum ClubMemberStatus {
  activo('activo', 'Activo'),
  inactivo('inactivo', 'Inactivo');

  const ClubMemberStatus(this.value, this.label);

  final String value;
  final String label;

  static ClubMemberStatus fromString(String value) {
    return ClubMemberStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ClubMemberStatus.activo,
    );
  }
}

enum ClubBookStatus {
  propuesto('propuesto', 'Propuesto'),
  votando('votando', 'En votación'),
  proximo('proximo', 'Próximo'),
  activo('activo', 'Activo'),
  completado('completado', 'Completado');

  const ClubBookStatus(this.value, this.label);

  final String value;
  final String label;

  static ClubBookStatus fromString(String value) {
    return ClubBookStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ClubBookStatus.propuesto,
    );
  }
}

enum SectionMode {
  automatico('automatico', 'Automático'),
  manual('manual', 'Manual');

  const SectionMode(this.value, this.label);

  final String value;
  final String label;

  static SectionMode fromString(String value) {
    return SectionMode.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SectionMode.automatico,
    );
  }
}

enum ReadingProgressStatus {
  noEmpezado('no_empezado', 'No empezado'),
  alDia('al_dia', 'Al día'),
  atrasado('atrasado', 'Atrasado'),
  terminado('terminado', 'Terminado');

  const ReadingProgressStatus(this.value, this.label);

  final String value;
  final String label;

  static ReadingProgressStatus fromString(String value) {
    return ReadingProgressStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ReadingProgressStatus.noEmpezado,
    );
  }
}

enum ProposalStatus {
  abierta('abierta', 'Abierta'),
  cerrada('cerrada', 'Cerrada'),
  ganadora('ganadora', 'Ganadora'),
  descartada('descartada', 'Descartada');

  const ProposalStatus(this.value, this.label);

  final String value;
  final String label;

  static ProposalStatus fromString(String value) {
    return ProposalStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ProposalStatus.abierta,
    );
  }
}

enum ModerationAction {
  borrarComentario('borrar_comentario', 'Borrar comentario'),
  expulsarMiembro('expulsar_miembro', 'Expulsar miembro'),
  cerrarVotacion('cerrar_votacion', 'Cerrar votación'),
  ocultarComentario('ocultar_comentario', 'Ocultar comentario');

  const ModerationAction(this.value, this.label);

  final String value;
  final String label;

  static ModerationAction fromString(String value) {
    return ModerationAction.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ModerationAction.borrarComentario,
    );
  }
}
