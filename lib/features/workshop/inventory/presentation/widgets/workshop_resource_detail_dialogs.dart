import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
import 'package:alchemist_hunter/common/widgets/detail_lines.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/viewmodels/crafted_inventory_selectors.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/extraction_inventory_selectors.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/workshop_display_labels.dart';
import 'package:flutter/material.dart';

class WorkshopMaterialResourceDetailDialog extends StatelessWidget {
  const WorkshopMaterialResourceDetailDialog({
    super.key,
    required this.material,
  });

  final MaterialInventoryView material;

  @override
  Widget build(BuildContext context) {
    return AppDialogLayout(
      title: material.name,
      body: DetailLines(
        lines: <String>[
          '보유 수량 x${material.quantity}',
          '희귀도 ${workshopMaterialRarityLabel(material.rarity)}',
          '원소 ${material.traitSummary}',
        ],
      ),
    );
  }
}

class WorkshopTraitResourceDetailDialog extends StatelessWidget {
  const WorkshopTraitResourceDetailDialog({super.key, required this.trait});

  final ExtractedTraitInventoryView trait;

  @override
  Widget build(BuildContext context) {
    return AppDialogLayout(
      title: trait.name,
      body: DetailLines(
        lines: <String>['보유량 ${workshopTraitAmountLabel(trait.amount)}'],
      ),
    );
  }
}

class WorkshopPotionResourceDetailDialog extends StatelessWidget {
  const WorkshopPotionResourceDetailDialog({super.key, required this.potion});

  final CraftedPotionStackView potion;

  @override
  Widget build(BuildContext context) {
    return AppDialogLayout(
      title: potion.name,
      body: DetailLines(
        lines: <String>[
          '보유 수량 x${potion.quantity}',
          '품질 ${potion.qualityLabel}',
          '점수 ${potion.scoreLabel}',
          '원소 ${potion.traitsLabel}',
        ],
      ),
    );
  }
}
