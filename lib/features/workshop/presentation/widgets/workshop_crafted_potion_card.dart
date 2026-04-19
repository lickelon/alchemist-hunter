import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/presentation/workshop_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkshopCraftedPotionCard extends StatelessWidget {
  const WorkshopCraftedPotionCard({super.key, required this.stackCount});

  final int stackCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Crafted Potions',
      description: stackCount == 0 ? '완성 포션 없음' : '포션 스택 $stackCount개',
      icon: Icons.local_drink_outlined,
      onTap: () => _showPotionSheet(context),
    );
  }

  void _showPotionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const _WorkshopCraftedPotionSheet();
      },
    );
  }
}

class _WorkshopCraftedPotionSheet extends ConsumerWidget {
  const _WorkshopCraftedPotionSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, int> stacks = ref.watch(craftedPotionStacksProvider);
    final Map<String, CraftedPotion> details = ref.watch(
      craftedPotionDetailsProvider,
    );

    return AppBottomSheet(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            '완성 포션 상세',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: stacks.isEmpty
                ? const Center(child: Text('완성 포션이 없습니다'))
                : ListView(
                    children: stacks.entries.map((
                      MapEntry<String, int> entry,
                    ) {
                      final CraftedPotion? detail = details[entry.key];
                      return ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: Text('${entry.key} x${entry.value}'),
                        subtitle: Text(
                          '품질 ${detail?.qualityGrade.name.toUpperCase() ?? '-'}',
                        ),
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: Text(
                              '점수 ${(detail?.qualityScore ?? 0).toStringAsFixed(2)} / 특성 ${detail?.traits.toString() ?? '{}'}',
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
