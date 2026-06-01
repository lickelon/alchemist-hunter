import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/support/domain/services/workshop_support_service.dart';
import 'package:alchemist_hunter/features/workshop/support/presentation/viewmodels/workshop_support_service_providers.dart';
import 'package:alchemist_hunter/features/workshop/support/presentation/viewmodels/workshop_support_view_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      final Map<String, CharacterProgress> homunculusMap =
          <String, CharacterProgress>{
            for (final CharacterProgress character
                in state.characters.homunculi)
              character.id: character,
          };

      return WorkshopSupportService.slotOrder
          .map((String slotId) {
            final String? characterId = supportService.assignedCharacterId(
              state,
              slotId,
            );
            return WorkshopSupportSlotView(
              slotId: slotId,
              slotLabel: supportService.slotLabel(slotId),
              effectLabel: supportService.slotEffectLabel(slotId),
              assignedCharacterId: characterId,
              assignedCharacterName: characterId == null
                  ? '비어 있음'
                  : homunculusMap[characterId]?.name ?? characterId,
            );
          })
          .toList(growable: false);
    });
