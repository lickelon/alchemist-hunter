import 'package:alchemist_hunter/common/widgets/app_bottom_sheet.dart';
import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:alchemist_hunter/features/workshop/crafting/presentation/widgets/workshop_brew_experiment_tab.dart';
import 'package:flutter/material.dart';

class WorkshopResearchCard extends StatelessWidget {
  const WorkshopResearchCard({super.key, required this.traitTypeCount});

  final int traitTypeCount;

  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: '연구',
      summary: traitTypeCount == 0 ? '원소 없음' : '원소 $traitTypeCount종',
      icon: Icons.science_outlined,
      onTap: () {
        showAppBottomSheet<void>(
          context: context,
          builder: (BuildContext context) {
            return const AppSheetLayout(
              title: '연구',
              body: WorkshopBrewExperimentTab(),
            );
          },
        );
      },
    );
  }
}
