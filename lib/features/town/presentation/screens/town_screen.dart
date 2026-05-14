import 'package:alchemist_hunter/common/widgets/app_screen_body.dart';
import 'package:alchemist_hunter/common/widgets/info_card.dart';
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
        InfoCard(
          title: '마을 경제',
          subtitle: '골드 $gold / 명성 $townInsight',
          icon: Icons.account_balance_wallet_outlined,
        ),
        TownShopCard(
          title: '일반 상점',
          shopType: ShopType.general,
          itemCount: generalShop.items.length,
        ),
        TownShopCard(
          title: '촉매 상점',
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
