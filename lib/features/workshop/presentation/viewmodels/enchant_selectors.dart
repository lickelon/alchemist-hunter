import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alchemist_hunter/core/session/session_providers.dart';
import 'package:alchemist_hunter/features/characters/domain/character_models.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/workshop/data/catalogs/material_catalog.dart';
import 'package:alchemist_hunter/features/workshop/data/catalogs/potion_catalog.dart';
import 'package:alchemist_hunter/features/workshop/domain/models.dart';

class EnchantPotionView {
  const EnchantPotionView({
    required this.stackKey,
    required this.name,
    required this.quantity,
    required this.qualityLabel,
    required this.traitsLabel,
  });

  final String stackKey;
  final String name;
  final int quantity;
  final String qualityLabel;
  final String traitsLabel;
}

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

final Provider<List<EnchantPotionView>>
enchantPotionViewsProvider = Provider<List<EnchantPotionView>>((Ref ref) {
  final Map<String, int> stacks = ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.workshop.craftedPotionStacks,
    ),
  );
  final Map<String, CraftedPotion> details = ref.watch(
    sessionControllerProvider.select(
      (SessionState state) => state.workshop.craftedPotionDetails,
    ),
  );

  final List<EnchantPotionView> views = stacks.entries.map((
    MapEntry<String, int> entry,
  ) {
    final CraftedPotion? detail = details[entry.key];
    final PotionBlueprint? potion = detail == null
        ? null
        : potionCatalog
              .where(
                (PotionBlueprint blueprint) =>
                    blueprint.id == detail.typePotionId,
              )
              .firstOrNull;
    final List<MapEntry<String, double>> sortedTraits =
        detail?.traits.entries.toList() ?? <MapEntry<String, double>>[];
    sortedTraits.sort(
      (MapEntry<String, double> left, MapEntry<String, double> right) =>
          right.value.compareTo(left.value),
    );
    final String traitsLabel = sortedTraits
        .take(2)
        .map((MapEntry<String, double> trait) {
          final TraitUnit? unit = traitCatalog
              .where((TraitUnit entry) => entry.id == trait.key)
              .firstOrNull;
          return '${unit?.name ?? trait.key} ${(trait.value * 100).round()}%';
        })
        .join(', ');

    return EnchantPotionView(
      stackKey: entry.key,
      name: potion?.name ?? entry.key,
      quantity: entry.value,
      qualityLabel: detail?.qualityGrade.name.toUpperCase() ?? '-',
      traitsLabel: traitsLabel.isEmpty ? '특성 정보 없음' : traitsLabel,
    );
  }).toList();

  views.sort((EnchantPotionView left, EnchantPotionView right) {
    final int quantityCompare = right.quantity.compareTo(left.quantity);
    if (quantityCompare != 0) {
      return quantityCompare;
    }
    return left.name.compareTo(right.name);
  });
  return views;
});

final Provider<List<EnchantEquipmentView>>
enchantEquipmentViewsProvider = Provider<List<EnchantEquipmentView>>((Ref ref) {
  final SessionState state = ref.watch(sessionControllerProvider);
  final List<EnchantEquipmentView> views = <EnchantEquipmentView>[
    ...state.town.equipmentInventory.map((EquipmentInstance item) {
      return _mapEquipmentView(item, '보관함');
    }),
  ];

  views.addAll(_characterEquipmentViews(state.characters.mercenaries, '용병'));
  views.addAll(_characterEquipmentViews(state.characters.homunculi, '호문쿨루스'));

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

List<EnchantEquipmentView> _characterEquipmentViews(
  List<CharacterProgress> characters,
  String groupLabel,
) {
  final List<EnchantEquipmentView> views = <EnchantEquipmentView>[];
  for (final CharacterProgress character in characters) {
    for (final EquipmentSlot slot in EquipmentSlot.values) {
      final EquipmentInstance? item = character.equipment.itemForSlot(slot);
      if (item == null) {
        continue;
      }
      views.add(_mapEquipmentView(item, '$groupLabel 장착: ${character.name}'));
    }
  }
  return views;
}

EnchantEquipmentView _mapEquipmentView(
  EquipmentInstance item,
  String locationLabel,
) {
  return EnchantEquipmentView(
    equipmentId: item.id,
    name: item.name,
    slotLabel: _slotLabel(item.slot),
    locationLabel: locationLabel,
    statLabel:
        'ATK ${item.totalAttack} / DEF ${item.totalDefense} / HP ${item.totalHealth}',
    enchantLabel: item.enchant?.label ?? '인챈트 없음',
  );
}

String _slotLabel(EquipmentSlot slot) {
  switch (slot) {
    case EquipmentSlot.weapon:
      return '무기';
    case EquipmentSlot.armor:
      return '방어구';
    case EquipmentSlot.accessory:
      return '장신구';
  }
}
