import 'package:alchemist_hunter/common/themes/app_text_styles.dart';
import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/features/characters/presentation/widgets/character_detail_section.dart';
import 'package:flutter/material.dart';

class CharacterCombatSection extends StatelessWidget {
  const CharacterCombatSection({
    super.key,
    required this.powerLabel,
    required this.statPairs,
  });

  final String powerLabel;
  final List<(String, String)> statPairs;

  @override
  Widget build(BuildContext context) {
    return CharacterDetailSection(
      title: '전투 스탯',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(powerLabel, style: AppTextStyles.of(context).dataEmphasis),
          const SizedBox(height: AppSpacing.lg),
          _StatGrid(pairs: statPairs),
        ],
      ),
    );
  }
}

class CharacterCombatEffectSection extends StatelessWidget {
  const CharacterCombatEffectSection({super.key, required this.effectLines});

  final List<String> effectLines;

  @override
  Widget build(BuildContext context) {
    return CharacterDetailSection(
      title: '전투 효과',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: effectLines
            .map(
              (String line) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Text(line),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.pairs});

  final List<(String, String)> pairs;

  @override
  Widget build(BuildContext context) {
    final List<Widget> rows = <Widget>[];
    for (int i = 0; i < pairs.length; i += 3) {
      final List<(String, String)> rowItems = pairs.skip(i).take(3).toList();
      if (rows.isNotEmpty) {
        rows.add(const SizedBox(height: AppSpacing.md));
      }
      rows.add(
        Row(
          children: <Widget>[
            for (final (String label, String value) in rowItems)
              Expanded(
                child: _StatCell(label: label, value: value),
              ),
            for (int j = rowItems.length; j < 3; j++)
              const Expanded(child: SizedBox()),
          ],
        ),
      );
    }
    return Column(children: rows);
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(value, style: AppTextStyles.of(context).dataEmphasis),
      ],
    );
  }
}
