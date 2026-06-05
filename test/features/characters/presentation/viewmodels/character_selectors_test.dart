import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/characters/presentation/viewmodels/character_list_selectors.dart';
import 'package:alchemist_hunter/features/characters/presentation/viewmodels/character_view_models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../../support/catalog_fixtures.dart';

void main() {
  test('character hint selectors reflect rank and tier conditions', () {
    final ProviderContainer container = ProviderContainer(
      overrides: testCatalogProviderOverrides(),
    );
    addTearDown(container.dispose);

    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );
    session.state = createTestInitialSessionState(DateTime(2026, 1, 1, 10));
    final CharacterProgress target = session.state.characters.mercenaries.first;
    final CharacterProgress tierReadyTarget = target.copyWith(
      rank: target.maxRankForCurrentTier,
    );
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
          tierReadyTarget.copyWith(level: tierReadyTarget.maxLevelForRank),
        ],
      ),
    );

    final CharacterListItemView view = container
        .read(mercenaryListItemViewsProvider)
        .first;

    expect(view.typeLabel, '용병');
    expect(view.growthLabel, '레벨 10, 랭크 2, 티어 1');
    expect(view.rankHint, '현재 티어 최대 랭크 도달');
    expect(view.tierHint, '티어업 가능');
    expect(view.tierMaterialLabel, '승급 재료: 용병 승급 재료 2 1/1');
    expect(view.assignmentLabel, 'Stage 1');
    expect(view.equipmentSlots.first.slotLabel, '무기');
    expect(view.equipmentSlots.first.availableItems, hasLength(1));
  });

  test('homunculus selector exposes assignment and growth labels', () {
    final ProviderContainer container = ProviderContainer(
      overrides: testCatalogProviderOverrides(),
    );
    addTearDown(container.dispose);

    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );
    session.state = createTestInitialSessionState(DateTime(2026, 1, 1, 10));
    final CharacterProgress target = session.state.characters.homunculi.first;
    session.state = session.state.copyWith(
      battle: session.state.battle.copyWith(
        stageAssignments: const <String, List<String>>{},
      ),
      workshop: session.state.workshop.copyWith(
        supportAssignmentsByFunction: const <String, String>{
          'extraction': 'homo_1',
        },
      ),
      characters: session.state.characters.copyWith(
        homunculi: <CharacterProgress>[target],
      ),
    );

    final CharacterListItemView view = container
        .read(homunculusListItemViewsProvider)
        .first;

    expect(view.typeLabel, '호문쿨루스');
    expect(
      view.growthLabel,
      '레벨 ${target.level}, 랭크 ${target.rank}, 티어 ${target.tierIndex}',
    );
    expect(view.assignmentLabel, '작업실(추출)');
    expect(view.assignmentGuideLabel, '배치 변경은 전투/작업실 화면에서 진행');
  });
}
