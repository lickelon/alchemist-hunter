import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/app/session/session_progress_sync_controller.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double timeAcceleration = ref.watch(
      sessionControllerProvider.select(
        (SessionState state) => state.player.timeAcceleration,
      ),
    );
    final int diamonds = ref.watch(
      sessionControllerProvider.select(
        (SessionState state) => state.player.diamonds,
      ),
    );
    return AppBar(
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            key: const ValueKey<String>('main_menu_button'),
            tooltip: '메뉴',
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: const Icon(Icons.menu),
          );
        },
      ),
      title: const Text('Alchemist Hunter', overflow: TextOverflow.ellipsis),
      actions: <Widget>[
        TextButton.icon(
          onPressed: () {
            ref.read(sessionProgressSyncControllerProvider).sync();
            final SessionController session = ref.read(
              sessionControllerProvider.notifier,
            );
            final SessionState current = session.snapshot();
            final double nextSpeed = _nextAcceleration(
              current.player.timeAcceleration,
            );
            session.applyState(
              current.copyWith(
                player: current.player.copyWith(timeAcceleration: nextSpeed),
              ),
            );
            session.appendLog('시간 가속 x${_speedLabel(nextSpeed)}');
          },
          icon: const Icon(Icons.timer),
          label: Text('x${_speedLabel(timeAcceleration)}'),
        ),
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: Row(
            children: <Widget>[
              const Icon(Icons.diamond),
              const SizedBox(width: AppSpacing.sm),
              Text('다이아 $diamonds'),
            ],
          ),
        ),
      ],
      titleSpacing: AppSpacing.md,
      actionsPadding: EdgeInsets.zero,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  double _nextAcceleration(double current) {
    const List<double> speeds = <double>[1, 2, 4, 8, 30];
    final int currentIndex = speeds.indexOf(current);
    if (currentIndex == -1 || currentIndex == speeds.length - 1) {
      return speeds.first;
    }
    return speeds[currentIndex + 1];
  }

  String _speedLabel(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
  }
}
