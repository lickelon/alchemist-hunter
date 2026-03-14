import '../models.dart';

abstract interface class BattleCatalogRepository {
  List<String> stageCatalog();

  BattleDropTable dropTable(String stageId);
}
