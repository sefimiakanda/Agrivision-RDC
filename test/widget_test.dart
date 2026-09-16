import 'package:flutter_test/flutter_test.dart';

import 'package:agrivision_drc/database/parcelle_repository.dart';
import 'package:agrivision_drc/main.dart';
import 'package:agrivision_drc/models/parcelle.dart';

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

  testWidgets('ouvre le carnet et affiche son état vide', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      AgrivisionApp(parcelleRepository: EmptyParcelleRepository()),
    );

    await tester.tap(find.text('Carnet agricole'));
    await tester.pumpAndSettle();

    expect(find.text('Mes parcelles'), findsOneWidget);
    expect(find.text('Aucune parcelle enregistrée'), findsOneWidget);
  });
}

class EmptyParcelleRepository implements ParcelleRepository {
  @override
  Future<List<Parcelle>> getParcelles() async => const [];

  @override
  Future<Parcelle> createParcelle(Parcelle parcelle) async => parcelle;

  @override
  Future<void> updateParcelle(Parcelle parcelle) async {}

  @override
  Future<void> deleteParcelle(int id) async {}
}
