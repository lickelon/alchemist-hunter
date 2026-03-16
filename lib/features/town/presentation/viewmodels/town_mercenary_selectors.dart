import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_service_providers.dart';
import 'package:alchemist_hunter/features/town/town_catalog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TownMercenaryCandidateView {
  const TownMercenaryCandidateView({
    required this.id,
    required this.name,
    required this.roleLabel,
    required this.tierLabel,
    required this.hireCost,
    required this.canHire,
  });

  final String id;
  final String name;
  final String roleLabel;
  final String tierLabel;
  final int hireCost;
  final bool canHire;

  String get hireHint => canHire ? '' : ' / 골드 부족';
}

final Provider<int> townMercenaryCandidateCountProvider = Provider<int>((
  Ref ref,
) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.town.mercenaryCandidates.length,
    ),
  );
});

final Provider<int> townMercenaryCountProvider = Provider<int>((Ref ref) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.characters.mercenaries.length,
    ),
  );
});

final Provider<List<TownMercenaryCandidateView>>
townMercenaryCandidateViewsProvider =
    Provider<List<TownMercenaryCandidateView>>((Ref ref) {
      final SessionState state = ref.watch(sessionControllerProvider);
      final service = ref.watch(townSkillTreeServiceProvider);
      final List<TownSkillNode> nodes = ref.watch(townSkillNodesProvider);
      return state.town.mercenaryCandidates
          .map((MercenaryCandidate entry) {
            final int hireCost = service.discountedGoldCost(
              baseCost: entry.hireCost,
              discountRate: service.mercenaryHireDiscountRate(state, nodes),
            );
            return TownMercenaryCandidateView(
              id: entry.id,
              name: entry.name,
              roleLabel: entry.roleLabel,
              tierLabel: entry.tierLabel,
              hireCost: hireCost,
              canHire: state.player.gold >= hireCost,
            );
          })
          .toList(growable: false);
    });
