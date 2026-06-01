import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<BattleCatalogRepository> battleCatalogRepositoryProvider =
    Provider<BattleCatalogRepository>(
      (Ref ref) => throw StateError('Battle catalog repository is not loaded'),
    );

final Provider<List<String>> stageCatalogProvider = Provider<List<String>>(
  (Ref ref) => ref.watch(battleCatalogRepositoryProvider).stageCatalog(),
);
