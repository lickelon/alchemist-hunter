import 'package:alchemist_hunter/features/battle/presentation/screens/dungeon_screen.dart';
import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dungeon screen shows locked reason for later stages', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );
    final CharacterProgress merc = session.state.characters.mercenaries.first;
    session.state = session.state.copyWith(
      characters: session.state.characters.copyWith(
        mercenaries: <CharacterProgress>[
          merc.copyWith(
            equipment: CharacterEquipmentLoadout(
              weapon: EquipmentInstance(
                id: 'eq_instance_1',
                blueprintId: 'eq_1',
                name: 'Bronze Sword',
                slot: EquipmentSlot.weapon,
                attack: 12,
                defense: 0,
                health: 0,
                createdAt: DateTime(2026, 1, 1, 10),
              ),
            ),
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: DungeonScreen())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Stage 2'), findsOneWidget);
    expect(find.textContaining('편성 2명 / 전투력 254'), findsOneWidget);
    expect(
      find.textContaining('잠금 조건: 특수 재료 Moontear Crystal 1개 이상 획득'),
      findsOneWidget,
    );
    expect(find.text('Locked'), findsWidgets);

    await tester.tap(find.text('Stage 1'));
    await tester.pumpAndSettle();

    expect(find.text('Stage 1 편성'), findsOneWidget);
    expect(find.text('배치 2/3명 / 전투력 254'), findsOneWidget);
  });
}
