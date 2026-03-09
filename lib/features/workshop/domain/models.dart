import 'package:flutter/foundation.dart';

enum MaterialRarity { common, uncommon, rare, epic }

enum TraitType { single, compound }

enum ExtractionMode { full, selective }

enum PotionUseType { sell, combat, both }

enum QueueJobStatus { queued, processing, completed, failed }

enum ShopType { general, catalyst }

enum SessionPhase { early, mid, late }

enum PotionQualityGrade { s, a, b, c }

@immutable
class TraitUnit {
  const TraitUnit({
    required this.id,
    required this.name,
    required this.type,
    required this.potency,
    this.components = const <String, double>{},
  });

  final String id;
  final String name;
  final TraitType type;
  final double potency;
  final Map<String, double> components;
}

@immutable
class MaterialEntity {
  const MaterialEntity({
    required this.id,
    required this.name,
    required this.rarity,
    required this.traits,
    required this.analyzable,
    required this.source,
  });

  final String id;
  final String name;
  final MaterialRarity rarity;
  final List<TraitUnit> traits;
  final bool analyzable;
  final String source;
}

@immutable
class PotionBlueprint {
  const PotionBlueprint({
    required this.id,
    required this.name,
    required this.targetTraits,
    required this.baseValue,
    required this.useType,
  });

  final String id;
  final String name;
  final Map<String, double> targetTraits;
  final int baseValue;
  final PotionUseType useType;
}

@immutable
class PotionRecipeRule {
  const PotionRecipeRule({
    required this.id,
    required this.requiredTraits,
    required this.resultPotionId,
    this.optionalTraits = const <String>{},
    this.forbiddenTraits = const <String>{},
  });

  final String id;
  final Set<String> requiredTraits;
  final Set<String> optionalTraits;
  final Set<String> forbiddenTraits;
  final String resultPotionId;
}

@immutable
class PotionRecipeBranchRule {
  const PotionRecipeBranchRule({
    required this.recipeId,
    required this.dominantTrait,
    required this.ratioGapMin,
    required this.branchedPotionId,
  });

  final String recipeId;
  final String dominantTrait;
  final double ratioGapMin;
  final String branchedPotionId;
}

@immutable
class PotionQualityRule {
  const PotionQualityRule({
    required this.gradeThresholds,
  });

  final Map<PotionQualityGrade, double> gradeThresholds;
}

@immutable
class CraftedPotion {
  const CraftedPotion({
    required this.id,
    required this.typePotionId,
    required this.qualityGrade,
    required this.qualityScore,
    required this.traits,
    required this.createdAt,
  });

  final String id;
  final String typePotionId;
  final PotionQualityGrade qualityGrade;
  final double qualityScore;
  final Map<String, double> traits;
  final DateTime createdAt;
}

@immutable
class ExtractionProfile {
  const ExtractionProfile({
    required this.id,
    required this.mode,
    required this.yieldRate,
    required this.purityRate,
    required this.timeCost,
  });

  final String id;
  final ExtractionMode mode;
  final double yieldRate;
  final double purityRate;
  final Duration timeCost;
}

@immutable
class CraftRetryPolicy {
  const CraftRetryPolicy({required this.maxRetries});

  final int maxRetries;
}

@immutable
class CraftQueueJob {
  const CraftQueueJob({
    required this.id,
    required this.potionId,
    required this.repeatCount,
    required this.retryPolicy,
    required this.status,
    required this.eta,
    this.currentRepeat = 0,
    this.retryCount = 0,
  });

  final String id;
  final String potionId;
  final int repeatCount;
  final CraftRetryPolicy retryPolicy;
  final QueueJobStatus status;
  final Duration eta;
  final int currentRepeat;
  final int retryCount;

  CraftQueueJob copyWith({
    QueueJobStatus? status,
    Duration? eta,
    int? currentRepeat,
    int? retryCount,
  }) {
    return CraftQueueJob(
      id: id,
      potionId: potionId,
      repeatCount: repeatCount,
      retryPolicy: retryPolicy,
      status: status ?? this.status,
      eta: eta ?? this.eta,
      currentRepeat: currentRepeat ?? this.currentRepeat,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

@immutable
class ShopItem {
  const ShopItem({
    required this.materialId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  final String materialId;
  final String name;
  final int price;
  final int quantity;
}

@immutable
class ShopState {
  const ShopState({
    required this.shopType,
    required this.items,
    required this.nextRefreshAt,
    required this.forcedRefreshCost,
    required this.baseRefreshCost,
    required this.refreshCostStep,
    required this.cycleRefreshCount,
  });

  final ShopType shopType;
  final List<ShopItem> items;
  final DateTime nextRefreshAt;
  final int forcedRefreshCost;
  final int baseRefreshCost;
  final int refreshCostStep;
  final int cycleRefreshCount;

  ShopState copyWith({
    List<ShopItem>? items,
    DateTime? nextRefreshAt,
    int? forcedRefreshCost,
    int? cycleRefreshCount,
  }) {
    return ShopState(
      shopType: shopType,
      items: items ?? this.items,
      nextRefreshAt: nextRefreshAt ?? this.nextRefreshAt,
      forcedRefreshCost: forcedRefreshCost ?? this.forcedRefreshCost,
      baseRefreshCost: baseRefreshCost,
      refreshCostStep: refreshCostStep,
      cycleRefreshCount: cycleRefreshCount ?? this.cycleRefreshCount,
    );
  }
}

@immutable
class BattleDropEntry {
  const BattleDropEntry({
    required this.materialId,
    required this.min,
    required this.max,
    required this.chance,
  });

  final String materialId;
  final int min;
  final int max;
  final double chance;
}

@immutable
class BattleDropTable {
  const BattleDropTable({
    required this.stageId,
    required this.normalDrops,
    required this.specialDrops,
  });

  final String stageId;
  final List<BattleDropEntry> normalDrops;
  final List<BattleDropEntry> specialDrops;
}

@immutable
class HeroProfile {
  const HeroProfile({required this.id, required this.name, required this.power});

  final String id;
  final String name;
  final int power;
}

@immutable
class AutoBattleConfig {
  const AutoBattleConfig({
    required this.party,
    required this.potionLoadout,
    required this.stageId,
  });

  final List<HeroProfile> party;
  final Map<String, int> potionLoadout;
  final String stageId;
}

@immutable
class ProgressState {
  const ProgressState({
    required this.unlockFlags,
    required this.automationTier,
    required this.sessionPhase,
  });

  final Set<String> unlockFlags;
  final int automationTier;
  final SessionPhase sessionPhase;
}

@immutable
class BattleResult {
  const BattleResult({
    required this.success,
    required this.turns,
    required this.loot,
    required this.failurePenalty,
  });

  final bool success;
  final int turns;
  final Map<String, int> loot;
  final int failurePenalty;
}

@immutable
class ExtractedTrait {
  const ExtractedTrait({
    required this.traitId,
    required this.name,
    required this.amount,
    required this.purity,
  });

  final String traitId;
  final String name;
  final double amount;
  final double purity;
}
