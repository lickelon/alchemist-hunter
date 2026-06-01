class WorkshopBrewExperimentSelection {
  static const double defaultPrimaryRatio = 0.55;

  final List<String> _selectedTraitIds = <String>[];
  double primaryRatio = defaultPrimaryRatio;

  List<String> get selectedTraitIds => _selectedTraitIds;

  int get selectedCount => _selectedTraitIds.length;

  bool get canSubmit => _selectedTraitIds.length == 2;

  String? get primaryTraitId => canSubmit ? _selectedTraitIds[0] : null;

  String? get secondaryTraitId => canSubmit ? _selectedTraitIds[1] : null;

  Map<String, double> get inputTraits {
    if (!canSubmit) {
      return const <String, double>{};
    }
    return <String, double>{
      _selectedTraitIds[0]: primaryRatio,
      _selectedTraitIds[1]: 1 - primaryRatio,
    };
  }

  void syncWithInventory(Map<String, double> inventory) {
    _selectedTraitIds.removeWhere(
      (String traitId) => (inventory[traitId] ?? 0) <= 0,
    );
  }

  void toggleTrait(String traitId) {
    if (_selectedTraitIds.contains(traitId)) {
      _selectedTraitIds.remove(traitId);
      primaryRatio = defaultPrimaryRatio;
      return;
    }
    if (_selectedTraitIds.length >= 2) {
      _selectedTraitIds.removeAt(0);
    }
    _selectedTraitIds.add(traitId);
    primaryRatio = defaultPrimaryRatio;
  }

  void reset() {
    _selectedTraitIds.clear();
    primaryRatio = defaultPrimaryRatio;
  }
}
