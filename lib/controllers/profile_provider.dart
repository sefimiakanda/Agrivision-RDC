import 'package:flutter/foundation.dart';

import '../models/agriculteur_profile.dart';
import '../services/profile_store.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider(this._store);

  final ProfileStore _store;
  AgriculteurProfile _profile = const AgriculteurProfile();
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  AgriculteurProfile get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await _store.load();
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'Impossible de charger le profil.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> save(AgriculteurProfile profile) async {
    _isSaving = true;
    notifyListeners();
    try {
      await _store.save(profile);
      _profile = profile;
      _errorMessage = null;
      return true;
    } catch (_) {
      _errorMessage = 'Impossible d’enregistrer le profil.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
