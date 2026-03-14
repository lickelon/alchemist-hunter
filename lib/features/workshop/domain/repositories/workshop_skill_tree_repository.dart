import '../models.dart';

abstract interface class WorkshopSkillTreeRepository {
  List<WorkshopSkillNode> nodes();

  WorkshopSkillNode? findById(String nodeId);
}
