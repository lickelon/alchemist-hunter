import '../character_models.dart';

class CharactersState {
  const CharactersState({required this.mercenaries, required this.homunculi});

  final List<CharacterProgress> mercenaries;
  final List<CharacterProgress> homunculi;

  CharactersState copyWith({
    List<CharacterProgress>? mercenaries,
    List<CharacterProgress>? homunculi,
  }) {
    return CharactersState(
      mercenaries: mercenaries ?? this.mercenaries,
      homunculi: homunculi ?? this.homunculi,
    );
  }
}
