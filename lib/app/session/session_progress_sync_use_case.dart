import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_expedition_resolver.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_expedition_progress_service.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/shop_catalog_repository.dart';
import 'package:alchemist_hunter/features/town/domain/services/economy_service.dart';
import 'package:alchemist_hunter/features/town/domain/services/forge_queue_progress_service.dart';
import 'package:alchemist_hunter/features/town/domain/use_cases/town_use_case.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_queue_progress_service.dart';

class SessionProgressSyncUseCase {
  const SessionProgressSyncUseCase({
    this.offlineCap = const Duration(hours: 8),
    this.battleCycle = const Duration(seconds: 60),
    BattleExpeditionProgressService battleExpeditionProgressService =
        const BattleExpeditionProgressService(),
    WorkshopQueueProgressService workshopQueueProgressService =
        const WorkshopQueueProgressService(),
    ForgeQueueProgressService forgeQueueProgressService =
        const ForgeQueueProgressService(),
  }) : _battleExpeditionProgressService = battleExpeditionProgressService,
       _workshopQueueProgressService = workshopQueueProgressService,
       _forgeQueueProgressService = forgeQueueProgressService;

  final Duration offlineCap;
  final Duration battleCycle;
  final BattleExpeditionProgressService _battleExpeditionProgressService;
  final WorkshopQueueProgressService _workshopQueueProgressService;
  final ForgeQueueProgressService _forgeQueueProgressService;

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
    return state.copyWith(
      battle: _battleExpeditionProgressService.syncExpeditions(
        state: state,
        syncFrom: syncFrom,
        now: now,
        speedMultiplier: speedMultiplier,
        battleCycle: battleCycle,
        battleExpeditionResolver: battleExpeditionResolver,
        battleCatalogRepository: battleCatalogRepository,
      ),
    );
  }

  SessionState _syncWorkshopQueue({
    required SessionState state,
    required DateTime syncFrom,
    required DateTime now,
    required double speedMultiplier,
  }) {
    return state.copyWith(
      workshop: _workshopQueueProgressService.syncQueue(
        workshop: state.workshop,
        syncFrom: syncFrom,
        now: now,
        speedMultiplier: speedMultiplier,
      ),
    );
  }

  SessionState _syncForgeQueue({
    required SessionState state,
    required DateTime syncFrom,
    required DateTime now,
    required double speedMultiplier,
  }) {
    return state.copyWith(
      town: _forgeQueueProgressService.syncQueue(
        town: state.town,
        syncFrom: syncFrom,
        now: now,
        speedMultiplier: speedMultiplier,
      ),
    );
  }
}
