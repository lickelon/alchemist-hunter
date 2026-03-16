import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_service_providers.dart';
import 'package:alchemist_hunter/features/town/town_catalog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TownEquipmentBlueprintView {
  const TownEquipmentBlueprintView({
    required this.id,
    required this.name,
    required this.slotLabel,
    required this.statLabel,
    required this.materialCostLabel,
    required this.durationLabel,
    required this.canCraft,
  });

  final String id;
  final String name;
  final String slotLabel;
  final String statLabel;
  final String materialCostLabel;
  final String durationLabel;
  final bool canCraft;
}

class TownEquipmentInventoryView {
  const TownEquipmentInventoryView({
    required this.id,
    required this.name,
    required this.slotLabel,
    required this.statLabel,
  });

  final String id;
  final String name;
  final String slotLabel;
  final String statLabel;
}

class TownForgeJobView {
  const TownForgeJobView({
    required this.id,
    required this.name,
    required this.statusLabel,
    required this.remainingLabel,
    required this.canClaim,
  });

  final String id;
  final String name;
  final String statusLabel;
  final String remainingLabel;
  final bool canClaim;
}

final Provider<List<EquipmentInstance>> townEquipmentInventoryProvider =
    Provider<List<EquipmentInstance>>((Ref ref) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.town.equipmentInventory,
        ),
      );
    });

final Provider<int> townEquipmentCountProvider = Provider<int>((Ref ref) {
  return ref.watch(
    townEquipmentInventoryProvider.select(
      (List<EquipmentInstance> inventory) => inventory.length,
    ),
  );
});

final Provider<List<TownForgeJob>> townForgeQueueProvider =
    Provider<List<TownForgeJob>>((Ref ref) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.town.forgeQueue,
        ),
      );
    });

final Provider<int> townForgeInProgressCountProvider = Provider<int>((Ref ref) {
  return ref.watch(
    townForgeQueueProvider.select(
      (List<TownForgeJob> jobs) => jobs
          .where(
            (TownForgeJob job) => job.status != TownForgeJobStatus.completed,
          )
          .length,
    ),
  );
});

final Provider<int> townForgeCompletedCountProvider = Provider<int>((Ref ref) {
  return ref.watch(
    townForgeQueueProvider.select(
      (List<TownForgeJob> jobs) => jobs
          .where(
            (TownForgeJob job) => job.status == TownForgeJobStatus.completed,
          )
          .length,
    ),
  );
});

final Provider<List<TownEquipmentBlueprintView>>
townEquipmentBlueprintViewsProvider = Provider<List<TownEquipmentBlueprintView>>((
  Ref ref,
) {
  final SessionState state = ref.watch(sessionControllerProvider);
  final List<EquipmentBlueprint> blueprints = ref.watch(
    townEquipmentBlueprintsProvider,
  );
  final Map<String, String> materialNames = ref.watch(
    townEquipmentMaterialNamesProvider,
  );
  final service = ref.watch(townSkillTreeServiceProvider);
  final Map<String, int> inventory = state.player.materialInventory;
  final List<TownSkillNode> nodes = ref.watch(townSkillNodesProvider);

  return blueprints
      .map((EquipmentBlueprint blueprint) {
        final Map<String, int> adjustedCosts = service.adjustedMaterialCosts(
          baseCosts: blueprint.materialCosts,
          efficiencyRate: service.equipmentCraftEfficiencyRate(state, nodes),
        );
        final bool canCraft = adjustedCosts.entries.every(
          (MapEntry<String, int> entry) =>
              (inventory[entry.key] ?? 0) >= entry.value,
        );
        return TownEquipmentBlueprintView(
          id: blueprint.id,
          name: blueprint.name,
          slotLabel: blueprint.slot.name,
          statLabel:
              'ATK ${blueprint.attack} / DEF ${blueprint.defense} / HP ${blueprint.health}',
          materialCostLabel: adjustedCosts.entries
              .map(
                (MapEntry<String, int> entry) =>
                    '${materialNames[entry.key] ?? entry.key} x${entry.value}',
              )
              .join(', '),
          durationLabel: '${blueprint.craftDuration.inSeconds}s',
          canCraft: canCraft,
        );
      })
      .toList(growable: false);
});

final Provider<List<TownEquipmentInventoryView>>
townEquipmentInventoryViewsProvider = Provider<List<TownEquipmentInventoryView>>((
  Ref ref,
) {
  final List<EquipmentInstance> inventory = ref.watch(
    townEquipmentInventoryProvider,
  );
  return inventory
      .map((EquipmentInstance entry) {
        final String baseLabel =
            'ATK ${entry.totalAttack} / DEF ${entry.totalDefense} / HP ${entry.totalHealth}';
        return TownEquipmentInventoryView(
          id: entry.id,
          name: entry.name,
          slotLabel: entry.slot.name,
          statLabel: entry.enchant == null
              ? baseLabel
              : '$baseLabel / ${entry.enchant!.label}',
        );
      })
      .toList(growable: false);
});

final Provider<List<TownForgeJobView>> townForgeJobViewsProvider =
    Provider<List<TownForgeJobView>>((Ref ref) {
      final List<TownForgeJob> jobs = ref.watch(townForgeQueueProvider);
      final List<TownForgeJob> sorted = <TownForgeJob>[...jobs]
        ..sort((TownForgeJob left, TownForgeJob right) {
          if (left.status == right.status) {
            return left.queuedAt.compareTo(right.queuedAt);
          }
          return left.status == TownForgeJobStatus.completed ? 1 : -1;
        });
      return sorted
          .map((TownForgeJob job) {
            final bool completed = job.status == TownForgeJobStatus.completed;
            return TownForgeJobView(
              id: job.id,
              name: job.name,
              statusLabel: completed
                  ? '완료'
                  : job.status == TownForgeJobStatus.processing
                  ? '제작 중'
                  : '대기 중',
              remainingLabel: completed
                  ? '수령 대기'
                  : '남은 시간 ${job.remaining.inSeconds}s',
              canClaim: completed,
            );
          })
          .toList(growable: false);
    });
