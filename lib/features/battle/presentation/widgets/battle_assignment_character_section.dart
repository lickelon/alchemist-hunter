import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_assignment_view_models.dart';
import 'package:alchemist_hunter/features/battle/presentation/viewmodels/battle_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BattleAssignmentCharacterSection extends ConsumerWidget {
  const BattleAssignmentCharacterSection({
    super.key,
    required this.stageId,
    required this.characters,
  });

  final String stageId;
  final List<BattleAssignmentCharacterView> characters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: characters
          .map((BattleAssignmentCharacterView character) {
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
              subtitle: _AssignmentSubtitle(character: character),
              controlAffinity: ListTileControlAffinity.trailing,
            );
          })
          .toList(growable: false),
    );
  }
}

class _AssignmentSubtitle extends StatelessWidget {
  const _AssignmentSubtitle({required this.character});

  final BattleAssignmentCharacterView character;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle? detailStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final TextStyle? errorStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.error,
    );
    final String? statusLine = character.assignmentHint.isNotEmpty
        ? character.assignmentHint
        : character.assignable
        ? null
        : '파티가 가득 참';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          '${character.typeLabel} / 전투력 ${character.power}',
          style: detailStyle,
        ),
        if (statusLine != null) ...<Widget>[
          const SizedBox(height: AppSpacing.xs),
          Text(
            statusLine,
            style: character.assignmentHint.isEmpty ? errorStyle : detailStyle,
          ),
        ],
      ],
    );
  }
}
