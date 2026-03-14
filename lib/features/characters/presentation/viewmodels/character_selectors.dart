import 'package:alchemist_hunter/features/characters/domain/character_models.dart';
import 'package:alchemist_hunter/core/session/session_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CharacterListItemView {
  const CharacterListItemView({
    required this.character,
    required this.rankHint,
    required this.tierHint,
  });

  final CharacterProgress character;
  final String rankHint;
  final String tierHint;
}

final Provider<List<CharacterProgress>> mercenaryListProvider =
    Provider<List<CharacterProgress>>((Ref ref) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.characters.mercenaries,
        ),
      );
    });

final Provider<List<CharacterListItemView>> mercenaryListItemViewsProvider =
    Provider<List<CharacterListItemView>>((Ref ref) {
      return _buildCharacterViews(
        characters: ref.watch(mercenaryListProvider),
        inventory: ref.watch(
          sessionControllerProvider.select(
            (SessionState state) => state.player.materialInventory,
          ),
        ),
      );
    });

final Provider<List<CharacterListItemView>> homunculusListItemViewsProvider =
    Provider<List<CharacterListItemView>>((Ref ref) {
      return _buildCharacterViews(
        characters: ref.watch(homunculusListProvider),
        inventory: ref.watch(
          sessionControllerProvider.select(
            (SessionState state) => state.player.materialInventory,
          ),
        ),
      );
    });

List<CharacterListItemView> _buildCharacterViews({
  required List<CharacterProgress> characters,
  required Map<String, int> inventory,
}) {
  return characters.map((CharacterProgress character) {
    return CharacterListItemView(
      character: character,
      rankHint: _rankUpHint(character),
      tierHint: _tierUpHint(character, inventory),
    );
  }).toList();
}

String _rankUpHint(CharacterProgress character) {
  if (character.canRankUp) {
    return '랭크업 가능';
  }
  if (character.rank >= character.maxRankForCurrentTier) {
    return '현재 티어 최대 랭크 도달';
  }
  return '랭크업 조건: Lv ${character.maxLevelForRank} 도달 필요';
}

String _tierUpHint(CharacterProgress character, Map<String, int> inventory) {
  if (character.tierIndex >= character.maxTier) {
    return '티어 승급 완료';
  }

  final String materialKey = character.type == CharacterType.mercenary
      ? 'tier_mat_mercenary_${character.tierIndex + 1}'
      : 'tier_mat_homunculus_${character.tierIndex + 1}';
  final int owned = inventory[materialKey] ?? 0;

  if (character.canTierUp) {
    if (owned > 0) {
      return '티어업 가능';
    }
    return '티어업 조건 충족, 승급 재료 부족';
  }

  return '티어업 조건: Rank ${character.maxRankForCurrentTier} 도달 필요';
}

final Provider<List<CharacterProgress>> homunculusListProvider =
    Provider<List<CharacterProgress>>((Ref ref) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.characters.homunculi,
        ),
      );
    });
