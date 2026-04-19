import 'package:alchemist_hunter/features/workshop/presentation/workshop_providers.dart';
import 'package:flutter/material.dart';

class WorkshopEnchantPotionSelector extends StatelessWidget {
  const WorkshopEnchantPotionSelector({
    super.key,
    required this.potions,
    required this.selectedPotionStackKey,
    required this.onChanged,
  });

  final List<EnchantPotionView> potions;
  final String? selectedPotionStackKey;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('포션 선택', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 96),
          child: RadioGroup<String>(
            groupValue: selectedPotionStackKey,
            onChanged: onChanged,
            child: potions.isEmpty
                ? const Center(child: Text('인챈트에 사용할 포션이 없습니다'))
                : ListView(
                    shrinkWrap: true,
                    children: potions.map((EnchantPotionView potion) {
                      return RadioListTile<String>(
                        value: potion.stackKey,
                        title: Text('${potion.name} x${potion.quantity}'),
                        subtitle: Text(
                          '품질 ${potion.qualityLabel} / ${potion.traitsLabel}',
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ),
      ],
    );
  }
}

class WorkshopEnchantEquipmentSelector extends StatelessWidget {
  const WorkshopEnchantEquipmentSelector({
    super.key,
    required this.equipments,
    required this.selectedEquipmentId,
    required this.onChanged,
  });

  final List<EnchantEquipmentView> equipments;
  final String? selectedEquipmentId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('장비 선택', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 120),
          child: RadioGroup<String>(
            groupValue: selectedEquipmentId,
            onChanged: onChanged,
            child: equipments.isEmpty
                ? const Center(child: Text('인챈트 가능한 장비가 없습니다'))
                : ListView(
                    shrinkWrap: true,
                    children: equipments.map((EnchantEquipmentView item) {
                      return RadioListTile<String>(
                        value: item.equipmentId,
                        title: Text(item.name),
                        subtitle: Text(
                          '${item.locationLabel} / ${item.slotLabel}\n${item.statLabel}\n${item.enchantLabel}',
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ),
      ],
    );
  }
}

class WorkshopEnchantPreviewSection extends StatelessWidget {
  const WorkshopEnchantPreviewSection({super.key, required this.preview});

  final EnchantPreviewView? preview;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '예상 결과',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: preview == null
              ? const Text('포션과 장비를 선택하면 인챈트 결과를 미리 볼 수 있습니다')
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      preview!.equipmentName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text('현재 ${preview!.currentEnchantLabel}'),
                    Text('예상 ${preview!.nextEnchantLabel}'),
                    const SizedBox(height: 6),
                    Text(preview!.currentStatLabel),
                    Text(preview!.nextStatLabel),
                    Text(preview!.deltaStatLabel),
                    if (preview!.replaceRequired) ...<Widget>[
                      const SizedBox(height: 6),
                      const Text('기존 인챈트가 교체됩니다'),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
