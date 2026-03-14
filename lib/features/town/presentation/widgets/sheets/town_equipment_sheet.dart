import 'package:alchemist_hunter/features/town/presentation/town_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TownEquipmentSheet extends ConsumerWidget {
  const TownEquipmentSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<TownEquipmentBlueprintView> blueprints = ref.watch(
      townEquipmentBlueprintViewsProvider,
    );
    final List<TownEquipmentInventoryView> inventory = ref.watch(
      townEquipmentInventoryViewsProvider,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '기본 장비 제작',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                '제작 가능 장비',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: ListView(
                  children: blueprints.map((TownEquipmentBlueprintView entry) {
                    return ListTile(
                      dense: true,
                      title: Text(entry.name),
                      subtitle: Text(
                        '${entry.slotLabel} / ${entry.statLabel}\n${entry.materialCostLabel}',
                      ),
                      trailing: FilledButton.tonal(
                        onPressed: entry.canCraft
                            ? () {
                                ref
                                    .read(equipmentCraftControllerProvider)
                                    .craftEquipment(entry.id);
                              }
                            : null,
                        child: const Text('제작'),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Divider(),
              const Text(
                '보유 장비',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: inventory.isEmpty
                    ? const Center(child: Text('보유 장비가 없습니다'))
                    : ListView(
                        children: inventory.map((
                          TownEquipmentInventoryView entry,
                        ) {
                          return ListTile(
                            dense: true,
                            title: Text(entry.name),
                            subtitle: Text(
                              '${entry.slotLabel} / ${entry.statLabel}',
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
