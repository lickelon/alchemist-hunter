import 'package:alchemist_hunter/core/session/session_providers.dart';
import 'package:alchemist_hunter/features/workshop/data/catalogs/extraction_profiles.dart';
import 'package:alchemist_hunter/features/workshop/data/catalogs/material_catalog.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/alchemy_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

class WorkshopExtractionUseCase {
  const WorkshopExtractionUseCase();

  SessionState extractMaterial({
    required SessionState state,
    required String materialId,
    required String profileId,
    required AlchemyService alchemyService,
    List<String>? selectedTraits,
  }) {
    final int owned = state.player.materialInventory[materialId] ?? 0;
    if (owned <= 0) {
      return state;
    }

    final MaterialEntity material = materialCatalog.firstWhere(
      (MaterialEntity entry) => entry.id == materialId,
      orElse: () => throw ArgumentError('Material not found: $materialId'),
    );
    final ExtractionProfile profile = extractionProfileCatalog.firstWhere(
      (ExtractionProfile entry) => entry.id == profileId,
      orElse: () =>
          throw ArgumentError('ExtractionProfile not found: $profileId'),
    );
    if (profile.mode == ExtractionMode.selective &&
        (selectedTraits == null || selectedTraits.isEmpty)) {
      return state;
    }

    final Map<String, double> extractedTraits = alchemyService
        .extractTraitInventory(
          material: material,
          profile: profile,
          selectedTraits: selectedTraits,
        );
    if (extractedTraits.isEmpty) {
      return state;
    }

    final Map<String, int> materials = <String, int>{
      ...state.player.materialInventory,
    };
    final int nextCount = owned - 1;
    if (nextCount <= 0) {
      materials.remove(materialId);
    } else {
      materials[materialId] = nextCount;
    }

    final Map<String, double> inventory = <String, double>{
      ...state.workshop.extractedTraitInventory,
    };
    extractedTraits.forEach((String traitId, double amount) {
      inventory[traitId] = (inventory[traitId] ?? 0) + amount;
    });

    return state.copyWith(
      player: state.player.copyWith(materialInventory: materials),
      workshop: state.workshop.copyWith(extractedTraitInventory: inventory),
    );
  }
}
