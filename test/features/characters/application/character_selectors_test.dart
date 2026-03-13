import 'package:alchemist_hunter/features/characters/application/character_selectors.dart';
import 'package:alchemist_hunter/features/characters/domain/character_models.dart';
import 'package:alchemist_hunter/features/session/application/session_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('character hint selectors reflect rank and tier conditions', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );
    final CharacterProgress target = session.state.characters.mercenaries.first;
    session.state = session.state.copyWith(
      player: session.state.player.copyWith(
        materialInventory: const <String, int>{'tier_mat_mercenary_2': 1},
      ),
      characters: session.state.characters.copyWith(
        mercenaries: <CharacterProgress>[
          target.copyWith(
            rank: target.maxRankForCurrentTier,
            level: target.maxLevelForRank,
          ),
        ],
      ),
    );

    final CharacterListItemView view = container
        .read(mercenaryListItemViewsProvider)
        .first;

    expect(view.rankHint, '현재 티어 최대 랭크 도달');
    expect(view.tierHint, '티어업 가능');
  });
}
