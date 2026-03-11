import 'package:alchemist_hunter/features/workshop/application/workshop_providers.dart';
import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkshopMaterialCard extends StatelessWidget {
  const WorkshopMaterialCard({
    super.key,
    required this.materialTypeCount,
    required this.totalCount,
  });

  final int materialTypeCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Items',
      description: materialTypeCount == 0
          ? '보유 아이템 없음'
          : '종류 $materialTypeCount개 / 총 $totalCount개',
      icon: Icons.inventory_2_outlined,
      onTap: () => _showItemList(context),
    );
  }

  void _showItemList(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const _WorkshopMaterialSheet();
      },
    );
  }
}

class _WorkshopMaterialSheet extends ConsumerWidget {
  const _WorkshopMaterialSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<MaterialInventoryView> materials = ref.watch(
      materialInventoryViewsProvider,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '보유 아이템 목록',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: materials.isEmpty
                    ? const Center(child: Text('보유 아이템이 없습니다'))
                    : ListView.builder(
                        itemCount: materials.length,
                        itemBuilder: (BuildContext context, int index) {
                          final MaterialInventoryView entry = materials[index];
                          return ListTile(
                            dense: true,
                            title: Text(entry.name),
                            subtitle: Text(
                              '${entry.rarity.name} / ${entry.traitSummary}',
                            ),
                            trailing: Text('x${entry.quantity}'),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
