import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/presentation/viewmodels/character_assignment_selectors.dart';
import 'package:alchemist_hunter/features/characters/presentation/viewmodels/character_detail_selectors.dart';
import 'package:alchemist_hunter/features/characters/presentation/viewmodels/character_equipment_selectors.dart';
import 'package:alchemist_hunter/features/characters/presentation/viewmodels/character_view_models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<List<CharacterProgress>> mercenaryListProvider =
    Provider<List<CharacterProgress>>((Ref ref) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.characters.mercenaries,
        ),
      );
    });

final Provider<List<CharacterProgress>> homunculusListProvider =
    Provider<List<CharacterProgress>>((Ref ref) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.characters.homunculi,
        ),
      );
    });

final Provider<List<CharacterListItemView>> mercenaryListItemViewsProvider =
    Provider<List<CharacterListItemView>>((Ref ref) {
      return _buildCharacterViews(
        characters: ref.watch(mercenaryListProvider),
        inventory: ref.watch(
          sessionControllerProvider.select(
            (SessionState state) => state.player.materialInventory,
          ),
        ),
        equipmentInventory: ref.watch(
          sessionControllerProvider.select(
            (SessionState state) => state.town.equipmentInventory,
          ),
        ),
        stageAssignments: ref.watch(
          sessionControllerProvider.select(
            (SessionState state) => state.battle.stageAssignments,
          ),
        ),
        workshopSupportAssignments: ref.watch(
          sessionControllerProvider.select(
            (SessionState state) => state.workshop.supportAssignmentsByFunction,
          ),
        ),
      );
    });

final Provider<List<CharacterListItemView>> homunculusListItemViewsProvider =
    Provider<List<CharacterListItemView>>((Ref ref) {
      return _buildCharacterViews(
        characters: ref.watch(homunculusListProvider),
        inventory: ref.watch(
          sessionControllerProvider.select(
            (SessionState state) => state.player.materialInventory,
          ),
        ),
        equipmentInventory: ref.watch(
          sessionControllerProvider.select(
            (SessionState state) => state.town.equipmentInventory,
          ),
        ),
        stageAssignments: ref.watch(
          sessionControllerProvider.select(
            (SessionState state) => state.battle.stageAssignments,
          ),
        ),
        workshopSupportAssignments: ref.watch(
          sessionControllerProvider.select(
            (SessionState state) => state.workshop.supportAssignmentsByFunction,
          ),
        ),
      );
    });

final Provider<List<CharacterListItemView>> allCharacterListItemViewsProvider =
    Provider<List<CharacterListItemView>>((Ref ref) {
      return <CharacterListItemView>[
        ...ref.watch(mercenaryListItemViewsProvider),
        ...ref.watch(homunculusListItemViewsProvider),
      ];
    });

final ProviderFamily<CharacterListItemView?, String> mercenaryItemViewProvider =
    Provider.family<CharacterListItemView?, String>((Ref ref, String id) {
      for (final CharacterListItemView item in ref.watch(
        mercenaryListItemViewsProvider,
      )) {
        if (item.character.id == id) {
          return item;
        }
      }
      return null;
    });

final ProviderFamily<CharacterListItemView?, String>
homunculusItemViewProvider = Provider.family<CharacterListItemView?, String>((
  Ref ref,
  String id,
) {
  for (final CharacterListItemView item in ref.watch(
    homunculusListItemViewsProvider,
  )) {
    if (item.character.id == id) {
      return item;
    }
  }
  return null;
});

List<CharacterListItemView> _buildCharacterViews({
  required List<CharacterProgress> characters,
  required Map<String, int> inventory,
  required List<EquipmentInstance> equipmentInventory,
  required Map<String, List<String>> stageAssignments,
  required Map<String, String> workshopSupportAssignments,
}) {
  return characters.map((CharacterProgress character) {
    return CharacterListItemView(
      character: character,
      typeLabel: characterTypeLabel(character.type),
      summaryLine: characterSummaryLine(character),
      growthLabel:
          'Lv ${character.level} / Rank ${character.rank} / Tier ${character.tierIndex}',
      rankHint: characterRankHint(character),
      tierHint: characterTierHint(character, inventory),
      tierMaterialLabel: characterTierMaterialLabel(character, inventory),
      detailLines: characterDetailLines(character),
      assignmentLabel: characterAssignmentLabel(
        characterId: character.id,
        stageAssignments: stageAssignments,
        workshopSupportAssignments: workshopSupportAssignments,
      ),
      assignmentGuideLabel: characterAssignmentGuideLabel,
      equipmentSlots: buildCharacterEquipmentSlots(
        character: character,
        equipmentInventory: equipmentInventory,
      ),
    );
  }).toList();
}
