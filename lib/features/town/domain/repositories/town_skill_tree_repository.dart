import '../models.dart';

abstract interface class TownSkillTreeRepository {
  List<TownSkillNode> nodes();

  TownSkillNode? findById(String nodeId);
}
