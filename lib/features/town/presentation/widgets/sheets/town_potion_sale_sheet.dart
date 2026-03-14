import 'package:alchemist_hunter/features/town/presentation/town_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TownPotionSaleSheet extends ConsumerWidget {
  const TownPotionSaleSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<TownPotionSaleView> views = ref.watch(
      townPotionSaleViewsProvider,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '포션 판매',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: views.isEmpty
                    ? const Center(child: Text('판매 가능한 포션이 없습니다'))
                    : ListView(
                        children: views.map((TownPotionSaleView entry) {
                          return ListTile(
                            dense: true,
                            title: Text('${entry.stackKey} x${entry.quantity}'),
                            subtitle: Text(
                              '품질 ${entry.qualityLabel} / 점수 ${entry.scoreLabel}\n판매가 ${entry.saleValue}',
                            ),
                            trailing: FilledButton.tonal(
                              onPressed: () {
                                ref
                                    .read(townPotionSaleControllerProvider)
                                    .sellCraftedPotion(entry.stackKey, 1);
                              },
                              child: const Text('판매'),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
