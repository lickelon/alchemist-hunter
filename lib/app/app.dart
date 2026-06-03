import 'package:alchemist_hunter/app/home_page.dart';
import 'package:alchemist_hunter/common/themes/app_theme.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alchemist Hunter',
      theme: AppTheme.light,
      home: const HomePage(),
    );
  }
}
