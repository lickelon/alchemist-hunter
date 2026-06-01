import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/models/potion_models.dart';
import 'package:flutter/foundation.dart';

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
