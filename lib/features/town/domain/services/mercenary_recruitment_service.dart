import 'package:alchemist_hunter/features/town/data/catalogs/mercenary_templates.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';

class MercenaryRecruitmentService {
  const MercenaryRecruitmentService();

  List<MercenaryCandidate> buildCandidates({required int refreshIndex}) {
    return List<MercenaryCandidate>.generate(3, (int index) {
      final MercenaryTemplate template = mercenaryTemplates[
          (refreshIndex + index) % mercenaryTemplates.length];
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
