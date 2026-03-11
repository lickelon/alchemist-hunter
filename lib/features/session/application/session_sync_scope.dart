import 'dart:async';

import 'package:alchemist_hunter/features/town/application/town_providers.dart';
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

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      ref.read(townControllerProvider).syncShopAutoRefresh();
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
