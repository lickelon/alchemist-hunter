import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/mercenary_template_repository.dart';

class StaticMercenaryTemplateRepository implements MercenaryTemplateRepository {
  const StaticMercenaryTemplateRepository({
    required List<MercenaryTemplate> templates,
  }) : _templates = templates;

  final List<MercenaryTemplate> _templates;

  @override
  List<MercenaryTemplate> templates() => _templates;
}
