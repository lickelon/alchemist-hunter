import 'package:alchemist_hunter/common/widgets/app_screen_body.dart';
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
    final int forgeQueueCount = ref.watch(townForgeInProgressCountProvider);
    final int forgeCompletedCount = ref.watch(townForgeCompletedCountProvider);
    final int mercenaryCandidateCount = ref.watch(
      townMercenaryCandidateCountProvider,
    );
    final List<TownPotionSaleView> craftedPotionStacks = ref.watch(
      townPotionSaleViewsProvider,
    );

    return AppScreenBody(
      children: <Widget>[
        Card(
          child: ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Town Economy'),
            subtitle: Text('Gold: $gold / TownInsight: $townInsight'),
          ),
        ),
        TownShopCard(
          title: 'General Shop',
          shopType: ShopType.general,
          itemCount: generalShop.items.length,
        ),
        TownShopCard(
          title: 'Catalyst Shop',
          shopType: ShopType.catalyst,
          itemCount: catalystShop.items.length,
        ),
        TownMercenaryHireCard(candidateCount: mercenaryCandidateCount),
        TownSkillTreeCard(
          unlockedCount: unlockedSkillNodes,
          totalCount: totalSkillNodes,
        ),
        TownEquipmentCraftCard(
          forgeQueueCount: forgeQueueCount,
          completedCount: forgeCompletedCount,
        ),
        TownPotionSellCard(stackCount: craftedPotionStacks.length),
      ],
    );
  }
}
