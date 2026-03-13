import 'package:alchemist_hunter/features/session/application/session_providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('applyState replaces current snapshot without feature rules', () {
    final SessionController session = SessionController(
      clock: () => DateTime(2026, 1, 1, 10),
    );

    final SessionState nextState = session.state.copyWith(
      player: session.state.player.copyWith(gold: 999),
    );
    session.applyState(nextState);

    expect(session.snapshot().player.gold, 999);
  });

  test('appendLog deduplicates consecutive identical messages', () {
    final SessionController session = SessionController(
      clock: () => DateTime(2026, 1, 1, 10),
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
