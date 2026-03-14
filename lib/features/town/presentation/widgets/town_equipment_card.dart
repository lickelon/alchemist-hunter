import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/presentation/town_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TownEquipmentCraftCard extends StatelessWidget {
  const TownEquipmentCraftCard({super.key, required this.equipmentCount});

  final int equipmentCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Equipment Craft',
      description: equipmentCount == 0
          ? '제작 장비 없음'
          : '보유 장비 $equipmentCount개',
      icon: Icons.construction_outlined,
      onTap: () => _showEquipmentSheet(context),
    );
  }

  void _showEquipmentSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const _TownEquipmentSheet();
      },
    );
  }
}

class _TownEquipmentSheet extends ConsumerWidget {
  const _TownEquipmentSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<EquipmentBlueprint> blueprints = ref.watch(
      townEquipmentBlueprintsProvider,
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
                  children: blueprints.map((EquipmentBlueprint entry) {
                    return ListTile(
                      dense: true,
                      title: Text(entry.name),
                      subtitle: Text(
                        '${entry.slot.name} / ATK ${entry.attack} / DEF ${entry.defense} / HP ${entry.health} / ${entry.goldCost}G',
                      ),
                      trailing: FilledButton.tonal(
                        onPressed: () {
                          ref
                              .read(townControllerProvider)
                              .craftEquipment(entry.id);
                        },
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
                        children: inventory.map((TownEquipmentInventoryView entry) {
                          return ListTile(
                            dense: true,
                            title: Text(entry.name),
                            subtitle: Text('${entry.slotLabel} / ${entry.statLabel}'),
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
