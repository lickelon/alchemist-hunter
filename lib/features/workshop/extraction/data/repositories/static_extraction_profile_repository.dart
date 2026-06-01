import 'package:alchemist_hunter/features/workshop/data/repositories/workshop_catalog_data.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/extraction/domain/repositories/extraction_profile_repository.dart';

class StaticExtractionProfileRepository implements ExtractionProfileRepository {
  const StaticExtractionProfileRepository({
    required WorkshopCatalogAssets catalog,
  }) : _catalog = catalog;

  final WorkshopCatalogAssets _catalog;

  List<ExtractionProfile> get _profiles => _catalog.extractionProfiles;

  @override
  ExtractionProfile? findProfileById(String profileId) {
    return _profiles
        .where((ExtractionProfile profile) => profile.id == profileId)
        .firstOrNull;
  }

  @override
  List<ExtractionProfile> profiles() => _profiles;
}
