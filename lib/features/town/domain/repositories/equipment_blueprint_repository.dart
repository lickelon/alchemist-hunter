import '../models.dart';

abstract interface class EquipmentBlueprintRepository {
  List<EquipmentBlueprint> blueprints();

  EquipmentBlueprint? findById(String blueprintId);
}
