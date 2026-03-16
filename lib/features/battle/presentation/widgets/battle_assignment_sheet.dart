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

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.72,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${stageId.replaceFirst("stage_", "Stage ")} 편성',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text('배치 ${assignedIds.length}/3명 / 전투력 $partyPower'),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: characters.map((BattleAssignmentCharacterView character) {
                    return CheckboxListTile(
                      value: character.assigned,
                      onChanged: character.assignable
                          ? (_) {
                              ref
                                  .read(battleControllerProvider)
                                  .toggleStageAssignment(stageId, character.id);
                            }
                          : null,
                      title: Text(character.name),
                      subtitle: Text(
                        '${character.typeLabel} / 전투력 ${character.power}${character.assignmentHint.isNotEmpty ? " / ${character.assignmentHint}" : character.assignable ? "" : " / 파티가 가득 참"}',
                      ),
                      controlAffinity: ListTileControlAffinity.trailing,
                    );
                  }).toList(growable: false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
