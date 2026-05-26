import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/town/domain/models.dart';
import 'package:alchemist_hunter/features/town/presentation/widgets/sheets/town_shop_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('town shop sheet shows stock policy and disables sold out item', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        sessionControllerProvider.overrideWith(
          (Ref ref) => SessionController(clock: () => DateTime(2026, 1, 1, 10)),
        ),
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

    expect(find.text('상품별 주기 한도 20개 / 15분마다 재입고'), findsOneWidget);
    expect(find.text('다음 재입고 10:15'), findsAtLeastNWidgets(1));
    expect(find.text('Emberroot'), findsOneWidget);
    expect(find.textContaining('품절'), findsWidgets);

    final Finder soldOutButton = find.widgetWithText(FilledButton, '품절');
    expect(soldOutButton, findsOneWidget);
    expect(tester.widget<FilledButton>(soldOutButton).onPressed, isNull);

    await tester.tap(find.widgetWithText(FilledButton, '강제 갱신 (골드 25)'));
    await tester.pumpAndSettle();

    expect(find.textContaining('재고 20'), findsWidgets);
    final Finder buyButton = find.widgetWithText(FilledButton, '구매').first;
    expect(tester.widget<FilledButton>(buyButton).onPressed, isNotNull);
  });
}
