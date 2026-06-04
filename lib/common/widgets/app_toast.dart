import 'dart:async';

import 'package:alchemist_hunter/common/themes/app_radius.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:flutter/material.dart';

class AppToast {
  const AppToast._();

  static OverlayEntry? _currentEntry;
  static Timer? _timer;

  static void show(BuildContext context, String message) {
    final OverlayEntry? currentEntry = _currentEntry;
    if (currentEntry?.mounted == true) {
      currentEntry?.remove();
    }
    _timer?.cancel();

    final OverlayState overlay = Overlay.of(context, rootOverlay: true);
    final OverlayEntry entry = OverlayEntry(
      builder: (BuildContext context) {
        final ColorScheme colorScheme = Theme.of(context).colorScheme;
        return Positioned(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.xxl,
          child: IgnorePointer(
            child: Material(
              elevation: 4,
              borderRadius: AppRadius.card,
              color: colorScheme.inverseSurface,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.lg,
                ),
                child: Text(
                  message,
                  style: TextStyle(color: colorScheme.onInverseSurface),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      },
    );

    _currentEntry = entry;
    overlay.insert(entry);
    _timer = Timer(const Duration(milliseconds: 2000), () {
      if (entry.mounted) {
        entry.remove();
      }
      if (_currentEntry == entry) {
        _currentEntry = null;
        _timer = null;
      }
    });
  }
}
