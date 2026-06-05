import 'package:alchemist_hunter/features/characters/domain/models.dart';

String createOpaqueCharacterId({
  required DateTime now,
  required int seed,
  Iterable<String> reservedIds = const <String>[],
}) {
  final Set<String> reserved = reservedIds.toSet();
  int currentSeed = seed;
  while (true) {
    final String id = 'c_${_base36(_opaqueValue(now, currentSeed))}';
    if (!reserved.contains(id)) {
      return id;
    }
    currentSeed += 1;
  }
}

Set<String> collectCharacterIds(
  CharactersState characters, {
  Iterable<CharacterProgress?> pendingCharacters = const <CharacterProgress?>[],
}) {
  return <String>{
    ...characters.mercenaries.map(
      (CharacterProgress character) => character.id,
    ),
    ...characters.homunculi.map((CharacterProgress character) => character.id),
    ...pendingCharacters.whereType<CharacterProgress>().map(
      (CharacterProgress character) => character.id,
    ),
  };
}

int _opaqueValue(DateTime now, int seed) {
  int hash = 0xcbf29ce484222325;
  for (final int codeUnit in '${now.microsecondsSinceEpoch}:$seed'.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x100000001b3) & 0x7fffffffffffffff;
  }
  return hash;
}

String _base36(int value) {
  if (value == 0) {
    return '0';
  }
  const String digits = '0123456789abcdefghijklmnopqrstuvwxyz';
  int remaining = value;
  final StringBuffer buffer = StringBuffer();
  while (remaining > 0) {
    buffer.write(digits[remaining % 36]);
    remaining = remaining ~/ 36;
  }
  return buffer.toString().split('').reversed.join();
}
