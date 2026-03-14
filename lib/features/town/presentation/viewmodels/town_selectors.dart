import 'package:alchemist_hunter/core/session/session_providers.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<int> townGoldProvider = Provider<int>((Ref ref) {
  return ref.watch(
    sessionControllerProvider.select((SessionState state) => state.player.gold),
  );
});

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
