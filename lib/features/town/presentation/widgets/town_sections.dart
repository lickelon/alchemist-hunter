import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter/material.dart';

class TownShopCard extends StatelessWidget {
  const TownShopCard({
    super.key,
    required this.title,
    required this.items,
    required this.refreshCost,
    required this.onBuy,
    required this.onRefresh,
  });

  final String title;
  final List<ShopItem> items;
  final int refreshCost;
  final ValueChanged<String> onBuy;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...items.take(4).map(
              (ShopItem item) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text('${item.name} (${item.quantity})'),
                subtitle: Text('Price: ${item.price}'),
                trailing: FilledButton.tonal(
                  onPressed: () => onBuy(item.materialId),
                  child: const Text('Buy'),
                ),
              ),
            ),
            FilledButton.tonal(
              onPressed: onRefresh,
              child: Text('Refresh ($refreshCost)'),
            ),
          ],
        ),
      ),
    );
  }
}

class TownPotionSellCard extends StatelessWidget {
  const TownPotionSellCard({
    super.key,
    required this.stacks,
    required this.details,
    required this.onSell,
  });

  final Map<String, int> stacks;
  final Map<String, CraftedPotion> details;
  final ValueChanged<String> onSell;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text('Potion Sell', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            if (stacks.isEmpty)
              const Text('No crafted potions')
            else
              ...stacks.entries.map((MapEntry<String, int> entry) {
                final CraftedPotion? detail = details[entry.key];
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text('${entry.key} x${entry.value}'),
                  subtitle: Text(
                    'Quality: ${detail?.qualityGrade.name.toUpperCase() ?? '-'} / Score: ${(detail?.qualityScore ?? 0).toStringAsFixed(2)}',
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: () => onSell(entry.key),
                    child: const Text('Sell 1'),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
