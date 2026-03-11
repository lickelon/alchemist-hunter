import 'package:alchemist_hunter/features/session/application/session_providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
