import 'package:flutter/foundation.dart';

import 'equipment_models.dart';

enum TownForgeJobStatus { queued, processing, completed }

@immutable
class TownForgeJob {
  const TownForgeJob({
    required this.id,
    required this.blueprintId,
    required this.name,
    required this.status,
    required this.queuedAt,
    this.startedAt,
    required this.remaining,
    required this.duration,
    required this.reservedMaterials,
    this.resultEquipment,
  });

  final String id;
  final String blueprintId;
  final String name;
  final TownForgeJobStatus status;
  final DateTime queuedAt;
  final DateTime? startedAt;
  final Duration remaining;
  final Duration duration;
  final Map<String, int> reservedMaterials;
  final EquipmentInstance? resultEquipment;

  TownForgeJob copyWith({
    TownForgeJobStatus? status,
    DateTime? startedAt,
    bool clearStartedAt = false,
    Duration? remaining,
    EquipmentInstance? resultEquipment,
  }) {
    return TownForgeJob(
      id: id,
      blueprintId: blueprintId,
      name: name,
      status: status ?? this.status,
      queuedAt: queuedAt,
      startedAt: clearStartedAt ? null : startedAt ?? this.startedAt,
      remaining: remaining ?? this.remaining,
      duration: duration,
      reservedMaterials: reservedMaterials,
      resultEquipment: resultEquipment ?? this.resultEquipment,
    );
  }
}
