import 'package:flutter/material.dart';

/// 앱 전체 테마 설정.
///
/// [light]를 [MaterialApp.theme]에 전달한다.
/// TabBar 스타일링처럼 반복되는 인라인 속성은 여기서 중앙 관리한다.
class AppTheme {
  const AppTheme._();

  static ThemeData get light => ThemeData(
    colorSchemeSeed: Colors.orange,
    useMaterial3: true,
    tabBarTheme: const TabBarThemeData(
      indicatorColor: Colors.transparent,
      labelPadding: EdgeInsets.zero,
      splashFactory: NoSplash.splashFactory,
      labelColor: Colors.orange,
      unselectedLabelColor: Colors.grey,
    ),
  );
}
