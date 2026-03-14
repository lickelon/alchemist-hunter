import 'package:alchemist_hunter/features/characters/presentation/character_providers.dart';
import 'package:alchemist_hunter/features/characters/domain/character_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CharactersScreen extends ConsumerWidget {
  const CharactersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CharacterListItemView> mercenaries = ref.watch(
      mercenaryListItemViewsProvider,
    );
    final List<CharacterListItemView> homunculi = ref.watch(
      homunculusListItemViewsProvider,
    );
    final CharacterController controller = ref.read(
      characterControllerProvider,
    );

    return DefaultTabController(
      length: 2,
      child: Column(
        children: <Widget>[
          const TabBar(
            tabs: <Widget>[
              Tab(text: 'Mercenary'),
              Tab(text: 'Homunculus'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: <Widget>[
                _CharacterList(
                  characters: mercenaries,
                  onRankUp: (String id) =>
                      controller.rankUp(CharacterType.mercenary, id),
                  onTierUp: (String id) =>
                      controller.tierUp(CharacterType.mercenary, id),
                ),
                _CharacterList(
                  characters: homunculi,
                  onRankUp: (String id) =>
                      controller.rankUp(CharacterType.homunculus, id),
                  onTierUp: (String id) =>
                      controller.tierUp(CharacterType.homunculus, id),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterList extends ConsumerWidget {
  const _CharacterList({
    required this.characters,
    required this.onRankUp,
    required this.onTierUp,
  });

  final List<CharacterListItemView> characters;
  final ValueChanged<String> onRankUp;
  final ValueChanged<String> onTierUp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (characters.isEmpty) {
      return const Center(child: Text('No characters'));
    }
    return ListView(
      padding: const EdgeInsets.all(8),
      children: characters.map((CharacterListItemView item) {
        final CharacterProgress character = item.character;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  character.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Lv ${character.level} / Rank ${character.rank} / Tier ${character.tierIndex}',
                ),
                Text(
                  'XP ${character.xp}/${character.xpToNextLevel} / MaxLv ${character.maxLevelForRank}',
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: <Widget>[
                    FilledButton.tonal(
                      onPressed: character.canRankUp
                          ? () => onRankUp(character.id)
                          : null,
                      child: const Text('Rank Up'),
                    ),
                    FilledButton.tonal(
                      onPressed: character.canTierUp
                          ? () => onTierUp(character.id)
                          : null,
                      child: const Text('Tier Up'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item.rankHint,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  item.tierHint,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
