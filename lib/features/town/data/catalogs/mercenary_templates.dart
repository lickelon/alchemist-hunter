import 'package:alchemist_hunter/features/town/domain/models.dart';

const List<MercenaryTemplate> mercenaryTemplates = <MercenaryTemplate>[
  MercenaryTemplate(
    id: 'merc_template_sellsword',
    name: 'Apprentice Sellsword',
    roleLabel: '전열 돌격',
    hireCost: 180,
    tierIndex: 1,
  ),
  MercenaryTemplate(
    id: 'merc_template_guard',
    name: 'Hedge Guard',
    roleLabel: '방어 전담',
    hireCost: 160,
    tierIndex: 1,
  ),
  MercenaryTemplate(
    id: 'merc_template_scout',
    name: 'Dusk Scout',
    roleLabel: '후열 지원',
    hireCost: 170,
    tierIndex: 1,
  ),
  MercenaryTemplate(
    id: 'merc_template_adept',
    name: 'Ash Adept',
    roleLabel: '전투 보조',
    hireCost: 190,
    tierIndex: 1,
  ),
];
