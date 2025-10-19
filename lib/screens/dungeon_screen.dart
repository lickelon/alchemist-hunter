import 'package:alchemist_hunter/common/widgets/list_card.dart';
import 'package:flutter/material.dart';

class DungeonScreen extends StatefulWidget {
  const DungeonScreen({super.key});

  @override
  State<DungeonScreen> createState() => _DungeonScreenState();
}

class _DungeonScreenState extends State<DungeonScreen> {
  @override
  Widget build(BuildContext context) {
    return const DungeonListView();
  }
}

class DungeonListView extends StatefulWidget {
  const DungeonListView({super.key});

  @override
  State<DungeonListView> createState() => _DungeonListViewState();
}

class _DungeonListViewState extends State<DungeonListView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return DungeonListCard(
          dungeonName: 'Dungeon Name ${index + 1}',
          dungeonDescription: 'Dungeon Description ${index + 1}',
        );
      },
    );
  }
}

class DungeonListCard extends StatefulWidget {
  final String dungeonName;
  final String dungeonDescription;
  const DungeonListCard({
    super.key,
    required this.dungeonName,
    required this.dungeonDescription,
  });

  @override
  State<DungeonListCard> createState() => _DungeonListCardState();
}

class _DungeonListCardState extends State<DungeonListCard> {
  @override
  Widget build(BuildContext context) {
    return ListCard(
      name: widget.dungeonName,
      description: widget.dungeonDescription,
      buttonText: 'Enter',
    );
  }
}
