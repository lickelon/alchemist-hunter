import 'package:alchemist_hunter/app/catalog/app_catalog_providers.dart';
import 'package:alchemist_hunter/features/battle/presentation/screens/dungeon_screen.dart';
import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/app/session/session_progress_sync_controller.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/themes/app_theme.dart';
import 'package:alchemist_hunter/common/widgets/app_toast.dart';
import 'package:alchemist_hunter/features/characters/presentation/screens/characters_screen.dart';
import 'package:alchemist_hunter/app/session_sync_scope.dart';
import 'package:alchemist_hunter/features/town/presentation/screens/town_screen.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/dashboard/presentation/screens/workshop_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alchemist Hunter',
      theme: AppTheme.light,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SessionSyncScope(
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: const _HomeAppBar(),
          drawer: const _HomeDrawer(),
          bottomNavigationBar: const _MainTabBar(),
          body: const TabBarView(
            children: <Widget>[
              TownScreen(),
              WorkshopScreen(),
              CharactersScreen(),
              DungeonScreen(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double timeAcceleration = ref.watch(
      sessionControllerProvider.select(
        (SessionState state) => state.player.timeAcceleration,
      ),
    );
    final int diamonds = ref.watch(
      sessionControllerProvider.select(
        (SessionState state) => state.player.diamonds,
      ),
    );
    return AppBar(
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            key: const ValueKey<String>('main_menu_button'),
            tooltip: '메뉴',
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(Icons.menu),
          );
        },
      ),
      title: const Text('Alchemist Hunter', overflow: TextOverflow.ellipsis),
      actions: <Widget>[
        TextButton.icon(
          onPressed: () {
            ref.read(sessionProgressSyncControllerProvider).sync();
            final SessionController session = ref.read(
              sessionControllerProvider.notifier,
            );
            final SessionState current = session.snapshot();
            final double nextSpeed = _nextAcceleration(
              current.player.timeAcceleration,
            );
            session.applyState(
              current.copyWith(
                player: current.player.copyWith(timeAcceleration: nextSpeed),
              ),
            );
            session.appendLog('시간 가속 x${_speedLabel(nextSpeed)}');
          },
          icon: const Icon(Icons.timer),
          label: Text('x${_speedLabel(timeAcceleration)}'),
        ),
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: Row(
            children: <Widget>[
              const Icon(Icons.diamond),
              const SizedBox(width: AppSpacing.sm),
              Text('다이아 $diamonds'),
            ],
          ),
        ),
      ],
      titleSpacing: AppSpacing.md,
      actionsPadding: EdgeInsets.zero,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  double _nextAcceleration(double current) {
    const List<double> speeds = <double>[1, 2, 4, 8, 30];
    final int currentIndex = speeds.indexOf(current);
    if (currentIndex == -1 || currentIndex == speeds.length - 1) {
      return speeds.first;
    }
    return speeds[currentIndex + 1];
  }

  String _speedLabel(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}

class _HomeDrawer extends ConsumerWidget {
  const _HomeDrawer();

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

class _MainTabBar extends StatelessWidget {
  const _MainTabBar();

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: TabBar(
        tabs: <Widget>[
          Tab(icon: Icon(Icons.location_city), text: '마을'),
          Tab(icon: Icon(Icons.science), text: '작업실'),
          Tab(icon: Icon(Icons.person), text: '캐릭터'),
          Tab(icon: Icon(Icons.shield), text: '전투'),
        ],
      ),
    );
  }
}
