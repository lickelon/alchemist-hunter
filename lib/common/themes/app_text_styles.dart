import 'package:flutter/material.dart';

@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({required this.subsectionTitle});

  final TextStyle subsectionTitle;

  static AppTextStyles fromTheme(ThemeData theme) {
    return AppTextStyles(
      subsectionTitle: (theme.textTheme.labelLarge ?? const TextStyle())
          .copyWith(fontWeight: FontWeight.w700),
    );
  }

  static AppTextStyles of(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.extension<AppTextStyles>() ?? AppTextStyles.fromTheme(theme);
  }

  @override
  AppTextStyles copyWith({TextStyle? subsectionTitle}) {
    return AppTextStyles(
      subsectionTitle: subsectionTitle ?? this.subsectionTitle,
    );
  }

  @override
  AppTextStyles lerp(ThemeExtension<AppTextStyles>? other, double t) {
    if (other is! AppTextStyles) {
      return this;
    }
    return AppTextStyles(
      subsectionTitle:
          TextStyle.lerp(subsectionTitle, other.subsectionTitle, t) ??
          subsectionTitle,
    );
  }
}
