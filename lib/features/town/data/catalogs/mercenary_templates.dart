import 'package:alchemist_hunter/features/characters/domain/combat_jobs.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';

const List<MercenaryTemplate> mercenaryTemplates = <MercenaryTemplate>[
  MercenaryTemplate(
    id: 'merc_template_sellsword',
    name: 'Apprentice Sellsword',
    roleLabel: '전열 돌격',
    combatJobId: CombatJobIds.mercenaryWarrior,
    hireCost: 180,
    tierIndex: 1,
  ),
  MercenaryTemplate(
    id: 'merc_template_guard',
    name: 'Hedge Guard',
    roleLabel: '방어 전담',
    combatJobId: CombatJobIds.mercenaryWarrior,
    hireCost: 160,
    tierIndex: 1,
  ),
  MercenaryTemplate(
    id: 'merc_template_scout',
    name: 'Dusk Scout',
    roleLabel: '후열 지원',
    combatJobId: CombatJobIds.mercenaryArcher,
    hireCost: 170,
    tierIndex: 1,
  ),
  MercenaryTemplate(
    id: 'merc_template_adept',
    name: 'Ash Adept',
    roleLabel: '전투 보조',
    combatJobId: CombatJobIds.mercenaryMage,
    hireCost: 190,
    tierIndex: 1,
  ),
];
