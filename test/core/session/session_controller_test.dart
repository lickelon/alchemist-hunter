import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/catalog_fixtures.dart';

void main() {
  test('applyState replaces current snapshot without feature rules', () {
    final DateTime now = DateTime(2026, 1, 1, 10);
    final SessionController session = SessionController(
      initialState: createTestInitialSessionState(now),
      clock: () => now,
    );

    final SessionState nextState = session.state.copyWith(
      player: session.state.player.copyWith(gold: 999),
    );
    session.applyState(nextState);

    expect(session.snapshot().player.gold, 999);
  });

  test('appendLog deduplicates consecutive identical messages', () {
    final DateTime now = DateTime(2026, 1, 1, 10);
    final SessionController session = SessionController(
      initialState: createTestInitialSessionState(now),
      clock: () => now,
    );

    session.appendLog('same message');
    session.appendLog('same message');

    expect(
      session.state.workshop.logs
          .where((String entry) => entry == 'same message')
          .length,
      1,
    );
  });
}
