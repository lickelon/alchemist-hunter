import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_factory.dart';
import 'state/session_state.dart';

class SessionController extends StateNotifier<SessionState> {
  SessionController({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      super(createInitialSessionState((clock ?? DateTime.now)()));

  final DateTime Function() _clock;

  DateTime now() => _clock();

  SessionState snapshot() => state;

  void applyState(SessionState nextState) => state = nextState;

  void appendLog(String message) {
    if (state.workshop.logs.isNotEmpty &&
        state.workshop.logs.first == message) {
      return;
    }
    state = state.copyWith(
      workshop: state.workshop.copyWith(
        logs: <String>[message, ...state.workshop.logs].take(20).toList(),
      ),
    );
  }
}

final StateNotifierProvider<SessionController, SessionState>
sessionControllerProvider =
    StateNotifierProvider<SessionController, SessionState>((Ref ref) {
      return SessionController();
    });
