import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/presentation/character_providers.dart';
import 'package:alchemist_hunter/features/characters/presentation/widgets/character_detail_sheet.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter/material.dart';

class CharacterCard extends StatelessWidget {
  const CharacterCard({
    super.key,
    required this.item,
    required this.onRankUp,
    required this.onTierUp,
    required this.onEquip,
    required this.onUnequip,
  });

  final CharacterListItemView item;
  final ValueChanged<String> onRankUp;
  final ValueChanged<String> onTierUp;
  final void Function(String characterId, String equipmentId) onEquip;
  final void Function(String characterId, EquipmentSlot slot) onUnequip;

  @override
  Widget build(BuildContext context) {
    final CharacterProgress character = item.character;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetailSheet(context, character),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      character.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    item.typeLabel,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(item.assignmentLabel),
              const SizedBox(height: 4),
              Text(item.growthLabel),
              const SizedBox(height: 8),
              Text(
                item.summaryLine,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailSheet(BuildContext context, CharacterProgress character) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return CharacterDetailSheet(
          type: character.type,
          characterId: character.id,
          onRankUp: onRankUp,
          onTierUp: onTierUp,
          onEquip: onEquip,
          onUnequip: onUnequip,
        );
      },
    );
  }
}
