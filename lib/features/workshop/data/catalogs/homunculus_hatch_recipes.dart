import 'package:alchemist_hunter/features/workshop/domain/models.dart';

const List<HomunculusHatchRecipe> homunculusHatchRecipes =
    <HomunculusHatchRecipe>[
      HomunculusHatchRecipe(
        id: 'hatch_vital_seed',
        name: 'Vital Seed Flask',
        description: '생명력이 강한 흑화 호문쿨루스를 배양한다.',
        resultName: 'Vital Nigredo',
        roleLabel: '지원',
        supportEffectLabel: '파티 생존력 보조',
        essenceCost: 40,
        arcaneDustCost: 2,
        materialCosts: <String, int>{'m_1': 2, 'm_3': 1},
        traitCosts: <String, double>{'t_hp': 0.8},
      ),
      HomunculusHatchRecipe(
        id: 'hatch_guard_seed',
        name: 'Guard Seed Flask',
        description: '방어 성향이 강한 흑화 호문쿨루스를 배양한다.',
        resultName: 'Guard Nigredo',
        roleLabel: '방어',
        supportEffectLabel: '방어 안정화 보조',
        essenceCost: 44,
        arcaneDustCost: 2,
        materialCosts: <String, int>{'m_2': 1, 'm_3': 2},
        traitCosts: <String, double>{'t_def': 0.8},
      ),
      HomunculusHatchRecipe(
        id: 'hatch_swift_seed',
        name: 'Swift Seed Flask',
        description: '기동성이 높은 흑화 호문쿨루스를 배양한다.',
        resultName: 'Swift Nigredo',
        roleLabel: '기동',
        supportEffectLabel: '행동 속도 보조',
        essenceCost: 42,
        arcaneDustCost: 2,
        materialCosts: <String, int>{'m_1': 1, 'm_4': 1},
        traitCosts: <String, double>{'t_spd': 0.8},
      ),
    ];
