import 'package:flutter_test/flutter_test.dart';

import 'package:agrivision_drc/main.dart';

void main() {
  testWidgets('affiche les trois modules principaux', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AgrivisionApp());

    expect(find.text('Agrivision RDC'), findsOneWidget);
    expect(find.text('Carnet agricole'), findsOneWidget);
    expect(find.text('Météo agricole'), findsOneWidget);
    expect(find.text('Assistant agricole'), findsOneWidget);
  });

  testWidgets('ouvre le module météo depuis l’accueil', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AgrivisionApp());

    await tester.tap(find.text('Météo agricole'));
    await tester.pumpAndSettle();

    expect(
      find.text('Ce module sera construit dans la prochaine étape.'),
      findsOneWidget,
    );
  });
}
