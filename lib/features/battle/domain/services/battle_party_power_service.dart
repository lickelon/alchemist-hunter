import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/characters/domain/character_models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';

class BattlePartyPowerService {
  const BattlePartyPowerService();

  List<HeroProfile> buildParty(CharactersState state) {
    return <HeroProfile>[
      ...state.mercenaries.map(_buildHeroProfile),
      ...state.homunculi.map(_buildHeroProfile),
    ];
  }

  int totalPower(CharactersState state) {
    return buildParty(
      state,
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
    return (item.attack * 2) + (item.defense * 2) + (item.health ~/ 4);
  }
}
