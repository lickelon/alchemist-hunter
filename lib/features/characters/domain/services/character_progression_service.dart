import 'package:alchemist_hunter/features/characters/domain/models.dart';

class CharacterProgressionService {
  const CharacterProgressionService();

  CharactersState grantBattleXp({
    required CharactersState state,
    required int xpGain,
  }) {
    return state.copyWith(
      mercenaries: _grantXpList(state.mercenaries, xpGain),
      homunculi: _grantXpList(state.homunculi, xpGain),
    );
  }

  List<CharacterProgress> _grantXpList(
    List<CharacterProgress> source,
    int xpGain,
  ) {
    return source.map((CharacterProgress character) {
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
