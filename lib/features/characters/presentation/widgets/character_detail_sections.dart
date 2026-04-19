import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/presentation/viewmodels/character_selectors.dart';
import 'package:flutter/material.dart';

class CharacterDetailSection extends StatelessWidget {
  const CharacterDetailSection({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class CharacterGrowthSection extends StatelessWidget {
  const CharacterGrowthSection({
    super.key,
    required this.character,
    required this.growthLabel,
  });

  final CharacterProgress character;
  final String growthLabel;

  @override
  Widget build(BuildContext context) {
    return CharacterDetailSection(
      title: '현재 성장',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(growthLabel),
          const SizedBox(height: 4),
          Text(
            'XP ${character.xp}/${character.xpToNextLevel} / MaxLv ${character.maxLevelForRank}',
          ),
        ],
      ),
    );
  }
}

class CharacterGoalSection extends StatelessWidget {
  const CharacterGoalSection({
    super.key,
    required this.rankHint,
    required this.tierHint,
    required this.tierMaterialLabel,
  });

  final String rankHint;
  final String tierHint;
  final String tierMaterialLabel;

  @override
  Widget build(BuildContext context) {
    return CharacterDetailSection(
      title: '다음 목표',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(rankHint),
          const SizedBox(height: 4),
          Text(tierHint),
          const SizedBox(height: 4),
          Text(tierMaterialLabel),
        ],
      ),
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
          const SizedBox(height: 4),
          Text(
            assignmentGuideLabel,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class CharacterProfileSection extends StatelessWidget {
  const CharacterProfileSection({super.key, required this.detailLines});

  final List<String> detailLines;

  @override
  Widget build(BuildContext context) {
    return CharacterDetailSection(
      title: '프로필',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: detailLines
            .map(
              (String line) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(line),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class CharacterActionSection extends StatelessWidget {
  const CharacterActionSection({
    super.key,
    required this.character,
    required this.onRankUp,
    required this.onTierUp,
  });

  final CharacterProgress character;
  final ValueChanged<String> onRankUp;
  final ValueChanged<String> onTierUp;

  @override
  Widget build(BuildContext context) {
    return CharacterDetailSection(
      title: '액션',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: <Widget>[
          FilledButton.tonal(
            onPressed: character.canRankUp
                ? () => onRankUp(character.id)
                : null,
            child: const Text('Rank Up'),
          ),
          FilledButton.tonal(
            onPressed: character.canTierUp
                ? () => onTierUp(character.id)
                : null,
            child: const Text('Tier Up'),
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
                padding: const EdgeInsets.only(bottom: 8),
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
                          const SizedBox(height: 2),
                          Text(
                            slot.statLabel,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
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
