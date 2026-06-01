import 'package:alchemist_hunter/features/town/data/catalogs/equipment_blueprints.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/equipment_blueprint_repository.dart';

class StaticEquipmentBlueprintRepository
    implements EquipmentBlueprintRepository {
  const StaticEquipmentBlueprintRepository({
    List<EquipmentBlueprint>? blueprints,
  }) : _blueprints = blueprints;

  final List<EquipmentBlueprint>? _blueprints;

  List<EquipmentBlueprint> get _catalog =>
      _blueprints ?? townEquipmentBlueprints;

  @override
  List<EquipmentBlueprint> blueprints() => _catalog;

  @override
  EquipmentBlueprint? findById(String blueprintId) {
    return _catalog
        .where((EquipmentBlueprint blueprint) => blueprint.id == blueprintId)
        .firstOrNull;
  }
}
