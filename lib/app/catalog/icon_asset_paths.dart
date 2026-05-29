abstract final class CatalogIconAssetPaths {
  static String material(String materialId) {
    final String assetMaterialId = switch (materialId) {
      'promo_core_mercenary_2' => 'm_29',
      'promo_core_homunculus_2' => 'm_30',
      'tier_mat_mercenary_2' => 'm_27',
      'tier_mat_homunculus_2' => 'm_28',
      _ => materialId,
    };
    return 'assets/icons/materials/$assetMaterialId.png';
  }

  static String equipment(String blueprintId) {
    return 'assets/icons/equipment/$blueprintId.png';
  }

  static String element(String elementId) {
    return 'assets/icons/elements/$elementId.png';
  }

  static String potion(String potionId) {
    return 'assets/icons/potions/$potionId.png';
  }
}
