import 'package:alchemist_hunter/features/workshop/support/domain/services/workshop_support_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<WorkshopSupportService> workshopSupportServiceProvider =
    Provider<WorkshopSupportService>(
      (Ref ref) => const WorkshopSupportService(),
    );
