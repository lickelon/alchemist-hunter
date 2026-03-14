import 'package:flutter/foundation.dart';

@immutable
class MercenaryTemplate {
  const MercenaryTemplate({
    required this.id,
    required this.name,
    required this.roleLabel,
    required this.hireCost,
    required this.tierIndex,
  });

  final String id;
  final String name;
  final String roleLabel;
  final int hireCost;
  final int tierIndex;

  String get tierLabel {
    switch (tierIndex) {
      case 1:
        return 'Rookie';
      case 2:
        return 'Veteran';
      case 3:
        return 'Elite';
      case 4:
        return 'Champion';
      default:
        return 'Legend';
    }
  }
}

@immutable
class MercenaryCandidate {
  const MercenaryCandidate({
    required this.id,
    required this.templateId,
    required this.name,
    required this.roleLabel,
    required this.hireCost,
    required this.tierIndex,
  });

  final String id;
  final String templateId;
  final String name;
  final String roleLabel;
  final int hireCost;
  final int tierIndex;

  String get tierLabel {
    switch (tierIndex) {
      case 1:
        return 'Rookie';
      case 2:
        return 'Veteran';
      case 3:
        return 'Elite';
      case 4:
        return 'Champion';
      default:
        return 'Legend';
    }
  }
}
