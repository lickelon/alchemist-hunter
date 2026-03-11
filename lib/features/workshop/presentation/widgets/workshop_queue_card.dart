import 'package:alchemist_hunter/features/workshop/application/workshop_providers.dart';
import 'package:alchemist_hunter/features/workshop/application/services/potion_crafting_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/session/application/session_providers.dart';
import 'package:alchemist_hunter/common/widgets/list_card.dart';
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
    final List<MaterialEntity> materials = ref.watch(materialsProvider);
    final Map<String, int> inventory = ref.watch(
      sessionControllerProvider.select(
        (SessionState state) => state.player.materialInventory,
      ),
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
                                        materials,
                                        inventory,
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
                        children: queue.take(20).map((CraftQueueJob job) {
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
                          final bool canResume =
                              job.status == QueueJobStatus.blocked &&
                              remainingCount > 0 &&
                              craftingService.canCraftRepeatCount(
                                blueprint: blueprint,
                                inventory: inventory,
                                materials: materials,
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
    List<MaterialEntity> materials,
    Map<String, int> inventory,
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
                    final Map<String, int>? requirements = craftingService
                        .requiredMaterialsForRepeatCount(
                          blueprint: option.blueprint,
                          inventory: inventory,
                          materials: materials,
                          repeatCount: quantity,
                        );
                    final bool isMax = quantity == option.maxCraftableCount;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(isMax ? '최대 등록' : '$quantity회 등록'),
                      subtitle: Text(
                        _formatMaterialRequirements(requirements, materials),
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

  String _formatMaterialRequirements(
    Map<String, int>? requirements,
    List<MaterialEntity> materials,
  ) {
    if (requirements == null || requirements.isEmpty) {
      return '필요 재료 계산 불가';
    }

    final Map<String, String> materialNames = <String, String>{
      for (final MaterialEntity material in materials) material.id: material.name,
    };
    return requirements.entries
        .map(
          (MapEntry<String, int> entry) =>
              '${materialNames[entry.key] ?? entry.key} x${entry.value}',
        )
        .join(', ');
  }

  String _queueStatusText({
    required CraftQueueJob job,
    required bool canResume,
  }) {
    if (job.status == QueueJobStatus.blocked) {
      return canResume ? '상태 진행 불가, 재료 보충 후 재개 가능' : '상태 진행 불가, 재료 부족';
    }
    if (job.status == QueueJobStatus.completed) {
      return '상태 완료';
    }
    if (job.status == QueueJobStatus.processing) {
      return '상태 진행 중, ETA ${job.eta.inSeconds}s';
    }
    return '상태 대기 중, ${job.currentRepeat}/${job.repeatCount}';
  }
}
