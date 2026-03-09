import 'dart:async';

import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/town/application/game_providers.dart';
import 'package:alchemist_hunter/features/town/presentation/widgets/town_sections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TownScreen extends ConsumerStatefulWidget {
  const TownScreen({super.key});

  @override
  ConsumerState<TownScreen> createState() => _TownScreenState();
}

class _TownScreenState extends ConsumerState<TownScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      ref.read(gameControllerProvider.notifier).syncShopAutoRefresh();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GameState state = ref.watch(gameControllerProvider);
    return ListView(
      padding: const EdgeInsets.all(12),
      children: <Widget>[
        Card(
          child: ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: const Text('Town Economy'),
            subtitle: Text('Gold: ${state.gold} / TownInsight: (준비중)'),
          ),
        ),
        const SizedBox(height: 8),
        TownShopCard(
          title: 'General Shop',
          getItems: () => ref.read(gameControllerProvider).generalShop.items,
          getRefreshCost: () => ref.read(gameControllerProvider).generalShop.forcedRefreshCost,
          onBuy: (String id) =>
              ref.read(gameControllerProvider.notifier).buyGeneralMaterial(id, 1),
          onRefresh: () => ref.read(gameControllerProvider.notifier).forceRefresh(ShopType.general),
        ),
        const SizedBox(height: 8),
        TownShopCard(
          title: 'Catalyst Shop',
          getItems: () => ref.read(gameControllerProvider).catalystShop.items,
          getRefreshCost: () => ref.read(gameControllerProvider).catalystShop.forcedRefreshCost,
          onBuy: (String id) =>
              ref.read(gameControllerProvider.notifier).buyCatalystMaterial(id, 1),
          onRefresh: () => ref.read(gameControllerProvider.notifier).forceRefresh(ShopType.catalyst),
        ),
        const SizedBox(height: 8),
        TownPotionSellCard(
          getStacks: () => ref.read(gameControllerProvider).craftedPotionStacks,
          getDetails: () => ref.read(gameControllerProvider).craftedPotionDetails,
          onSell: (String key) => ref.read(gameControllerProvider.notifier).sellCraftedPotion(key, 1),
        ),
      ],
    );
  }
}
