import 'package:alchemist_hunter/features/game/domain/models.dart';

class DummyData {
  static final List<TraitUnit> traits = <TraitUnit>[
    const TraitUnit(id: 't_hp', name: 'Vital', type: TraitType.single, potency: 1),
    const TraitUnit(id: 't_atk', name: 'Aggro', type: TraitType.single, potency: 1),
    const TraitUnit(id: 't_def', name: 'Guard', type: TraitType.single, potency: 1),
    const TraitUnit(id: 't_spd', name: 'Swift', type: TraitType.single, potency: 1),
    const TraitUnit(id: 't_crit', name: 'Ruthless', type: TraitType.single, potency: 1),
    const TraitUnit(id: 't_life', name: 'Leech', type: TraitType.single, potency: 1),
    const TraitUnit(id: 't_focus', name: 'Focus', type: TraitType.single, potency: 1),
    const TraitUnit(id: 't_drop', name: 'Fortune', type: TraitType.single, potency: 1),
    const TraitUnit(id: 't_dark', name: 'Light', type: TraitType.single, potency: 1),
    const TraitUnit(id: 't_pure', name: 'Purity', type: TraitType.single, potency: 1),
    const TraitUnit(id: 't_mana', name: 'Mana', type: TraitType.single, potency: 1),
    const TraitUnit(id: 't_regen', name: 'Regen', type: TraitType.single, potency: 1),
    const TraitUnit(
      id: 'c_vigor',
      name: 'Vigor Blend',
      type: TraitType.compound,
      potency: 2,
      components: <String, double>{'t_hp': 0.6, 't_regen': 0.4},
    ),
    const TraitUnit(
      id: 'c_hunter',
      name: 'Hunter Blend',
      type: TraitType.compound,
      potency: 2,
      components: <String, double>{'t_atk': 0.5, 't_focus': 0.5},
    ),
    const TraitUnit(
      id: 'c_guardian',
      name: 'Guardian Blend',
      type: TraitType.compound,
      potency: 2,
      components: <String, double>{'t_def': 0.7, 't_hp': 0.3},
    ),
    const TraitUnit(
      id: 'c_luck',
      name: 'Lucky Blend',
      type: TraitType.compound,
      potency: 2,
      components: <String, double>{'t_drop': 0.6, 't_crit': 0.4},
    ),
    const TraitUnit(
      id: 'c_twilight',
      name: 'Twilight Blend',
      type: TraitType.compound,
      potency: 2,
      components: <String, double>{'t_dark': 0.5, 't_mana': 0.5},
    ),
    const TraitUnit(
      id: 'c_alch',
      name: 'Alchemist Blend',
      type: TraitType.compound,
      potency: 2,
      components: <String, double>{'t_pure': 0.5, 't_focus': 0.5},
    ),
  ];

  static final List<MaterialEntity> materials = List<MaterialEntity>.generate(
    30,
    (int i) => MaterialEntity(
      id: 'm_${i + 1}',
      name: 'Material ${i + 1}',
      rarity: i < 24 ? MaterialRarity.common : MaterialRarity.rare,
      traits: <TraitUnit>[traits[i % traits.length], traits[(i + 3) % traits.length]],
      analyzable: true,
      source: i < 18 ? 'general_shop' : 'battle',
    ),
  );

  static final List<PotionBlueprint> potions = List<PotionBlueprint>.generate(
    15,
    (int i) => PotionBlueprint(
      id: 'p_${i + 1}',
      name: 'Potion ${i + 1}',
      targetTraits: <String, double>{
        traits[i % 12].id: 0.6,
        traits[(i + 1) % 12].id: 0.4,
      },
      baseValue: 100 + (i * 25),
      useType: i < 10 ? PotionUseType.both : PotionUseType.combat,
    ),
  );

  static final List<ExtractionProfile> extractionProfiles = <ExtractionProfile>[
    const ExtractionProfile(
      id: 'full_basic',
      mode: ExtractionMode.full,
      yieldRate: 0.85,
      purityRate: 0.75,
      timeCost: Duration(seconds: 20),
    ),
    const ExtractionProfile(
      id: 'sel_precise',
      mode: ExtractionMode.selective,
      yieldRate: 0.65,
      purityRate: 0.92,
      timeCost: Duration(seconds: 30),
    ),
  ];

  static final List<String> stages = List<String>.generate(5, (int i) => 'stage_${i + 1}');

  static final List<String> enemySets =
      List<String>.generate(20, (int i) => 'enemy_set_${i + 1}');

  static ShopState generalShopState(DateTime now) {
    return ShopState(
      shopType: ShopType.general,
      items: materials
          .take(8)
          .map(
            (MaterialEntity m) => ShopItem(
              materialId: m.id,
              name: m.name,
              price: 50,
              quantity: 20,
            ),
          )
          .toList(),
      nextRefreshAt: now.add(const Duration(minutes: 15)),
      forcedRefreshCost: 25,
      baseRefreshCost: 25,
      refreshCostStep: 15,
      cycleRefreshCount: 0,
    );
  }

  static ShopState catalystShopState(DateTime now) {
    return ShopState(
      shopType: ShopType.catalyst,
      items: materials
          .skip(24)
          .take(6)
          .map(
            (MaterialEntity m) => ShopItem(
              materialId: m.id,
              name: m.name,
              price: 180,
              quantity: 8,
            ),
          )
          .toList(),
      nextRefreshAt: now.add(const Duration(minutes: 30)),
      forcedRefreshCost: 90,
      baseRefreshCost: 90,
      refreshCostStep: 45,
      cycleRefreshCount: 0,
    );
  }

  static BattleDropTable dropTable(String stageId) {
    return BattleDropTable(
      stageId: stageId,
      normalDrops: const <BattleDropEntry>[
        BattleDropEntry(materialId: 'm_1', min: 1, max: 3, chance: 0.8),
        BattleDropEntry(materialId: 'm_2', min: 1, max: 2, chance: 0.7),
        BattleDropEntry(materialId: 'm_7', min: 1, max: 1, chance: 0.4),
      ],
      specialDrops: const <BattleDropEntry>[
        BattleDropEntry(materialId: 'm_27', min: 1, max: 1, chance: 0.35),
        BattleDropEntry(materialId: 'm_30', min: 1, max: 2, chance: 0.2),
      ],
    );
  }
}
