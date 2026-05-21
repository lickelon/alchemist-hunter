abstract final class CatalogIconAssetPaths {
  static String material(String materialId) {
    return 'assets/icons/materials/$materialId.png';
  }

  static String equipment(String blueprintId) {
    return 'assets/icons/equipment/$blueprintId.png';
  }

  static String element(String elementId) {
    return 'assets/icons/elements/$elementId.png';
  }
}
