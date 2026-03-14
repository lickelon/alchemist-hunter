import 'package:alchemist_hunter/features/town/domain/services/economy_service.dart';
import 'package:alchemist_hunter/features/town/domain/services/mercenary_recruitment_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<EconomyService> economyServiceProvider =
    Provider<EconomyService>((Ref ref) => EconomyService());

final Provider<MercenaryRecruitmentService> mercenaryRecruitmentServiceProvider =
    Provider<MercenaryRecruitmentService>(
      (Ref ref) => const MercenaryRecruitmentService(),
    );
