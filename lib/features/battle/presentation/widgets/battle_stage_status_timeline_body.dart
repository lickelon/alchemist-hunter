import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_stage_status_layout.dart';
import 'package:flutter/material.dart';

class BattleStageStatusTimelineBody extends StatelessWidget {
  const BattleStageStatusTimelineBody({
    super.key,
    required this.controller,
    required this.lines,
  });

  final ScrollController controller;
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      itemExtent: MediaQuery.textScalerOf(
        context,
      ).scale(BattleStageStatusLayout.timelineLineHeight),
      itemCount: lines.length,
      itemBuilder: (BuildContext context, int index) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Text(
            lines[index],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    );
  }
}
