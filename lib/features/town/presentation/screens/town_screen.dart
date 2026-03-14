import 'package:alchemist_hunter/features/town/presentation/widgets/town_sections.dart';
import 'package:alchemist_hunter/features/town/presentation/town_providers.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TownScreen extends ConsumerWidget {
  const TownScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int gold = ref.watch(townGoldProvider);
    final int townInsight = ref.watch(townInsightProvider);
    final int unlockedSkillNodes = ref.watch(
      townUnlockedSkillNodeCountProvider,
    );
    final int totalSkillNodes = ref.watch(townSkillNodeCountProvider);
    final ShopState generalShop = ref.watch(generalShopStateProvider);
    final ShopState catalystShop = ref.watch(catalystShopStateProvider);
    final int generalRefreshCost = ref.watch(generalShopRefreshCostProvider);
    final int catalystRefreshCost = ref.watch(catalystShopRefreshCostProvider);
    final int equipmentCount = ref.watch(townEquipmentCountProvider);
    final int mercenaryCandidateCount = ref.watch(
      townMercenaryCandidateCountProvider,
    );
    final int mercenaryCount = ref.watch(townMercenaryCountProvider);
    final List<TownPotionSaleView> craftedPotionStacks = ref.watch(
      townPotionSaleViewsProvider,
    );

    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        Card(
          child: ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Town Economy'),
            subtitle: Text(
              'Gold: $gold / TownInsight: $townInsight / Skill Nodes: $unlockedSkillNodes/$totalSkillNodes',
            ),
          ),
        ),
        const SizedBox(height: 8),
        TownShopCard(
          title: 'General Shop',
          shopType: ShopType.general,
          itemCount: generalShop.items.length,
          refreshCost: generalRefreshCost,
        ),
        const SizedBox(height: 8),
        TownShopCard(
          title: 'Catalyst Shop',
          shopType: ShopType.catalyst,
          itemCount: catalystShop.items.length,
          refreshCost: catalystRefreshCost,
        ),
        const SizedBox(height: 8),
        TownMercenaryHireCard(
          candidateCount: mercenaryCandidateCount,
          mercenaryCount: mercenaryCount,
        ),
        const SizedBox(height: 8),
        TownSkillTreeCard(
          unlockedCount: unlockedSkillNodes,
          totalCount: totalSkillNodes,
        ),
        const SizedBox(height: 8),
        TownEquipmentCraftCard(equipmentCount: equipmentCount),
        const SizedBox(height: 8),
        TownPotionSellCard(stackCount: craftedPotionStacks.length),
      ],
    );
  }
}
