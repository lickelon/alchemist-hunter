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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '호문쿨루스 부화',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Essence $essence / ArcaneDust $arcaneDust / 보유 호문쿨루스 $homunculusCount체',
              ),
              const SizedBox(height: 8),
              Expanded(
                child: recipes.isEmpty
                    ? const Center(child: Text('부화 가능한 레시피가 없습니다'))
                    : ListView(
                        children: recipes.map((HomunculusHatchRecipeView recipe) {
                          return ListTile(
                            dense: true,
                            title: Text(recipe.name),
                            subtitle: Text(
                              '${recipe.description}\n결과 ${recipe.resultName}\n${recipe.costLabel}',
                            ),
                            trailing: FilledButton.tonal(
                              onPressed: recipe.canHatch
                                  ? () {
                                      ref
                                          .read(workshopHatchControllerProvider)
                                          .hatch(recipe.id);
                                    }
                                  : null,
                              child: const Text('부화'),
                            ),
                          );
                        }).toList(growable: false),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
