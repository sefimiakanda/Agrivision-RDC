import 'package:shared_preferences/shared_preferences.dart';

import '../models/agriculteur_profile.dart';

abstract interface class ProfileStore {
  Future<AgriculteurProfile> load();

  Future<void> save(AgriculteurProfile profile);
}

class SharedPreferencesProfileStore implements ProfileStore {
  SharedPreferencesProfileStore({this._preferences});

  SharedPreferences? _preferences;
  static const _nameKey = 'profile.name';
  static const _cityKey = 'profile.city';
  static const _cultureKey = 'profile.mainCulture';
  static const _farmSizeKey = 'profile.farmSize';

  Future<SharedPreferences> get _prefs async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  @override
  Future<AgriculteurProfile> load() async {
    final preferences = await _prefs;
    final legacyCulture = preferences.getString(_cultureKey) ?? '';
    final legacyFarmSize = preferences.getDouble(_farmSizeKey) ?? 0;
    return AgriculteurProfile(
      name: preferences.getString(_nameKey) ?? '',
      city: preferences.getString(_cityKey) ?? '',
      mainCulture: legacyCulture,
      farmSize: legacyFarmSize,
    );
  }

  @override
  Future<void> save(AgriculteurProfile profile) async {
    final preferences = await _prefs;
    await preferences.setString(_nameKey, profile.name);
    await preferences.setString(_cityKey, profile.city);
    await preferences.setString(_cultureKey, profile.mainCulture);
    await preferences.setDouble(_farmSizeKey, profile.farmSize);
  }
}
