import 'package:alchemist_hunter/features/characters/domain/character_models.dart';
import 'package:alchemist_hunter/features/characters/presentation/screens/characters_screen.dart';
import 'package:alchemist_hunter/features/session/application/session_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('character screen shows rank and tier unlock hints', (
    WidgetTester tester,
  ) async {
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

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: CharactersScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('현재 티어 최대 랭크 도달'), findsOneWidget);
    expect(find.text('티어업 가능'), findsOneWidget);
  });
}
