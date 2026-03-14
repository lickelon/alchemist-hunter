import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/workshop/presentation/workshop_providers.dart';

class WorkshopEnchantSheet extends ConsumerStatefulWidget {
  const WorkshopEnchantSheet({super.key});

  @override
  ConsumerState<WorkshopEnchantSheet> createState() =>
      _WorkshopEnchantSheetState();
}

class _WorkshopEnchantSheetState extends ConsumerState<WorkshopEnchantSheet> {
  String? _selectedPotionStackKey;
  String? _selectedEquipmentId;

  Future<void> _submitEnchant(EnchantPreviewView preview) async {
    if (preview.replaceRequired) {
      final bool? confirmed = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('기존 인챈트 교체'),
            content: Text(
              '${preview.equipmentName}\n'
              '현재 ${preview.currentEnchantLabel}\n'
              '변경 ${preview.nextEnchantLabel}\n'
              '${preview.currentStatLabel}\n'
              '${preview.nextStatLabel}\n'
              '${preview.deltaStatLabel}',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('교체'),
              ),
            ],
          );
        },
      );
      if (confirmed != true) {
        return;
      }
    }

    ref.read(workshopEnchantControllerProvider).enchantEquipment(
      _selectedEquipmentId!,
      _selectedPotionStackKey!,
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<EnchantPotionView> potions = ref.watch(
      enchantPotionViewsProvider,
    );
    final List<EnchantEquipmentView> equipments = ref.watch(
      enchantEquipmentViewsProvider,
    );
    final EnchantPreviewView? preview = ref.watch(
      enchantPreviewProvider(
        (
          potionStackKey: _selectedPotionStackKey,
          equipmentId: _selectedEquipmentId,
        ),
      ),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '장비 인챈트',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Text(
                '포션 선택',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: RadioGroup<String>(
                  groupValue: _selectedPotionStackKey,
                  onChanged: (String? value) {
                    setState(() => _selectedPotionStackKey = value);
                  },
                  child: potions.isEmpty
                      ? const Center(child: Text('인챈트에 사용할 포션이 없습니다'))
                      : ListView(
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
              const Divider(),
              const Text(
                '장비 선택',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: RadioGroup<String>(
                  groupValue: _selectedEquipmentId,
                  onChanged: (String? value) {
                    setState(() => _selectedEquipmentId = value);
                  },
                  child: equipments.isEmpty
                      ? const Center(child: Text('인챈트 가능한 장비가 없습니다'))
                      : ListView(
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
              const SizedBox(height: 12),
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
                            preview.equipmentName,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text('현재 ${preview.currentEnchantLabel}'),
                          Text('예상 ${preview.nextEnchantLabel}'),
                          const SizedBox(height: 6),
                          Text(preview.currentStatLabel),
                          Text(preview.nextStatLabel),
                          Text(preview.deltaStatLabel),
                          if (preview.replaceRequired) ...<Widget>[
                            const SizedBox(height: 6),
                            const Text('기존 인챈트가 교체됩니다'),
                          ],
                        ],
                      ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: preview == null ? null : () => _submitEnchant(preview),
                  child: Text(preview?.replaceRequired == true ? '인챈트 교체' : '인챈트 실행'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
