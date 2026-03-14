import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/mercenary_template_repository.dart';

class MercenaryRecruitmentService {
  const MercenaryRecruitmentService();

  List<MercenaryCandidate> buildCandidates({
    required int refreshIndex,
    required MercenaryTemplateRepository templateRepository,
  }) {
    final List<MercenaryTemplate> templates = templateRepository.templates();
    return List<MercenaryCandidate>.generate(3, (int index) {
      final MercenaryTemplate template = templates[
          (refreshIndex + index) % templates.length];
      return MercenaryCandidate(
        id: 'candidate_${refreshIndex}_$index',
        templateId: template.id,
        name: template.name,
        roleLabel: template.roleLabel,
        hireCost: template.hireCost,
        tierIndex: template.tierIndex,
      );
    });
  }
}
