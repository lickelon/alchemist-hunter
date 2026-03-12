import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/features/session/application/session_providers.dart';
import 'package:alchemist_hunter/features/workshop/application/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/application/workshop_providers.dart';
import 'package:alchemist_hunter/features/workshop/data/dummy_data.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class _WorkshopQueueSheet extends ConsumerWidget {
  const _WorkshopQueueSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CraftQueueJob> queue = ref.watch(craftQueueProvider);
    final List<PotionQueueOption> options = ref.watch(
      workshopPotionQueueOptionsProvider,
    );
    final WorkshopController controller = ref.read(workshopControllerProvider);
    final PotionCraftingService craftingService = ref.read(
      potionCraftingServiceProvider,
    );
    final Map<String, double> extractedInventory = ref.watch(
      sessionControllerProvider.select(
        (SessionState state) => state.workshop.extractedTraitInventory,
      ),
    );
    final Map<String, String> traitNames = <String, String>{
      for (final TraitUnit trait in DummyData.traits) trait.id: trait.name,
    };
    final List<CraftQueueJob> sortedQueue = <CraftQueueJob>[...queue]
      ..sort(_compareQueueJob);
    final int completedCount = queue
        .where((CraftQueueJob job) => job.status == QueueJobStatus.completed)
        .length;

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
                  const SizedBox(width: 8),
                  FilledButton.tonal(
                    onPressed: completedCount > 0
                        ? () {
                            ref.read(workshopControllerProvider).clearCompleted();
                          }
                        : null,
                    child: Text('완료 정리 ($completedCount)'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '포션 등록',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
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
                                        controller,
                                        craftingService,
                                        extractedInventory,
                                        traitNames,
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
              const Text(
                '현재 대기열',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Expanded(
                flex: 2,
                child: queue.isEmpty
                    ? const Center(child: Text('대기열이 비어있습니다'))
                    : ListView(
                        children: sortedQueue.take(20).map((CraftQueueJob job) {
                          final PotionBlueprint blueprint = options
                              .map((PotionQueueOption option) => option.blueprint)
                              .firstWhere(
                                (PotionBlueprint option) => option.id == job.potionId,
                                orElse: () => PotionBlueprint(
                                  id: job.potionId,
                                  name: job.potionId,
                                  targetTraits: const <String, double>{},
                                  baseValue: 0,
                                  useType: PotionUseType.sell,
                                ),
                              );
                          final int remainingCount =
                              job.repeatCount - job.currentRepeat;
                          final Map<String, double>? requiredTraits =
                              remainingCount > 0
                              ? craftingService.requiredTraitsForRepeatCount(
                                  blueprint: blueprint,
                                  repeatCount: remainingCount,
                                )
                              : null;
                          final bool canResume =
                              job.status == QueueJobStatus.blocked &&
                              remainingCount > 0 &&
                              craftingService.canCraftRepeatCount(
                                blueprint: blueprint,
                                extractedInventory: extractedInventory,
                                repeatCount: remainingCount,
                              );
                          return ListTile(
                            dense: true,
                            title: Text(
                              '${blueprint.name} ${job.currentRepeat}/${job.repeatCount}',
                            ),
                            subtitle: Text(
                              _queueStatusText(
                                job: job,
                                canResume: canResume,
                                lackingMaterials: _formatMissingTraits(
                                  requirements: requiredTraits,
                                  extractedInventory: extractedInventory,
                                  traitNames: traitNames,
                                ),
                              ),
                            ),
                            trailing: job.status == QueueJobStatus.blocked
                                ? FilledButton.tonal(
                                    onPressed: canResume
                                        ? () => controller.resumeBlocked(job.id)
                                        : null,
                                    child: const Text('재개'),
                                  )
                                : null,
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
    WorkshopController controller,
    PotionCraftingService craftingService,
    Map<String, double> extractedInventory,
    Map<String, String> traitNames,
    PotionQueueOption option,
  ) {
    final List<int> quantities = <int>{
      if (option.maxCraftableCount >= 1) 1,
      if (option.maxCraftableCount >= 3) 3,
      if (option.maxCraftableCount >= 5) 5,
      option.maxCraftableCount,
    }.toList()..sort();

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
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: quantities.map((int quantity) {
                    final Map<String, double>? requirements = craftingService
                        .requiredTraitsForRepeatCount(
                          blueprint: option.blueprint,
                          repeatCount: quantity,
                        );
                    final bool isMax = quantity == option.maxCraftableCount;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(isMax ? '최대 등록' : '$quantity회 등록'),
                      subtitle: Text(
                        _formatTraitRequirements(requirements, traitNames),
                      ),
                      trailing: FilledButton.tonal(
                        onPressed: () {
                          controller.enqueuePotion(option.blueprint.id, quantity);
                          Navigator.of(bottomSheetContext).pop();
                        },
                        child: const Text('등록'),
                      ),
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

  String _formatTraitRequirements(
    Map<String, double>? requirements,
    Map<String, String> traitNames,
  ) {
    if (requirements == null || requirements.isEmpty) {
      return '필요 특성 계산 불가';
    }

    return requirements.entries
        .map(
          (MapEntry<String, double> entry) =>
              '${traitNames[entry.key] ?? entry.key} ${entry.value.toStringAsFixed(2)}',
        )
        .join(', ');
  }

  String _queueStatusText({
    required CraftQueueJob job,
    required bool canResume,
    required String? lackingMaterials,
  }) {
    if (job.status == QueueJobStatus.blocked) {
      if (canResume) {
        return '상태 진행 불가, 추출 특성 보충 후 재개 가능';
      }
      if (lackingMaterials != null && lackingMaterials.isNotEmpty) {
        return '상태 진행 불가, 부족 특성: $lackingMaterials';
      }
      return '상태 진행 불가, 추출 특성 부족';
    }
    if (job.status == QueueJobStatus.completed) {
      return '상태 완료';
    }
    if (job.status == QueueJobStatus.processing) {
      return '상태 진행 중, ETA ${job.eta.inSeconds}s';
    }
    return '상태 대기 중, ${job.currentRepeat}/${job.repeatCount}';
  }

  String? _formatMissingTraits({
    required Map<String, double>? requirements,
    required Map<String, double> extractedInventory,
    required Map<String, String> traitNames,
  }) {
    if (requirements == null || requirements.isEmpty) {
      return null;
    }

    final List<String> missing = <String>[];
    for (final MapEntry<String, double> entry in requirements.entries) {
      final double owned = extractedInventory[entry.key] ?? 0;
      if (owned + 0.0001 >= entry.value) {
        continue;
      }
      missing.add(
        '${traitNames[entry.key] ?? entry.key} ${(entry.value - owned).toStringAsFixed(2)}',
      );
    }
    if (missing.isEmpty) {
      return null;
    }
    return missing.join(', ');
  }

  int _compareQueueJob(CraftQueueJob left, CraftQueueJob right) {
    int rank(QueueJobStatus status) {
      return switch (status) {
        QueueJobStatus.processing => 0,
        QueueJobStatus.blocked => 1,
        QueueJobStatus.queued => 2,
        QueueJobStatus.completed => 3,
      };
    }

    final int statusCompare = rank(left.status).compareTo(rank(right.status));
    if (statusCompare != 0) {
      return statusCompare;
    }
    return left.id.compareTo(right.id);
  }
}
