import 'package:alchemist_hunter/common/themes/app_radius.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/themes/app_text_styles.dart';
import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final ThemeData base = ThemeData(
      colorSchemeSeed: Colors.orange,
      useMaterial3: true,
    );

    return base.copyWith(
      cardTheme: const CardThemeData(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
      ),
      textTheme: base.textTheme.copyWith(
        titleMedium: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: Colors.transparent,
        labelPadding: EdgeInsets.zero,
        splashFactory: NoSplash.splashFactory,
        labelColor: base.colorScheme.primary,
        unselectedLabelColor: base.colorScheme.onSurfaceVariant,
      ),
      extensions: <ThemeExtension<dynamic>>[AppTextStyles.fromTheme(base)],
    );
  }
}
