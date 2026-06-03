import 'package:flutter/material.dart';

class MainTabBar extends StatelessWidget {
  const MainTabBar({super.key});

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
