String battleStageDisplayName(String stageId, {String? fallback}) {
  final int? stageNumber = int.tryParse(stageId.replaceFirst('stage_', ''));
  if (stageNumber != null) {
    return '$stageNumber단계';
  }
  return fallback ?? stageId;
}

String battleSignedValueLabel(int value) {
  if (value == 0) {
    return '0';
  }
  return '${value > 0 ? '+' : ''}$value';
}
