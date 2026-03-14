import 'package:alchemist_hunter/core/session/session_controller.dart' as core;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'session_factory.dart';
import 'session_state.dart';

export 'player_state.dart';
export 'session_factory.dart';
export 'session_state.dart';

SessionState _appendLog(SessionState state, String message) {
  if (state.workshop.logs.isNotEmpty && state.workshop.logs.first == message) {
    return state;
  }
  return state.copyWith(
    workshop: state.workshop.copyWith(
      logs: <String>[message, ...state.workshop.logs].take(20).toList(),
    ),
  );
}

class AppSessionController extends core.SessionController<SessionState> {
  AppSessionController({super.clock})
    : super(
        initialState: createInitialSessionState((clock ?? DateTime.now)()),
        logAppender: _appendLog,
      );
}

typedef SessionController = AppSessionController;

final StateNotifierProvider<AppSessionController, SessionState>
sessionControllerProvider =
    StateNotifierProvider<AppSessionController, SessionState>((Ref ref) {
      return AppSessionController();
    });
