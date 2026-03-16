import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/presentation/viewmodels/town_service_providers.dart';
import 'package:alchemist_hunter/features/town/town_catalog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<ShopState> generalShopStateProvider = Provider<ShopState>((
  Ref ref,
) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.town.generalShop,
    ),
  );
});

final Provider<ShopState> catalystShopStateProvider = Provider<ShopState>((
  Ref ref,
) {
  return ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.town.catalystShop,
    ),
  );
});

final Provider<int> generalShopRefreshCostProvider = Provider<int>((Ref ref) {
  final SessionState state = ref.watch(sessionControllerProvider);
  final ShopState shop = ref.watch(generalShopStateProvider);
  final service = ref.watch(townSkillTreeServiceProvider);
  final double discountRate = service.shopRefreshDiscountRate(
    state,
    ref.watch(townSkillNodesProvider),
  );
  return service.discountedGoldCost(
    baseCost: shop.forcedRefreshCost,
    discountRate: discountRate,
  );
});

final Provider<int> catalystShopRefreshCostProvider = Provider<int>((Ref ref) {
  final SessionState state = ref.watch(sessionControllerProvider);
  final ShopState shop = ref.watch(catalystShopStateProvider);
  final service = ref.watch(townSkillTreeServiceProvider);
  final double discountRate = service.shopRefreshDiscountRate(
    state,
    ref.watch(townSkillNodesProvider),
  );
  return service.discountedGoldCost(
    baseCost: shop.forcedRefreshCost,
    discountRate: discountRate,
  );
});
