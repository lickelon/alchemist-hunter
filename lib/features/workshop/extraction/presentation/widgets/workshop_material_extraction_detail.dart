import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/themes/app_dialog_heights.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/themes/app_text_styles.dart';
import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_toast.dart';
import 'package:alchemist_hunter/common/widgets/catalog_asset_icon.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/extraction_controller.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/extraction_detail_selector.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/workshop_display_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'workshop_extraction_profile_list.dart';

class WorkshopMaterialExtractionDetailDialog extends StatelessWidget {
  const WorkshopMaterialExtractionDetailDialog({
    super.key,
    required this.materialId,
  });

  final String materialId;

  @override
  Widget build(BuildContext context) {
    return _WorkshopMaterialExtractionDetailContent(materialId: materialId);
  }
}

class _WorkshopMaterialExtractionDetailContent extends ConsumerStatefulWidget {
  const _WorkshopMaterialExtractionDetailContent({required this.materialId});

  final String materialId;

  @override
  ConsumerState<_WorkshopMaterialExtractionDetailContent> createState() =>
      _WorkshopMaterialExtractionDetailContentState();
}

class _WorkshopMaterialExtractionDetailContentState
    extends ConsumerState<_WorkshopMaterialExtractionDetailContent> {
  final Set<String> _selectedTraits = <String>{};
  double _quantityValue = 1;

  @override
  Widget build(BuildContext context) {
    final MaterialExtractionDetailView? detail = ref.watch(
      materialExtractionDetailViewProvider(widget.materialId),
    );
    final WorkshopExtractionController controller = ref.read(
      workshopExtractionControllerProvider,
    );
    if (detail == null) {
      return const SizedBox.shrink();
    }
    final int maxQuantity = detail.ownedQuantity < 1 ? 1 : detail.ownedQuantity;
    final double sliderValue = _quantityValue
        .clamp(1.0, maxQuantity.toDouble())
        .toDouble();
    final int selectedQuantity = sliderValue
        .round()
        .clamp(1, maxQuantity)
        .toInt();
    final Widget header = Row(
      children: <Widget>[
        CatalogAssetIcon(
          assetPath: CatalogIconAssetPaths.material(detail.materialId),
        ),
        const SizedBox(width: AppSpacing.md),
        Text('보유 ${detail.ownedQuantity}개'),
      ],
    );

    Widget buildBody() {
      final TextStyle subsectionTitleStyle = AppTextStyles.of(
        context,
      ).subsectionTitle;
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('추출 수량', style: subsectionTitleStyle),
            const SizedBox(height: AppSpacing.md),
            _ExtractionQuantitySlider(
              selectedQuantity: selectedQuantity,
              value: sliderValue,
              maxQuantity: maxQuantity,
              onChanged: (double value) {
                setState(() {
                  _quantityValue = value;
                });
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('분석 결과', style: subsectionTitleStyle),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: detail.traits.map((ExtractionTraitOptionView trait) {
                final bool selected = _selectedTraits.contains(trait.id);
                return FilterChip(
                  avatar: CatalogAssetIcon(
                    assetPath: CatalogIconAssetPaths.element(trait.id),
                    size: 24,
                    padding: 2,
                  ),
                  label: Text(
                    '${trait.name} 원소 ${workshopTraitAmountLabel(trait.amount)}',
                  ),
                  selected: selected,
                  onSelected: (bool value) {
                    setState(() {
                      if (value) {
                        _selectedTraits.add(trait.id);
                      } else {
                        _selectedTraits.remove(trait.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('추출 프로필', style: subsectionTitleStyle),
            const SizedBox(height: AppSpacing.md),
            WorkshopExtractionProfileList(
              profiles: detail.profiles,
              hasSelection: _selectedTraits.isNotEmpty,
              onExtract: (String profileId) {
                final WorkshopExtractionSubmitResult result = controller
                    .extractMaterial(
                      detail.materialId,
                      profileId,
                      quantity: selectedQuantity,
                      selectedTraits: _selectedTraits.isEmpty
                          ? null
                          : _selectedTraits.toList(),
                    );
                if (result == WorkshopExtractionSubmitResult.success) {
                  Navigator.of(context).pop();
                  return;
                }
                final String message = switch (result) {
                  WorkshopExtractionSubmitResult.queueFull => '작업실 큐가 가득 찼습니다',
                  WorkshopExtractionSubmitResult.materialMissing => '재료 부족',
                  WorkshopExtractionSubmitResult.elementSelectionRequired =>
                    '원소 선택 필요',
                  WorkshopExtractionSubmitResult.success => '',
                  WorkshopExtractionSubmitResult.failed => '추출 등록에 실패했습니다',
                };
                AppToast.show(context, message);
              },
            ),
          ],
        ),
      );
    }

    return AppDialogLayout(
      title: detail.materialName,
      body: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.sizeOf(context).height * AppDialogHeights.tall,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            header,
            const SizedBox(height: AppSpacing.md),
            Expanded(child: buildBody()),
          ],
        ),
      ),
    );
  }
}

class _ExtractionQuantitySlider extends StatelessWidget {
  const _ExtractionQuantitySlider({
    required this.selectedQuantity,
    required this.value,
    required this.maxQuantity,
    required this.onChanged,
  });

  final int selectedQuantity;
  final double value;
  final int maxQuantity;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool enabled = maxQuantity > 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                '선택 $selectedQuantity개',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(
              '최대 $maxQuantity개',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 1,
          max: maxQuantity.toDouble(),
          onChanged: enabled
              ? (double value) {
                  onChanged(value);
                }
              : null,
        ),
      ],
    );
  }
}
