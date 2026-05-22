import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_service_providers.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/services/potion_display_service.dart';
import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TownPotionSaleView {
  const TownPotionSaleView({
    required this.stackKey,
    required this.potionId,
    required this.name,
    required this.quantity,
    required this.qualityLabel,
    required this.scoreLabel,
    required this.saleValue,
  });

  final String stackKey;
  final String potionId;
  final String name;
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
      const PotionDisplayService displayService = PotionDisplayService();

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
          potionId: detail?.typePotionId ?? entry.key,
          name: displayService.potionName(
            stackKey: entry.key,
            detail: detail,
            potionCatalogRepository: potionRepository,
          ),
          quantity: entry.value,
          qualityLabel: detail?.qualityGrade.name.toUpperCase() ?? '-',
          scoreLabel: (detail?.qualityScore ?? 0).toStringAsFixed(2),
          saleValue: baseValue == null
              ? 0
              : (baseValue * qualityMultiplier * (1 + saleBonus)).round(),
        );
      }).toList();

      views.sort((TownPotionSaleView left, TownPotionSaleView right) {
        final int nameCompare = left.name.compareTo(right.name);
        if (nameCompare != 0) {
          return nameCompare;
        }
        return left.stackKey.compareTo(right.stackKey);
      });
      return views;
    });
