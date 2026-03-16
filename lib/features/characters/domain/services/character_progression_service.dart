import 'package:alchemist_hunter/features/characters/domain/models.dart';

class CharacterProgressionService {
  const CharacterProgressionService();

  CharactersState grantBattleXp({
    required CharactersState state,
    required int xpGain,
    List<String>? participantIds,
  }) {
    final Set<String>? participantSet = participantIds?.toSet();
    return state.copyWith(
      mercenaries: _grantXpList(
        state.mercenaries,
        xpGain,
        participantSet: participantSet,
      ),
      homunculi: _grantXpList(
        state.homunculi,
        xpGain,
        participantSet: participantSet,
      ),
    );
  }

  CharactersState grantCharacterXpMap({
    required CharactersState state,
    required Map<String, int> xpByCharacter,
  }) {
    return state.copyWith(
      mercenaries: _grantXpMap(state.mercenaries, xpByCharacter),
      homunculi: _grantXpMap(state.homunculi, xpByCharacter),
    );
  }

  List<CharacterProgress> _grantXpList(
    List<CharacterProgress> source,
    int xpGain,
    {Set<String>? participantSet}
  ) {
    return source.map((CharacterProgress character) {
      if (participantSet != null && !participantSet.contains(character.id)) {
        return character;
      }
      int level = character.level;
      int xp = character.xp + xpGain;
      final int maxLevel = character.maxLevelForRank;
      if (level >= maxLevel) {
        return character.copyWith(level: maxLevel, xp: 0);
      }
      while (level < character.maxLevelForRank) {
        final int need = level * 20;
        if (xp < need) {
          break;
        }
        xp -= need;
        level += 1;
      }
      if (level >= maxLevel) {
        return character.copyWith(level: maxLevel, xp: 0);
      }
      return character.copyWith(level: level, xp: xp);
    }).toList();
  }

  List<CharacterProgress> _grantXpMap(
    List<CharacterProgress> source,
    Map<String, int> xpByCharacter,
  ) {
    return source.map((CharacterProgress character) {
      final int? xpGain = xpByCharacter[character.id];
      if (xpGain == null || xpGain <= 0) {
        return character;
      }
      int level = character.level;
      int xp = character.xp + xpGain;
      final int maxLevel = character.maxLevelForRank;
      if (level >= maxLevel) {
        return character.copyWith(level: maxLevel, xp: 0);
      }
      while (level < character.maxLevelForRank) {
        final int need = level * 20;
        if (xp < need) {
          break;
        }
        xp -= need;
        level += 1;
      }
      if (level >= maxLevel) {
        return character.copyWith(level: maxLevel, xp: 0);
      }
      return character.copyWith(level: level, xp: xp);
    }).toList();
  }
}
