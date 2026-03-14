import 'package:alchemist_hunter/features/town/data/catalogs/equipment_blueprints.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/equipment_blueprint_repository.dart';

class StaticEquipmentBlueprintRepository
    implements EquipmentBlueprintRepository {
  const StaticEquipmentBlueprintRepository();

  @override
  List<EquipmentBlueprint> blueprints() => townEquipmentBlueprints;

  @override
  EquipmentBlueprint? findById(String blueprintId) {
    return townEquipmentBlueprints
        .where((EquipmentBlueprint blueprint) => blueprint.id == blueprintId)
        .firstOrNull;
  }
}
