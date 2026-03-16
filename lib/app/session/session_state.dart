import 'package:alchemist_hunter/features/battle/domain/models/battle_state.dart';
import 'package:alchemist_hunter/features/characters/domain/models/characters_state.dart';
import 'package:alchemist_hunter/features/town/domain/models/town_state.dart';
import 'package:alchemist_hunter/features/workshop/domain/models/workshop_state.dart';

import 'player_state.dart';

class SessionState {
  const SessionState({
    required this.lastSyncAt,
    required this.player,
    required this.town,
    required this.workshop,
    required this.battle,
    required this.characters,
  });

  final DateTime lastSyncAt;
  final PlayerState player;
  final TownState town;
  final WorkshopState workshop;
  final BattleState battle;
  final CharactersState characters;

  SessionState copyWith({
    DateTime? lastSyncAt,
    PlayerState? player,
    TownState? town,
    WorkshopState? workshop,
    BattleState? battle,
    CharactersState? characters,
  }) {
    return SessionState(
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      player: player ?? this.player,
      town: town ?? this.town,
      workshop: workshop ?? this.workshop,
      battle: battle ?? this.battle,
      characters: characters ?? this.characters,
    );
  }
}
