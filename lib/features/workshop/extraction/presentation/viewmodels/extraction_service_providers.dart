import 'package:alchemist_hunter/features/workshop/extraction/domain/services/alchemy_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<AlchemyService> alchemyServiceProvider =
    Provider<AlchemyService>((Ref ref) => AlchemyService());
