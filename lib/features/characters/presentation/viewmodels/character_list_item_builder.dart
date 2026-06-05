import 'package:alchemist_hunter/features/battle/combat/domain/services/battle_combat_stat_service.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/presentation/viewmodels/character_assignment_selectors.dart';
import 'package:alchemist_hunter/features/characters/presentation/viewmodels/character_combat_labels.dart';
import 'package:alchemist_hunter/features/characters/presentation/viewmodels/character_detail_selectors.dart';
import 'package:alchemist_hunter/features/characters/presentation/viewmodels/character_view_models.dart';

CharacterListItemView buildCharacterListItemView({
  required CharacterProgress character,
  required Map<String, int> inventory,
  required List<CharacterEquipmentSlotView> equipmentSlots,
  required Map<String, List<String>> stageAssignments,
  required Map<String, String> workshopSupportAssignments,
  required BattleCombatStatService statService,
}) {
  final heroProfile = statService.buildHeroProfile(character);
  final String combatDisciplineLabel = characterCombatDisciplineLabel(
    character.resolvedCombatJobId,
    statService: statService,
  );
  return CharacterListItemView(
    character: character,
    typeLabel: characterTypeLabel(character.type),
    growthLabel:
        '레벨 ${character.level}, 랭크 ${character.rank}, ${characterTierLabel(character)}',
    rankHint: characterRankHint(character),
    tierHint: characterTierHint(character, inventory),
    tierMaterialLabel: characterTierMaterialLabel(character, inventory),
    combatPowerLabel: characterCombatPowerLabel(
      power: heroProfile.power,
      combatDisciplineLabel: combatDisciplineLabel,
    ),
    combatStatPairs: characterCombatStatPairs(heroProfile.stats),
    combatEffectLines: characterCombatEffectLines(heroProfile),
    hasTierUpMaterial: characterHasTierUpMaterial(character, inventory),
    assignmentLabel: characterAssignmentLabel(
      characterId: character.id,
      stageAssignments: stageAssignments,
      workshopSupportAssignments: workshopSupportAssignments,
    ),
    assignmentGuideLabel: characterAssignmentGuideLabel,
    equipmentSlots: equipmentSlots,
  );
}
