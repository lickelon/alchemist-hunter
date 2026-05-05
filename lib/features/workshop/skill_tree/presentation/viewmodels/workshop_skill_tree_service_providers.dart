import 'package:alchemist_hunter/features/workshop/skill_tree/domain/services/workshop_skill_tree_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<WorkshopSkillTreeService> workshopSkillTreeServiceProvider =
    Provider<WorkshopSkillTreeService>(
      (Ref ref) => const WorkshopSkillTreeService(),
    );
