import 'package:alchemist_hunter/features/workshop/domain/models.dart';

const List<ExtractionProfile> extractionProfileCatalog = <ExtractionProfile>[
  ExtractionProfile(
    id: 'full_basic',
    mode: ExtractionMode.full,
    yieldRate: 0.85,
    purityRate: 0.75,
    timeCost: Duration(seconds: 20),
  ),
  ExtractionProfile(
    id: 'sel_precise',
    mode: ExtractionMode.selective,
    yieldRate: 0.65,
    purityRate: 0.92,
    timeCost: Duration(seconds: 30),
  ),
];
