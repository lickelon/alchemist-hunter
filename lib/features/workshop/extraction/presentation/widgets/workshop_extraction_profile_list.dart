import 'package:flutter/material.dart';

import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_badge.dart';
import 'package:alchemist_hunter/features/workshop/extraction/presentation/viewmodels/extraction_detail_selector.dart';

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
          subtitle: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: <Widget>[
                AppBadge(label: profile.yieldLabel),
                AppBadge(label: profile.purityLabel),
                if (!selectable) const AppBadge(label: '원소 선택 필요'),
              ],
            ),
          ),
          trailing: FilledButton.tonal(
            onPressed: selectable ? () => onExtract(profile.id) : null,
            child: const Text('등록'),
          ),
        );
      }).toList(),
    );
  }
}
