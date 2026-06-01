import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_assignment_view_models.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final battleStagePotionLoadoutProvider =
    Provider.family<Map<String, int>, String>((Ref ref, String stageId) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) =>
              state.battle.stagePotionLoadouts[stageId] ??
              const <String, int>{},
        ),
      );
    });

final battleStageAssignmentPotionViewsProvider =
    Provider.family<List<BattleAssignmentPotionView>, String>((
      Ref ref,
      String stageId,
    ) {
      final SessionState state = ref.watch(sessionControllerProvider);
      final Map<String, int> selectedCounts = ref.watch(
        battleStagePotionLoadoutProvider(stageId),
      );
      final List<PotionBlueprint> potions = ref.watch(potionsProvider);

      final List<BattleAssignmentPotionView> views = state
          .workshop
          .craftedPotionStacks
          .entries
          .where((MapEntry<String, int> entry) => entry.value > 0)
          .map((MapEntry<String, int> entry) {
            final CraftedPotion? detail =
                state.workshop.craftedPotionDetails[entry.key];
            if (detail == null) {
              return null;
            }
            final PotionBlueprint? potion = potions
                .where((PotionBlueprint item) => item.id == detail.typePotionId)
                .firstOrNull;
            if (potion == null || potion.useType == PotionUseType.sell) {
              return null;
            }
            final String qualityLabel = detail.qualityGrade.name.toUpperCase();
            return BattleAssignmentPotionView(
              stackKey: entry.key,
              potionId: potion.id,
              label: '${potion.name} $qualityLabel',
              ownedCount: entry.value,
              selectedCount: selectedCounts[entry.key] ?? 0,
            );
          })
          .whereType<BattleAssignmentPotionView>()
          .toList(growable: false);

      views.sort((
        BattleAssignmentPotionView left,
        BattleAssignmentPotionView right,
      ) {
        return left.label.compareTo(right.label);
      });
      return views;
    });
