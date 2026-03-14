import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/repositories/town_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/town/domain/services/town_skill_tree_service.dart';
import 'package:alchemist_hunter/features/town/domain/use_cases/sell_crafted_potion_use_case.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/workshop_catalog.dart';
import 'package:alchemist_hunter/features/town/town_catalog.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_service_providers.dart';

class TownPotionSaleController {
  TownPotionSaleController(
    this._session, {
    SellCraftedPotionUseCase sellCraftedPotionUseCase =
        const SellCraftedPotionUseCase(),
    required PotionCatalogRepository potionCatalogRepository,
    required TownSkillTreeRepository townSkillTreeRepository,
    required TownSkillTreeService townSkillTreeService,
  }) : _sellCraftedPotionUseCase = sellCraftedPotionUseCase,
       _potionCatalogRepository = potionCatalogRepository,
       _townSkillTreeRepository = townSkillTreeRepository,
       _townSkillTreeService = townSkillTreeService;

  final SessionController _session;
  final SellCraftedPotionUseCase _sellCraftedPotionUseCase;
  final PotionCatalogRepository _potionCatalogRepository;
  final TownSkillTreeRepository _townSkillTreeRepository;
  final TownSkillTreeService _townSkillTreeService;

  void sellCraftedPotion(String stackKey, int quantity) {
    final SessionState current = _session.snapshot();
    final int owned = current.workshop.craftedPotionStacks[stackKey] ?? 0;
    final bool hasEnough = quantity > 0 && owned >= quantity;
    final bool hasDetails = current.workshop.craftedPotionDetails.containsKey(
      stackKey,
    );
    final SessionState nextState = _sellCraftedPotionUseCase.sellCraftedPotion(
      state: current,
      stackKey: stackKey,
      quantity: quantity,
      potionBaseValueLookup: (String potionId) {
        return _potionCatalogRepository.findPotionById(potionId)?.baseValue;
      },
      townSkillTreeRepository: _townSkillTreeRepository,
      townSkillTreeService: _townSkillTreeService,
    );
    final int earned = nextState.player.gold - current.player.gold;
    _session.applyState(nextState);
    _session.appendLog(
      !hasEnough
          ? 'Not enough crafted potion to sell'
          : !hasDetails
          ? 'Potion detail not found'
          : 'Sold potion $stackKey x$quantity for $earned gold',
    );
  }
}

final Provider<TownPotionSaleController> townPotionSaleControllerProvider =
    Provider<TownPotionSaleController>((Ref ref) {
      return TownPotionSaleController(
        ref.read(sessionControllerProvider.notifier),
        potionCatalogRepository: ref.read(potionCatalogRepositoryProvider),
        townSkillTreeRepository: ref.read(townSkillTreeRepositoryProvider),
        townSkillTreeService: ref.read(townSkillTreeServiceProvider),
      );
    });
