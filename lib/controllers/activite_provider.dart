import 'package:flutter/foundation.dart';

import '../database/parcelle_repository.dart';
import '../models/activite.dart';

class ActiviteProvider extends ChangeNotifier {
  ActiviteProvider(this._repository);

  final ParcelleRepository _repository;
  List<Activite> _activites = const [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Activite> get activites => List.unmodifiable(_activites);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadActivites(int parcelleId) async {
    _setLoading(true);
    try {
      _activites = await _repository.getActivites(parcelleId);
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'Impossible de charger les activités.';
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> saveActivite(Activite activite) async {
    _setLoading(true);
    try {
      if (activite.id == null) {
        final created = await _repository.createActivite(activite);
        _activites = [created, ..._activites];
      } else {
        await _repository.updateActivite(activite);
        _activites = [
          for (final item in _activites)
            if (item.id == activite.id) activite else item,
        ];
      }
      _errorMessage = null;
      return true;
    } catch (_) {
      _errorMessage = 'Impossible d’enregistrer l’activité.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> removeActivite(Activite activite) async {
    final id = activite.id;
    if (id == null) {
      return false;
    }

    _setLoading(true);
    try {
      await _repository.deleteActivite(id);
      _activites = _activites.where((item) => item.id != id).toList();
      _errorMessage = null;
      return true;
    } catch (_) {
      _errorMessage = 'Impossible de supprimer l’activité.';
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
