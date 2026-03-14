import 'package:alchemist_hunter/features/battle/data/catalogs/battle_tables.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<List<String>> stageCatalogProvider = Provider<List<String>>(
  (Ref ref) => stageCatalog,
);
