import 'package:alchemist_hunter/features/workshop/crafting/domain/models/workshop_craft_recipe_models.dart';

const List<WorkshopCraftRecipe> workshopCraftRecipes = <WorkshopCraftRecipe>[
  WorkshopCraftRecipe(
    id: 'craft_tier_mat_mercenary_2',
    name: '용병 승급 재료 2',
    category: WorkshopCraftRecipeCategory.promotionMaterial,
    materialCosts: <String, int>{'m_3': 3, 'promo_core_mercenary_2': 1},
    traitCosts: <String, double>{'t_atk': 2, 't_focus': 1},
    essenceCost: 40,
    arcaneDustCost: 1,
    duration: Duration(seconds: 45),
    resultMaterials: <String, int>{'tier_mat_mercenary_2': 1},
  ),
  WorkshopCraftRecipe(
    id: 'craft_tier_mat_homunculus_2',
    name: '호문쿨루스 승급 재료 2',
    category: WorkshopCraftRecipeCategory.promotionMaterial,
    materialCosts: <String, int>{'m_4': 3, 'promo_core_homunculus_2': 1},
    traitCosts: <String, double>{'t_mana': 2, 't_pure': 1},
    essenceCost: 40,
    arcaneDustCost: 1,
    duration: Duration(seconds: 45),
    resultMaterials: <String, int>{'tier_mat_homunculus_2': 1},
  ),
];
