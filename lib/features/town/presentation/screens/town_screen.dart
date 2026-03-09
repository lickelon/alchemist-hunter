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
            title: const Text('Town Economy'),
            subtitle: Text('Gold: ${state.gold} / TownInsight: (준비중)'),
          ),
        ),
        const SizedBox(height: 8),
        TownShopCard(
          title: 'General Shop',
          items: state.generalShop.items,
          refreshCost: state.generalShop.forcedRefreshCost,
          onBuy: (String id) =>
              ref.read(gameControllerProvider.notifier).buyGeneralMaterial(id, 1),
          onRefresh: () => ref.read(gameControllerProvider.notifier).forceRefresh(ShopType.general),
        ),
        const SizedBox(height: 8),
        TownShopCard(
          title: 'Catalyst Shop',
          items: state.catalystShop.items,
          refreshCost: state.catalystShop.forcedRefreshCost,
          onBuy: (String id) =>
              ref.read(gameControllerProvider.notifier).buyCatalystMaterial(id, 1),
          onRefresh: () => ref.read(gameControllerProvider.notifier).forceRefresh(ShopType.catalyst),
        ),
        const SizedBox(height: 8),
        TownPotionSellCard(
          stacks: state.craftedPotionStacks,
          details: state.craftedPotionDetails,
          onSell: (String key) => ref.read(gameControllerProvider.notifier).sellCraftedPotion(key, 1),
        ),
      ],
    );
  }
}
