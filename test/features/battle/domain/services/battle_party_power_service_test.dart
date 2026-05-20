import 'package:alchemist_hunter/features/battle/domain/models.dart';
import 'package:alchemist_hunter/features/battle/domain/services/battle_party_power_service.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('totalPower includes equipped item stats', () {
    const BattlePartyPowerService service = BattlePartyPowerService();
    final EquipmentInstance sword = EquipmentInstance(
      id: 'eq_instance_1',
      blueprintId: 'eq_1',
      name: 'Bronze Sword',
      slot: EquipmentSlot.weapon,
      attack: 12,
      defense: 0,
      health: 0,
      createdAt: DateTime(2026, 1, 1, 10),
    );

    const CharactersState baseState = CharactersState(
      mercenaries: <CharacterProgress>[
        CharacterProgress(
          id: 'merc_1',
          name: 'Rookie Swordsman',
          type: CharacterType.mercenary,
          combatJobId: CombatJobIds.mercenaryWarrior,
          level: 1,
          rank: 1,
          xp: 0,
          mercenaryTier: MercenaryTier.rookie,
        ),
      ],
      homunculi: <CharacterProgress>[
        CharacterProgress(
          id: 'homo_1',
          name: 'Nigredo Seed',
          type: CharacterType.homunculus,
          combatJobId: CombatJobIds.homunculusMage,
          level: 1,
          rank: 1,
          xp: 0,
          homunculusTier: HomunculusTier.nigredo,
        ),
      ],
    );

    final int basePower = service.totalPower(baseState);
    final CharactersState equippedState = baseState.copyWith(
      mercenaries: <CharacterProgress>[
        baseState.mercenaries.first.copyWith(
          equipment: const CharacterEquipmentLoadout().equip(sword),
        ),
      ],
    );

    expect(basePower, greaterThan(0));
    expect(service.totalPower(equippedState), greaterThan(basePower));
    expect(
      service.totalPower(
        equippedState,
        assignedCharacterIds: const <String>['merc_1'],
      ),
      greaterThan(service.powerForCharacter(baseState.mercenaries.first)),
    );
  });

  test('buildParty includes equipment special effects in hero profile', () {
    const BattlePartyPowerService service = BattlePartyPowerService();
    final EquipmentInstance sword = EquipmentInstance(
      id: 'eq_instance_1',
      blueprintId: 'eq_1',
      name: 'Bronze Sword',
      slot: EquipmentSlot.weapon,
      physicalAttack: 12,
      statModifiers: const <BattleStatModifier>[
        BattleStatModifier(
          type: BattleStatModifierType.accuracy,
          mode: BattleModifierMode.flat,
          value: 0.06,
          sourceId: 'eq_1_focus',
        ),
      ],
      modifiers: const <BattleModifier>[
        BattleModifier(
          type: BattleModifierType.damageDealt,
          mode: BattleModifierMode.percent,
          value: 0.05,
          sourceId: 'eq_1_edge',
        ),
      ],
      createdAt: DateTime(2026, 1, 1, 10),
    );

    final CharactersState state =
        const CharactersState(
          mercenaries: <CharacterProgress>[
            CharacterProgress(
              id: 'merc_1',
              name: 'Rookie Swordsman',
              type: CharacterType.mercenary,
              combatJobId: CombatJobIds.mercenaryWarrior,
              level: 1,
              rank: 1,
              xp: 0,
              mercenaryTier: MercenaryTier.rookie,
            ),
          ],
          homunculi: <CharacterProgress>[],
        ).copyWith(
          mercenaries: <CharacterProgress>[
            const CharacterProgress(
              id: 'merc_1',
              name: 'Rookie Swordsman',
              type: CharacterType.mercenary,
              combatJobId: CombatJobIds.mercenaryWarrior,
              level: 1,
              rank: 1,
              xp: 0,
              mercenaryTier: MercenaryTier.rookie,
            ).copyWith(
              equipment: const CharacterEquipmentLoadout().equip(sword),
            ),
          ],
        );

    final HeroProfile hero = service.buildParty(state).first;

    expect(hero.stats.accuracy, greaterThan(0));
    expect(hero.modifiers, isNotEmpty);
    expect(hero.modifiers.first.type, BattleModifierType.damageDealt);
  });

  test('level increases hp and keeps non-hp base stats stable', () {
    const BattlePartyPowerService service = BattlePartyPowerService();
    const CharacterProgress mage = CharacterProgress(
      id: 'merc_mage_1',
      name: 'Ash Adept',
      type: CharacterType.mercenary,
      combatJobId: CombatJobIds.mercenaryMage,
      level: 1,
      rank: 1,
      xp: 0,
      mercenaryTier: MercenaryTier.rookie,
    );

    final BattleCombatStats levelOne = service.statsForCharacter(mage);
    final BattleCombatStats levelThree = service.statsForCharacter(
      mage.copyWith(level: 3),
    );

    expect(levelThree.maxHp, greaterThan(levelOne.maxHp));
    expect(levelThree.physicalAttack, levelOne.physicalAttack);
    expect(levelThree.magicalAttack, levelOne.magicalAttack);
    expect(levelThree.speed, levelOne.speed);
  });

  test('job id changes stat profile', () {
    const BattlePartyPowerService service = BattlePartyPowerService();
    const CharacterProgress warrior = CharacterProgress(
      id: 'merc_job_1',
      name: 'Warrior',
      type: CharacterType.mercenary,
      combatJobId: CombatJobIds.mercenaryWarrior,
      level: 1,
      rank: 1,
      xp: 0,
      mercenaryTier: MercenaryTier.rookie,
    );
    const CharacterProgress mage = CharacterProgress(
      id: 'merc_job_2',
      name: 'Mage',
      type: CharacterType.mercenary,
      combatJobId: CombatJobIds.mercenaryMage,
      level: 1,
      rank: 1,
      xp: 0,
      mercenaryTier: MercenaryTier.rookie,
    );

    final BattleCombatStats warriorStats = service.statsForCharacter(warrior);
    final BattleCombatStats mageStats = service.statsForCharacter(mage);

    expect(warriorStats.physicalAttack, greaterThan(mageStats.physicalAttack));
    expect(mageStats.magicalAttack, greaterThan(warriorStats.magicalAttack));
  });

  test('all ally combat jobs provide mp and active skills', () {
    const BattlePartyPowerService service = BattlePartyPowerService();
    const List<String> jobIds = <String>[
      CombatJobIds.mercenaryWarrior,
      CombatJobIds.mercenaryMage,
      CombatJobIds.mercenaryRogue,
      CombatJobIds.mercenaryArcher,
      CombatJobIds.homunculusWarrior,
      CombatJobIds.homunculusMage,
      CombatJobIds.homunculusRogue,
      CombatJobIds.homunculusArcher,
    ];
    final CharactersState state = CharactersState(
      mercenaries: jobIds
          .where((String jobId) => jobId.startsWith('mercenary_'))
          .map(_characterForJob)
          .toList(growable: false),
      homunculi: jobIds
          .where((String jobId) => jobId.startsWith('homunculus_'))
          .map(_characterForJob)
          .toList(growable: false),
    );

    final List<HeroProfile> heroes = service.buildParty(state);

    expect(heroes, hasLength(jobIds.length));
    for (final HeroProfile hero in heroes) {
      expect(hero.stats.maxMp, greaterThan(0), reason: hero.jobId);
      expect(hero.stats.mpRegen, greaterThan(0), reason: hero.jobId);
      expect(hero.skills, isNotEmpty, reason: hero.jobId);
    }
  });
}

CharacterProgress _characterForJob(String jobId) {
  final bool homunculus = jobId.startsWith('homunculus_');
  return CharacterProgress(
    id: jobId,
    name: jobId,
    type: homunculus ? CharacterType.homunculus : CharacterType.mercenary,
    combatJobId: jobId,
    level: 1,
    rank: 1,
    xp: 0,
    mercenaryTier: homunculus ? null : MercenaryTier.rookie,
    homunculusTier: homunculus ? HomunculusTier.nigredo : null,
  );
}
