import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/alchemy_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/extraction_profile_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/material_catalog_repository.dart';

class WorkshopExtractionUseCase {
  const WorkshopExtractionUseCase();

  SessionState extractMaterial({
    required SessionState state,
    required String materialId,
    required String profileId,
    required AlchemyService alchemyService,
    required MaterialCatalogRepository materialCatalogRepository,
    required ExtractionProfileRepository extractionProfileRepository,
    int quantity = 1,
    List<String>? selectedTraits,
  }) {
    final int owned = state.player.materialInventory[materialId] ?? 0;
    if (owned <= 0 || quantity <= 0 || owned < quantity) {
      return state;
    }

    final MaterialEntity? material = materialCatalogRepository.findMaterialById(
      materialId,
    );
    final ExtractionProfile? profile = extractionProfileRepository
        .findProfileById(profileId);
    if (material == null || profile == null) {
      return state;
    }
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
    final int nextCount = owned - quantity;
    if (nextCount <= 0) {
      materials.remove(materialId);
    } else {
      materials[materialId] = nextCount;
    }

    final Map<String, double> inventory = <String, double>{
      ...state.workshop.extractedTraitInventory,
    };
    extractedTraits.forEach((String traitId, double amount) {
      inventory[traitId] = (inventory[traitId] ?? 0) + (amount * quantity);
    });

    return state.copyWith(
      player: state.player.copyWith(
        materialInventory: materials,
        arcaneDust: state.player.arcaneDust + quantity,
      ),
      workshop: state.workshop.copyWith(
        extractedTraitInventory: inventory,
        extractionCount: state.workshop.extractionCount + quantity,
      ),
    );
  }
}
