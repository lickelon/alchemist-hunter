import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/enchanting/domain/services/equipment_enchant_target_service.dart';

class WorkshopEnchantJobFactory {
  const WorkshopEnchantJobFactory();

  CraftQueueJob createJob({
    required DateTime queuedAt,
    required String equipmentId,
    required String potionStackKey,
    required CraftedPotion potion,
    required EquipmentEnchantTarget target,
    required EquipmentInstance completedEquipment,
    required bool hasActiveJob,
  }) {
    const Duration duration = Duration(seconds: 20);
    return CraftQueueJob(
      id: 'job_${queuedAt.microsecondsSinceEpoch}_enchant_$equipmentId',
      type: WorkshopJobType.enchant,
      status: hasActiveJob ? QueueJobStatus.queued : QueueJobStatus.processing,
      queuedAt: queuedAt,
      startedAt: hasActiveJob ? null : queuedAt,
      duration: duration,
      eta: duration,
      title: target.item.name,
      potionStackKey: potionStackKey,
      equipmentId: equipmentId,
      equipmentOwnerId: target.ownerCharacter?.id,
      equipmentOwnerType: target.ownerType,
      reservedPotion: potion,
      reservedEquipment: target.item,
      completedEquipment: completedEquipment,
    );
  }
}
