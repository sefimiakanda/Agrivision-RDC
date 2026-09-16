import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/activite_provider.dart';
import '../../models/activite.dart';

class ActiviteFormScreen extends StatefulWidget {
  const ActiviteFormScreen({
    super.key,
    required this.parcelleId,
    this.activite,
  });

  final int parcelleId;
  final Activite? activite;

  @override
  State<ActiviteFormScreen> createState() => _ActiviteFormScreenState();
}

class _ActiviteFormScreenState extends State<ActiviteFormScreen> {
  static const _activityTypes = [
    'Semis',
    'Arrosage',
    'Fertilisation',
    'Désherbage',
    'Traitement phytosanitaire',
    'Récolte',
    'Observation',
  ];

  final _formKey = GlobalKey<FormState>();
  late String _selectedType;
  late DateTime _selectedDate;
  late final TextEditingController _descriptionController;
  bool _isSaving = false;

  bool get _isEditing => widget.activite != null;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.activite?.type ?? _activityTypes.first;
    _selectedDate = widget.activite?.date ?? DateTime.now();
    _descriptionController = TextEditingController(
      text: widget.activite?.description ?? '',
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Modifier l’activité' : 'Ajouter une activité',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            Text(
              'Détail de l’intervention',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF17352B),
              ),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type d’activité',
                prefixIcon: Icon(Icons.agriculture_outlined),
              ),
              items: _activityTypes
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                Icons.calendar_today_outlined,
                color: Color(0xFF176B4D),
              ),
              title: const Text('Date de l’activité'),
              subtitle: Text(_formatDate(_selectedDate)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Observation ou détail',
                hintText: 'Ajoutez une note utile pour votre suivi...',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                  padding: EdgeInsets.only(bottom: 64),
                  child: Icon(Icons.notes_outlined),
                ),
              ),
            ),
            const SizedBox(height: 30),
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
                    : 'Enregistrer l’activité',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _selectedDate,
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);
    final activite = Activite(
      id: widget.activite?.id,
      parcelleId: widget.parcelleId,
      type: _selectedType,
      date: _selectedDate,
      description: _descriptionController.text.trim(),
    );
    final saved = await context.read<ActiviteProvider>().saveActivite(activite);
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
            context.read<ActiviteProvider>().errorMessage ??
                'Impossible d’enregistrer l’activité.',
          ),
        ),
      );
    }
  }
}
