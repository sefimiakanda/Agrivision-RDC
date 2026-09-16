import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:agrivision_drc/database/parcelle_repository.dart';
import 'package:agrivision_drc/main.dart';
import 'package:agrivision_drc/models/activite.dart';
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

    expect(find.text('Météo agricole'), findsOneWidget);
    expect(
      find.text('Recherchez une ville pour voir sa météo.'),
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

  testWidgets('enregistre une parcelle depuis le formulaire', (
    WidgetTester tester,
  ) async {
    final repository = EmptyParcelleRepository();
    await tester.pumpWidget(AgrivisionApp(parcelleRepository: repository));

    await tester.tap(find.text('Carnet agricole'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Parcelle familiale');
    await tester.enterText(fields.at(1), 'Kinshasa');
    await tester.enterText(fields.at(2), 'Maïs');
    await tester.enterText(fields.at(3), '2.5');
    await tester.tap(find.text('Enregistrer la parcelle'));
    await tester.pumpAndSettle();

    expect(find.text('Mes parcelles'), findsOneWidget);
    expect(find.text('Parcelle familiale'), findsOneWidget);
    expect(repository.createdParcelles.single.superficie, 2.5);
  });
}

class EmptyParcelleRepository implements ParcelleRepository {
  final List<Parcelle> createdParcelles = [];

  @override
  Future<List<Parcelle>> getParcelles() async => const [];

  @override
  Future<Parcelle> createParcelle(Parcelle parcelle) async {
    final created = parcelle.copyWith(id: createdParcelles.length + 1);
    createdParcelles.add(created);
    return created;
  }

  @override
  Future<void> updateParcelle(Parcelle parcelle) async {}

  @override
  Future<void> deleteParcelle(int id) async {}

  @override
  Future<List<Activite>> getActivites(int parcelleId) async => const [];

  @override
  Future<Activite> createActivite(Activite activite) async => activite;

  @override
  Future<void> updateActivite(Activite activite) async {}

  @override
  Future<void> deleteActivite(int id) async {}
}
