import 'package:alchemist_hunter/features/workshop/domain/models.dart';

String workshopMaterialRarityLabel(MaterialRarity rarity) {
  return switch (rarity) {
    MaterialRarity.common => '일반',
    MaterialRarity.uncommon => '고급',
    MaterialRarity.rare => '희귀',
    MaterialRarity.epic => '서사',
  };
}

String workshopTraitAmountLabel(double amount) {
  return '${amount >= 0 ? '+' : ''}${amount.toStringAsFixed(2)}';
}
