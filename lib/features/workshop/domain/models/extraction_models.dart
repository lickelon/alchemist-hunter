import 'package:flutter/foundation.dart';

import 'enums.dart';

@immutable
class ExtractionProfile {
  const ExtractionProfile({
    required this.id,
    required this.mode,
    required this.yieldRate,
    required this.purityRate,
    required this.timeCost,
  });

  final String id;
  final ExtractionMode mode;
  final double yieldRate;
  final double purityRate;
  final Duration timeCost;
}

@immutable
class ExtractedTrait {
  const ExtractedTrait({
    required this.traitId,
    required this.name,
    required this.amount,
    required this.purity,
  });

  final String traitId;
  final String name;
  final double amount;
  final double purity;
}
