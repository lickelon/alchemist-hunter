import 'package:alchemist_hunter/features/characters/domain/models.dart';

String characterTypeLabel(CharacterType type) {
  return switch (type) {
    CharacterType.mercenary => '용병',
    CharacterType.homunculus => '호문쿨루스',
  };
}

String characterTierName(CharacterProgress character) {
  if (character.type == CharacterType.mercenary) {
    return switch (character.mercenaryTier ?? MercenaryTier.rookie) {
      MercenaryTier.rookie => 'Rookie',
      MercenaryTier.veteran => 'Veteran',
      MercenaryTier.elite => 'Elite',
      MercenaryTier.champion => 'Champion',
      MercenaryTier.legend => 'Legend',
    };
  }
  return switch (character.homunculusTier ?? HomunculusTier.nigredo) {
    HomunculusTier.nigredo => 'Nigredo',
    HomunculusTier.albedo => 'Albedo',
    HomunculusTier.citrinitas => 'Citrinitas',
    HomunculusTier.rubedo => 'Rubedo',
  };
}

String characterTierLabel(CharacterProgress character) {
  return '티어 ${character.tierIndex}';
}

String characterDisplayName(CharacterProgress character) {
  return '${characterTierName(character)} ${character.name}';
}

String characterRankHint(CharacterProgress character) {
  if (character.canRankUp) {
    return '랭크업 가능';
  }
  if (character.rank >= character.maxRankForCurrentTier) {
    return '현재 티어 최대 랭크 도달';
  }
  return '랭크업 조건: 레벨 ${character.maxLevelForRank} 도달 필요';
}

String characterTierHint(
  CharacterProgress character,
  Map<String, int> inventory,
) {
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

  return '티어업 조건: 랭크 ${character.maxRankForCurrentTier} 도달 필요';
}

bool characterHasTierUpMaterial(
  CharacterProgress character,
  Map<String, int> inventory,
) {
  if (character.tierIndex >= character.maxTier) {
    return false;
  }
  final String materialKey = character.type == CharacterType.mercenary
      ? 'tier_mat_mercenary_${character.tierIndex + 1}'
      : 'tier_mat_homunculus_${character.tierIndex + 1}';
  return (inventory[materialKey] ?? 0) >= 1;
}

String characterTierMaterialLabel(
  CharacterProgress character,
  Map<String, int> inventory,
) {
  if (character.tierIndex >= character.maxTier) {
    return '승급 재료: 없음';
  }
  final String materialKey = character.type == CharacterType.mercenary
      ? 'tier_mat_mercenary_${character.tierIndex + 1}'
      : 'tier_mat_homunculus_${character.tierIndex + 1}';
  final int owned = inventory[materialKey] ?? 0;
  final String materialName = _tierMaterialDisplayName(character);
  return '승급 재료: $materialName $owned/1';
}

String _tierMaterialDisplayName(CharacterProgress character) {
  final int nextTier = character.tierIndex + 1;
  return switch (character.type) {
    CharacterType.mercenary => '용병 승급 재료 $nextTier',
    CharacterType.homunculus => '호문쿨루스 승급 재료 $nextTier',
  };
}
