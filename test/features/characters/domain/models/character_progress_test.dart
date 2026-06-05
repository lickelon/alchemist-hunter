import 'package:alchemist_hunter/features/characters/domain/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('homunculus max rank follows tier thresholds', () {
    const CharacterProgress base = CharacterProgress(
      id: 'homo_test',
      name: 'Test Homunculus',
      type: CharacterType.homunculus,
      level: 1,
      rank: 1,
      xp: 0,
      homunculusTier: HomunculusTier.nigredo,
    );

    expect(base.maxRankForCurrentTier, 3);
    expect(
      base
          .copyWith(homunculusTier: HomunculusTier.albedo)
          .maxRankForCurrentTier,
      5,
    );
    expect(
      base
          .copyWith(homunculusTier: HomunculusTier.citrinitas)
          .maxRankForCurrentTier,
      8,
    );
    expect(
      base
          .copyWith(homunculusTier: HomunculusTier.rubedo)
          .maxRankForCurrentTier,
      10,
    );
  });

  test('rank in current tier follows reset rank', () {
    const CharacterProgress character = CharacterProgress(
      id: 'homo_test',
      name: 'Test Homunculus',
      type: CharacterType.homunculus,
      level: 1,
      rank: 5,
      xp: 0,
      homunculusTier: HomunculusTier.albedo,
    );

    expect(character.rankInCurrentTier, 5);
  });
}
