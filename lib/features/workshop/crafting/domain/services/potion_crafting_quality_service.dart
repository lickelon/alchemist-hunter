part of 'potion_crafting_service.dart';

extension PotionCraftingQualityService on PotionCraftingService {
  ({PotionQualityGrade grade, double score}) calculateQuality({
    required Map<String, double> targetTraits,
    required Map<String, double> inputTraits,
    required PotionQualityRule qualityRule,
  }) {
    final double score = calculateQualityScore(
      targetTraits: targetTraits,
      actualTraits: normalizeTraits(inputTraits),
    );
    return (grade: resolveGrade(score, qualityRule), score: score);
  }

  double calculateQualityScore({
    required Map<String, double> targetTraits,
    required Map<String, double> actualTraits,
  }) {
    if (targetTraits.isEmpty) {
      return 0;
    }

    int diffPercent = 0;
    targetTraits.forEach((String id, double targetRatio) {
      final int targetPercent = ratioToPercent(targetRatio);
      final int actualPercent = ratioToPercent(actualTraits[id] ?? 0);
      diffPercent += (targetPercent - actualPercent).abs();
    });

    final double score = 1 - (diffPercent / 100);
    return score.clamp(0, 1);
  }

  int ratioToPercent(double ratio) {
    return (ratio * 100).round().clamp(0, 100);
  }

  PotionQualityGrade resolveGrade(double score, PotionQualityRule rule) {
    final Map<PotionQualityGrade, double> thresholds = rule.gradeThresholds;
    if (score >= (thresholds[PotionQualityGrade.s] ?? 0.9)) {
      return PotionQualityGrade.s;
    }
    if (score >= (thresholds[PotionQualityGrade.a] ?? 0.75)) {
      return PotionQualityGrade.a;
    }
    if (score >= (thresholds[PotionQualityGrade.b] ?? 0.55)) {
      return PotionQualityGrade.b;
    }
    if (score >= (thresholds[PotionQualityGrade.c] ?? 0)) {
      return PotionQualityGrade.c;
    }
    return PotionQualityGrade.f;
  }
}
