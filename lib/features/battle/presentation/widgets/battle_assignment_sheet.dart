import 'package:alchemist_hunter/common/widgets/app_sheet_layout.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_assignment_character_section.dart';
import 'package:alchemist_hunter/features/battle/presentation/widgets/battle_assignment_potion_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/features/battle/presentation/battle_providers.dart';

class BattleAssignmentSheet extends ConsumerWidget {
  const BattleAssignmentSheet({super.key, required this.stageId});

  final String stageId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> assignedIds = ref.watch(
      battleStageAssignmentProvider(stageId),
    );
    final int partyPower = ref.watch(battleStagePartyPowerProvider(stageId));
    final List<BattleAssignmentCharacterView> characters = ref.watch(
      battleStageAssignmentCharacterViewsProvider(stageId),
    );
    final List<BattleAssignmentPotionView> potions = ref.watch(
      battleStageAssignmentPotionViewsProvider(stageId),
    );
    final String stageName = ref.watch(battleStageDisplayNameProvider(stageId));

    return AppSheetLayout(
      title: '$stageName 편성',
      header: Text('배치 ${assignedIds.length}/3명 / 전투력 $partyPower'),
      body: ListView(
        children: <Widget>[
          BattleAssignmentCharacterSection(
            stageId: stageId,
            characters: characters,
          ),
          const Divider(),
          BattleAssignmentPotionSection(stageId: stageId, potions: potions),
        ],
      ),
    );
  }
}
