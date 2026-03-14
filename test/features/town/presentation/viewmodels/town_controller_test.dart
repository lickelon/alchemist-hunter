import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/data/repositories/static_equipment_blueprint_repository.dart';
import 'package:alchemist_hunter/features/town/data/repositories/static_mercenary_template_repository.dart';
import 'package:alchemist_hunter/features/town/data/repositories/static_shop_catalog_repository.dart';
import 'package:alchemist_hunter/features/town/data/repositories/static_town_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/services/economy_service.dart';
import 'package:alchemist_hunter/features/town/domain/services/town_skill_tree_service.dart';
import 'package:alchemist_hunter/features/town/presentation/town_providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SessionController buildSession({DateTime? now}) {
    return SessionController(clock: () => now ?? DateTime(2026, 1, 1, 10));
  }

  ShopController buildShopController(SessionController session) {
    return ShopController(
      session,
      EconomyService(),
      shopCatalogRepository: const StaticShopCatalogRepository(),
      townSkillTreeRepository: const StaticTownSkillTreeRepository(),
      townSkillTreeService: const TownSkillTreeService(),
    );
  }

  EquipmentCraftController buildEquipmentCraftController(
    SessionController session,
  ) {
    return EquipmentCraftController(
      session,
      equipmentBlueprintRepository: const StaticEquipmentBlueprintRepository(),
      townSkillTreeRepository: const StaticTownSkillTreeRepository(),
      townSkillTreeService: const TownSkillTreeService(),
    );
  }

  MercenaryController buildMercenaryController(SessionController session) {
    return MercenaryController(
      session,
      mercenaryTemplateRepository: const StaticMercenaryTemplateRepository(),
      townSkillTreeRepository: const StaticTownSkillTreeRepository(),
      townSkillTreeService: const TownSkillTreeService(),
    );
  }

  test('buyGeneralMaterial updates gold inventory and shop stock', () {
    final SessionController session = buildSession();
    final ShopController controller = buildShopController(session);

    final ShopItem item = session.state.town.generalShop.items.first;
    controller.buyGeneralMaterial(item.materialId, 2);

    expect(session.state.player.gold, 1400);
    expect(session.state.player.materialInventory[item.materialId], 2);
    expect(
      session.state.town.generalShop.items
          .firstWhere(
            (ShopItem current) => current.materialId == item.materialId,
          )
          .quantity,
      18,
    );
    expect(
      session.state.workshop.logs.first,
      'Bought 2 of ${item.materialId} (general)',
    );
  });

  test('forceRefresh updates shop and consumes gold', () {
    final SessionController session = buildSession();
    final ShopController controller = buildShopController(session);
    final int previousGold = session.state.player.gold;
    final DateTime previousRefreshAt =
        session.state.town.generalShop.nextRefreshAt;

    controller.forceRefresh(ShopType.general);

    expect(session.state.player.gold, previousGold - 25);
    expect(session.state.town.generalShop.cycleRefreshCount, 1);
    expect(session.state.town.generalShop.nextRefreshAt, previousRefreshAt);
    expect(session.state.workshop.logs.first, 'Forced refresh general shop');
  });

  test('forceRefresh applies town trade ledger discount', () {
    final SessionController session = buildSession();
    final ShopController controller = buildShopController(session);
    session.state = session.state.copyWith(
      town: session.state.town.copyWith(
        skillTree: session.state.town.skillTree.copyWith(
          nodeLevels: const <String, int>{'town_trade_ledger': 1},
          unlockedNodes: const <String>{'town_trade_ledger'},
        ),
      ),
    );

    controller.forceRefresh(ShopType.general);

    expect(session.state.player.gold, 1477);
  });

  test('syncShopAutoRefresh refreshes overdue shop state', () {
    final SessionController session = buildSession(
      now: DateTime(2026, 1, 1, 10, 30),
    );
    final ShopController controller = buildShopController(session);

    session.state = session.state.copyWith(
      town: session.state.town.copyWith(
        generalShop: session.state.town.generalShop.copyWith(
          nextRefreshAt: DateTime(2026, 1, 1, 10),
          forcedRefreshCost: 55,
          cycleRefreshCount: 2,
        ),
      ),
    );

    controller.syncShopAutoRefresh();

    expect(
      session.state.town.generalShop.nextRefreshAt,
      DateTime(2026, 1, 1, 10, 45),
    );
    expect(session.state.town.generalShop.forcedRefreshCost, 25);
    expect(session.state.town.generalShop.cycleRefreshCount, 0);
    expect(session.state.workshop.logs.first, 'Auto refresh executed');
  });

  test('craftEquipment consumes gold and stores equipment instance', () {
    final SessionController session = buildSession();
    final EquipmentCraftController controller = buildEquipmentCraftController(
      session,
    );
    session.state = session.state.copyWith(
      player: session.state.player.copyWith(
        materialInventory: const <String, int>{'m_1': 2, 'm_2': 1},
      ),
    );

    controller.craftEquipment('eq_1');

    expect(session.state.player.gold, 1500);
    expect(session.state.player.materialInventory, isEmpty);
    expect(session.state.town.equipmentInventory, hasLength(1));
    expect(session.state.town.equipmentInventory.first.blueprintId, 'eq_1');
    expect(session.state.workshop.logs.first, 'Crafted Bronze Sword');
  });

  test('craftEquipment applies forge rack material reduction', () {
    final SessionController session = buildSession();
    final EquipmentCraftController controller = buildEquipmentCraftController(
      session,
    );
    session.state = session.state.copyWith(
      player: session.state.player.copyWith(
        materialInventory: const <String, int>{'m_1': 1, 'm_2': 1},
      ),
      town: session.state.town.copyWith(
        skillTree: session.state.town.skillTree.copyWith(
          nodeLevels: const <String, int>{
            'town_trade_ledger': 1,
            'town_forge_rack': 1,
          },
          unlockedNodes: const <String>{'town_trade_ledger', 'town_forge_rack'},
        ),
      ),
    );

    controller.craftEquipment('eq_1');

    expect(session.state.player.materialInventory, isEmpty);
    expect(session.state.town.equipmentInventory.first.name, 'Bronze Sword');
  });

  test('hireMercenary consumes gold and appends mercenary', () {
    final SessionController session = buildSession();
    final MercenaryController controller = buildMercenaryController(session);
    final MercenaryCandidate candidate =
        session.state.town.mercenaryCandidates.first;

    controller.hireMercenary(candidate.id);

    expect(session.state.player.gold, 1500 - candidate.hireCost);
    expect(session.state.characters.mercenaries, hasLength(2));
    expect(session.state.characters.mercenaries.last.name, candidate.name);
    expect(session.state.town.mercenaryCandidates, hasLength(2));
    expect(session.state.workshop.logs.first, 'Hired ${candidate.name}');
  });

  test('hireMercenary applies hiring board discount', () {
    final SessionController session = buildSession();
    final MercenaryController controller = buildMercenaryController(session);
    final MercenaryCandidate candidate =
        session.state.town.mercenaryCandidates.first;
    session.state = session.state.copyWith(
      town: session.state.town.copyWith(
        skillTree: session.state.town.skillTree.copyWith(
          nodeLevels: const <String, int>{
            'town_trade_ledger': 1,
            'town_hiring_board': 1,
          },
          unlockedNodes: const <String>{
            'town_trade_ledger',
            'town_hiring_board',
          },
        ),
      ),
    );

    controller.hireMercenary(candidate.id);

    expect(session.state.player.gold, 1500 - 166);
  });

  test('refreshMercenaryCandidates rotates candidate list', () {
    final SessionController session = buildSession();
    final MercenaryController controller = buildMercenaryController(session);
    final List<String> previousIds = session.state.town.mercenaryCandidates
        .map((MercenaryCandidate entry) => entry.id)
        .toList(growable: false);

    controller.refreshMercenaryCandidates();

    expect(session.state.town.mercenaryRefreshCount, 1);
    expect(
      session.state.town.mercenaryCandidates
          .map((MercenaryCandidate entry) => entry.id)
          .toList(growable: false),
      isNot(previousIds),
    );
    expect(session.state.workshop.logs.first, 'Refreshed mercenary candidates');
  });
}
