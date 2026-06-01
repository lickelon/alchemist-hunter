import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/equipment_blueprint_repository.dart';

class StaticEquipmentBlueprintRepository
    implements EquipmentBlueprintRepository {
  const StaticEquipmentBlueprintRepository({
    required List<EquipmentBlueprint> blueprints,
  }) : _blueprints = blueprints;

  final List<EquipmentBlueprint> _blueprints;

  @override
  List<EquipmentBlueprint> blueprints() => _blueprints;

  @override
  EquipmentBlueprint? findById(String blueprintId) {
    return _blueprints
        .where((EquipmentBlueprint blueprint) => blueprint.id == blueprintId)
        .firstOrNull;
  }
}
