import 'package:alchemist_hunter/features/workshop/data/repositories/workshop_catalog_asset_loader.dart';
import 'package:alchemist_hunter/features/workshop/extraction/data/catalogs/extraction_profiles.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/extraction/domain/repositories/extraction_profile_repository.dart';

class StaticExtractionProfileRepository implements ExtractionProfileRepository {
  const StaticExtractionProfileRepository({WorkshopCatalogAssets? catalog})
    : _catalog = catalog;

  final WorkshopCatalogAssets? _catalog;

  List<ExtractionProfile> get _profiles =>
      _catalog?.extractionProfiles ?? extractionProfileCatalog;

  @override
  ExtractionProfile? findProfileById(String profileId) {
    return _profiles
        .where((ExtractionProfile profile) => profile.id == profileId)
        .firstOrNull;
  }

  @override
  List<ExtractionProfile> profiles() => _profiles;
}
