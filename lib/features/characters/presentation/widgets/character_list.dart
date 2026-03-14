import 'package:alchemist_hunter/features/characters/presentation/character_providers.dart';
import 'package:alchemist_hunter/features/characters/presentation/widgets/character_card.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter/material.dart';

class CharacterList extends StatelessWidget {
  const CharacterList({
    super.key,
    required this.characters,
    required this.onRankUp,
    required this.onTierUp,
    required this.onEquip,
    required this.onUnequip,
  });

  final List<CharacterListItemView> characters;
  final ValueChanged<String> onRankUp;
  final ValueChanged<String> onTierUp;
  final void Function(String characterId, String equipmentId) onEquip;
  final void Function(String characterId, EquipmentSlot slot) onUnequip;

  @override
  Widget build(BuildContext context) {
    if (characters.isEmpty) {
      return const Center(child: Text('No characters'));
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: characters.map((CharacterListItemView item) {
        return CharacterCard(
          item: item,
          onRankUp: onRankUp,
          onTierUp: onTierUp,
          onEquip: onEquip,
          onUnequip: onUnequip,
        );
      }).toList(),
    );
  }
}
