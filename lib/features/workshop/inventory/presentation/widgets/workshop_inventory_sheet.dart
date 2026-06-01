import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/viewmodels/crafted_inventory_selectors.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/extraction_inventory_selectors.dart';
import 'package:alchemist_hunter/features/workshop/inventory/presentation/widgets/workshop_inventory_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkshopInventorySheet extends ConsumerWidget {
  const WorkshopInventorySheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<MaterialInventoryView> materials = ref.watch(
      materialInventoryViewsProvider,
    );
    final List<ExtractedTraitInventoryView> traits = ref.watch(
      extractedTraitViewsProvider,
    );
    final List<CraftedPotionStackView> potions = ref.watch(
      craftedPotionStackViewsProvider,
    );

    return DefaultTabController(
      length: 3,
      child: AppSheetLayout(
        title: '작업실 인벤토리',
        header: const TabBar(
          tabs: <Widget>[
            Tab(text: '재료'),
            Tab(text: '원소'),
            Tab(text: '포션'),
          ],
        ),
        body: TabBarView(
          children: <Widget>[
            InventoryMaterialTab(materials: materials),
            InventoryTraitTab(traits: traits),
            InventoryPotionTab(potions: potions),
          ],
        ),
      ),
    );
  }
}
