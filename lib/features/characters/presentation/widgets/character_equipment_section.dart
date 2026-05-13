import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/features/characters/presentation/viewmodels/character_view_models.dart';
import 'package:alchemist_hunter/features/characters/presentation/widgets/character_detail_section.dart';
import 'package:flutter/material.dart';

class CharacterEquipmentSection extends StatelessWidget {
  const CharacterEquipmentSection({
    super.key,
    required this.slots,
    required this.onManage,
  });

  final List<CharacterEquipmentSlotView> slots;
  final ValueChanged<CharacterEquipmentSlotView> onManage;

  @override
  Widget build(BuildContext context) {
    return CharacterDetailSection(
      title: '장비 관리',
      child: Column(
        children: slots
            .map((CharacterEquipmentSlotView slot) {
              final bool canManage =
                  slot.equippedItem != null || slot.availableItems.isNotEmpty;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${slot.slotLabel}: ${slot.currentLabel}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            slot.statLabel,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    FilledButton.tonal(
                      onPressed: canManage ? () => onManage(slot) : null,
                      child: Text(slot.equippedItem == null ? '장착' : '관리'),
                    ),
                  ],
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}
