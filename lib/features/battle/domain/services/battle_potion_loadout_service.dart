import 'package:alchemist_hunter/features/workshop/domain/models.dart';

class ResolvedBattlePotionLoadout {
  const ResolvedBattlePotionLoadout({
    required this.appliedLoadout,
    required this.fallback,
  });

  final Map<String, int> appliedLoadout;
  final bool fallback;
}

class BattlePotionLoadoutService {
  const BattlePotionLoadoutService();

  ResolvedBattlePotionLoadout resolveLoadout({
    required Map<String, int> requestedLoadout,
    required Map<String, int> ownedStacks,
  }) {
    final Map<String, int> sanitized = <String, int>{};
    for (final MapEntry<String, int> entry in requestedLoadout.entries) {
      if (entry.value > 0) {
        sanitized[entry.key] = entry.value;
      }
    }
    if (sanitized.isEmpty) {
      return const ResolvedBattlePotionLoadout(
        appliedLoadout: <String, int>{},
        fallback: false,
      );
    }

    final bool fullyAvailable = sanitized.entries.every((
      MapEntry<String, int> entry,
    ) {
      return (ownedStacks[entry.key] ?? 0) >= entry.value;
    });

    if (!fullyAvailable) {
      return const ResolvedBattlePotionLoadout(
        appliedLoadout: <String, int>{},
        fallback: true,
      );
    }

    return ResolvedBattlePotionLoadout(
      appliedLoadout: sanitized,
      fallback: false,
    );
  }

  WorkshopState consumeLoadout({
    required WorkshopState workshop,
    required Map<String, int> appliedLoadout,
  }) {
    if (appliedLoadout.isEmpty) {
      return workshop;
    }

    final Map<String, int> nextStacks = <String, int>{
      ...workshop.craftedPotionStacks,
    };
    final Map<String, CraftedPotion> nextDetails = <String, CraftedPotion>{
      ...workshop.craftedPotionDetails,
    };

    for (final MapEntry<String, int> entry in appliedLoadout.entries) {
      final int remaining = (nextStacks[entry.key] ?? 0) - entry.value;
      if (remaining > 0) {
        nextStacks[entry.key] = remaining;
      } else {
        nextStacks.remove(entry.key);
        nextDetails.remove(entry.key);
      }
    }

    return workshop.copyWith(
      craftedPotionStacks: nextStacks,
      craftedPotionDetails: nextDetails,
    );
  }
}
