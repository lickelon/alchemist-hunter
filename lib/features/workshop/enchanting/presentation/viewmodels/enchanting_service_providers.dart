import 'package:alchemist_hunter/features/workshop/enchanting/domain/services/equipment_enchant_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<EquipmentEnchantService> equipmentEnchantServiceProvider =
    Provider<EquipmentEnchantService>(
      (Ref ref) => const EquipmentEnchantService(),
    );
