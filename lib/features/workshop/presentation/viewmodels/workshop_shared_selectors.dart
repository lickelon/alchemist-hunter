import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/workshop_catalog.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/workshop_service_providers.dart';

final Provider<int> workshopEssenceProvider = Provider<int>((Ref ref) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.player.essence,
    ),
  );
});

final Provider<int> workshopArcaneDustProvider = Provider<int>((Ref ref) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.player.arcaneDust,
    ),
  );
});

final Provider<int> workshopSkillNodeCountProvider = Provider<int>((Ref ref) {
  return ref.watch(
    workshopSkillNodesProvider.select(
      (List<WorkshopSkillNode> nodes) => nodes.length,
    ),
  );
});

final Provider<int> workshopUnlockedSkillNodeCountProvider = Provider<int>((
  Ref ref,
) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.workshop.skillTree.unlockedNodes.length,
    ),
  );
});

final Provider<int> workshopQueueCapacityProvider = Provider<int>((Ref ref) {
  final SessionState state = ref.watch(sessionControllerProvider);
  return ref
      .watch(workshopSkillTreeServiceProvider)
      .craftQueueCapacity(state, ref.watch(workshopSkillNodesProvider)) +
      ref.watch(workshopSupportServiceProvider).craftQueueCapacityBonus(state);
});

final Provider<double> workshopExtractionYieldBonusRateProvider =
    Provider<double>((Ref ref) {
      final SessionState state = ref.watch(sessionControllerProvider);
      return ref
              .watch(workshopSkillTreeServiceProvider)
              .extractionYieldBonusRate(state, ref.watch(workshopSkillNodesProvider)) +
          ref.watch(workshopSupportServiceProvider).extractionYieldBonusRate(state);
    });

final Provider<double> workshopEnchantPotencyBonusRateProvider =
    Provider<double>((Ref ref) {
      final SessionState state = ref.watch(sessionControllerProvider);
      return ref
              .watch(workshopSkillTreeServiceProvider)
              .enchantPotencyBonusRate(state, ref.watch(workshopSkillNodesProvider)) +
          ref.watch(workshopSupportServiceProvider).enchantPotencyBonusRate(state);
    });

final Provider<List<String>> recentLogsProvider = Provider<List<String>>((
  Ref ref,
) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.workshop.logs,
    ),
  );
});
