import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/equipment_display_labels.dart';
import 'package:alchemist_hunter/features/workshop/enchanting/presentation/viewmodels/enchant_equipment_lookup.dart';

class EnchantEquipmentView {
  const EnchantEquipmentView({
    required this.equipmentId,
    required this.blueprintId,
    required this.name,
    required this.slotLabel,
    required this.locationLabel,
    required this.statLabel,
    required this.enchantLabel,
  });

  final String equipmentId;
  final String blueprintId;
  final String name;
  final String slotLabel;
  final String locationLabel;
  final String statLabel;
  final String enchantLabel;
}

final Provider<List<EnchantEquipmentView>> enchantEquipmentViewsProvider =
    Provider<List<EnchantEquipmentView>>((Ref ref) {
      final SessionState state = ref.watch(sessionControllerProvider);
      final List<EnchantEquipmentView> views =
          collectEnchantEquipmentRecords(state).map((
            EnchantEquipmentRecord record,
          ) {
            final item = record.item;
            return EnchantEquipmentView(
              equipmentId: item.id,
              blueprintId: item.blueprintId,
              name: item.name,
              slotLabel: equipmentSlotLabel(item.slot),
              locationLabel: record.locationLabel,
              statLabel: equipmentInstanceDetailLabel(item),
              enchantLabel: item.enchant?.label ?? '인챈트 없음',
            );
          }).toList();

      views.sort((EnchantEquipmentView left, EnchantEquipmentView right) {
        final int locationCompare = left.locationLabel.compareTo(
          right.locationLabel,
        );
        if (locationCompare != 0) {
          return locationCompare;
        }
        return left.name.compareTo(right.name);
      });
      return views;
    });
