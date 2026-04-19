import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/workshop/presentation/workshop_providers.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_enchant_sections.dart';

class WorkshopEnchantSheet extends ConsumerStatefulWidget {
  const WorkshopEnchantSheet({super.key});

  @override
  ConsumerState<WorkshopEnchantSheet> createState() =>
      _WorkshopEnchantSheetState();
}

class _WorkshopEnchantSheetState extends ConsumerState<WorkshopEnchantSheet> {
  String? _selectedPotionStackKey;
  String? _selectedEquipmentId;

  Future<void> _submitEnchant(
    BuildContext sheetContext,
    EnchantPreviewView preview,
  ) async {
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

    final WorkshopEnchantSubmitResult result = ref
        .read(workshopEnchantControllerProvider)
        .enchantEquipment(_selectedEquipmentId!, _selectedPotionStackKey!);
    if (!mounted || !sheetContext.mounted) {
      return;
    }
    if (result == WorkshopEnchantSubmitResult.success) {
      Navigator.of(sheetContext).pop();
      return;
    }
    final String message = result == WorkshopEnchantSubmitResult.queueFull
        ? '작업실 큐가 가득 찼습니다'
        : '인챈트 등록에 실패했습니다';
    ScaffoldMessenger.of(
      sheetContext,
    ).showSnackBar(SnackBar(content: Text(message)));
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
      enchantPreviewProvider((
        potionStackKey: _selectedPotionStackKey,
        equipmentId: _selectedEquipmentId,
      )),
    );

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.72,
      child: ScaffoldMessenger(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Builder(
            builder: (BuildContext sheetContext) {
              return SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        '장비 인챈트',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      WorkshopEnchantPotionSelector(
                        potions: potions,
                        selectedPotionStackKey: _selectedPotionStackKey,
                        onChanged: (String? value) {
                          setState(() => _selectedPotionStackKey = value);
                        },
                      ),
                      const Divider(),
                      WorkshopEnchantEquipmentSelector(
                        equipments: equipments,
                        selectedEquipmentId: _selectedEquipmentId,
                        onChanged: (String? value) {
                          setState(() => _selectedEquipmentId = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      WorkshopEnchantPreviewSection(preview: preview),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: preview == null
                              ? null
                              : () => _submitEnchant(sheetContext, preview),
                          child: Text(
                            preview?.replaceRequired == true
                                ? '인챈트 교체 등록'
                                : '인챈트 등록',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
