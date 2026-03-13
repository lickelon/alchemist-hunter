import 'package:alchemist_hunter/features/characters/domain/character_models.dart';

import 'battle_state.dart';
import 'player_state.dart';
import 'town_state.dart';
import 'workshop_state.dart';

class SessionState {
  const SessionState({
    required this.player,
    required this.town,
    required this.workshop,
    required this.battle,
    required this.characters,
  });

  final PlayerState player;
  final TownState town;
  final WorkshopState workshop;
  final BattleState battle;
  final CharactersState characters;

  SessionState copyWith({
    PlayerState? player,
    TownState? town,
    WorkshopState? workshop,
    BattleState? battle,
    CharactersState? characters,
  }) {
    return SessionState(
      player: player ?? this.player,
      town: town ?? this.town,
      workshop: workshop ?? this.workshop,
      battle: battle ?? this.battle,
      characters: characters ?? this.characters,
    );
  }
}
