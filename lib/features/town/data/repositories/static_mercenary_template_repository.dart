import 'package:alchemist_hunter/features/town/data/catalogs/mercenary_templates.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/mercenary_template_repository.dart';

class StaticMercenaryTemplateRepository implements MercenaryTemplateRepository {
  const StaticMercenaryTemplateRepository();

  @override
  List<MercenaryTemplate> templates() => mercenaryTemplates;
}
