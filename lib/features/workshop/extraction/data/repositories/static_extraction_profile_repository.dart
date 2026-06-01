import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/extraction/domain/repositories/extraction_profile_repository.dart';

class StaticExtractionProfileRepository implements ExtractionProfileRepository {
  const StaticExtractionProfileRepository({
    required List<ExtractionProfile> profiles,
  }) : _profiles = profiles;

  final List<ExtractionProfile> _profiles;

  @override
  ExtractionProfile? findProfileById(String profileId) {
    return _profiles
        .where((ExtractionProfile profile) => profile.id == profileId)
        .firstOrNull;
  }

  @override
  List<ExtractionProfile> profiles() => _profiles;
}
