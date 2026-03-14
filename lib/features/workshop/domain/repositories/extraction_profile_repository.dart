import '../models.dart';

abstract interface class ExtractionProfileRepository {
  List<ExtractionProfile> profiles();

  ExtractionProfile? findProfileById(String profileId);
}
