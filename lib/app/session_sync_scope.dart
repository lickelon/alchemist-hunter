import 'dart:async';

import 'package:alchemist_hunter/app/session/session_progress_sync_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionSyncScope extends ConsumerStatefulWidget {
  const SessionSyncScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SessionSyncScope> createState() => _SessionSyncScopeState();
}

class _SessionSyncScopeState extends ConsumerState<SessionSyncScope> {
  Timer? _timer;
  SessionProgressSyncController get _syncController =>
      ref.read(sessionProgressSyncControllerProvider);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _syncController.sync();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
