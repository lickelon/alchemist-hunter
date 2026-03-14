import 'package:alchemist_hunter/core/session/session_providers.dart';
import 'package:alchemist_hunter/features/town/data/catalogs/equipment_blueprints.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/services/economy_service.dart';
import 'package:alchemist_hunter/features/town/domain/use_cases/craft_equipment_use_case.dart';
import 'package:alchemist_hunter/features/town/domain/use_cases/town_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<EconomyService> economyServiceProvider =
    Provider<EconomyService>((Ref ref) => EconomyService());

class TownController {
  TownController(
    this._session,
    this._economy, {
    TownUseCase townDomain = const TownUseCase(),
    CraftEquipmentUseCase craftEquipmentUseCase = const CraftEquipmentUseCase(),
  }) : _townDomain = townDomain,
       _craftEquipmentUseCase = craftEquipmentUseCase;

  final SessionController _session;
  final EconomyService _economy;
  final TownUseCase _townDomain;
  final CraftEquipmentUseCase _craftEquipmentUseCase;

  void buyGeneralMaterial(String materialId, int quantity) {
    _syncShops();
    final SessionState current = _session.snapshot();
    final SessionState nextState = _townDomain.buyMaterial(
      state: current,
      shopType: ShopType.general,
      materialId: materialId,
      quantity: quantity,
      economy: _economy,
    );
    _apply(
      nextState,
      logMessage: identical(nextState, current)
          ? 'Purchase failed for $materialId'
          : 'Bought $quantity of $materialId (${ShopType.general.name})',
    );
  }

  void buyCatalystMaterial(String materialId, int quantity) {
    _syncShops();
    final SessionState current = _session.snapshot();
    final SessionState nextState = _townDomain.buyMaterial(
      state: current,
      shopType: ShopType.catalyst,
      materialId: materialId,
      quantity: quantity,
      economy: _economy,
    );
    _apply(
      nextState,
      logMessage: identical(nextState, current)
          ? 'Purchase failed for $materialId'
          : 'Bought $quantity of $materialId (${ShopType.catalyst.name})',
    );
  }

  void forceRefresh(ShopType shopType) {
    _syncShops();
    final SessionState current = _session.snapshot();
    final SessionState nextState = _townDomain.forceRefresh(
      state: current,
      shopType: shopType,
      now: _session.now(),
      economy: _economy,
    );
    _apply(
      nextState,
      logMessage: identical(nextState, current)
          ? 'Not enough gold for refresh'
          : 'Forced refresh ${shopType.name} shop',
    );
  }

  void syncShopAutoRefresh() {
    _syncShops();
  }

  void craftEquipment(String blueprintId) {
    final SessionState current = _session.snapshot();
    EquipmentBlueprint? blueprint;
    for (final EquipmentBlueprint entry in townEquipmentBlueprints) {
      if (entry.id == blueprintId) {
        blueprint = entry;
        break;
      }
    }
    if (blueprint == null) {
      _session.appendLog('Equipment blueprint missing: $blueprintId');
      return;
    }

    final SessionState nextState = _craftEquipmentUseCase.craftEquipment(
      state: current,
      blueprint: blueprint,
      now: _session.now(),
    );
    _apply(
      nextState,
      logMessage: identical(nextState, current)
          ? 'Not enough gold for ${blueprint.name}'
          : 'Crafted ${blueprint.name}',
    );
  }

  void _syncShops() {
    final SessionState current = _session.snapshot();
    final SessionState nextState = _townDomain.syncShops(
      state: current,
      now: _session.now(),
      economy: _economy,
    );
    _apply(
      nextState,
      logMessage: identical(nextState, current)
          ? null
          : 'Auto refresh executed',
    );
  }

  void _apply(SessionState nextState, {String? logMessage}) {
    _session.applyState(nextState);
    if (logMessage != null) {
      _session.appendLog(logMessage);
    }
  }
}

final Provider<TownController> townControllerProvider =
    Provider<TownController>((Ref ref) {
      return TownController(
        ref.read(sessionControllerProvider.notifier),
        ref.read(economyServiceProvider),
      );
    });
