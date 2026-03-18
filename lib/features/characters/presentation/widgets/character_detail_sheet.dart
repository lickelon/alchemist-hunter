import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/presentation/character_providers.dart';
import 'package:alchemist_hunter/features/characters/presentation/viewmodels/character_selectors.dart';
import 'package:alchemist_hunter/features/characters/presentation/widgets/character_equipment_sheet.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CharacterDetailSheet extends ConsumerWidget {
  const CharacterDetailSheet({
    super.key,
    required this.type,
    required this.characterId,
    required this.onRankUp,
    required this.onTierUp,
    required this.onEquip,
    required this.onUnequip,
  });

  final CharacterType type;
  final String characterId;
  final ValueChanged<String> onRankUp;
  final ValueChanged<String> onTierUp;
  final void Function(String characterId, String equipmentId) onEquip;
  final void Function(String characterId, EquipmentSlot slot) onUnequip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CharacterListItemView? item = switch (type) {
      CharacterType.mercenary => ref.watch(mercenaryItemViewProvider(characterId)),
      CharacterType.homunculus => ref.watch(homunculusItemViewProvider(characterId)),
    };
    if (item == null) {
      return const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('캐릭터 정보를 찾을 수 없습니다'),
        ),
      );
    }

    final CharacterProgress character = item.character;
    final String totalStatLabel = _totalStatLabel(item.equipmentSlots);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.82,
          child: ListView(
            children: <Widget>[
              Text(
                '${character.name} / ${item.typeLabel}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              _Section(
                title: '현재 성장',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(item.growthLabel),
                    const SizedBox(height: 4),
                    Text(
                      'XP ${character.xp}/${character.xpToNextLevel} / MaxLv ${character.maxLevelForRank}',
                    ),
                  ],
                ),
              ),
              _Section(title: '총합 스탯', child: Text(totalStatLabel)),
              _Section(
                title: '다음 목표',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(item.rankHint),
                    const SizedBox(height: 4),
                    Text(item.tierHint),
                    const SizedBox(height: 4),
                    Text(item.tierMaterialLabel),
                  ],
                ),
              ),
              _Section(
                title: '배치 상태',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(item.assignmentLabel),
                    const SizedBox(height: 4),
                    Text(
                      item.assignmentGuideLabel,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              if (item.detailLines.isNotEmpty)
                _Section(
                  title: '프로필',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: item.detailLines
                        .map((String line) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(line),
                            ))
                        .toList(growable: false),
                  ),
                ),
              _Section(
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
              ),
              _Section(
                title: '장비 관리',
                child: Column(
                  children: item.equipmentSlots.map((CharacterEquipmentSlotView slot) {
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
                            onPressed: canManage
                                ? () => _showEquipmentSheet(
                                      context,
                                      character: character,
                                      slot: slot,
                                    )
                                : null,
                            child: Text(slot.equippedItem == null ? '장착' : '관리'),
                          ),
                        ],
                      ),
                    );
                  }).toList(growable: false),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEquipmentSheet(
    BuildContext context, {
    required CharacterProgress character,
    required CharacterEquipmentSlotView slot,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return CharacterEquipmentSheet(
          character: character,
          slot: slot,
          onEquip: onEquip,
          onUnequip: onUnequip,
        );
      },
    );
  }
}

String _totalStatLabel(List<CharacterEquipmentSlotView> slots) {
  int attack = 0;
  int defense = 0;
  int health = 0;
  for (final CharacterEquipmentSlotView slot in slots) {
    final EquipmentInstance? item = slot.equippedItem;
    if (item == null) {
      continue;
    }
    attack += item.totalAttack;
    defense += item.totalDefense;
    health += item.totalHealth;
  }
  return 'ATK $attack / DEF $defense / HP $health';
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

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
