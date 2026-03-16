import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_expedition_resolver.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/shop_catalog_repository.dart';
import 'package:alchemist_hunter/features/town/domain/services/economy_service.dart';
import 'package:alchemist_hunter/features/town/domain/use_cases/town_use_case.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

class SessionProgressSyncUseCase {
  const SessionProgressSyncUseCase({
    this.offlineCap = const Duration(hours: 8),
    this.battleCycle = const Duration(seconds: 60),
  });

  final Duration offlineCap;
  final Duration battleCycle;

  SessionState sync({
    required SessionState state,
    required DateTime now,
    required TownUseCase townUseCase,
    required EconomyService economyService,
    required ShopCatalogRepository shopCatalogRepository,
    required BattleExpeditionResolver battleExpeditionResolver,
    required BattleCatalogRepository battleCatalogRepository,
  }) {
    if (!now.isAfter(state.lastSyncAt)) {
      return state.copyWith(lastSyncAt: now);
    }

    final DateTime syncFrom = _syncFrom(state.lastSyncAt, now);
    final double speedMultiplier = state.player.timeAcceleration;

    SessionState nextState = townUseCase.syncShops(
      state: state,
      now: now,
      economy: economyService,
      shopCatalogRepository: shopCatalogRepository,
    );
    nextState = _syncBattleExpeditions(
      state: nextState,
      syncFrom: syncFrom,
      now: now,
      speedMultiplier: speedMultiplier,
      battleExpeditionResolver: battleExpeditionResolver,
      battleCatalogRepository: battleCatalogRepository,
    );
    nextState = _syncWorkshopQueue(
      state: nextState,
      syncFrom: syncFrom,
      now: now,
      speedMultiplier: speedMultiplier,
    );
    nextState = _syncForgeQueue(
      state: nextState,
      syncFrom: syncFrom,
      now: now,
      speedMultiplier: speedMultiplier,
    );
    return nextState.copyWith(lastSyncAt: now);
  }

  DateTime _syncFrom(DateTime previous, DateTime now) {
    final DateTime minTime = now.subtract(offlineCap);
    if (previous.isBefore(minTime)) {
      return minTime;
    }
    return previous;
  }

  SessionState _syncBattleExpeditions({
    required SessionState state,
    required DateTime syncFrom,
    required DateTime now,
    required double speedMultiplier,
    required BattleExpeditionResolver battleExpeditionResolver,
    required BattleCatalogRepository battleCatalogRepository,
  }) {
    if (state.battle.stageExpeditions.isEmpty) {
      return state;
    }

    final Map<String, BattleExpeditionState> nextExpeditions =
        <String, BattleExpeditionState>{...state.battle.stageExpeditions};

    state.battle.stageExpeditions.forEach((
      String stageId,
      BattleExpeditionState expedition,
    ) {
      if (expedition.status != BattleExpeditionStatus.running) {
        return;
      }

      final DateTime baseTime = _laterOf(
        syncFrom,
        expedition.lastResolvedAt ?? syncFrom,
      );
      if (!now.isAfter(baseTime)) {
        nextExpeditions[stageId] = expedition.copyWith(lastResolvedAt: now);
        return;
      }

      final Duration totalElapsed =
          expedition.cycleProgress +
          _scaledDuration(now.difference(baseTime), speedMultiplier);
      final int cycleCount = totalElapsed.inSeconds ~/ battleCycle.inSeconds;
      final Duration nextProgress = Duration(
        seconds: totalElapsed.inSeconds % battleCycle.inSeconds,
      );

      BattlePendingClaim pendingClaim = expedition.pendingClaim;
      String summary = expedition.lastSummary;
      for (int index = 0; index < cycleCount; index++) {
        final BattleCycleResolution resolution = battleExpeditionResolver
            .resolveCycle(
              state: state,
              stageId: stageId,
              battleCatalogRepository: battleCatalogRepository,
            );
        pendingClaim = _mergeBattlePendingClaim(
          pendingClaim,
          resolution.pendingClaim,
        );
        summary = resolution.summary;
      }

      nextExpeditions[stageId] = expedition.copyWith(
        lastResolvedAt: now,
        cycleProgress: nextProgress,
        pendingClaim: pendingClaim,
        lastSummary: summary,
      );
    });

    return state.copyWith(
      battle: state.battle.copyWith(stageExpeditions: nextExpeditions),
    );
  }

  BattlePendingClaim _mergeBattlePendingClaim(
    BattlePendingClaim left,
    BattlePendingClaim right,
  ) {
    final Map<String, int> mergedMaterials = <String, int>{...left.materials};
    right.materials.forEach((String key, int value) {
      mergedMaterials[key] = (mergedMaterials[key] ?? 0) + value;
    });
    final Map<String, int> mergedXp = <String, int>{...left.characterXp};
    right.characterXp.forEach((String key, int value) {
      mergedXp[key] = (mergedXp[key] ?? 0) + value;
    });
    return BattlePendingClaim(
      materials: mergedMaterials,
      gold: left.gold + right.gold,
      essence: left.essence + right.essence,
      characterXp: mergedXp,
    );
  }

