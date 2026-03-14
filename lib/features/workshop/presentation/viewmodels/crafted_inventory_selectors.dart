import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

class CraftedPotionStackView {
  const CraftedPotionStackView({
    required this.stackKey,
    required this.quantity,
    required this.qualityLabel,
    required this.scoreLabel,
    required this.traitsLabel,
  });

  final String stackKey;
  final int quantity;
  final String qualityLabel;
  final String scoreLabel;
  final String traitsLabel;
}

final Provider<Map<String, int>> craftedPotionStacksProvider =
    Provider<Map<String, int>>((Ref ref) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.workshop.craftedPotionStacks,
        ),
      );
    });

final Provider<Map<String, CraftedPotion>> craftedPotionDetailsProvider =
    Provider<Map<String, CraftedPotion>>((Ref ref) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.workshop.craftedPotionDetails,
        ),
      );
    });

final Provider<List<CraftedPotionStackView>> craftedPotionStackViewsProvider =
    Provider<List<CraftedPotionStackView>>((Ref ref) {
      final Map<String, int> stacks = ref.watch(craftedPotionStacksProvider);
      final Map<String, CraftedPotion> details = ref.watch(
        craftedPotionDetailsProvider,
      );
      final List<CraftedPotionStackView> views = stacks.entries.map((
        MapEntry<String, int> entry,
      ) {
        final CraftedPotion? detail = details[entry.key];
        return CraftedPotionStackView(
          stackKey: entry.key,
          quantity: entry.value,
          qualityLabel: detail?.qualityGrade.name.toUpperCase() ?? '-',
          scoreLabel: (detail?.qualityScore ?? 0).toStringAsFixed(2),
          traitsLabel: detail?.traits.toString() ?? '{}',
        );
      }).toList();
      views.sort((CraftedPotionStackView left, CraftedPotionStackView right) {
        return left.stackKey.compareTo(right.stackKey);
      });
      return views;
    });
