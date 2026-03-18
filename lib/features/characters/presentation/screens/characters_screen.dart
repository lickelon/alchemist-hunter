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
    final List<CharacterListItemView> characters = ref.watch(
      allCharacterListItemViewsProvider,
    );
    final CharacterController controller = ref.read(
      characterControllerProvider,
    );

    return CharacterList(
      characters: characters,
      onRankUp: (String id) => controller.rankUp(_typeOf(characters, id), id),
      onTierUp: (String id) => controller.tierUp(_typeOf(characters, id), id),
      onEquip: (String characterId, String equipmentId) => controller.equip(
        _typeOf(characters, characterId),
        characterId,
        equipmentId,
      ),
      onUnequip: (String characterId, EquipmentSlot slot) => controller.unequip(
        _typeOf(characters, characterId),
        characterId,
        slot,
      ),
    );
  }
}

CharacterType _typeOf(List<CharacterListItemView> characters, String id) {
  for (final CharacterListItemView item in characters) {
    if (item.character.id == id) {
      return item.character.type;
    }
  }
  return CharacterType.mercenary;
}
