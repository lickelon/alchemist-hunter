import 'package:alchemist_hunter/common/widgets/app_badge.dart';
import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/widgets/workshop_brew_recipe_book_tab.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/widgets/workshop_material_craft_tab.dart';
import 'package:alchemist_hunter/features/workshop/shared/presentation/viewmodels/workshop_resource_selectors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkshopCraftCard extends StatelessWidget {
  const WorkshopCraftCard({
    super.key,
    required this.brewCraftableCount,
    required this.materialCraftableCount,
  });

  final int brewCraftableCount;
  final int materialCraftableCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: '연금술',
      summary: brewCraftableCount == 0 && materialCraftableCount == 0
          ? '등록 없음'
          : '양조 $brewCraftableCount종, 제작 $materialCraftableCount종',
      icon: Icons.local_drink_outlined,
      onTap: () => _showCraftSheet(context),
    );
  }

  void _showCraftSheet(BuildContext context) {
    showAppBottomSheet<void>(
      context: context,
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
    final int queueLength = ref.watch(
      sessionControllerProvider.select(
        (SessionState state) => state.workshop.queue.length,
      ),
    );
    final int queueCapacity = ref.watch(workshopQueueCapacityProvider);
    final bool queueFull = queueLength >= queueCapacity;

    return DefaultTabController(
      length: 2,
      child: AppSheetLayout(
        title: '연금술',
        header: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (queueFull) ...<Widget>[
              Row(
                children: <Widget>[
                  AppBadge(label: '큐 가득 참 $queueLength/$queueCapacity'),
                ],
              ),
              const SizedBox(height: 12),
            ],
            const TabBar(
              tabs: <Widget>[
                Tab(text: '양조'),
                Tab(text: '제작'),
              ],
            ),
          ],
        ),
        body: const TabBarView(
          children: <Widget>[
            WorkshopBrewRecipeBookTab(),
            WorkshopMaterialCraftTab(),
          ],
        ),
      ),
    );
  }
}
