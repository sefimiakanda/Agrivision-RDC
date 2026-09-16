import 'package:flutter/foundation.dart';

import '../database/parcelle_repository.dart';
import '../models/parcelle.dart';

class ParcelleProvider extends ChangeNotifier {
  ParcelleProvider(this._repository);

  final ParcelleRepository _repository;
  List<Parcelle> _parcelles = const [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Parcelle> get parcelles => List.unmodifiable(_parcelles);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadParcelles() async {
    _setLoading(true);
    try {
      _parcelles = await _repository.getParcelles();
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'Impossible de charger vos parcelles.';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> saveParcelle(Parcelle parcelle) async {
    _setLoading(true);
    try {
      if (parcelle.id == null) {
        final created = await _repository.createParcelle(parcelle);
        _parcelles = [..._parcelles, created];
      } else {
        await _repository.updateParcelle(parcelle);
        _parcelles = [
          for (final item in _parcelles)
            if (item.id == parcelle.id) parcelle else item,
        ];
      }
      _errorMessage = null;
      return true;
    } catch (_) {
      _errorMessage = 'Impossible d’enregistrer la parcelle.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> removeParcelle(Parcelle parcelle) async {
    final id = parcelle.id;
    if (id == null) {
      return false;
    }

    _setLoading(true);
    try {
      await _repository.deleteParcelle(id);
      _parcelles = _parcelles.where((item) => item.id != id).toList();
      _errorMessage = null;
      return true;
    } catch (_) {
      _errorMessage = 'Impossible de supprimer la parcelle.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
