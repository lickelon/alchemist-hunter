import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/features/battle/combat/domain/services/battle_combat_stat_service.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/presentation/viewmodels/character_equipment_selectors.dart';
import 'package:alchemist_hunter/features/characters/presentation/viewmodels/character_list_item_builder.dart';
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
        statService: BattleCombatStatService(
          battleCatalogRepository: ref.watch(battleCatalogRepositoryProvider),
        ),
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
        statService: BattleCombatStatService(
          battleCatalogRepository: ref.watch(battleCatalogRepositoryProvider),
        ),
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
  required BattleCombatStatService statService,
  required Map<String, int> inventory,
  required List<EquipmentInstance> equipmentInventory,
  required Map<String, List<String>> stageAssignments,
  required Map<String, String> workshopSupportAssignments,
}) {
  return characters.map((CharacterProgress character) {
    return buildCharacterListItemView(
      character: character,
      statService: statService,
      inventory: inventory,
      equipmentSlots: buildCharacterEquipmentSlots(
        character: character,
        equipmentInventory: equipmentInventory,
      ),
      stageAssignments: stageAssignments,
      workshopSupportAssignments: workshopSupportAssignments,
    );
  }).toList();
}
