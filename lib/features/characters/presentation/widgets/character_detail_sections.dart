import 'package:alchemist_hunter/common/themes/app_spacing.dart';
import 'package:alchemist_hunter/common/widgets/app_toast.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/presentation/viewmodels/character_selectors.dart';
import 'package:flutter/material.dart';

class CharacterDetailSection extends StatelessWidget {
  const CharacterDetailSection({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

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
          Text(powerLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.lg),
          _StatGrid(pairs: statPairs),
        ],
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
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class CharacterAssignmentSection extends StatelessWidget {
  const CharacterAssignmentSection({
    super.key,
    required this.assignmentLabel,
    required this.assignmentGuideLabel,
  });

  final String assignmentLabel;
  final String assignmentGuideLabel;

  @override
  Widget build(BuildContext context) {
    return CharacterDetailSection(
      title: '배치 상태',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(assignmentLabel),
          const SizedBox(height: AppSpacing.sm),
          Text(
            assignmentGuideLabel,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class CharacterEquipmentSection extends StatelessWidget {
  const CharacterEquipmentSection({
    super.key,
    required this.slots,
    required this.onManage,
  });

  final List<CharacterEquipmentSlotView> slots;
  final ValueChanged<CharacterEquipmentSlotView> onManage;

  @override
  Widget build(BuildContext context) {
    return CharacterDetailSection(
      title: '장비 관리',
      child: Column(
        children: slots
            .map((CharacterEquipmentSlotView slot) {
              final bool canManage =
                  slot.equippedItem != null || slot.availableItems.isNotEmpty;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${slot.slotLabel}: ${slot.currentLabel}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            slot.statLabel,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    FilledButton.tonal(
                      onPressed: canManage ? () => onManage(slot) : null,
                      child: Text(slot.equippedItem == null ? '장착' : '관리'),
                    ),
                  ],
                ),
              );
            })
            .toList(growable: false),
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
