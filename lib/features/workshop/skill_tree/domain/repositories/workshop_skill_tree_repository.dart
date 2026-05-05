import 'package:alchemist_hunter/features/workshop/skill_tree/domain/models/workshop_skill_tree_models.dart';

abstract interface class WorkshopSkillTreeRepository {
  List<WorkshopSkillNode> nodes();

  WorkshopSkillNode? findById(String nodeId);
}
