import 'package:alchemist_hunter/app/home_app_bar.dart';
import 'package:alchemist_hunter/app/home_drawer.dart';
import 'package:alchemist_hunter/app/main_tab_bar.dart';
import 'package:alchemist_hunter/app/session_sync_scope.dart';
import 'package:alchemist_hunter/features/battle/presentation/screens/dungeon_screen.dart';
import 'package:alchemist_hunter/features/characters/presentation/screens/characters_screen.dart';
import 'package:alchemist_hunter/features/town/presentation/screens/town_screen.dart';
import 'package:alchemist_hunter/features/workshop/dashboard/presentation/screens/workshop_screen.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SessionSyncScope(
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: const HomeAppBar(),
          drawer: const HomeDrawer(),
          bottomNavigationBar: const MainTabBar(),
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
