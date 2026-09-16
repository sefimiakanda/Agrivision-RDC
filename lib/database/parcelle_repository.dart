import '../models/parcelle.dart';

abstract interface class ParcelleRepository {
  Future<List<Parcelle>> getParcelles();

  Future<Parcelle> createParcelle(Parcelle parcelle);

  Future<void> updateParcelle(Parcelle parcelle);

  Future<void> deleteParcelle(int id);
}