  SessionState _syncWorkshopQueue({
    required SessionState state,
    required DateTime syncFrom,
    required DateTime now,
    required double speedMultiplier,
  }) {
    if (state.workshop.queue.isEmpty) {
      return state;
    }

    final List<CraftQueueJob> nextQueue = <CraftQueueJob>[];
    WorkshopPendingClaim pendingClaim = state.workshop.pendingClaim;
    DateTime cursor = syncFrom;

    for (final CraftQueueJob job in state.workshop.queue) {
      if (job.status == QueueJobStatus.blocked) {
        nextQueue.add(job);
        continue;
      }

      if (job.status == QueueJobStatus.completed) {
        pendingClaim = _appendWorkshopPendingClaim(pendingClaim, job);
        continue;
      }

      final DateTime startTime = _laterOf(
        cursor,
        job.startedAt ?? job.queuedAt,
      );
      if (!now.isAfter(startTime)) {
        nextQueue.add(
          job.copyWith(
            status: job.startedAt == null
                ? QueueJobStatus.queued
                : QueueJobStatus.processing,
          ),
        );
        continue;
      }

      final Duration available = _scaledDuration(
        now.difference(startTime),
        speedMultiplier,
      );
      if (job.eta > available) {
        nextQueue.add(
          job.copyWith(
            status: QueueJobStatus.processing,
            startedAt: job.startedAt ?? startTime,
            eta: job.eta - available,
          ),
        );
        cursor = now;
        continue;
      }

      pendingClaim = _appendWorkshopPendingClaim(pendingClaim, job);
      cursor = startTime.add(job.eta);
    }

    return state.copyWith(
      workshop: state.workshop.copyWith(
        queue: nextQueue,
        pendingClaim: pendingClaim,
      ),
    );
  }

  WorkshopPendingClaim _appendWorkshopPendingClaim(
    WorkshopPendingClaim pendingClaim,
    CraftQueueJob job,
  ) {
    switch (job.type) {
      case WorkshopJobType.extraction:
        final Map<String, double> nextTraits = <String, double>{
          ...pendingClaim.extractedTraits,
        };
        job.completedExtractedTraits.forEach((String key, double value) {
          nextTraits[key] = (nextTraits[key] ?? 0) + value;
        });
        return pendingClaim.copyWith(
          extractedTraits: nextTraits,
          arcaneDust: pendingClaim.arcaneDust + job.completedArcaneDust,
          extractionCount: pendingClaim.extractionCount + job.quantity,
        );
      case WorkshopJobType.craft:
        if (job.completedPotionStackKey == null || job.completedPotion == null) {
          return pendingClaim;
        }
        final Map<String, int> nextStacks = <String, int>{
          ...pendingClaim.potionStacks,
        };
        nextStacks[job.completedPotionStackKey!] =
            (nextStacks[job.completedPotionStackKey!] ?? 0) + job.repeatCount;
        final Map<String, CraftedPotion> nextDetails =
            <String, CraftedPotion>{...pendingClaim.potionDetails};
        nextDetails.putIfAbsent(
          job.completedPotionStackKey!,
          () => job.completedPotion!,
        );
        return pendingClaim.copyWith(
          potionStacks: nextStacks,
          potionDetails: nextDetails,
          potionCraftCount: pendingClaim.potionCraftCount + job.repeatCount,
        );
      case WorkshopJobType.enchant:
        if (job.completedEquipment == null) {
          return pendingClaim;
        }
        return pendingClaim.copyWith(
          equipmentClaims: <WorkshopEquipmentClaim>[
            ...pendingClaim.equipmentClaims,
            WorkshopEquipmentClaim(
              equipment: job.completedEquipment!,
              ownerCharacterId: job.equipmentOwnerId,
              ownerType: job.equipmentOwnerType,
            ),
          ],
          enchantCount: pendingClaim.enchantCount + 1,
        );
      case WorkshopJobType.hatch:
        if (job.completedHomunculus == null) {
          return pendingClaim;
        }
        return pendingClaim.copyWith(
          homunculi: <CharacterProgress>[
            ...pendingClaim.homunculi,
            job.completedHomunculus!,
          ],
        );
    }
  }

  SessionState _syncForgeQueue({
    required SessionState state,
    required DateTime syncFrom,
    required DateTime now,
    required double speedMultiplier,
  }) {
    if (state.town.forgeQueue.isEmpty) {
      return state;
    }

    final List<TownForgeJob> nextQueue = <TownForgeJob>[];
    DateTime cursor = syncFrom;

    for (final TownForgeJob job in state.town.forgeQueue) {
      if (job.status == TownForgeJobStatus.completed) {
        nextQueue.add(job);
        continue;
      }

      final DateTime startTime = _laterOf(
        cursor,
        job.startedAt ?? job.queuedAt,
      );
      if (!now.isAfter(startTime)) {
        nextQueue.add(
          job.copyWith(
            status: job.startedAt == null
                ? TownForgeJobStatus.queued
                : TownForgeJobStatus.processing,
          ),
        );
        continue;
      }

      final Duration available = _scaledDuration(
        now.difference(startTime),
        speedMultiplier,
      );
      if (job.remaining > available) {
        nextQueue.add(
          job.copyWith(
            status: TownForgeJobStatus.processing,
            startedAt: job.startedAt ?? startTime,
            remaining: job.remaining - available,
          ),
        );
        cursor = now;
        continue;
      }

      nextQueue.add(
        job.copyWith(
          status: TownForgeJobStatus.completed,
          startedAt: job.startedAt ?? startTime,
          remaining: Duration.zero,
        ),
      );
      cursor = startTime.add(job.remaining);
    }

    return state.copyWith(town: state.town.copyWith(forgeQueue: nextQueue));
  }

  DateTime _laterOf(DateTime left, DateTime right) {
    return left.isAfter(right) ? left : right;
  }

  Duration _scaledDuration(Duration source, double multiplier) {
    if (multiplier <= 1) {
      return source;
    }
    return Duration(
      microseconds: (source.inMicroseconds * multiplier).round(),
    );
  }
}
