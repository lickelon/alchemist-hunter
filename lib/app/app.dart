import 'package:alchemist_hunter/features/battle/presentation/screens/dungeon_screen.dart';
import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/app/session/session_progress_sync_controller.dart';
import 'package:alchemist_hunter/features/characters/presentation/screens/characters_screen.dart';
import 'package:alchemist_hunter/app/session_sync_scope.dart';
import 'package:alchemist_hunter/features/town/presentation/screens/town_screen.dart';
import 'package:alchemist_hunter/features/workshop/presentation/screens/workshop_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alchemist Hunter',
      theme: ThemeData(colorSchemeSeed: Colors.orange, useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SessionSyncScope(
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: _HomeAppBar(),
          bottomNavigationBar: _MainTabBar(),
          body: TabBarView(
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
    return AppBar(
      leading: const Icon(Icons.menu),
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
          padding: EdgeInsets.only(right: 12),
          child: Row(
            children: <Widget>[
              Text('Diamonds'),
              SizedBox(width: 4),
              Icon(Icons.diamond),
            ],
          ),
        ),
      ],
      titleSpacing: 8,
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

class _MainTabBar extends StatelessWidget {
  const _MainTabBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: TabBar(
        indicatorColor: Colors.transparent,
        labelPadding: EdgeInsets.zero,
        splashFactory: NoSplash.splashFactory,
        labelColor: Colors.orange,
        unselectedLabelColor: Colors.grey,
        tabs: const <Widget>[
          Tab(icon: Icon(Icons.location_city), text: 'Town'),
          Tab(icon: Icon(Icons.science), text: 'Workshop'),
          Tab(icon: Icon(Icons.person), text: 'Characters'),
          Tab(icon: Icon(Icons.shield), text: 'Battle'),
        ],
      ),
    );
  }
}
