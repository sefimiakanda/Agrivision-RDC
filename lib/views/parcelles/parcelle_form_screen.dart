import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/parcelle_provider.dart';
import '../../models/parcelle.dart';

class ParcelleFormScreen extends StatefulWidget {
  const ParcelleFormScreen({super.key, this.parcelle});

  final Parcelle? parcelle;

  @override
  State<ParcelleFormScreen> createState() => _ParcelleFormScreenState();
}

class _ParcelleFormScreenState extends State<ParcelleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _villeController;
  late final TextEditingController _nomController;
  late final TextEditingController _cultureController;
  late final TextEditingController _superficieController;

  bool _isSaving = false;

  bool get _isEditing => widget.parcelle != null;

  @override
  void initState() {
    super.initState();
    final parcelle = widget.parcelle;
    _villeController = TextEditingController(text: parcelle?.ville ?? '');
    _nomController = TextEditingController(text: parcelle?.nom ?? '');
    _cultureController = TextEditingController(text: parcelle?.culture ?? '');
    _superficieController = TextEditingController(
      text: parcelle == null ? '' : parcelle.superficie.toString(),
    );
  }

  @override
  void dispose() {
    _villeController.dispose();
    _nomController.dispose();
    _cultureController.dispose();
    _superficieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Modifier la parcelle' : 'Ajouter une parcelle',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Text(
              _isEditing
                  ? 'Actualisez les informations'
                  : 'Renseignez votre parcelle',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF17352B),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ces informations resteront disponibles hors connexion.',
              style: TextStyle(color: Color(0xFF63746B)),
            ),
            const SizedBox(height: 28),
            _textField(
              controller: _nomController,
              label: 'Nom de la parcelle',
              hint: 'Ex. Parcelle familiale',
              icon: Icons.label_outline,
            ),
            const SizedBox(height: 16),
            _textField(
              controller: _villeController,
              label: 'Ville',
              hint: 'Ex. Kinshasa',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 16),
            _textField(
              controller: _cultureController,
              label: 'Culture principale',
              hint: 'Ex. Maïs',
              icon: Icons.grass,
            ),
            const SizedBox(height: 16),
            _textField(
              controller: _superficieController,
              label: 'Superficie (hectares)',
              hint: 'Ex. 2.5',
              icon: Icons.square_foot,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                final parsed = _parseSuperficie(value);
                if (parsed == null || parsed <= 0) {
                  return 'Saisissez une superficie supérieure à 0.';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                _isEditing
                    ? 'Enregistrer les changements'
                    : 'Enregistrer la parcelle',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
      validator:
          validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Ce champ est obligatoire.';
            }
            return null;
          },
    );
  }

  double? _parseSuperficie(String? value) {
    if (value == null) {
      return null;
    }
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    final parcelle = Parcelle(
      id: widget.parcelle?.id,
      ville: _villeController.text.trim(),
      nom: _nomController.text.trim(),
      culture: _cultureController.text.trim(),
      superficie: _parseSuperficie(_superficieController.text)!,
    );
    final saved = await context.read<ParcelleProvider>().saveParcelle(parcelle);
    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);
    if (saved) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<ParcelleProvider>().errorMessage ??
                'Impossible d’enregistrer la parcelle.',
          ),
        ),
      );
    }
  }
}
