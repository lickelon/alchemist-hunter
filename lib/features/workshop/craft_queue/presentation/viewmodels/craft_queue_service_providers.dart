import 'package:alchemist_hunter/features/workshop/craft_queue/domain/services/craft_queue_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<CraftQueueService> craftQueueServiceProvider =
    Provider<CraftQueueService>((Ref ref) => CraftQueueService());
