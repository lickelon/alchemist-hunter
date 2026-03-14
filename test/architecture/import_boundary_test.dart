import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('core, domain, presentation import boundaries stay isolated', () {
    final List<String> violations = <String>[];
    final RegExp importPattern = RegExp(
      r"import 'package:alchemist_hunter/([^']+)';",
    );

    for (final FileSystemEntity entity in Directory(
      'lib',
    ).listSync(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) {
        continue;
      }

      final String relativePath = entity.path.replaceAll('\\', '/');
      final String source = entity.readAsStringSync();
      final Iterable<RegExpMatch> imports = importPattern.allMatches(source);

      if (relativePath.startsWith('lib/core/')) {
        for (final RegExpMatch match in imports) {
          final String target = match.group(1)!;
          if (target.startsWith('features/')) {
            violations.add('$relativePath -> $target');
          }
        }
      }

      if (relativePath.contains('/domain/')) {
        for (final RegExpMatch match in imports) {
          final String target = match.group(1)!;
          if (target.contains('/data/')) {
            violations.add('$relativePath -> $target');
          }
        }
      }

      if (relativePath.contains('/presentation/')) {
        for (final RegExpMatch match in imports) {
          final String target = match.group(1)!;
          if (target.contains('/data/')) {
            violations.add('$relativePath -> $target');
          }
        }
      }

      if (relativePath.startsWith('lib/features/')) {
        final List<String> segments = relativePath.split('/');
        final String currentFeature = segments[2];
        for (final RegExpMatch match in imports) {
          final String target = match.group(1)!;
          final RegExpMatch? featureMatch = RegExp(
            r'^features/([^/]+)/(presentation|data)/',
          ).firstMatch(target);
          if (featureMatch == null) {
            continue;
          }
          if (featureMatch.group(1) != currentFeature) {
            violations.add('$relativePath -> $target');
          }
        }
      }
    }

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
