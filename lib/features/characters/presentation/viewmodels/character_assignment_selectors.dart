const String characterAssignmentGuideLabel = '배치 변경은 전투/작업실 화면에서 진행';

String characterAssignmentLabel({
  required String characterId,
  required Map<String, List<String>> stageAssignments,
  required Map<String, String> workshopSupportAssignments,
}) {
  final List<String> assignments = stageAssignments.entries
      .where((MapEntry<String, List<String>> entry) {
        return entry.value.contains(characterId);
      })
      .map((MapEntry<String, List<String>> entry) {
        return entry.key.replaceFirst('stage_', 'Stage ');
      })
      .toList();

  final String? workshopSlot = _workshopSlotLabel(
    characterId,
    workshopSupportAssignments,
  );
  if (workshopSlot != null) {
    assignments.add('작업실($workshopSlot)');
  }

  if (assignments.isEmpty) {
    return '배치 상태: 대기';
  }
  return '배치 상태: ${assignments.join(", ")}';
}

String? _workshopSlotLabel(
  String characterId,
  Map<String, String> workshopSupportAssignments,
) {
  for (final MapEntry<String, String> entry
      in workshopSupportAssignments.entries) {
    if (entry.value != characterId) {
      continue;
    }
    switch (entry.key) {
      case 'extraction':
        return '추출';
      case 'crafting':
        return '제조';
      case 'enchant':
        return '인챈트';
      case 'hatch':
        return '부화';
    }
  }
  return null;
}
