import 'package:alchemist_hunter/app/session/session_state.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/repositories/workshop_craft_recipe_repository.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/domain/repositories/workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/skill_tree/domain/services/workshop_skill_tree_service.dart';
import 'package:alchemist_hunter/features/workshop/support/domain/services/workshop_support_service.dart';

part 'workshop_brew_enqueue_use_case.dart';
part 'workshop_craft_enqueue_support.dart';
part 'workshop_material_recipe_enqueue_use_case.dart';
part 'workshop_potion_enqueue_use_case.dart';

class WorkshopCraftEnqueueUseCase
    with
        _CraftEnqueueSupportMixin,
        _WorkshopPotionEnqueueMixin,
        _WorkshopMaterialRecipeEnqueueMixin,
        _WorkshopBrewEnqueueMixin {
  const WorkshopCraftEnqueueUseCase();
}
