import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/workshop_catalog.dart';

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

final Provider<int> workshopUnlockedSkillNodeCountProvider =
    Provider<int>((Ref ref) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.workshop.skillTree.unlockedNodes.length,
        ),
      );
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
