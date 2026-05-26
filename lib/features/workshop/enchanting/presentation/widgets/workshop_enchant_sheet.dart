import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/workshop/enchanting/presentation/viewmodels/enchant_controller.dart';
import 'package:alchemist_hunter/features/workshop/enchanting/presentation/viewmodels/enchant_equipment_selectors.dart';
import 'package:alchemist_hunter/features/workshop/enchanting/presentation/viewmodels/enchant_potion_selectors.dart';
import 'package:alchemist_hunter/features/workshop/enchanting/presentation/viewmodels/enchant_preview_selector.dart';
import 'package:alchemist_hunter/features/workshop/enchanting/presentation/widgets/workshop_enchant_sections.dart';

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
          return AppDialogLayout(
            title: '기존 인챈트 교체',
            body: Text(
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
    if (!mounted) {
      return;
    }
    if (result == WorkshopEnchantSubmitResult.success) {
      Navigator.of(context).pop();
      return;
    }
    final String message = result == WorkshopEnchantSubmitResult.queueFull
        ? '작업실 큐가 가득 찼습니다'
        : '인챈트 등록에 실패했습니다';
    AppToast.show(context, message);
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

    return AppSheetLayout(
      title: '장비 인챈트',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
            const SizedBox(height: AppSpacing.lg),
            WorkshopEnchantPreviewSection(preview: preview),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: preview == null
                    ? null
                    : () => _submitEnchant(preview),
                child: Text(
                  preview?.replaceRequired == true ? '인챈트 교체 등록' : '인챈트 등록',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
