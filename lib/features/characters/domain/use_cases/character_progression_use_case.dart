import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';

class CharacterProgressionUseCase {
  const CharacterProgressionUseCase();

  SessionState rankUp({
    required SessionState state,
    required CharacterType type,
    required String characterId,
  }) {
    final List<CharacterProgress> source = type == CharacterType.mercenary
        ? state.characters.mercenaries
        : state.characters.homunculi;
    final int index = source.indexWhere(
      (CharacterProgress c) => c.id == characterId,
    );
    if (index < 0) {
      return state;
    }

    final CharacterProgress current = source[index];
    if (!current.canRankUp) {
      return state;
    }

    final CharacterProgress updated = current.copyWith(
      rank: current.rank + 1,
      level: 1,
      xp: 0,
    );
    final List<CharacterProgress> nextList = <CharacterProgress>[...source];
    nextList[index] = updated;

    return state.copyWith(
      characters: type == CharacterType.mercenary
          ? state.characters.copyWith(mercenaries: nextList)
          : state.characters.copyWith(homunculi: nextList),
    );
  }

  SessionState tierUp({
    required SessionState state,
    required CharacterType type,
    required String characterId,
  }) {
    final List<CharacterProgress> source = type == CharacterType.mercenary
        ? state.characters.mercenaries
        : state.characters.homunculi;
    final int index = source.indexWhere(
      (CharacterProgress c) => c.id == characterId,
    );
    if (index < 0) {
      return state;
    }
    final CharacterProgress current = source[index];
    if (!current.canTierUp) {
      return state;
    }

    final String requiredMaterial = _tierMaterialKey(current);
    if ((state.player.materialInventory[requiredMaterial] ?? 0) < 1) {
      return state;
    }

    final Map<String, int> materials = <String, int>{
      ...state.player.materialInventory,
    };
    materials[requiredMaterial] = (materials[requiredMaterial] ?? 0) - 1;
    if (materials[requiredMaterial] == 0) {
      materials.remove(requiredMaterial);
    }

    CharacterProgress updated;
    if (current.type == CharacterType.mercenary) {
      final MercenaryTier tier = current.mercenaryTier ?? MercenaryTier.rookie;
      updated = current.copyWith(
        mercenaryTier: MercenaryTier.values[tier.index + 1],
        rank: 1,
        level: 1,
        xp: 0,
      );
    } else {
      final HomunculusTier tier =
          current.homunculusTier ?? HomunculusTier.nigredo;
      updated = current.copyWith(
        homunculusTier: HomunculusTier.values[tier.index + 1],
        rank: 1,
        level: 1,
        xp: 0,
      );
    }

    final List<CharacterProgress> nextList = <CharacterProgress>[...source];
    nextList[index] = updated;

    return state.copyWith(
      player: state.player.copyWith(materialInventory: materials),
      characters: type == CharacterType.mercenary
          ? state.characters.copyWith(mercenaries: nextList)
          : state.characters.copyWith(homunculi: nextList),
    );
  }

  String _tierMaterialKey(CharacterProgress character) {
    final int nextTier = character.tierIndex + 1;
    if (character.type == CharacterType.mercenary) {
      return 'tier_mat_mercenary_$nextTier';
    }
    return 'tier_mat_homunculus_$nextTier';
  }
}
