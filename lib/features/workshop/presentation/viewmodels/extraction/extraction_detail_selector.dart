import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/workshop_shared_selectors.dart';
import 'package:alchemist_hunter/features/workshop/workshop_catalog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExtractionTraitOptionView {
  const ExtractionTraitOptionView({
    required this.id,
    required this.name,
    required this.amount,
  });

  final String id;
  final String name;
  final double amount;
}

class ExtractionProfileOptionView {
  const ExtractionProfileOptionView({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.requiresSelection,
  });

  final String id;
  final String title;
  final String subtitle;
  final bool requiresSelection;
}

class MaterialExtractionDetailView {
  const MaterialExtractionDetailView({
    required this.materialId,
    required this.materialName,
    required this.ownedQuantity,
    required this.traits,
    required this.profiles,
  });

  final String materialId;
  final String materialName;
  final int ownedQuantity;
  final List<ExtractionTraitOptionView> traits;
  final List<ExtractionProfileOptionView> profiles;
}

final materialExtractionDetailViewProvider =
    Provider.family<MaterialExtractionDetailView?, String>((
      Ref ref,
      String materialId,
    ) {
      final MaterialEntity? material = ref
          .watch(materialsProvider)
          .where((MaterialEntity entry) => entry.id == materialId)
          .firstOrNull;
      if (material == null) {
        return null;
      }
      final double yieldBonus = ref.watch(
        workshopExtractionYieldBonusRateProvider,
      );
      return MaterialExtractionDetailView(
        materialId: material.id,
        materialName: material.name,
        ownedQuantity: ref.watch(
          sessionControllerProvider.select(
            (SessionState state) =>
                state.player.materialInventory[material.id] ?? 0,
          ),
        ),
        traits: material.traits
            .map(
              (TraitUnit trait) => ExtractionTraitOptionView(
                id: trait.id,
                name: trait.name,
                amount: trait.potency,
              ),
            )
            .toList(),
        profiles: ref
            .watch(extractionProfilesProvider)
            .map(
              (ExtractionProfile profile) => ExtractionProfileOptionView(
                id: profile.id,
                title: profile.mode == ExtractionMode.full ? '전체 추출' : '선택 추출',
                subtitle:
                    '수율 ${(profile.yieldRate * (1 + yieldBonus)).toStringAsFixed(2)} / 순도 ${profile.purityRate.toStringAsFixed(2)}',
                requiresSelection: profile.mode == ExtractionMode.selective,
              ),
            )
            .toList(),
      );
    });
