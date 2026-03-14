import 'package:alchemist_hunter/app/session/app_session.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_extraction_card.dart';
import 'package:alchemist_hunter/features/workshop/presentation/widgets/workshop_material_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('workshop material sheet shows material name and trait summary', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);

    final SessionController session = container.read(
      sessionControllerProvider.notifier,
    );
    session.state = session.state.copyWith(
      player: session.state.player.copyWith(
        materialInventory: const <String, int>{'m_1': 2},
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: WorkshopMaterialCard(materialTypeCount: 1, totalCount: 2),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Items'));
    await tester.pumpAndSettle();

    expect(find.text('Emberroot'), findsOneWidget);
    expect(find.text('common / Vital / Swift'), findsOneWidget);
    expect(find.text('x2'), findsOneWidget);
  });

  testWidgets(
    'workshop extraction sheet shows trait stock and extraction actions',
    (WidgetTester tester) async {
      final ProviderContainer container = ProviderContainer();
      addTearDown(container.dispose);

      final SessionController session = container.read(
        sessionControllerProvider.notifier,
      );
      session.state = session.state.copyWith(
        player: session.state.player.copyWith(
          materialInventory: const <String, int>{'m_1': 2},
        ),
        workshop: session.state.workshop.copyWith(
          extractedTraitInventory: const <String, double>{'t_hp': 0.85},
        ),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: WorkshopExtractionCard(
                materialTypeCount: 1,
                extractedTraitTypeCount: 1,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Extraction'));
      await tester.pumpAndSettle();

      expect(find.text('보유 추출 특성'), findsOneWidget);
      expect(find.textContaining('Vital 0.85'), findsOneWidget);
      expect(find.text('분석/추출'), findsOneWidget);

      await tester.tap(find.text('분석/추출'));
      await tester.pumpAndSettle();

      expect(find.text('보유 2개'), findsOneWidget);
      expect(find.text('추출 수량'), findsOneWidget);
      expect(find.text('최대'), findsOneWidget);
    },
  );
}
