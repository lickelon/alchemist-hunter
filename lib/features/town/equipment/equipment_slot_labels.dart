import 'package:alchemist_hunter/features/town/domain/models.dart';

String equipmentSlotLabel(EquipmentSlot slot) {
  return switch (slot) {
    EquipmentSlot.weapon => '무기',
    EquipmentSlot.armor => '방어구',
    EquipmentSlot.accessory => '장신구',
  };
}
