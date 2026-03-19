import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/features/workshop/presentation/workshop_providers.dart';

import 'workshop_enqueue_options_sheet.dart';

class WorkshopCraftCard extends StatelessWidget {
  const WorkshopCraftCard({
    super.key,
    required this.description,
  });

  final String description;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Craft',
      description: description,
      icon: Icons.local_drink_outlined,
      onTap: () => _showCraftSheet(context),
    );
  }

  void _showCraftSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const WorkshopCraftSheet();
      },
    );
  }
}

class WorkshopCraftSheet extends ConsumerWidget {
  const WorkshopCraftSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<PotionQueueOptionView> options = ref.watch(
      workshopPotionQueueOptionViewsProvider,
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                '포션 제조',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: options.isEmpty
                    ? const Center(child: Text('등록 가능한 포션이 없습니다'))
                    : ListView.builder(
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final PotionQueueOptionView option = options[index];
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(option.title),
                            subtitle: Text(
                              option.unlocked
                                  ? option.materialHint
                                  : '잠김: ${option.lockReason}',
                            ),
                            trailing: FilledButton.tonal(
                              onPressed: option.unlocked && option.craftableNow
                                  ? () {
                                      showModalBottomSheet<void>(
                                        context: context,
                                        builder:
                                            (BuildContext bottomSheetContext) {
                                              return WorkshopEnqueueOptionsSheet(
                                                potionId: option.potionId,
                                                title: option.title,
                                                maxCraftableCount:
                                                    option.maxCraftableCount,
                                              );
                                            },
                                      );
                                    }
                                  : null,
                              child: const Text('등록'),
                            ),
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
