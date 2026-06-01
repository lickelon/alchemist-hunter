import 'package:alchemist_hunter/common/themes/app_radius.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/themes/app_text_styles.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/presentation/viewmodels/character_view_models.dart';
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
    final ThemeData theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: () => _showDetailSheet(context, character),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      character.name,
                      style: AppTextStyles.of(context).subsectionTitle,
                    ),
                  ),
                  Text(
                    item.typeLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(item.assignmentLabel),
              const SizedBox(height: AppSpacing.sm),
              Text(item.growthLabel),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailSheet(BuildContext context, CharacterProgress character) {
    showAppBottomSheet<void>(
      context: context,
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
