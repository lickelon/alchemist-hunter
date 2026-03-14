import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/features/workshop/presentation/workshop_providers.dart';

class WorkshopEnchantCard extends StatelessWidget {
  const WorkshopEnchantCard({
    super.key,
    required this.potionStackCount,
    required this.equipmentCount,
  });

  final int potionStackCount;
  final int equipmentCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Enchant',
      description: '포션 $potionStackCount스택 / 장비 $equipmentCount개 인챈트 가능',
      icon: Icons.auto_fix_high_outlined,
      onTap: () => _showEnchantSheet(context),
    );
  }

  void _showEnchantSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const _WorkshopEnchantSheet();
      },
    );
  }
}

class _WorkshopEnchantSheet extends ConsumerStatefulWidget {
  const _WorkshopEnchantSheet();

  @override
  ConsumerState<_WorkshopEnchantSheet> createState() =>
      _WorkshopEnchantSheetState();
}

class _WorkshopEnchantSheetState extends ConsumerState<_WorkshopEnchantSheet> {
  String? _selectedPotionStackKey;
  String? _selectedEquipmentId;

  @override
  Widget build(BuildContext context) {
    final List<EnchantPotionView> potions = ref.watch(
      enchantPotionViewsProvider,
    );
    final List<EnchantEquipmentView> equipments = ref.watch(
      enchantEquipmentViewsProvider,
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
              Expanded(
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
              Expanded(
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
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      _selectedPotionStackKey != null &&
                          _selectedEquipmentId != null
                      ? () {
                          ref
                              .read(workshopEnchantControllerProvider)
                              .enchantEquipment(
                                _selectedEquipmentId!,
                                _selectedPotionStackKey!,
                              );
                          Navigator.of(context).pop();
                        }
                      : null,
                  child: const Text('인챈트 실행'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
