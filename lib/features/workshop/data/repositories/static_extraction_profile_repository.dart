import 'package:alchemist_hunter/features/workshop/data/catalogs/extraction_profiles.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/repositories/extraction_profile_repository.dart';

class StaticExtractionProfileRepository implements ExtractionProfileRepository {
  const StaticExtractionProfileRepository();

  @override
  ExtractionProfile? findProfileById(String profileId) {
    return extractionProfileCatalog
        .where((ExtractionProfile profile) => profile.id == profileId)
        .firstOrNull;
  }

  @override
  List<ExtractionProfile> profiles() => extractionProfileCatalog;
}
