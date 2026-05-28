import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';

typedef EnchantEquipmentRecord = ({
  EquipmentInstance item,
  String locationLabel,
});

List<EnchantEquipmentRecord> collectEnchantEquipmentRecords(
  SessionState state,
) {
  final List<EnchantEquipmentRecord> records = <EnchantEquipmentRecord>[
    ...state.town.equipmentInventory.map(
      (EquipmentInstance item) => (item: item, locationLabel: '보관함'),
    ),
  ];

  void addCharacterRecords(
    List<CharacterProgress> characters,
    String groupLabel,
  ) {
    for (final CharacterProgress character in characters) {
      for (final EquipmentSlot slot in EquipmentSlot.values) {
        final EquipmentInstance? item = character.equipment.itemForSlot(slot);
        if (item == null) {
          continue;
        }
        records.add((
          item: item,
          locationLabel: '$groupLabel 장착: ${character.name}',
        ));
      }
    }
  }

  addCharacterRecords(state.characters.mercenaries, '용병');
  addCharacterRecords(state.characters.homunculi, '호문쿨루스');
  return records;
}

EquipmentInstance? findEnchantEquipmentById(
  SessionState state,
  String equipmentId,
) {
  for (final EnchantEquipmentRecord record in collectEnchantEquipmentRecords(
    state,
  )) {
    if (record.item.id == equipmentId) {
      return record.item;
    }
  }
  return null;
}
