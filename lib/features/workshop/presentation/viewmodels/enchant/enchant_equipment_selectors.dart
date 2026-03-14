import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/presentation/viewmodels/enchant/enchant_equipment_lookup.dart';

class EnchantEquipmentView {
  const EnchantEquipmentView({
    required this.equipmentId,
    required this.name,
    required this.slotLabel,
    required this.locationLabel,
    required this.statLabel,
    required this.enchantLabel,
  });

  final String equipmentId;
  final String name;
  final String slotLabel;
  final String locationLabel;
  final String statLabel;
  final String enchantLabel;
}

final Provider<List<EnchantEquipmentView>>
enchantEquipmentViewsProvider = Provider<List<EnchantEquipmentView>>((Ref ref) {
  final SessionState state = ref.watch(sessionControllerProvider);
  final List<EnchantEquipmentView> views = collectEnchantEquipmentRecords(state)
      .map((EnchantEquipmentRecord record) {
        final item = record.item;
        return EnchantEquipmentView(
          equipmentId: item.id,
          name: item.name,
          slotLabel: equipmentSlotLabel(item.slot),
          locationLabel: record.locationLabel,
          statLabel:
              'ATK ${item.totalAttack} / DEF ${item.totalDefense} / HP ${item.totalHealth}',
          enchantLabel: item.enchant?.label ?? '인챈트 없음',
        );
      })
      .toList();

  views.sort((EnchantEquipmentView left, EnchantEquipmentView right) {
    final int locationCompare = left.locationLabel.compareTo(right.locationLabel);
    if (locationCompare != 0) {
      return locationCompare;
    }
    return left.name.compareTo(right.name);
  });
  return views;
});
