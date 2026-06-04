import 'package:alchemist_hunter/app/catalog/icon_asset_paths.dart';
import 'package:alchemist_hunter/common/widgets/resource_icon_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('single item stays at the leading edge of the centered grid', (
    WidgetTester tester,
  ) async {
    const Key gridKey = ValueKey<String>('grid');
    const Key itemKey = ValueKey<String>('item');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              key: gridKey,
              width: 220,
              child: ResourceIconGrid(
                items: <ResourceIconGridItem>[
                  ResourceIconGridItem(
                    key: itemKey,
                    assetPath: CatalogIconAssetPaths.material('m_1'),
                    badgeLabel: 'x1',
                    semanticLabel: 'Emberroot x1',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final Rect gridRect = tester.getRect(find.byKey(gridKey));
    final Rect itemRect = tester.getRect(find.byKey(itemKey));

    expect(itemRect.left, moreOrLessEquals(gridRect.left, epsilon: 0.1));
  });

  testWidgets('tiles expand to absorb remaining row width', (
    WidgetTester tester,
  ) async {
    const Key firstKey = ValueKey<String>('first');
    const Key secondKey = ValueKey<String>('second');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 240,
            child: ResourceIconGrid(
              items: <ResourceIconGridItem>[
                ResourceIconGridItem(
                  key: firstKey,
                  assetPath: CatalogIconAssetPaths.material('m_1'),
                  badgeLabel: 'x1',
                  semanticLabel: 'Emberroot x1',
                ),
                ResourceIconGridItem(
                  key: secondKey,
                  assetPath: CatalogIconAssetPaths.material('m_2'),
                  badgeLabel: 'x1',
                  semanticLabel: 'Ironbloom Bark x1',
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final Rect firstRect = tester.getRect(find.byKey(firstKey));
    final Rect secondRect = tester.getRect(find.byKey(secondKey));

    expect(firstRect.width, moreOrLessEquals(57, epsilon: 0.1));
    expect(secondRect.width, moreOrLessEquals(57, epsilon: 0.1));
  });
}
