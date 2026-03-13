import 'package:flutter/material.dart';

import 'package:alchemist_hunter/features/workshop/application/workshop_providers.dart';

class WorkshopExtractionProfileList extends StatelessWidget {
  const WorkshopExtractionProfileList({
    super.key,
    required this.profiles,
    required this.hasSelection,
    required this.onExtract,
  });

  final List<ExtractionProfileOptionView> profiles;
  final bool hasSelection;
  final ValueChanged<String> onExtract;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: profiles.map((ExtractionProfileOptionView profile) {
        final bool selectable = !profile.requiresSelection || hasSelection;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(profile.title),
          subtitle: Text(profile.subtitle),
          trailing: FilledButton.tonal(
            onPressed: selectable ? () => onExtract(profile.id) : null,
            child: const Text('추출'),
          ),
        );
      }).toList(),
    );
  }
}
