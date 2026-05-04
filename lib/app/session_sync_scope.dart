import 'dart:async';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/app/session/session_progress_sync_controller.dart';
import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionSyncScope extends ConsumerStatefulWidget {
  const SessionSyncScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SessionSyncScope> createState() => _SessionSyncScopeState();
}

class _SessionSyncScopeState extends ConsumerState<SessionSyncScope> {
  static const Duration _idleInterval = Duration(seconds: 1);
  static const Duration _activeBattleInterval = Duration(milliseconds: 100);

  Timer? _timer;
  Duration? _currentInterval;
  Duration? _scheduledInterval;
  SessionProgressSyncController get _syncController =>
      ref.read(sessionProgressSyncControllerProvider);

  @override
  void initState() {
    super.initState();
    _restartTimer(
      _intervalFor(_hasActiveBattle(ref.read(sessionControllerProvider))),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasActiveBattle = ref.watch(
      sessionControllerProvider.select(_hasActiveBattle),
    );
    final Duration desiredInterval = _intervalFor(hasActiveBattle);
    if (desiredInterval != _currentInterval &&
        desiredInterval != _scheduledInterval) {
      _scheduledInterval = desiredInterval;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        _scheduledInterval = null;
        _restartTimer(desiredInterval);
      });
    }
    return widget.child;
  }

  void _restartTimer(Duration interval) {
    _timer?.cancel();
    _currentInterval = interval;
    _timer = Timer.periodic(interval, (_) {
      _syncController.sync();
    });
  }

  bool _hasActiveBattle(SessionState state) {
    return state.battle.stageExpeditions.values.any((
      BattleExpeditionState expedition,
    ) {
      return expedition.isActive;
    });
  }

  Duration _intervalFor(bool hasActiveBattle) {
    return hasActiveBattle ? _activeBattleInterval : _idleInterval;
  }
}
