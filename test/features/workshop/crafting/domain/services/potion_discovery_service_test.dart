import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/crafting/domain/services/potion_discovery_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const PotionDiscoveryService service = PotionDiscoveryService();

  test('recordDiscovery adds new potion recipe', () {
    final WorkshopState workshop = createInitialSessionState(
      DateTime(2026, 1, 1, 10),
    ).workshop;

    final WorkshopState updated = service.recordDiscovery(
      workshop: workshop,
      potionId: 'p_1',
      discoveredTraits: const <String, double>{'t_hp': 0.6, 't_atk': 0.4},
      grade: PotionQualityGrade.a,
    );

    final DiscoveredPotionRecipe? recipe =
        updated.discoveredPotionRecipes['p_1'];
    expect(recipe, isNotNull);
    expect(recipe!.potionId, 'p_1');
    expect(recipe.discoveredTraits['t_hp'], 0.6);
    expect(recipe.bestKnownGrade, PotionQualityGrade.a);
  });

  test('recordDiscovery keeps existing recipe when new grade is lower', () {
    final WorkshopState workshop =
        createInitialSessionState(DateTime(2026, 1, 1, 10)).workshop.copyWith(
          discoveredPotionRecipes: const <String, DiscoveredPotionRecipe>{
            'p_1': DiscoveredPotionRecipe(
              potionId: 'p_1',
              discoveredTraits: <String, double>{'t_hp': 0.6, 't_atk': 0.4},
              bestKnownGrade: PotionQualityGrade.a,
            ),
          },
        );

    final WorkshopState updated = service.recordDiscovery(
      workshop: workshop,
      potionId: 'p_1',
      discoveredTraits: const <String, double>{'t_hp': 0.2, 't_atk': 0.8},
      grade: PotionQualityGrade.c,
    );

    final DiscoveredPotionRecipe recipe =
        updated.discoveredPotionRecipes['p_1']!;
    expect(recipe.discoveredTraits['t_hp'], 0.6);
    expect(recipe.bestKnownGrade, PotionQualityGrade.a);
  });

  test('recordDiscovery replaces existing recipe when new grade is higher', () {
    final WorkshopState workshop =
        createInitialSessionState(DateTime(2026, 1, 1, 10)).workshop.copyWith(
          discoveredPotionRecipes: const <String, DiscoveredPotionRecipe>{
            'p_1': DiscoveredPotionRecipe(
              potionId: 'p_1',
              discoveredTraits: <String, double>{'t_hp': 0.2, 't_atk': 0.8},
              bestKnownGrade: PotionQualityGrade.c,
            ),
          },
        );

    final WorkshopState updated = service.recordDiscovery(
      workshop: workshop,
      potionId: 'p_1',
      discoveredTraits: const <String, double>{'t_hp': 0.6, 't_atk': 0.4},
      grade: PotionQualityGrade.s,
    );

    final DiscoveredPotionRecipe recipe =
        updated.discoveredPotionRecipes['p_1']!;
    expect(recipe.discoveredTraits['t_hp'], 0.6);
    expect(recipe.bestKnownGrade, PotionQualityGrade.s);
  });
}
