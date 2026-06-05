import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_empty_state.dart';
import 'package:alchemist_hunter/common/widgets/app_badge.dart';
import 'package:alchemist_hunter/common/widgets/app_dialog_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_toast.dart';
import 'package:alchemist_hunter/common/widgets/detail_lines.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/workshop/shared/presentation/viewmodels/workshop_resource_selectors.dart';
import 'package:alchemist_hunter/features/workshop/hatchery/presentation/viewmodels/hatch_controller.dart';
import 'package:alchemist_hunter/features/workshop/hatchery/presentation/viewmodels/hatch_selectors.dart';

class WorkshopHatchSheet extends ConsumerWidget {
  const WorkshopHatchSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int essence = ref.watch(workshopEssenceProvider);
    final int arcaneDust = ref.watch(workshopArcaneDustProvider);
    final List<HomunculusHatchRecipeView> recipes = ref.watch(
      homunculusHatchRecipeViewsProvider,
    );

    return AppSheetLayout(
      title: '호문쿨루스 부화',
      header: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.sm,
        children: <Widget>[
          AppBadge(label: '정수 $essence'),
          AppBadge(label: '신비 $arcaneDust'),
        ],
      ),
      body: recipes.isEmpty
          ? const AppEmptyState('부화 가능한 레시피가 없습니다')
          : ListView(
              children: recipes
                  .map((HomunculusHatchRecipeView recipe) {
                    return ListTile(
                      dense: true,
                      title: Text(recipe.resultName),
                      subtitle: _HatchRecipeSummary(recipe: recipe),
                      onTap: () {
                        showDialog<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return _HatchRecipeDetailDialog(recipe: recipe);
                          },
                        );
                      },
                      trailing: FilledButton.tonal(
                        onPressed: recipe.canHatch
                            ? () {
                                final WorkshopHatchSubmitResult result = ref
                                    .read(workshopHatchControllerProvider)
                                    .hatch(recipe.id);
                                if (result ==
                                    WorkshopHatchSubmitResult.success) {
                                  return;
                                }
                                final String message = switch (result) {
                                  WorkshopHatchSubmitResult.queueFull =>
                                    '작업실 큐가 가득 찼습니다',
                                  WorkshopHatchSubmitResult.essenceMissing =>
                                    '정수 부족',
                                  WorkshopHatchSubmitResult.arcaneMissing =>
                                    '신비 부족',
                                  WorkshopHatchSubmitResult.materialMissing =>
                                    '재료 부족',
                                  WorkshopHatchSubmitResult.elementMissing =>
                                    '원소 부족',
                                  WorkshopHatchSubmitResult.success => '',
                                  WorkshopHatchSubmitResult.failed =>
                                    '부화 등록에 실패했습니다',
                                };
                                AppToast.show(context, message);
                              }
                            : null,
                        child: const Text('등록'),
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
    );
  }
}

class _HatchRecipeSummary extends StatelessWidget {
  const _HatchRecipeSummary({required this.recipe});

  final HomunculusHatchRecipeView recipe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              AppBadge(label: recipe.roleLabel),
              AppBadge(label: recipe.availabilityLabel),
            ],
          ),
        ],
      ),
    );
  }
}

class _HatchRecipeDetailDialog extends StatelessWidget {
  const _HatchRecipeDetailDialog({required this.recipe});

  final HomunculusHatchRecipeView recipe;

  @override
  Widget build(BuildContext context) {
    return AppDialogLayout(
      title: recipe.resultName,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              AppBadge(label: recipe.roleLabel),
              AppBadge(label: recipe.availabilityLabel),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          DetailLines(
            description: '효과',
            lines: <String>[recipe.supportEffectLabel],
          ),
          const SizedBox(height: AppSpacing.lg),
          DetailLines(description: '재료', lines: recipe.costLabels),
        ],
      ),
    );
  }
}
