import 'package:alchemist_hunter/features/characters/domain/character_models.dart';
import 'package:alchemist_hunter/features/session/application/session_logic.dart';
import 'package:alchemist_hunter/features/session/application/session_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CharacterController {
  CharacterController(
    this._session, {
    CharacterDomain characterDomain = const CharacterDomain(),
  }) : _characterDomain = characterDomain;

  final SessionController _session;
  final CharacterDomain _characterDomain;

  void rankUp(CharacterType type, String characterId) {
    _session.applyMutation(
      _characterDomain.rankUp(
        state: _session.snapshot(),
        type: type,
        characterId: characterId,
      ),
    );
  }

  void tierUp(CharacterType type, String characterId) {
    _session.applyMutation(
      _characterDomain.tierUp(
        state: _session.snapshot(),
        type: type,
        characterId: characterId,
      ),
    );
  }
}

final Provider<CharacterController> characterControllerProvider =
    Provider<CharacterController>((Ref ref) {
      return CharacterController(ref.read(sessionControllerProvider.notifier));
    });

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
