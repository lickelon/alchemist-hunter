import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/town_catalog.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TownEquipmentBlueprintView {
  const TownEquipmentBlueprintView({
    required this.id,
    required this.name,
    required this.slotLabel,
    required this.statLabel,
    required this.materialCostLabel,
    required this.canCraft,
  });

  final String id;
  final String name;
  final String slotLabel;
  final String statLabel;
  final String materialCostLabel;
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

class TownMercenaryCandidateView {
  const TownMercenaryCandidateView({
    required this.id,
    required this.name,
    required this.roleLabel,
    required this.tierLabel,
    required this.hireCost,
    required this.canHire,
  });

  final String id;
  final String name;
  final String roleLabel;
  final String tierLabel;
  final int hireCost;
  final bool canHire;

  String get hireHint => canHire ? '' : ' / 골드 부족';
}

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

final Provider<ShopState> generalShopStateProvider = Provider<ShopState>((
  Ref ref,
) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.town.generalShop,
    ),
  );
});

final Provider<ShopState> catalystShopStateProvider = Provider<ShopState>((
  Ref ref,
) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.town.catalystShop,
    ),
  );
});

final Provider<int> generalShopRefreshCostProvider = Provider<int>((Ref ref) {
  final SessionState state = ref.watch(sessionControllerProvider);
  final ShopState shop = ref.watch(generalShopStateProvider);
  final discountRate = ref
      .watch(townSkillTreeServiceProvider)
      .shopRefreshDiscountRate(state, ref.watch(townSkillNodesProvider));
  return ref
      .watch(townSkillTreeServiceProvider)
      .discountedGoldCost(
        baseCost: shop.forcedRefreshCost,
        discountRate: discountRate,
      );
});

final Provider<int> catalystShopRefreshCostProvider = Provider<int>((Ref ref) {
  final SessionState state = ref.watch(sessionControllerProvider);
  final ShopState shop = ref.watch(catalystShopStateProvider);
  final discountRate = ref
      .watch(townSkillTreeServiceProvider)
      .shopRefreshDiscountRate(state, ref.watch(townSkillNodesProvider));
  return ref
      .watch(townSkillTreeServiceProvider)
      .discountedGoldCost(
        baseCost: shop.forcedRefreshCost,
        discountRate: discountRate,
      );
});

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
          canCraft: canCraft,
        );
      })
      .toList(growable: false);
});

final Provider<int> townMercenaryCandidateCountProvider = Provider<int>((
  Ref ref,
) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.town.mercenaryCandidates.length,
    ),
  );
});

final Provider<int> townMercenaryCountProvider = Provider<int>((Ref ref) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.characters.mercenaries.length,
    ),
  );
});

final Provider<List<TownEquipmentInventoryView>>
townEquipmentInventoryViewsProvider = Provider<List<TownEquipmentInventoryView>>((
  Ref ref,
) {
  final List<EquipmentInstance> inventory = ref.watch(
    townEquipmentInventoryProvider,
  );
  return inventory.map((EquipmentInstance entry) {
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
  }).toList();
});

final Provider<List<TownMercenaryCandidateView>>
townMercenaryCandidateViewsProvider =
    Provider<List<TownMercenaryCandidateView>>((Ref ref) {
      final SessionState state = ref.watch(sessionControllerProvider);
      final service = ref.watch(townSkillTreeServiceProvider);
      final List<TownSkillNode> nodes = ref.watch(townSkillNodesProvider);
      return state.town.mercenaryCandidates
          .map((MercenaryCandidate entry) {
            final int hireCost = service.discountedGoldCost(
              baseCost: entry.hireCost,
              discountRate: service.mercenaryHireDiscountRate(state, nodes),
            );
            return TownMercenaryCandidateView(
              id: entry.id,
              name: entry.name,
              roleLabel: entry.roleLabel,
              tierLabel: entry.tierLabel,
              hireCost: hireCost,
              canHire: state.player.gold >= hireCost,
            );
          })
          .toList(growable: false);
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
