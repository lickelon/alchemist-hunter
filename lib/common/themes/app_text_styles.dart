import 'package:flutter/material.dart';

@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({
    required this.subsectionTitle,
    required this.dataEmphasis,
  });

  final TextStyle subsectionTitle;
  final TextStyle dataEmphasis;

  static AppTextStyles fromTheme(ThemeData theme) {
    return AppTextStyles(
      subsectionTitle: (theme.textTheme.labelLarge ?? const TextStyle())
          .copyWith(fontWeight: FontWeight.w700),
      dataEmphasis: (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }

  static AppTextStyles of(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.extension<AppTextStyles>() ?? AppTextStyles.fromTheme(theme);
  }

  @override
  AppTextStyles copyWith({
    TextStyle? subsectionTitle,
    TextStyle? dataEmphasis,
  }) {
    return AppTextStyles(
      subsectionTitle: subsectionTitle ?? this.subsectionTitle,
      dataEmphasis: dataEmphasis ?? this.dataEmphasis,
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
      dataEmphasis:
          TextStyle.lerp(dataEmphasis, other.dataEmphasis, t) ?? dataEmphasis,
    );
  }
}
