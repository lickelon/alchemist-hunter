import 'package:alchemist_hunter/features/workshop/extraction/domain/models/extraction_models.dart';

abstract interface class ExtractionProfileRepository {
  List<ExtractionProfile> profiles();

  ExtractionProfile? findProfileById(String profileId);
}
