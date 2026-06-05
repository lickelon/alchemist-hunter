import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';

String workshopSupportHomunculusDisplayName(CharacterProgress character) {
  return '${_homunculusTierName(character)} ${character.name}';
}

String workshopSupportHomunculusRoleLabel(
  CharacterProgress character,
  BattleCatalogRepository battleCatalogRepository,
) {
  final BattleCombatJobDefinition job = battleCatalogRepository
      .combatJobDefinition(character.resolvedCombatJobId);
  return switch (job.discipline) {
    CombatDiscipline.warrior => '전사',
    CombatDiscipline.mage => '마법사',
    CombatDiscipline.rogue => '도적',
    CombatDiscipline.archer => '궁수',
  };
}

String _homunculusTierName(CharacterProgress character) {
  return switch (character.homunculusTier ?? HomunculusTier.nigredo) {
    HomunculusTier.nigredo => 'Nigredo',
    HomunculusTier.albedo => 'Albedo',
    HomunculusTier.citrinitas => 'Citrinitas',
    HomunculusTier.rubedo => 'Rubedo',
  };
}
