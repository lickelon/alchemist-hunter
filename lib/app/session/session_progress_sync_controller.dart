import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/app/session/session_progress_sync_use_case.dart';
import 'package:alchemist_hunter/features/battle/battle_catalog.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_expedition_resolver.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_service.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/shop_catalog_repository.dart';
import 'package:alchemist_hunter/features/town/domain/services/economy_service.dart';
import 'package:alchemist_hunter/features/town/domain/use_cases/town_use_case.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_service_providers.dart';
import 'package:alchemist_hunter/features/town/town_catalog.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

final Provider<BattleExpeditionResolver> battleExpeditionResolverProvider =
    Provider<BattleExpeditionResolver>((Ref ref) {
      return DefaultBattleExpeditionResolver(
        battleService: BattleService(random: Random(11)),
      );
    });

final Provider<SessionProgressSyncUseCase> sessionProgressSyncUseCaseProvider =
    Provider<SessionProgressSyncUseCase>((Ref ref) {
      return const SessionProgressSyncUseCase();
    });

class SessionProgressSyncController {
  SessionProgressSyncController(
    this._session, {
    required SessionProgressSyncUseCase syncUseCase,
    required TownUseCase townUseCase,
    required EconomyService economyService,
    required ShopCatalogRepository shopCatalogRepository,
    required BattleExpeditionResolver battleExpeditionResolver,
    required BattleCatalogRepository battleCatalogRepository,
  }) : _syncUseCase = syncUseCase,
       _townUseCase = townUseCase,
       _economyService = economyService,
       _shopCatalogRepository = shopCatalogRepository,
       _battleExpeditionResolver = battleExpeditionResolver,
       _battleCatalogRepository = battleCatalogRepository;

  final SessionController _session;
  final SessionProgressSyncUseCase _syncUseCase;
  final TownUseCase _townUseCase;
  final EconomyService _economyService;
  final ShopCatalogRepository _shopCatalogRepository;
  final BattleExpeditionResolver _battleExpeditionResolver;
  final BattleCatalogRepository _battleCatalogRepository;

  void sync() {
    final SessionState current = _session.snapshot();
    final SessionState nextState = _syncUseCase.sync(
      state: current,
      now: _session.now(),
      townUseCase: _townUseCase,
      economyService: _economyService,
      shopCatalogRepository: _shopCatalogRepository,
      battleExpeditionResolver: _battleExpeditionResolver,
      battleCatalogRepository: _battleCatalogRepository,
    );
    _session.applyState(nextState);
    _appendDeltaLogs(current, nextState);
  }

  void _appendDeltaLogs(SessionState previous, SessionState next) {
    previous.battle.stageExpeditions.forEach((
      String stageId,
      BattleExpeditionState expedition,
    ) {
      final BattleExpeditionState? nextExpedition = next.battle.stageExpeditions[stageId];
      if (nextExpedition == null) {
        return;
      }
      if (expedition.pendingClaim.isEmpty && !nextExpedition.pendingClaim.isEmpty) {
        _session.appendLog('${stageId.replaceFirst('stage_', 'Stage ')} 보상 적재');
      }
    });

    final int previousCompleted = previous.workshop.queue
        .where((CraftQueueJob job) => job.status == QueueJobStatus.completed)
        .length;
    final int nextCompleted = next.workshop.queue
        .where((CraftQueueJob job) => job.status == QueueJobStatus.completed)
        .length;
    if (nextCompleted > previousCompleted) {
      _session.appendLog('작업실 완료 ${nextCompleted - previousCompleted}건');
    }

    final int previousForgeCompleted = previous.town.forgeQueue
        .where((TownForgeJob job) => job.status == TownForgeJobStatus.completed)
        .length;
    final int nextForgeCompleted = next.town.forgeQueue
        .where((TownForgeJob job) => job.status == TownForgeJobStatus.completed)
        .length;
    if (nextForgeCompleted > previousForgeCompleted) {
      _session.appendLog('대장간 완료 ${nextForgeCompleted - previousForgeCompleted}건');
    }
  }
}

final Provider<SessionProgressSyncController>
sessionProgressSyncControllerProvider = Provider<SessionProgressSyncController>((
  Ref ref,
) {
  return SessionProgressSyncController(
    ref.read(sessionControllerProvider.notifier),
    syncUseCase: ref.read(sessionProgressSyncUseCaseProvider),
    townUseCase: const TownUseCase(),
    economyService: ref.read(economyServiceProvider),
    shopCatalogRepository: ref.read(shopCatalogRepositoryProvider),
    battleExpeditionResolver: ref.read(battleExpeditionResolverProvider),
    battleCatalogRepository: ref.read(battleCatalogRepositoryProvider),
  );
});
