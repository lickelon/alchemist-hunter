import 'package:alchemist_hunter/app/app.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void bootstrap() {
  runApp(const ProviderScope(child: App()));
}
