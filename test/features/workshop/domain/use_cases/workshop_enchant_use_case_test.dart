import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/data/repositories/static_potion_catalog_repository.dart';
import 'package:alchemist_hunter/features/workshop/data/repositories/static_workshop_skill_tree_repository.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/equipment_enchant_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_support_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/services/workshop_skill_tree_service.dart';
import 'package:alchemist_hunter/features/workshop/domain/use_cases/workshop_enchant_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SessionState buildState() {
    final DateTime now = DateTime(2026, 1, 1, 10);
    return createInitialSessionState(now).copyWith(
      workshop: createInitialSessionState(now).workshop.copyWith(
        craftedPotionStacks: const <String, int>{'p_1|a': 1},
        craftedPotionDetails: <String, CraftedPotion>{
          'p_1|a': CraftedPotion(
            id: 'cp_1',
            typePotionId: 'p_1',
            qualityGrade: PotionQualityGrade.a,
            qualityScore: 0.84,
            traits: const <String, double>{'t_atk': 0.7, 't_hp': 0.3},
            createdAt: now,
          ),
        },
      ),
    );
  }

  test(
    'enchantEquipment applies enchant to stored equipment and consumes potion',
    () {
      final WorkshopEnchantUseCase useCase = WorkshopEnchantUseCase();
      final SessionState state = buildState().copyWith(
        town: buildState().town.copyWith(
          equipmentInventory: <EquipmentInstance>[
            EquipmentInstance(
              id: 'eq_instance_1',
              blueprintId: 'eq_1',
              name: 'Bronze Sword',
              slot: EquipmentSlot.weapon,
              attack: 12,
              defense: 0,
              health: 0,
              createdAt: DateTime(2026, 1, 1, 10),
            ),
          ],
        ),
      );

      final SessionState nextState = useCase.enchantEquipment(
        state: state,
        equipmentId: 'eq_instance_1',
        potionStackKey: 'p_1|a',
        enchantService: const EquipmentEnchantService(),
        potionCatalogRepository: const StaticPotionCatalogRepository(),
        workshopSkillTreeRepository: const StaticWorkshopSkillTreeRepository(),
        workshopSkillTreeService: const WorkshopSkillTreeService(),
        workshopSupportService: const WorkshopSupportService(),
      );

      expect(
        nextState.town.equipmentInventory.first.enchant?.label,
        'Potion 1 A',
      );
      expect(nextState.town.equipmentInventory.first.totalAttack, 25);
      expect(nextState.workshop.craftedPotionStacks, isEmpty);
    },
  );

  test(
    'enchantEquipment applies enchant to equipped item and consumes potion',
    () {
      final WorkshopEnchantUseCase useCase = WorkshopEnchantUseCase();
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
      final SessionState state = buildState().copyWith(
        characters: buildState().characters.copyWith(
          mercenaries: <CharacterProgress>[
            buildState().characters.mercenaries.first.copyWith(
              equipment: const CharacterEquipmentLoadout().equip(sword),
            ),
          ],
        ),
      );

      final SessionState nextState = useCase.enchantEquipment(
        state: state,
        equipmentId: 'eq_instance_1',
        potionStackKey: 'p_1|a',
        enchantService: const EquipmentEnchantService(),
        potionCatalogRepository: const StaticPotionCatalogRepository(),
        workshopSkillTreeRepository: const StaticWorkshopSkillTreeRepository(),
        workshopSkillTreeService: const WorkshopSkillTreeService(),
        workshopSupportService: const WorkshopSupportService(),
      );

      expect(
        nextState.characters.mercenaries.first.equipment.weapon?.enchant?.label,
        'Potion 1 A',
      );
      expect(
        nextState.characters.mercenaries.first.equipment.weapon?.totalAttack,
        25,
      );
      expect(nextState.workshop.craftedPotionStacks, isEmpty);
    },
  );

  test('enchantEquipment applies sigil press potency bonus', () {
    final WorkshopEnchantUseCase useCase = WorkshopEnchantUseCase();
    final SessionState state = buildState().copyWith(
      workshop: buildState().workshop.copyWith(
        craftedPotionStacks: const <String, int>{'p_1|a': 1},
        craftedPotionDetails: buildState().workshop.craftedPotionDetails,
        skillTree: buildState().workshop.skillTree.copyWith(
          nodeLevels: const <String, int>{
            'workshop_alembic': 1,
            'workshop_sigil_press': 1,
          },
          unlockedNodes: const <String>{
            'workshop_alembic',
            'workshop_sigil_press',
          },
        ),
      ),
      town: buildState().town.copyWith(
        equipmentInventory: <EquipmentInstance>[
          EquipmentInstance(
            id: 'eq_instance_1',
            blueprintId: 'eq_1',
            name: 'Bronze Sword',
            slot: EquipmentSlot.weapon,
            attack: 12,
            defense: 0,
            health: 0,
            createdAt: DateTime(2026, 1, 1, 10),
          ),
        ],
      ),
    );

    final SessionState nextState = useCase.enchantEquipment(
      state: state,
      equipmentId: 'eq_instance_1',
      potionStackKey: 'p_1|a',
      enchantService: const EquipmentEnchantService(),
      potionCatalogRepository: const StaticPotionCatalogRepository(),
      workshopSkillTreeRepository: const StaticWorkshopSkillTreeRepository(),
      workshopSkillTreeService: const WorkshopSkillTreeService(),
      workshopSupportService: const WorkshopSupportService(),
    );

    expect(nextState.town.equipmentInventory.first.totalAttack, 26);
  });

  test('enchantEquipment applies workshop support potency bonus', () {
    final WorkshopEnchantUseCase useCase = WorkshopEnchantUseCase();
    final SessionState baseState = buildState();
    final SessionState state = baseState.copyWith(
      workshop: baseState.workshop.copyWith(
        supportAssignmentsByFunction: const <String, String>{
          'enchant': 'homo_2',
        },
      ),
      characters: baseState.characters.copyWith(
        homunculi: <CharacterProgress>[
          baseState.characters.homunculi.first,
          CharacterProgress(
            id: 'homo_2',
            name: 'Guard Nigredo',
            type: CharacterType.homunculus,
            level: 1,
            rank: 1,
            xp: 0,
            homunculusTier: HomunculusTier.nigredo,
            homunculusOrigin: 'Guard Seed Flask',
            homunculusRole: '방어',
            homunculusSupportEffect: '방어 안정화 보조',
          ),
        ],
      ),
      town: baseState.town.copyWith(
        equipmentInventory: <EquipmentInstance>[
          EquipmentInstance(
            id: 'eq_instance_1',
            blueprintId: 'eq_1',
            name: 'Bronze Sword',
            slot: EquipmentSlot.weapon,
            attack: 12,
            defense: 0,
            health: 0,
            createdAt: DateTime(2026, 1, 1, 10),
          ),
        ],
      ),
    );

    final SessionState nextState = useCase.enchantEquipment(
      state: state,
      equipmentId: 'eq_instance_1',
      potionStackKey: 'p_1|a',
      enchantService: const EquipmentEnchantService(),
      potionCatalogRepository: const StaticPotionCatalogRepository(),
      workshopSkillTreeRepository: const StaticWorkshopSkillTreeRepository(),
      workshopSkillTreeService: const WorkshopSkillTreeService(),
      workshopSupportService: const WorkshopSupportService(),
    );

    expect(nextState.town.equipmentInventory.first.totalAttack, 26);
  });
}
