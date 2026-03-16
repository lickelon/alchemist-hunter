import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/town_catalog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<int> townGoldProvider = Provider<int>((Ref ref) {
  return ref.watch(
    sessionControllerProvider.select((SessionState state) => state.player.gold),
  );
});

final Provider<int> townInsightProvider = Provider<int>((Ref ref) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.player.townInsight,
    ),
  );
});

final Provider<int> townSkillNodeCountProvider = Provider<int>((Ref ref) {
  return ref.watch(
    townSkillNodesProvider.select((List<TownSkillNode> nodes) => nodes.length),
  );
});

final Provider<int> townUnlockedSkillNodeCountProvider = Provider<int>((
  Ref ref,
) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.town.skillTree.unlockedNodes.length,
    ),
  );
});
