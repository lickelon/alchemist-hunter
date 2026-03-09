import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:flutter/material.dart';

class WorkshopQueueCard extends StatelessWidget {
  const WorkshopQueueCard({
    super.key,
    required this.getQueue,
    required this.onEnqueue,
    required this.onTick,
  });

  final List<CraftQueueJob> Function() getQueue;
  final VoidCallback onEnqueue;
  final VoidCallback onTick;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Craft Queue',
      description: getQueue().isEmpty ? '대기열이 비어있음' : '대기열 ${getQueue().length}개 작업',
      icon: Icons.playlist_add_check_circle_outlined,
      onTap: () => _showQueueSheet(context),
    );
  }

  void _showQueueSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setModalState) {
            final List<CraftQueueJob> queue = getQueue();
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('제작 큐', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: <Widget>[
                          FilledButton.tonal(
                            onPressed: () {
                              onEnqueue();
                              setModalState(() {});
                            },
                            child: const Text('포션 x3 등록'),
                          ),
                          FilledButton(
                            onPressed: () {
                              onTick();
                              setModalState(() {});
                            },
                            child: const Text('틱 처리'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: queue.isEmpty
                            ? const Center(child: Text('대기열이 비어있습니다'))
                            : ListView(
                                children: queue.take(20).map((CraftQueueJob job) {
                                  return ListTile(
                                    dense: true,
                                    title: Text('${job.potionId} ${job.currentRepeat}/${job.repeatCount}'),
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
          },
        );
      },
    );
  }
}

class WorkshopMaterialCard extends StatelessWidget {
  const WorkshopMaterialCard({super.key, required this.getMaterials});

  final List<MapEntry<String, int>> Function() getMaterials;

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<String, int>> materials = getMaterials();
    final int totalCount =
        materials.fold<int>(0, (int prev, MapEntry<String, int> e) => prev + e.value);
    return ListCard(
      name: 'Items',
      description: materials.isEmpty
          ? '보유 아이템 없음'
          : '종류 ${materials.length}개 / 총 $totalCount개',
      icon: Icons.inventory_2_outlined,
      onTap: () => _showItemList(context),
    );
  }

  void _showItemList(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setModalState) {
            final List<MapEntry<String, int>> materials = getMaterials();
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('보유 아이템 목록', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
          },
        );
      },
    );
  }
}

class WorkshopCraftedPotionCard extends StatelessWidget {
  const WorkshopCraftedPotionCard({
    super.key,
    required this.getStacks,
    required this.getDetails,
  });

  final Map<String, int> Function() getStacks;
  final Map<String, CraftedPotion> Function() getDetails;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Crafted Potions',
      description: getStacks().isEmpty ? '완성 포션 없음' : '포션 스택 ${getStacks().length}개',
      icon: Icons.local_drink_outlined,
      onTap: () => _showPotionSheet(context),
    );
  }

  void _showPotionSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setModalState) {
            final Map<String, int> stacks = getStacks();
            final Map<String, CraftedPotion> details = getDetails();
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('완성 포션 상세', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: stacks.isEmpty
                            ? const Center(child: Text('완성 포션이 없습니다'))
                            : ListView(
                                children: stacks.entries.map((MapEntry<String, int> entry) {
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
          },
        );
      },
    );
  }
}

class WorkshopLogCard extends StatelessWidget {
  const WorkshopLogCard({super.key, required this.getLogs});

  final List<String> Function() getLogs;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Logs',
      description: getLogs().isEmpty ? '로그 없음' : '최근 로그 ${getLogs().length}개',
      icon: Icons.notes_outlined,
      onTap: () => _showLogSheet(context),
    );
  }

  void _showLogSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, void Function(void Function()) setModalState) {
            final List<String> logs = getLogs();
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.65,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('로그', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: logs.isEmpty
                            ? const Center(child: Text('로그가 없습니다'))
                            : ListView(
                                children: logs
                                    .map((String e) => ListTile(dense: true, title: Text(e)))
                                    .toList(),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
