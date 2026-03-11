import 'package:alchemist_hunter/features/characters/domain/character_models.dart';
import 'package:alchemist_hunter/features/session/application/session_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<List<CharacterProgress>> mercenaryListProvider =
    Provider<List<CharacterProgress>>((Ref ref) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.characters.mercenaries,
        ),
      );
    });

final Provider<List<CharacterProgress>> homunculusListProvider =
    Provider<List<CharacterProgress>>((Ref ref) {
      return ref.watch(
        sessionControllerProvider.select(
          (SessionState state) => state.characters.homunculi,
        ),
      );
    });
