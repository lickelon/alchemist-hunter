import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/core/session/session_providers.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/equipment_enchant_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/use_cases/workshop_enchant_use_case.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/workshop_service_providers.dart';

class WorkshopEnchantController {
  WorkshopEnchantController(
    this._session,
    this._enchantService, {
    WorkshopEnchantUseCase enchantUseCase = const WorkshopEnchantUseCase(),
  }) : _enchantUseCase = enchantUseCase;

  final SessionController _session;
  final EquipmentEnchantService _enchantService;
  final WorkshopEnchantUseCase _enchantUseCase;

  void enchantEquipment(String equipmentId, String potionStackKey) {
    final SessionState current = _session.snapshot();
    final SessionState nextState = _enchantUseCase.enchantEquipment(
      state: current,
      equipmentId: equipmentId,
      potionStackKey: potionStackKey,
      enchantService: _enchantService,
    );
    _session.applyState(nextState);
    _session.appendLog(
      identical(nextState, current)
          ? 'Cannot enchant $equipmentId with $potionStackKey'
          : 'Enchanted $equipmentId with $potionStackKey',
    );
  }
}

final Provider<WorkshopEnchantController> workshopEnchantControllerProvider =
    Provider<WorkshopEnchantController>((Ref ref) {
      return WorkshopEnchantController(
        ref.read(sessionControllerProvider.notifier),
        ref.read(equipmentEnchantServiceProvider),
      );
    });
