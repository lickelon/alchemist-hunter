import 'package:alchemist_hunter/features/characters/presentation/character_providers.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/presentation/widgets/character_list.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CharactersScreen extends ConsumerWidget {
  const CharactersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CharacterListItemView> mercenaries = ref.watch(
      mercenaryListItemViewsProvider,
    );
    final List<CharacterListItemView> homunculi = ref.watch(
      homunculusListItemViewsProvider,
    );
    final CharacterController controller = ref.read(
      characterControllerProvider,
    );

    return DefaultTabController(
      length: 2,
      child: Column(
        children: <Widget>[
          const TabBar(
            tabs: <Widget>[
              Tab(text: 'Mercenary'),
              Tab(text: 'Homunculus'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: <Widget>[
                CharacterList(
                  characters: mercenaries,
                  onRankUp: (String id) =>
                      controller.rankUp(CharacterType.mercenary, id),
                  onTierUp: (String id) =>
                      controller.tierUp(CharacterType.mercenary, id),
                  onEquip: (String characterId, String equipmentId) =>
                      controller.equip(
                        CharacterType.mercenary,
                        characterId,
                        equipmentId,
                      ),
                  onUnequip: (String characterId, EquipmentSlot slot) =>
                      controller.unequip(
                        CharacterType.mercenary,
                        characterId,
                        slot,
                      ),
                ),
                CharacterList(
                  characters: homunculi,
                  onRankUp: (String id) =>
                      controller.rankUp(CharacterType.homunculus, id),
                  onTierUp: (String id) =>
                      controller.tierUp(CharacterType.homunculus, id),
                  onEquip: (String characterId, String equipmentId) =>
                      controller.equip(
                        CharacterType.homunculus,
                        characterId,
                        equipmentId,
                      ),
                  onUnequip: (String characterId, EquipmentSlot slot) =>
                      controller.unequip(
                        CharacterType.homunculus,
                        characterId,
                        slot,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
