import 'package:alchemist_hunter/features/battle/presentation/screens/dungeon_screen.dart';
import 'package:alchemist_hunter/features/characters/presentation/screens/characters_screen.dart';
import 'package:alchemist_hunter/app/session_sync_scope.dart';
import 'package:alchemist_hunter/features/town/presentation/screens/town_screen.dart';
import 'package:alchemist_hunter/features/workshop/presentation/screens/workshop_screen.dart';
import 'package:flutter/material.dart';

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

class _HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _HomeAppBar();

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: const Icon(Icons.menu),
      title: const Text('Alchemist Hunter', overflow: TextOverflow.ellipsis),
      actions: const <Widget>[
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
