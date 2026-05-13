import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_toast.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/presentation/widgets/character_detail_section.dart';
import 'package:flutter/material.dart';

class CharacterGrowthSection extends StatelessWidget {
  const CharacterGrowthSection({
    super.key,
    required this.character,
    required this.growthLabel,
    required this.hasTierUpMaterial,
    required this.onRankUp,
    required this.onTierUp,
  });

  final CharacterProgress character;
  final String growthLabel;
  final bool hasTierUpMaterial;
  final ValueChanged<String> onRankUp;
  final ValueChanged<String> onTierUp;

  @override
  Widget build(BuildContext context) {
    final double xpRatio = character.xpToNextLevel > 0
        ? (character.xp / character.xpToNextLevel).clamp(0.0, 1.0)
        : 1.0;

    return CharacterDetailSection(
      title: '현재 성장',
      trailing: _ProgressActionButton(
        character: character,
        hasTierUpMaterial: hasTierUpMaterial,
        onRankUp: onRankUp,
        onTierUp: onTierUp,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              _GrowthBadge(label: 'Lv. ${character.level}'),
              _GrowthBadge(label: '랭크 ${character.rank}'),
              _GrowthBadge(label: '티어 ${character.tierIndex}'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(value: xpRatio, minHeight: 6),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                '${character.xp} / ${character.xpToNextLevel}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '최대 레벨 ${character.maxLevelForRank}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _GrowthBadge extends StatelessWidget {
  const _GrowthBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProgressActionButton extends StatelessWidget {
  const _ProgressActionButton({
    required this.character,
    required this.hasTierUpMaterial,
    required this.onRankUp,
    required this.onTierUp,
  });

  final CharacterProgress character;
  final bool hasTierUpMaterial;
  final ValueChanged<String> onRankUp;
  final ValueChanged<String> onTierUp;

  @override
  Widget build(BuildContext context) {
    if (character.tierIndex >= character.maxTier) {
      return FilledButton.tonal(onPressed: null, child: const Text('최대'));
    }
    if (character.rank >= character.maxRankForCurrentTier) {
      return FilledButton.tonal(
        onPressed: character.canTierUp
            ? () {
                if (!hasTierUpMaterial) {
                  AppToast.show(context, '승급 재료가 부족합니다');
                  return;
                }
                onTierUp(character.id);
              }
            : null,
        child: const Text('티어업'),
      );
    }
    return FilledButton.tonal(
      onPressed: character.canRankUp ? () => onRankUp(character.id) : null,
      child: const Text('랭크업'),
    );
  }
}
