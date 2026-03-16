import 'dart:math';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/app/session/session_progress_sync_use_case.dart';
import 'package:alchemist_hunter/features/battle/data/repositories/static_battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_expedition_resolver.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_service.dart';
import 'package:alchemist_hunter/features/town/data/repositories/static_shop_catalog_repository.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/services/economy_service.dart';
import 'package:alchemist_hunter/features/town/domain/use_cases/town_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('time acceleration shortens battle expedition cycle progress', () {
    final DateTime start = DateTime(2026, 1, 1, 10);
    final SessionState initial = createInitialSessionState(start);
    final SessionState state = initial.copyWith(
      player: initial.player.copyWith(timeAcceleration: 30),
      battle: initial.battle.copyWith(
        stageExpeditions: <String, BattleExpeditionState>{
          'stage_1': BattleExpeditionState(
            status: BattleExpeditionStatus.running,
            lastResolvedAt: start,
            cycleProgress: Duration.zero,
          ),
        },
      ),
    );

    final SessionState nextState = const SessionProgressSyncUseCase().sync(
      state: state,
      now: start.add(const Duration(seconds: 2)),
      townUseCase: const TownUseCase(),
      economyService: EconomyService(),
      shopCatalogRepository: const StaticShopCatalogRepository(),
      battleExpeditionResolver: DefaultBattleExpeditionResolver(
        battleService: BattleService(random: Random(11)),
      ),
      battleCatalogRepository: const StaticBattleCatalogRepository(),
    );

    final BattlePendingClaim claim =
        nextState.battle.stageExpeditions['stage_1']!.pendingClaim;
    expect(
      claim.gold > 0 || claim.essence > 0 || claim.materials.isNotEmpty,
      true,
    );
  });

  test('time acceleration shortens forge completion time', () {
    final DateTime start = DateTime(2026, 1, 1, 10);
    final SessionState initial = createInitialSessionState(start);
    final SessionState state = initial.copyWith(
      player: initial.player.copyWith(timeAcceleration: 2),
      town: initial.town.copyWith(
        forgeQueue: <TownForgeJob>[
          TownForgeJob(
            id: 'forge_1',
            blueprintId: 'eq_1',
            name: 'Bronze Sword',
            status: TownForgeJobStatus.processing,
            queuedAt: start,
            startedAt: start,
            remaining: const Duration(seconds: 30),
            duration: const Duration(seconds: 30),
            reservedMaterials: const <String, int>{'m_1': 2},
            resultEquipment: EquipmentInstance(
              id: 'eq_1_instance',
              blueprintId: 'eq_1',
              name: 'Bronze Sword',
              slot: EquipmentSlot.weapon,
              attack: 12,
              defense: 0,
              health: 0,
              createdAt: start,
            ),
          ),
        ],
      ),
    );

    final SessionState nextState = const SessionProgressSyncUseCase().sync(
      state: state,
      now: start.add(const Duration(seconds: 15)),
      townUseCase: const TownUseCase(),
      economyService: EconomyService(),
      shopCatalogRepository: const StaticShopCatalogRepository(),
      battleExpeditionResolver: DefaultBattleExpeditionResolver(
        battleService: BattleService(random: Random(11)),
      ),
      battleCatalogRepository: const StaticBattleCatalogRepository(),
    );

    expect(nextState.town.forgeQueue.first.status, TownForgeJobStatus.completed);
    expect(nextState.town.equipmentInventory, isEmpty);
  });
}
