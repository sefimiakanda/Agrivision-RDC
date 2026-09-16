import 'package:flutter_test/flutter_test.dart';

import 'package:agrivision_drc/controllers/parcelle_provider.dart';
import 'package:agrivision_drc/database/parcelle_repository.dart';
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
}

class FakeParcelleRepository implements ParcelleRepository {
  final List<Parcelle> _items = [];
  int _nextId = 1;

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
}
