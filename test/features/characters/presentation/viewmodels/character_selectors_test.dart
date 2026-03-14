import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/presentation/viewmodels/character_selectors.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('character hint selectors reflect rank and tier conditions', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );
    final CharacterProgress target = session.state.characters.mercenaries.first;
    session.state = session.state.copyWith(
      player: session.state.player.copyWith(
        materialInventory: const <String, int>{'tier_mat_mercenary_2': 1},
      ),
      town: session.state.town.copyWith(
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
      characters: session.state.characters.copyWith(
        mercenaries: <CharacterProgress>[
          target.copyWith(
            rank: target.maxRankForCurrentTier,
            level: target.maxLevelForRank,
          ),
        ],
      ),
    );

    final CharacterListItemView view = container
        .read(mercenaryListItemViewsProvider)
        .first;

    expect(view.rankHint, '현재 티어 최대 랭크 도달');
    expect(view.tierHint, '티어업 가능');
    expect(view.assignmentLabel, '배치 상태: Stage 1');
    expect(view.equipmentSlots.first.slotLabel, '무기');
    expect(view.equipmentSlots.first.availableItems, hasLength(1));
  });

  test('homunculus selector exposes origin role and support labels', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );
    final CharacterProgress target = session.state.characters.homunculi.first;
    session.state = session.state.copyWith(
      battle: session.state.battle.copyWith(stageAssignments: const <String, List<String>>{}),
      characters: session.state.characters.copyWith(
        homunculi: <CharacterProgress>[
          target.copyWith(
            homunculusOrigin: 'Vital Seed Flask',
            homunculusRole: '지원',
            homunculusSupportEffect: '파티 생존력 보조',
          ),
        ],
      ),
    );

    final CharacterListItemView view = container
        .read(homunculusListItemViewsProvider)
        .first;

    expect(view.detailLines, <String>[
      '출처 Vital Seed Flask',
      '역할 지원',
      '보조효과 파티 생존력 보조',
    ]);
    expect(view.assignmentLabel, '배치 상태: 대기');
  });
}
