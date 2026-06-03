import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_toast.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeDrawer extends ConsumerWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<MaterialEntity> materials = ref.watch(materialsProvider);
    final List<TraitUnit> traits = ref.watch(traitsProvider);
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            Text('메뉴', style: Theme.of(context).textTheme.titleMedium),
            if (kDebugMode) ...<Widget>[
              const SizedBox(height: AppSpacing.lg),
              Text('디버그', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppSpacing.md),
              FilledButton.tonalIcon(
                key: const ValueKey<String>('debug_grant_materials_button'),
                onPressed: () {
                  _grantMaterials(
                    ref,
                    materials
                        .where((MaterialEntity material) => material.analyzable)
                        .map((MaterialEntity material) => material.id),
                    10,
                    '일반 재료 +10',
                  );
                  AppToast.show(context, '일반 재료를 지급했습니다');
                },
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('일반 재료 +10'),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.tonalIcon(
                key: const ValueKey<String>('debug_grant_promotion_button'),
                onPressed: () {
                  _grantMaterials(
                    ref,
                    materials
                        .where(
                          (MaterialEntity material) =>
                              material.id.startsWith('promo_core_') ||
                              material.id.startsWith('tier_mat_'),
                        )
                        .map((MaterialEntity material) => material.id),
                    5,
                    '승급 재료 +5',
                  );
                  AppToast.show(context, '승급 재료를 지급했습니다');
                },
                icon: const Icon(Icons.upgrade_outlined),
                label: const Text('승급 재료 +5'),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.tonalIcon(
                key: const ValueKey<String>('debug_grant_traits_button'),
                onPressed: () {
                  _grantTraits(
                    ref,
                    traits.map((TraitUnit trait) => trait.id),
                    10,
                  );
                  AppToast.show(context, '추출 원소를 지급했습니다');
                },
                icon: const Icon(Icons.auto_awesome_outlined),
                label: const Text('추출 원소 +10'),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.tonalIcon(
                key: const ValueKey<String>('debug_grant_currencies_button'),
                onPressed: () {
                  _grantCurrencies(ref);
                  AppToast.show(context, '재화를 지급했습니다');
                },
                icon: const Icon(Icons.add_card_outlined),
                label: const Text('재화 지급'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _grantMaterials(
    WidgetRef ref,
    Iterable<String> materialIds,
    int quantity,
    String logLabel,
  ) {
    final SessionController session = ref.read(
      sessionControllerProvider.notifier,
    );
    final SessionState current = session.snapshot();
    final Map<String, int> inventory = <String, int>{
      ...current.player.materialInventory,
    };
    for (final String materialId in materialIds) {
      inventory[materialId] = (inventory[materialId] ?? 0) + quantity;
    }
    session.applyState(
      current.copyWith(
        player: current.player.copyWith(materialInventory: inventory),
      ),
    );
    session.appendLog('디버그 지급 / $logLabel');
  }

  void _grantTraits(WidgetRef ref, Iterable<String> traitIds, double amount) {
    final SessionController session = ref.read(
      sessionControllerProvider.notifier,
    );
    final SessionState current = session.snapshot();
    final Map<String, double> inventory = <String, double>{
      ...current.workshop.extractedTraitInventory,
    };
    for (final String traitId in traitIds) {
      inventory[traitId] = (inventory[traitId] ?? 0) + amount;
    }
    session.applyState(
      current.copyWith(
        workshop: current.workshop.copyWith(extractedTraitInventory: inventory),
      ),
    );
    session.appendLog('디버그 지급 / 추출 원소 +${amount.toInt()}');
  }

  void _grantCurrencies(WidgetRef ref) {
    final SessionController session = ref.read(
      sessionControllerProvider.notifier,
    );
    final SessionState current = session.snapshot();
    session.applyState(
      current.copyWith(
        player: current.player.copyWith(
          gold: current.player.gold + 5000,
          essence: current.player.essence + 500,
          arcaneDust: current.player.arcaneDust + 50,
          diamonds: current.player.diamonds + 100,
        ),
      ),
    );
    session.appendLog('디버그 지급 / 재화');
  }
}
