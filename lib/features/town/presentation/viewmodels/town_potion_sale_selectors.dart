import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_service_providers.dart';
import 'package:alchemist_hunter/features/town/town_catalog.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/workshop_catalog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TownPotionSaleView {
  const TownPotionSaleView({
    required this.stackKey,
    required this.quantity,
    required this.qualityLabel,
    required this.scoreLabel,
    required this.saleValue,
  });

  final String stackKey;
  final int quantity;
  final String qualityLabel;
  final String scoreLabel;
  final int saleValue;
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
      final SessionState state = ref.watch(sessionControllerProvider);
      final skillService = ref.watch(townSkillTreeServiceProvider);
      final saleBonus = skillService.potionSaleBonusRate(
        state,
        ref.watch(townSkillNodesProvider),
      );
      final potionRepository = ref.watch(potionCatalogRepositoryProvider);

      final List<TownPotionSaleView> views = stacks.entries.map((
        MapEntry<String, int> entry,
      ) {
        final CraftedPotion? detail = details[entry.key];
        final int? baseValue = detail == null
            ? null
            : potionRepository.findPotionById(detail.typePotionId)?.baseValue;
        final double qualityMultiplier = switch (detail?.qualityGrade) {
          PotionQualityGrade.s => 1.6,
          PotionQualityGrade.a => 1.3,
          PotionQualityGrade.b => 1.0,
          PotionQualityGrade.c => 0.8,
          null => 0,
        };
        return TownPotionSaleView(
          stackKey: entry.key,
          quantity: entry.value,
          qualityLabel: detail?.qualityGrade.name.toUpperCase() ?? '-',
          scoreLabel: (detail?.qualityScore ?? 0).toStringAsFixed(2),
          saleValue: baseValue == null
              ? 0
              : (baseValue * qualityMultiplier * (1 + saleBonus)).round(),
        );
      }).toList();

      views.sort((TownPotionSaleView left, TownPotionSaleView right) {
        return left.stackKey.compareTo(right.stackKey);
      });
      return views;
    });
