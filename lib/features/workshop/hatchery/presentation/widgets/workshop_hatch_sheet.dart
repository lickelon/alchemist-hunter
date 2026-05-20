import 'package:alchemist_hunter/common/widgets/detail_lines.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/workshop/dashboard/presentation/viewmodels/workshop_shared_selectors.dart';
import 'package:alchemist_hunter/features/workshop/hatchery/presentation/viewmodels/hatch_controller.dart';
import 'package:alchemist_hunter/features/workshop/hatchery/presentation/viewmodels/hatch_selectors.dart';

class WorkshopHatchSheet extends ConsumerWidget {
  const WorkshopHatchSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int essence = ref.watch(workshopEssenceProvider);
    final int arcaneDust = ref.watch(workshopArcaneDustProvider);
    final int homunculusCount = ref.watch(workshopHomunculusCountProvider);
    final List<HomunculusHatchRecipeView> recipes = ref.watch(
      homunculusHatchRecipeViewsProvider,
    );

    return AppBottomSheet(
      child: AppSheetLayout(
        title: '호문쿨루스 부화',
        header: Text(
          '정수 $essence / 신비 $arcaneDust / 보유 호문쿨루스 $homunculusCount체',
        ),
        body: recipes.isEmpty
            ? const Center(child: Text('부화 가능한 레시피가 없습니다'))
            : ListView(
                children: recipes
                    .map((HomunculusHatchRecipeView recipe) {
                      return ListTile(
                        dense: true,
                        title: Text(recipe.name),
                        subtitle: DetailLines(
                          description: recipe.description,
                          lines: <String>[
                            '결과 ${recipe.resultName}',
                            '역할 ${recipe.roleLabel}',
                            '보조효과 ${recipe.supportEffectLabel}',
                            recipe.costLabel,
                            recipe.availabilityLabel,
                          ],
                        ),
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
      ),
    );
  }
}
