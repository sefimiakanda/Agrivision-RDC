import 'package:flutter_test/flutter_test.dart';

import 'package:agrivision_drc/controllers/profile_provider.dart';
import 'package:agrivision_drc/models/agriculteur_profile.dart';
import 'package:agrivision_drc/services/profile_store.dart';

void main() {
  test('charge et enregistre le profil agricole', () async {
    final store = FakeProfileStore();
    final provider = ProfileProvider(store);

    await provider.load();
    expect(provider.profile.name, isEmpty);

    const profile = AgriculteurProfile(
      name: 'Fidele',
      city: 'Kinshasa',
      mainCulture: 'Maïs',
      farmSize: 2.5,
    );
    expect(await provider.save(profile), isTrue);

    final reloaded = ProfileProvider(store);
    await reloaded.load();
    expect(reloaded.profile.name, 'Fidele');
    expect(reloaded.profile.farmSize, 2.5);
  });
}

class FakeProfileStore implements ProfileStore {
  AgriculteurProfile profile = const AgriculteurProfile();

  @override
  Future<AgriculteurProfile> load() async => profile;

  @override
  Future<void> save(AgriculteurProfile value) async {
    profile = value;
  }
}
