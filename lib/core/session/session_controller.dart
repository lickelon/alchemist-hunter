import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef SessionLogAppender<TState> = TState Function(
  TState state,
  String message,
);

class SessionController<TState> extends StateNotifier<TState> {
  SessionController({
    required TState initialState,
    DateTime Function()? clock,
    SessionLogAppender<TState>? logAppender,
  }) : _clock = clock ?? DateTime.now,
       _logAppender = logAppender,
       super(initialState);

  final DateTime Function() _clock;
  final SessionLogAppender<TState>? _logAppender;

  DateTime now() => _clock();

  TState snapshot() => state;

  void applyState(TState nextState) => state = nextState;

  void appendLog(String message) {
    if (_logAppender == null) {
      return;
    }
    state = _logAppender(state, message);
  }
}
