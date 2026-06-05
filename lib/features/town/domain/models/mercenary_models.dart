import 'package:flutter/foundation.dart';

@immutable
class MercenaryTemplate {
  const MercenaryTemplate({
    required this.id,
    required this.combatJobId,
    required this.hireCost,
    required this.tierIndex,
  });

  final String id;
  final String combatJobId;
  final int hireCost;
  final int tierIndex;
}

@immutable
class MercenaryCandidate {
  const MercenaryCandidate({
    required this.id,
    required this.templateId,
    required this.combatJobId,
    required this.hireCost,
    required this.tierIndex,
  });

  final String id;
  final String templateId;
  final String combatJobId;
  final int hireCost;
  final int tierIndex;
}
