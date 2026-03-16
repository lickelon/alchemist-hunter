import 'package:flutter/foundation.dart';

import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';

import 'enums.dart';
import 'potion_models.dart';

@immutable
class CraftRetryPolicy {
  const CraftRetryPolicy({required this.maxRetries});

  final int maxRetries;
}

@immutable
class CraftQueueJob {
  const CraftQueueJob({
    required this.id,
    required this.type,
    required this.status,
    required this.queuedAt,
    required this.duration,
    required this.eta,
    this.title = '',
    this.startedAt,
    this.potionId,
    this.repeatCount = 1,
    this.retryPolicy = const CraftRetryPolicy(maxRetries: 0),
    this.currentRepeat = 0,
    this.retryCount = 0,
    this.materialId,
    this.profileId,
    this.quantity = 1,
    this.selectedTraits = const <String>[],
    this.recipeId,
    this.potionStackKey,
    this.equipmentId,
    this.equipmentOwnerId,
    this.equipmentOwnerType,
    this.reservedPotion,
    this.reservedEquipment,
    this.reservedMaterials = const <String, int>{},
    this.reservedTraits = const <String, double>{},
    this.completedPotionStackKey,
    this.completedPotion,
    this.completedExtractedTraits = const <String, double>{},
    this.completedArcaneDust = 0,
    this.completedEquipment,
    this.completedHomunculus,
  });

  final String id;
  final WorkshopJobType type;
  final DateTime queuedAt;
  final DateTime? startedAt;
  final Duration duration;
  final String title;
  final String? potionId;
  final int repeatCount;
  final CraftRetryPolicy retryPolicy;
  final QueueJobStatus status;
  final Duration eta;
  final int currentRepeat;
  final int retryCount;
  final String? materialId;
  final String? profileId;
  final int quantity;
  final List<String> selectedTraits;
  final String? recipeId;
  final String? potionStackKey;
  final String? equipmentId;
  final String? equipmentOwnerId;
  final CharacterType? equipmentOwnerType;
  final CraftedPotion? reservedPotion;
  final EquipmentInstance? reservedEquipment;
  final Map<String, int> reservedMaterials;
  final Map<String, double> reservedTraits;
  final String? completedPotionStackKey;
  final CraftedPotion? completedPotion;
  final Map<String, double> completedExtractedTraits;
  final int completedArcaneDust;
  final EquipmentInstance? completedEquipment;
  final CharacterProgress? completedHomunculus;

  CraftQueueJob copyWith({
    QueueJobStatus? status,
    DateTime? startedAt,
    bool clearStartedAt = false,
    Duration? duration,
    Duration? eta,
    int? currentRepeat,
    int? retryCount,
    String? completedPotionStackKey,
    CraftedPotion? completedPotion,
    Map<String, double>? completedExtractedTraits,
    int? completedArcaneDust,
    EquipmentInstance? completedEquipment,
    CharacterProgress? completedHomunculus,
  }) {
    return CraftQueueJob(
      id: id,
      type: type,
      status: status ?? this.status,
      queuedAt: queuedAt,
      startedAt: clearStartedAt ? null : startedAt ?? this.startedAt,
      duration: duration ?? this.duration,
      eta: eta ?? this.eta,
      title: title,
      potionId: potionId,
      repeatCount: repeatCount,
      retryPolicy: retryPolicy,
      currentRepeat: currentRepeat ?? this.currentRepeat,
      retryCount: retryCount ?? this.retryCount,
      materialId: materialId,
      profileId: profileId,
      quantity: quantity,
      selectedTraits: selectedTraits,
      recipeId: recipeId,
      potionStackKey: potionStackKey,
      equipmentId: equipmentId,
      equipmentOwnerId: equipmentOwnerId,
      equipmentOwnerType: equipmentOwnerType,
      reservedPotion: reservedPotion,
      reservedEquipment: reservedEquipment,
      reservedMaterials: reservedMaterials,
      reservedTraits: reservedTraits,
      completedPotionStackKey:
          completedPotionStackKey ?? this.completedPotionStackKey,
      completedPotion: completedPotion ?? this.completedPotion,
      completedExtractedTraits:
          completedExtractedTraits ?? this.completedExtractedTraits,
      completedArcaneDust: completedArcaneDust ?? this.completedArcaneDust,
      completedEquipment: completedEquipment ?? this.completedEquipment,
      completedHomunculus: completedHomunculus ?? this.completedHomunculus,
    );
  }
}

@immutable
class WorkshopEquipmentClaim {
  const WorkshopEquipmentClaim({
    required this.equipment,
    this.ownerCharacterId,
    this.ownerType,
  });

  final EquipmentInstance equipment;
  final String? ownerCharacterId;
  final CharacterType? ownerType;
}

@immutable
class WorkshopPendingClaim {
  const WorkshopPendingClaim({
    this.extractedTraits = const <String, double>{},
    this.arcaneDust = 0,
    this.potionStacks = const <String, int>{},
    this.potionDetails = const <String, CraftedPotion>{},
    this.equipmentClaims = const <WorkshopEquipmentClaim>[],
    this.homunculi = const <CharacterProgress>[],
    this.extractionCount = 0,
    this.potionCraftCount = 0,
    this.enchantCount = 0,
  });

  final Map<String, double> extractedTraits;
  final int arcaneDust;
  final Map<String, int> potionStacks;
  final Map<String, CraftedPotion> potionDetails;
  final List<WorkshopEquipmentClaim> equipmentClaims;
  final List<CharacterProgress> homunculi;
  final int extractionCount;
  final int potionCraftCount;
  final int enchantCount;

  bool get isEmpty {
    return extractedTraits.isEmpty &&
        arcaneDust == 0 &&
        potionStacks.isEmpty &&
        equipmentClaims.isEmpty &&
        homunculi.isEmpty &&
        extractionCount == 0 &&
        potionCraftCount == 0 &&
        enchantCount == 0;
  }

  WorkshopPendingClaim copyWith({
    Map<String, double>? extractedTraits,
    int? arcaneDust,
    Map<String, int>? potionStacks,
    Map<String, CraftedPotion>? potionDetails,
    List<WorkshopEquipmentClaim>? equipmentClaims,
    List<CharacterProgress>? homunculi,
    int? extractionCount,
    int? potionCraftCount,
    int? enchantCount,
  }) {
    return WorkshopPendingClaim(
      extractedTraits: extractedTraits ?? this.extractedTraits,
      arcaneDust: arcaneDust ?? this.arcaneDust,
      potionStacks: potionStacks ?? this.potionStacks,
      potionDetails: potionDetails ?? this.potionDetails,
      equipmentClaims: equipmentClaims ?? this.equipmentClaims,
      homunculi: homunculi ?? this.homunculi,
      extractionCount: extractionCount ?? this.extractionCount,
      potionCraftCount: potionCraftCount ?? this.potionCraftCount,
      enchantCount: enchantCount ?? this.enchantCount,
    );
  }
}
