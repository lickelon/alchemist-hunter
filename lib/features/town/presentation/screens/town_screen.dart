import 'package:alchemist_hunter/features/town/presentation/widgets/town_sections.dart';
import 'package:alchemist_hunter/features/town/application/town_providers.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TownScreen extends ConsumerWidget {
  const TownScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int gold = ref.watch(townGoldProvider);
    final ShopState generalShop = ref.watch(generalShopStateProvider);
    final ShopState catalystShop = ref.watch(catalystShopStateProvider);
    final Map<String, int> craftedPotionStacks = ref.watch(
      sellablePotionStacksProvider,
    );

    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        Card(
          child: ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Town Economy'),
            subtitle: Text('Gold: $gold / TownInsight: (준비중)'),
          ),
        ),
        const SizedBox(height: 8),
        TownShopCard(
          title: 'General Shop',
          shopType: ShopType.general,
          itemCount: generalShop.items.length,
          refreshCost: generalShop.forcedRefreshCost,
        ),
        const SizedBox(height: 8),
        TownShopCard(
          title: 'Catalyst Shop',
          shopType: ShopType.catalyst,
          itemCount: catalystShop.items.length,
          refreshCost: catalystShop.forcedRefreshCost,
        ),
        const SizedBox(height: 8),
        TownPotionSellCard(stackCount: craftedPotionStacks.length),
      ],
    );
  }
}
