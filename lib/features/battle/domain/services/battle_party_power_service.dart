import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';

class BattlePartyPowerService {
  const BattlePartyPowerService();

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

  int totalPower(
    CharactersState state, {
    List<String>? assignedCharacterIds,
  }) {
    return buildParty(
      state,
      assignedCharacterIds: assignedCharacterIds,
    ).fold<int>(0, (int sum, HeroProfile hero) => sum + hero.power);
  }

  HeroProfile _buildHeroProfile(CharacterProgress character) {
    return HeroProfile(
      id: character.id,
      name: character.name,
      power: powerForCharacter(character),
    );
  }

  int powerForCharacter(CharacterProgress character) {
    final int basePower = character.type == CharacterType.mercenary ? 90 : 80;
    final int levelPower = character.level * 15;
    final int rankPower = character.rank * 15;
    final int tierPower = (character.tierIndex - 1) * 25;
    final int equipmentPower = _equipmentPower(character.equipment);
    return basePower + levelPower + rankPower + tierPower + equipmentPower;
  }

  int _equipmentPower(CharacterEquipmentLoadout equipment) {
    return _powerForItem(equipment.weapon) +
        _powerForItem(equipment.armor) +
        _powerForItem(equipment.accessory);
  }

  int _powerForItem(EquipmentInstance? item) {
    if (item == null) {
      return 0;
    }
    return (item.totalAttack * 2) +
        (item.totalDefense * 2) +
        (item.totalHealth ~/ 4);
  }
}
