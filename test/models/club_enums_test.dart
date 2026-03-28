import 'package:book_sharing_app/models/club_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ClubFrequency', () {
    test('fromString returns correct frequency', () {
      expect(ClubFrequency.fromString('semanal'), ClubFrequency.semanal);
      expect(ClubFrequency.fromString('quincenal'), ClubFrequency.quincenal);
      expect(ClubFrequency.fromString('mensual'), ClubFrequency.mensual);
      expect(ClubFrequency.fromString('personalizada'), ClubFrequency.personalizada);
    });

    test('fromString returns mensual as fallback', () {
      expect(ClubFrequency.fromString('invalid'), ClubFrequency.mensual);
    });
  });

  group('ClubVisibility', () {
    test('fromString returns correct visibility', () {
      expect(ClubVisibility.fromString('privado'), ClubVisibility.privado);
      expect(ClubVisibility.fromString('publico'), ClubVisibility.publico);
    });

    test('fromString returns privado as fallback', () {
      expect(ClubVisibility.fromString('invalid'), ClubVisibility.privado);
    });
  });

  group('ClubMemberRole', () {
    test('fromString returns correct role', () {
      expect(ClubMemberRole.fromString('dueño'), ClubMemberRole.dueno);
      expect(ClubMemberRole.fromString('admin'), ClubMemberRole.admin);
      expect(ClubMemberRole.fromString('miembro'), ClubMemberRole.miembro);
    });

    test('fromString returns miembro as fallback', () {
      expect(ClubMemberRole.fromString('invalid'), ClubMemberRole.miembro);
    });

    test('isOwner returns true only for dueno', () {
      expect(ClubMemberRole.dueno.isOwner, true);
      expect(ClubMemberRole.admin.isOwner, false);
      expect(ClubMemberRole.miembro.isOwner, false);
    });

    test('isAdmin returns true for dueno and admin', () {
      expect(ClubMemberRole.dueno.isAdmin, true);
      expect(ClubMemberRole.admin.isAdmin, true);
      expect(ClubMemberRole.miembro.isAdmin, false);
    });
  });

  group('ClubMemberStatus', () {
    test('fromString returns correct status', () {
      expect(ClubMemberStatus.fromString('activo'), ClubMemberStatus.activo);
      expect(ClubMemberStatus.fromString('inactivo'), ClubMemberStatus.inactivo);
    });

    test('fromString returns activo as fallback', () {
      expect(ClubMemberStatus.fromString('invalid'), ClubMemberStatus.activo);
    });
  });

  group('ClubBookStatus', () {
    test('fromString returns correct status', () {
      expect(ClubBookStatus.fromString('propuesto'), ClubBookStatus.propuesto);
      expect(ClubBookStatus.fromString('votando'), ClubBookStatus.votando);
      expect(ClubBookStatus.fromString('proximo'), ClubBookStatus.proximo);
      expect(ClubBookStatus.fromString('activo'), ClubBookStatus.activo);
      expect(ClubBookStatus.fromString('completado'), ClubBookStatus.completado);
    });

    test('fromString returns propuesto as fallback', () {
      expect(ClubBookStatus.fromString('invalid'), ClubBookStatus.propuesto);
    });
  });

  group('SectionMode', () {
    test('fromString returns correct mode', () {
      expect(SectionMode.fromString('automatico'), SectionMode.automatico);
      expect(SectionMode.fromString('manual'), SectionMode.manual);
    });

    test('fromString returns automatico as fallback', () {
      expect(SectionMode.fromString('invalid'), SectionMode.automatico);
    });
  });

  group('ReadingProgressStatus', () {
    test('fromString returns correct status', () {
      expect(ReadingProgressStatus.fromString('no_empezado'), ReadingProgressStatus.noEmpezado);
      expect(ReadingProgressStatus.fromString('al_dia'), ReadingProgressStatus.alDia);
      expect(ReadingProgressStatus.fromString('atrasado'), ReadingProgressStatus.atrasado);
      expect(ReadingProgressStatus.fromString('terminado'), ReadingProgressStatus.terminado);
    });

    test('fromString returns noEmpezado as fallback', () {
      expect(ReadingProgressStatus.fromString('invalid'), ReadingProgressStatus.noEmpezado);
    });
  });

  group('ProposalStatus', () {
    test('fromString returns correct status', () {
      expect(ProposalStatus.fromString('abierta'), ProposalStatus.abierta);
      expect(ProposalStatus.fromString('cerrada'), ProposalStatus.cerrada);
      expect(ProposalStatus.fromString('ganadora'), ProposalStatus.ganadora);
      expect(ProposalStatus.fromString('descartada'), ProposalStatus.descartada);
    });

    test('fromString returns abierta as fallback', () {
      expect(ProposalStatus.fromString('invalid'), ProposalStatus.abierta);
    });
  });

  group('ModerationAction', () {
    test('fromString returns correct action', () {
      expect(ModerationAction.fromString('borrar_comentario'), ModerationAction.borrarComentario);
      expect(ModerationAction.fromString('expulsar_miembro'), ModerationAction.expulsarMiembro);
      expect(ModerationAction.fromString('cerrar_votacion'), ModerationAction.cerrarVotacion);
      expect(ModerationAction.fromString('ocultar_comentario'), ModerationAction.ocultarComentario);
    });

    test('fromString returns borrarComentario as fallback', () {
      expect(ModerationAction.fromString('invalid'), ModerationAction.borrarComentario);
    });
  });
}
