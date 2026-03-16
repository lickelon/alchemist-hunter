import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_support_service.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/workshop_service_providers.dart';

class WorkshopSupportSlotView {
  const WorkshopSupportSlotView({
    required this.slotId,
    required this.slotLabel,
    required this.effectLabel,
    required this.assignedCharacterId,
    required this.assignedCharacterName,
  });

  final String slotId;
  final String slotLabel;
  final String effectLabel;
  final String? assignedCharacterId;
  final String assignedCharacterName;
}

class WorkshopSupportCandidateView {
  const WorkshopSupportCandidateView({
    required this.id,
    required this.name,
    required this.roleLabel,
    required this.supportEffectLabel,
    required this.assignedToSlotLabel,
    required this.selectedForSlot,
    required this.assignable,
  });

  final String id;
  final String name;
  final String roleLabel;
  final String supportEffectLabel;
  final String? assignedToSlotLabel;
  final bool selectedForSlot;
  final bool assignable;
}

final Provider<int> workshopSupportSlotLimitProvider = Provider<int>((Ref ref) {
  return WorkshopSupportService.maxAssignedCount;
});

final Provider<Map<String, String>> workshopSupportAssignmentsProvider =
    Provider<Map<String, String>>((Ref ref) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.workshop.supportAssignmentsByFunction,
        ),
      );
    });

final Provider<int> workshopSupportAssignedCountProvider = Provider<int>((
  Ref ref,
) {
  return ref.watch(
    workshopSupportAssignmentsProvider.select(
      (Map<String, String> assignments) => assignments.length,
    ),
  );
});

final Provider<String> workshopSupportSummaryProvider = Provider<String>((
  Ref ref,
) {
  final SessionState state = ref.watch(sessionControllerProvider);
  return ref.watch(workshopSupportServiceProvider).summaryLabel(state);
});

final Provider<List<WorkshopSupportSlotView>> workshopSupportSlotViewsProvider =
    Provider<List<WorkshopSupportSlotView>>((Ref ref) {
      final SessionState state = ref.watch(sessionControllerProvider);
      final WorkshopSupportService supportService = ref.watch(
        workshopSupportServiceProvider,
      );
      final Map<String, CharacterProgress> homunculusMap = <String, CharacterProgress>{
        for (final CharacterProgress character in state.characters.homunculi)
          character.id: character,
      };

      return WorkshopSupportService.slotOrder.map((String slotId) {
        final String? characterId = supportService.assignedCharacterId(
          state,
          slotId,
        );
        return WorkshopSupportSlotView(
          slotId: slotId,
          slotLabel: supportService.slotLabel(slotId),
          effectLabel: supportService.slotEffectLabel(slotId),
          assignedCharacterId: characterId,
          assignedCharacterName:
              characterId == null ? '비어 있음' : homunculusMap[characterId]?.name ?? characterId,
        );
      }).toList(growable: false);
    });

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

      final List<WorkshopSupportCandidateView> views = state.characters.homunculi.map((
        CharacterProgress character,
      ) {
        final String? assignedSlot = supportService.assignedSlotLabelForCharacter(
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
                assignedSlot != supportService.slotLabel(slotId)) ||
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
          supportEffectLabel: character.homunculusSupportEffect ?? '보조 효과 분석 중',
          assignedToSlotLabel: assignedStage ?? assignedSlot,
          selectedForSlot: selectedForSlot,
          assignable: assignable,
        );
      }).toList(growable: false);

      views.sort((WorkshopSupportCandidateView left, WorkshopSupportCandidateView right) {
        if (left.selectedForSlot == right.selectedForSlot) {
          return left.name.compareTo(right.name);
        }
        return left.selectedForSlot ? -1 : 1;
      });
      return views;
    });
