import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/widgets/app_empty_state.dart';
import 'package:alchemist_hunter/common/widgets/resource_icon_grid.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/viewmodels/craft_queue_option_selectors.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/widgets/workshop_material_craft_detail_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkshopMaterialCraftTab extends ConsumerWidget {
  const WorkshopMaterialCraftTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<WorkshopMaterialCraftRecipeView> recipes = ref.watch(
      workshopMaterialCraftRecipeViewsProvider,
    );

    if (recipes.isEmpty) {
      return const AppEmptyState('등록 가능한 제작 항목이 없습니다');
    }
    return ResourceIconGrid(
      items: recipes
          .map((WorkshopMaterialCraftRecipeView recipe) {
            final String quantityLabel = 'x${recipe.resultQuantity}';
            return ResourceIconGridItem(
              key: ValueKey<String>('craft_recipe_${recipe.recipeId}'),
              assetPath: CatalogIconAssetPaths.material(
                recipe.resultMaterialId,
              ),
              badgeLabel: quantityLabel,
              semanticLabel: '${recipe.title} $quantityLabel',
              tooltipMessage: recipe.title,
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return WorkshopMaterialCraftDetailDialog(recipe: recipe);
                  },
                );
              },
            );
          })
          .toList(growable: false),
    );
  }
}
