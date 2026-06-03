import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/support/domain/services/workshop_support_service.dart';
import 'package:alchemist_hunter/features/workshop/support/presentation/viewmodels/workshop_support_assignment_selectors.dart';
import 'package:alchemist_hunter/features/workshop/support/presentation/viewmodels/workshop_support_labels.dart';
import 'package:alchemist_hunter/features/workshop/support/presentation/viewmodels/workshop_support_service_providers.dart';
import 'package:alchemist_hunter/features/workshop/support/presentation/viewmodels/workshop_support_view_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workshopSupportCandidateViewsProvider =
    Provider.family<List<WorkshopSupportCandidateView>, String>((
      Ref ref,
      String slotId,
    ) {
      final SessionState state = ref.watch(sessionControllerProvider);
      final Map<String, String> assignments = ref.watch(
        workshopSupportAssignmentsProvider,
      );
      final Map<String, List<String>> stageAssignments = ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.battle.stageAssignments,
        ),
      );
      final WorkshopSupportService supportService = ref.watch(
        workshopSupportServiceProvider,
      );
      final int assignedCount = assignments.length;
      final bool slotOccupiedByOther = assignments.containsKey(slotId);

      final List<WorkshopSupportCandidateView> views = state
          .characters
          .homunculi
          .map((CharacterProgress character) {
            final String? assignedSlot =
                assignedWorkshopSupportSlotLabelForCharacter(
                  supportService,
                  state,
                  character.id,
                );
            final String? assignedStage = stageAssignments.entries
                .where((MapEntry<String, List<String>> entry) {
                  return entry.value.contains(character.id);
                })
                .map((MapEntry<String, List<String>> entry) {
                  return entry.key.replaceFirst('stage_', 'Stage ');
                })
                .firstOrNull;
            final bool selectedForSlot = assignments[slotId] == character.id;
            final bool assignedElsewhere =
                (assignedSlot != null &&
                    assignedSlot != workshopSupportSlotLabel(slotId)) ||
                assignedStage != null;
            final bool assignable =
                selectedForSlot ||
                !slotOccupiedByOther &&
                    !assignedElsewhere &&
                    assignedCount < WorkshopSupportService.maxAssignedCount;
            return WorkshopSupportCandidateView(
              id: character.id,
              name: character.name,
              roleLabel: character.homunculusRole ?? '지원',
              supportEffectLabel:
                  character.homunculusSupportEffect ?? '보조 효과 분석 중',
              assignedToSlotLabel: assignedStage ?? assignedSlot,
              selectedForSlot: selectedForSlot,
              assignable: assignable,
            );
          })
          .toList(growable: false);

      views.sort((
        WorkshopSupportCandidateView left,
        WorkshopSupportCandidateView right,
      ) {
        if (left.selectedForSlot == right.selectedForSlot) {
          return left.name.compareTo(right.name);
        }
        return left.selectedForSlot ? -1 : 1;
      });
      return views;
    });
