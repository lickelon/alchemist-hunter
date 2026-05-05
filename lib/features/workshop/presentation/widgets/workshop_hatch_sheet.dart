import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/workshop/presentation/workshop_providers.dart';

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
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: Builder(
          builder: (BuildContext sheetContext) {
            return AppSheetLayout(
              title: '호문쿨루스 부화',
              header: Text(
                'Essence $essence / ArcaneDust $arcaneDust / 보유 호문쿨루스 $homunculusCount체',
              ),
              body: recipes.isEmpty
                  ? const Center(child: Text('부화 가능한 레시피가 없습니다'))
                  : ListView(
                      children: recipes
                          .map((HomunculusHatchRecipeView recipe) {
                            return ListTile(
                              dense: true,
                              title: Text(recipe.name),
                              subtitle: Text(
                                '${recipe.description}\n결과 ${recipe.resultName}\n역할 ${recipe.roleLabel}\n보조효과 ${recipe.supportEffectLabel}\n${recipe.costLabel}',
                              ),
                              trailing: FilledButton.tonal(
                                onPressed: recipe.canHatch
                                    ? () {
                                        final WorkshopHatchSubmitResult
                                        result = ref
                                            .read(
                                              workshopHatchControllerProvider,
                                            )
                                            .hatch(recipe.id);
                                        if (result ==
                                            WorkshopHatchSubmitResult.success) {
                                          return;
                                        }
                                        final String message =
                                            result ==
                                                WorkshopHatchSubmitResult
                                                    .queueFull
                                            ? '작업실 큐가 가득 찼습니다'
                                            : '부화 등록에 실패했습니다';
                                        AppToast.show(sheetContext, message);
                                      }
                                    : null,
                                child: const Text('등록'),
                              ),
                            );
                          })
                          .toList(growable: false),
                    ),
            );
          },
        ),
      ),
    );
  }
}
