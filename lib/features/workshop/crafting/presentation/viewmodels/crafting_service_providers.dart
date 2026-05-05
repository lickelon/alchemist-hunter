import 'dart:math';

import 'package:alchemist_hunter/features/workshop/crafting/domain/services/potion_crafting_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<PotionCraftingService> potionCraftingServiceProvider =
    Provider<PotionCraftingService>(
      (Ref ref) => PotionCraftingService(random: Random(13)),
    );
