import 'package:alchemist_hunter/features/characters/presentation/character_providers.dart';
import 'package:alchemist_hunter/features/characters/domain/character_models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CharactersScreen extends ConsumerWidget {
  const CharactersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CharacterListItemView> mercenaries = ref.watch(
      mercenaryListItemViewsProvider,
    );
    final List<CharacterListItemView> homunculi = ref.watch(
      homunculusListItemViewsProvider,
    );
    final CharacterController controller = ref.read(
      characterControllerProvider,
    );

    return DefaultTabController(
      length: 2,
      child: Column(
        children: <Widget>[
          const TabBar(
            tabs: <Widget>[
              Tab(text: 'Mercenary'),
              Tab(text: 'Homunculus'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: <Widget>[
                _CharacterList(
                  characters: mercenaries,
                  onRankUp: (String id) =>
                      controller.rankUp(CharacterType.mercenary, id),
                  onTierUp: (String id) =>
                      controller.tierUp(CharacterType.mercenary, id),
                  onEquip: (String characterId, String equipmentId) =>
                      controller.equip(
                        CharacterType.mercenary,
                        characterId,
                        equipmentId,
                      ),
                  onUnequip: (String characterId, EquipmentSlot slot) =>
                      controller.unequip(
                        CharacterType.mercenary,
                        characterId,
                        slot,
                      ),
                ),
                _CharacterList(
                  characters: homunculi,
                  onRankUp: (String id) =>
                      controller.rankUp(CharacterType.homunculus, id),
                  onTierUp: (String id) =>
                      controller.tierUp(CharacterType.homunculus, id),
                  onEquip: (String characterId, String equipmentId) =>
                      controller.equip(
                        CharacterType.homunculus,
                        characterId,
                        equipmentId,
                      ),
                  onUnequip: (String characterId, EquipmentSlot slot) =>
                      controller.unequip(
                        CharacterType.homunculus,
                        characterId,
                        slot,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterList extends ConsumerWidget {
  const _CharacterList({
    required this.characters,
    required this.onRankUp,
    required this.onTierUp,
    required this.onEquip,
    required this.onUnequip,
  });

  final List<CharacterListItemView> characters;
  final ValueChanged<String> onRankUp;
  final ValueChanged<String> onTierUp;
  final void Function(String characterId, String equipmentId) onEquip;
  final void Function(String characterId, EquipmentSlot slot) onUnequip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (characters.isEmpty) {
      return const Center(child: Text('No characters'));
    }
    return ListView(
      padding: const EdgeInsets.all(8),
      children: characters.map((CharacterListItemView item) {
        final CharacterProgress character = item.character;
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  character.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  'Lv ${character.level} / Rank ${character.rank} / Tier ${character.tierIndex}',
                ),
                Text(
                  'XP ${character.xp}/${character.xpToNextLevel} / MaxLv ${character.maxLevelForRank}',
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
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
                const SizedBox(height: 8),
                Text(
                  item.rankHint,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  item.tierHint,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 12),
                const Text(
                  '장비 슬롯',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ...item.equipmentSlots.map((CharacterEquipmentSlotView slot) {
                  final bool canManage =
                      slot.equippedItem != null ||
                      slot.availableItems.isNotEmpty;
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
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
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
                }),
              ],
            ),
          ),
        );
      }).toList(),
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
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${character.name} / ${slot.slotLabel}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (slot.equippedItem == null)
                    Text(
                      '현재 미장착',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(slot.equippedItem!.name),
                      subtitle: Text(slot.statLabel),
                      trailing: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onUnequip(character.id, slot.slot);
                        },
                        child: const Text('해제'),
                      ),
                    ),
                  const Divider(),
                  const Text(
                    '보관 장비',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: slot.availableItems.isEmpty
                        ? const Center(child: Text('장착 가능한 장비가 없습니다'))
                        : ListView(
                            children: slot.availableItems.map((
                              EquipmentInstance item,
                            ) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(item.name),
                                subtitle: Text(
                                  'ATK ${item.attack} / DEF ${item.defense} / HP ${item.health}',
                                ),
                                trailing: FilledButton.tonal(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    onEquip(character.id, item.id);
                                  },
                                  child: Text(
                                    slot.equippedItem == null ? '장착' : '교체',
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
