import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/presentation/widgets/sheets/town_shop_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/catalog_fixtures.dart';

void main() {
  testWidgets('town shop sheet shows item grid and sold out detail', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        ...testCatalogProviderOverrides(),
        sessionControllerProvider.overrideWith((Ref ref) {
          final DateTime now = DateTime(2026, 1, 1, 10);
          return SessionController(
            initialState: createTestInitialSessionState(now),
            clock: () => now,
          );
        }),
      ],
    );
    addTearDown(container.dispose);

    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );
    final ShopState shop = session.state.town.generalShop;
    final ShopItem first = shop.items.first;
    session.state = session.state.copyWith(
      town: session.state.town.copyWith(
        generalShop: shop.copyWith(
          items: <ShopItem>[
            ShopItem(
              materialId: first.materialId,
              name: first.name,
              price: first.price,
              quantity: 0,
            ),
            ...shop.items.skip(1),
          ],
        ),
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: TownShopSheet(title: '일반 상점', shopType: ShopType.general),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('한도 20개'), findsNothing);
    expect(find.text('재입고 15분'), findsNothing);
    expect(find.byKey(const ValueKey<String>('shop_item_m_1')), findsOneWidget);
    expect(find.textContaining('품절'), findsWidgets);

    await tester.tap(find.byKey(const ValueKey<String>('shop_item_m_1')));
    await tester.pumpAndSettle();

    expect(find.text('Emberroot'), findsOneWidget);
    expect(find.text('다음 입고 10:15'), findsOneWidget);
    final Finder soldOutButton = find.widgetWithText(FilledButton, '품절');
    expect(soldOutButton, findsOneWidget);
    expect(tester.widget<FilledButton>(soldOutButton).onPressed, isNull);
    await tester.tap(find.text('닫기').last);
    await tester.pumpAndSettle();

    expect(find.text('골드 25'), findsOneWidget);
    await tester.tap(find.text('갱신'));
    await tester.pumpAndSettle();

    expect(find.text('x20'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey<String>('shop_item_m_1')));
    await tester.pumpAndSettle();

    expect(find.text('재고 20개'), findsOneWidget);
    expect(find.text('선택 1개'), findsOneWidget);
    expect(find.text('최대 20개'), findsOneWidget);
    final Finder buyButton = find.widgetWithText(FilledButton, '구매').first;
    expect(tester.widget<FilledButton>(buyButton).onPressed, isNotNull);
  });
}
