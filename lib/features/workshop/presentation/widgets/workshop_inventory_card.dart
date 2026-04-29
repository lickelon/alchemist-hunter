import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/features/workshop/presentation/workshop_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkshopInventoryCard extends StatelessWidget {
  const WorkshopInventoryCard({
    super.key,
    required this.materialTypeCount,
    required this.traitTypeCount,
    required this.potionStackCount,
  });

  final int materialTypeCount;
  final int traitTypeCount;
  final int potionStackCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: 'Inventory',
      summary: potionStackCount > 0
          ? '보유 포션 $potionStackCount스택'
          : traitTypeCount > 0
          ? '보유 특성 $traitTypeCount종'
          : materialTypeCount > 0
          ? '보유 재료 $materialTypeCount종'
          : '보관 중인 자원 없음',
      icon: Icons.inventory_2_outlined,
      onTap: () => _showInventorySheet(context),
    );
  }

  void _showInventorySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const WorkshopInventorySheet();
      },
    );
  }
}

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
      child: AppBottomSheet(
        child: AppSheetLayout(
          title: '작업실 인벤토리',
          header: const TabBar(
            tabs: <Widget>[
              Tab(text: '재료'),
              Tab(text: '특성'),
              Tab(text: '포션'),
            ],
          ),
          body: TabBarView(
            children: <Widget>[
              _InventoryMaterialTab(materials: materials),
              _InventoryTraitTab(traits: traits),
              _InventoryPotionTab(potions: potions),
            ],
          ),
        ),
      ),
    );
  }
}

class _InventoryMaterialTab extends StatelessWidget {
  const _InventoryMaterialTab({required this.materials});

  final List<MaterialInventoryView> materials;

  @override
  Widget build(BuildContext context) {
    if (materials.isEmpty) {
      return const Center(child: Text('보유 재료가 없습니다'));
    }
    return ListView.builder(
      itemCount: materials.length,
      itemBuilder: (BuildContext context, int index) {
        final MaterialInventoryView entry = materials[index];
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(entry.name),
          subtitle: Text('${entry.rarity.name} / ${entry.traitSummary}'),
          trailing: Text('x${entry.quantity}'),
        );
      },
    );
  }
}

class _InventoryTraitTab extends StatelessWidget {
  const _InventoryTraitTab({required this.traits});

  final List<ExtractedTraitInventoryView> traits;

  @override
  Widget build(BuildContext context) {
    if (traits.isEmpty) {
      return const Center(child: Text('보유 추출 특성이 없습니다'));
    }
    return ListView.builder(
      itemCount: traits.length,
      itemBuilder: (BuildContext context, int index) {
        final ExtractedTraitInventoryView entry = traits[index];
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(entry.name),
          trailing: Text(entry.amount.toStringAsFixed(2)),
        );
      },
    );
  }
}

class _InventoryPotionTab extends StatelessWidget {
  const _InventoryPotionTab({required this.potions});

  final List<CraftedPotionStackView> potions;

  @override
  Widget build(BuildContext context) {
    if (potions.isEmpty) {
      return const Center(child: Text('보유 포션이 없습니다'));
    }
    return ListView.builder(
      itemCount: potions.length,
      itemBuilder: (BuildContext context, int index) {
        final CraftedPotionStackView entry = potions[index];
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text('${entry.stackKey} x${entry.quantity}'),
          subtitle: Text(
            '품질 ${entry.qualityLabel} / 점수 ${entry.scoreLabel}\n특성 ${entry.traitsLabel}',
          ),
        );
      },
    );
  }
}
