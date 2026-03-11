import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/workshop/application/workshop_providers.dart';

class WorkshopQueueCard extends StatelessWidget {
  const WorkshopQueueCard({super.key, required this.jobCount});

  final int jobCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Craft Queue',
      description: jobCount == 0 ? '대기열이 비어있음' : '대기열 $jobCount개 작업',
      icon: Icons.playlist_add_check_circle_outlined,
      onTap: () => _showQueueSheet(context),
    );
  }

  void _showQueueSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const _WorkshopQueueSheet();
      },
    );
  }
}

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

class WorkshopLogCard extends StatelessWidget {
  const WorkshopLogCard({super.key, required this.logCount});

  final int logCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Logs',
      description: logCount == 0 ? '로그 없음' : '최근 로그 $logCount개',
      icon: Icons.notes_outlined,
      onTap: () => _showLogSheet(context),
    );
  }

  void _showLogSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const _WorkshopLogSheet();
      },
    );
  }
}

class _WorkshopQueueSheet extends ConsumerWidget {
  const _WorkshopQueueSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CraftQueueJob> queue = ref.watch(craftQueueProvider);
    final List<PotionQueueOption> options = ref.watch(
      workshopPotionQueueOptionsProvider,
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
                '제작 큐',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  FilledButton(
                    onPressed: () {
                      ref.read(workshopControllerProvider).tickCraftQueue();
                    },
                    child: const Text('틱 처리'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('포션 등록', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Expanded(
                flex: 3,
                child: options.isEmpty
                    ? const Center(child: Text('등록 가능한 포션이 없습니다'))
                    : ListView.builder(
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final PotionQueueOption option = options[index];
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(option.blueprint.name),
                            subtitle: Text(
                              option.unlocked
                                  ? option.materialHint
                                  : '잠김: ${option.lockReason}',
                            ),
                            trailing: FilledButton.tonal(
                              onPressed: option.unlocked && option.craftableNow
                                  ? () {
                                      _showEnqueueOptions(
                                        context,
                                        ref,
                                        option,
                                      );
                                    }
                                  : null,
                              child: const Text('등록'),
                            ),
                          );
                        },
                      ),
              ),
              const Divider(),
              const Text('현재 대기열', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Expanded(
                flex: 2,
                child: queue.isEmpty
                    ? const Center(child: Text('대기열이 비어있습니다'))
                    : ListView(
                        children: queue.take(20).map((CraftQueueJob job) {
                          return ListTile(
                            dense: true,
                            title: Text(
                              '${job.potionId} ${job.currentRepeat}/${job.repeatCount}',
                            ),
                            subtitle: Text(
                              '상태 ${job.status.name}, 재시도 ${job.retryCount}, ETA ${job.eta.inSeconds}s',
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

  void _showEnqueueOptions(
    BuildContext context,
    WidgetRef ref,
    PotionQueueOption option,
  ) {
    final List<int> quantities = <int>{
      if (option.maxCraftableCount >= 1) 1,
      if (option.maxCraftableCount >= 3) 3,
      if (option.maxCraftableCount >= 5) 5,
      option.maxCraftableCount,
    }.toList()
      ..sort();

    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  option.blueprint.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text('최대 ${option.maxCraftableCount}회 제작 가능'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: quantities.map((int quantity) {
                    final bool isMax = quantity == option.maxCraftableCount;
                    return FilledButton.tonal(
                      onPressed: () {
                        ref
                            .read(workshopControllerProvider)
                            .enqueuePotion(option.blueprint.id, quantity);
                        Navigator.of(bottomSheetContext).pop();
                      },
                      child: Text(isMax ? '최대' : '$quantity회'),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WorkshopMaterialSheet extends ConsumerWidget {
  const _WorkshopMaterialSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<MapEntry<String, int>> materials = ref.watch(
      sortedMaterialInventoryProvider,
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
                          final MapEntry<String, int> entry = materials[index];
                          return ListTile(
                            dense: true,
                            title: Text(entry.key),
                            trailing: Text('x${entry.value}'),
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

class _WorkshopCraftedPotionSheet extends ConsumerWidget {
  const _WorkshopCraftedPotionSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Map<String, int> stacks = ref.watch(craftedPotionStacksProvider);
    final Map<String, CraftedPotion> details = ref.watch(
      craftedPotionDetailsProvider,
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
                '완성 포션 상세',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
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
                                padding: const EdgeInsets.only(bottom: 8),
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
        ),
      ),
    );
  }
}

class _WorkshopLogSheet extends ConsumerWidget {
  const _WorkshopLogSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> logs = ref.watch(recentLogsProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.65,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '로그',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: logs.isEmpty
                    ? const Center(child: Text('로그가 없습니다'))
                    : ListView(
                        children: logs.map((String entry) {
                          return ListTile(dense: true, title: Text(entry));
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
