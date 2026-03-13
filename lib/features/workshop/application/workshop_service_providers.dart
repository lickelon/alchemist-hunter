import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'services/alchemy_service.dart';
import 'services/craft_queue_service.dart';
import 'services/potion_crafting_service.dart';

final Provider<CraftQueueService> craftQueueServiceProvider =
    Provider<CraftQueueService>((Ref ref) => CraftQueueService());

final Provider<PotionCraftingService> potionCraftingServiceProvider =
    Provider<PotionCraftingService>(
      (Ref ref) => PotionCraftingService(random: Random(13)),
    );

final Provider<AlchemyService> alchemyServiceProvider =
    Provider<AlchemyService>((Ref ref) => AlchemyService());
