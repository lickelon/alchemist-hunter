import 'package:alchemist_hunter/core/session/session_providers.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TownPotionSaleView {
  const TownPotionSaleView({
    required this.stackKey,
    required this.quantity,
    required this.qualityLabel,
    required this.scoreLabel,
  });

  final String stackKey;
  final int quantity;
  final String qualityLabel;
  final String scoreLabel;
}

final Provider<List<TownPotionSaleView>> townPotionSaleViewsProvider =
    Provider<List<TownPotionSaleView>>((Ref ref) {
      final Map<String, int> stacks = ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.workshop.craftedPotionStacks,
        ),
      );
      final Map<String, CraftedPotion> details = ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.workshop.craftedPotionDetails,
        ),
      );

      final List<TownPotionSaleView> views = stacks.entries.map((
        MapEntry<String, int> entry,
      ) {
        final CraftedPotion? detail = details[entry.key];
        return TownPotionSaleView(
          stackKey: entry.key,
          quantity: entry.value,
          qualityLabel: detail?.qualityGrade.name.toUpperCase() ?? '-',
          scoreLabel: (detail?.qualityScore ?? 0).toStringAsFixed(2),
        );
      }).toList();

      views.sort((TownPotionSaleView left, TownPotionSaleView right) {
        return left.stackKey.compareTo(right.stackKey);
      });
      return views;
    });
