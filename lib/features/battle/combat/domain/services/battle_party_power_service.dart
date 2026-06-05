import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/repositories/battle_catalog_repository.dart';
import 'package:alchemist_hunter/features/battle/combat/domain/services/battle_combat_stat_service.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';

class BattlePartyPowerService {
  BattlePartyPowerService({
    required BattleCatalogRepository battleCatalogRepository,
  }) : _combatStatService = BattleCombatStatService(
         battleCatalogRepository: battleCatalogRepository,
       );

  final BattleCombatStatService _combatStatService;

  List<HeroProfile> buildParty(
    CharactersState state, {
    List<String>? assignedCharacterIds,
  }) {
    final Set<String>? assignedSet = assignedCharacterIds?.toSet();
    return <HeroProfile>[
      ...state.mercenaries
          .where(
            (CharacterProgress character) =>
                assignedSet == null || assignedSet.contains(character.id),
          )
          .map(_buildHeroProfile),
      ...state.homunculi
          .where(
            (CharacterProgress character) =>
                assignedSet == null || assignedSet.contains(character.id),
          )
          .map(_buildHeroProfile),
    ];
  }

  int totalPower(CharactersState state, {List<String>? assignedCharacterIds}) {
    return buildParty(
      state,
      assignedCharacterIds: assignedCharacterIds,
    ).fold<int>(0, (int sum, HeroProfile hero) => sum + hero.power);
  }

  BattleCombatStats statsForCharacter(CharacterProgress character) {
    return _combatStatService.buildStats(character);
  }

  HeroProfile _buildHeroProfile(CharacterProgress character) {
    return _combatStatService.buildHeroProfile(character);
  }

  int powerForCharacter(CharacterProgress character) {
    return _combatStatService.buildHeroProfile(character).power;
  }
}
