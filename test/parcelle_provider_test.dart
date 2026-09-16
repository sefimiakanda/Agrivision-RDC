import 'package:flutter_test/flutter_test.dart';

import 'package:agrivision_drc/controllers/activite_provider.dart';
import 'package:agrivision_drc/controllers/parcelle_provider.dart';
import 'package:agrivision_drc/database/parcelle_repository.dart';
import 'package:agrivision_drc/models/activite.dart';
import 'package:agrivision_drc/models/parcelle.dart';

void main() {
  test('gère le cycle CRUD d’une parcelle', () async {
    final repository = FakeParcelleRepository();
    final provider = ParcelleProvider(repository);
    final parcelle = const Parcelle(
      ville: 'Kinshasa',
      nom: 'Parcelle familiale',
      culture: 'Maïs',
      superficie: 2.5,
    );

    await provider.loadParcelles();
    expect(provider.parcelles, isEmpty);

    expect(await provider.saveParcelle(parcelle), isTrue);
    expect(provider.parcelles.single.nom, 'Parcelle familiale');
    expect(provider.parcelles.single.id, 1);

    final updated = provider.parcelles.single.copyWith(superficie: 3.0);
    expect(await provider.saveParcelle(updated), isTrue);
    expect(provider.parcelles.single.superficie, 3.0);

    expect(await provider.removeParcelle(updated), isTrue);
    expect(provider.parcelles, isEmpty);
  });

  test('gère le cycle CRUD d’une activité', () async {
    final repository = FakeParcelleRepository();
    final provider = ActiviteProvider(repository);
    final activite = Activite(
      parcelleId: 1,
      type: 'Semis',
      date: DateTime(2026, 9, 16),
      description: 'Semis de maïs.',
    );

    await provider.loadActivites(1);
    expect(provider.activites, isEmpty);

    expect(await provider.saveActivite(activite), isTrue);
    expect(provider.activites.single.type, 'Semis');
    expect(provider.activites.single.id, 1);

    final updated = provider.activites.single.copyWith(type: 'Arrosage');
    expect(await provider.saveActivite(updated), isTrue);
    expect(provider.activites.single.type, 'Arrosage');

    expect(await provider.removeActivite(updated), isTrue);
    expect(provider.activites, isEmpty);
  });
}

class FakeParcelleRepository implements ParcelleRepository {
  final List<Parcelle> _items = [];
  final List<Activite> _activites = [];
  int _nextId = 1;
  int _nextActiviteId = 1;

  @override
  Future<List<Parcelle>> getParcelles() async => List.of(_items);

  @override
  Future<Parcelle> createParcelle(Parcelle parcelle) async {
    final created = parcelle.copyWith(id: _nextId++);
    _items.add(created);
    return created;
  }

  @override
  Future<void> updateParcelle(Parcelle parcelle) async {
    final index = _items.indexWhere((item) => item.id == parcelle.id);
    _items[index] = parcelle;
  }

  @override
  Future<void> deleteParcelle(int id) async {
    _items.removeWhere((item) => item.id == id);
  }

  @override
  Future<List<Activite>> getActivites(int parcelleId) async =>
      _activites.where((item) => item.parcelleId == parcelleId).toList();

  @override
  Future<Activite> createActivite(Activite activite) async {
    final created = activite.copyWith(id: _nextActiviteId++);
    _activites.add(created);
    return created;
  }

  @override
  Future<void> updateActivite(Activite activite) async {
    final index = _activites.indexWhere((item) => item.id == activite.id);
    _activites[index] = activite;
  }

  @override
  Future<void> deleteActivite(int id) async {
    _activites.removeWhere((item) => item.id == id);
  }
}
