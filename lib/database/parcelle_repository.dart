import '../models/parcelle.dart';
import '../models/activite.dart';

abstract interface class ParcelleRepository {
  Future<List<Parcelle>> getParcelles();

  Future<Parcelle> createParcelle(Parcelle parcelle);

  Future<void> updateParcelle(Parcelle parcelle);

  Future<void> deleteParcelle(int id);

  Future<List<Activite>> getActivites(int parcelleId);

  Future<Activite> createActivite(Activite activite);

  Future<void> updateActivite(Activite activite);

  Future<void> deleteActivite(int id);
}
