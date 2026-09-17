import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/profile_provider.dart';
import '../../models/agriculteur_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.provider});

  final ProfileProvider provider;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: provider,
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _cityController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    _nameController = TextEditingController(text: profile.name);
    _cityController = TextEditingController(text: profile.city);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil agricole')),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              children: [
                const CircleAvatar(
                  radius: 38,
                  backgroundColor: Color(0xFFDCEDE3),
                  child: Icon(
                    Icons.person_outline,
                    size: 42,
                    color: Color(0xFF176B4D),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Votre profil d’exploitation',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF17352B),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ces informations restent sur votre appareil pour personnaliser les échanges avec l’assistant.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF63746B), height: 1.4),
                ),
                const SizedBox(height: 28),
                _field(_nameController, 'Nom ou prénom', Icons.person_outline),
                const SizedBox(height: 14),
                _field(
                  _cityController,
                  'Ville ou territoire',
                  Icons.location_on_outlined,
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: provider.isSaving ? null : _save,
                  icon: provider.isSaving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Enregistrer le profil'),
                ),
                if (provider.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFFB86B18)),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator:
          validator ??
          (value) => value == null || value.trim().isEmpty
              ? 'Ce champ est obligatoire.'
              : null,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final profile = AgriculteurProfile(
      name: _nameController.text.trim(),
      city: _cityController.text.trim(),
    );
    final saved = await context.read<ProfileProvider>().save(profile);
    if (saved && mounted) Navigator.of(context).pop();
  }
}
