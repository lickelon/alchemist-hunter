import 'package:alchemist_hunter/common/themes/app_dialog_heights.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/themes/app_text_styles.dart';
import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_slider_field.dart';
import 'package:alchemist_hunter/common/widgets/app_toast.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/extraction_controller.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/extraction_detail_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'workshop_extraction_material_header.dart';
import 'workshop_extraction_profile_list.dart';
import 'workshop_extraction_trait_selector.dart';

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
        .clamp(0.0, maxQuantity.toDouble())
        .toDouble();
    final int selectedQuantity = sliderValue
        .round()
        .clamp(0, maxQuantity)
        .toInt();

    Widget buildBody() {
      final TextStyle subsectionTitleStyle = AppTextStyles.of(
        context,
      ).subsectionTitle;
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('수량', style: subsectionTitleStyle),
            const SizedBox(height: AppSpacing.md),
            AppQuantitySlider(
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
            Text('원소', style: subsectionTitleStyle),
            const SizedBox(height: AppSpacing.md),
            WorkshopExtractionTraitSelector(
              traits: detail.traits,
              selectedTraits: _selectedTraits,
              onSelectionChanged: (String traitId, bool selected) {
                setState(() {
                  if (selected) {
                    _selectedTraits.add(traitId);
                  } else {
                    _selectedTraits.remove(traitId);
                  }
                });
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('프로필', style: subsectionTitleStyle),
            const SizedBox(height: AppSpacing.md),
            WorkshopExtractionProfileList(
              profiles: detail.profiles,
              hasSelection: selectedQuantity > 0 && _selectedTraits.isNotEmpty,
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
            WorkshopExtractionMaterialHeader(
              materialId: detail.materialId,
              ownedQuantity: detail.ownedQuantity,
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(child: buildBody()),
          ],
        ),
      ),
    );
  }
}
