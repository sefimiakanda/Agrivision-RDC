import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/parcelle_provider.dart';
import '../../database/database_helper.dart';
import '../../models/parcelle.dart';
import '../activites/activites_screen.dart';
import 'parcelle_form_screen.dart';

class ParcelleDetailsScreen extends StatelessWidget {
  const ParcelleDetailsScreen({super.key, required this.parcelle});

  final Parcelle parcelle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de la parcelle'),
        actions: [
          IconButton(
            onPressed: () => _edit(context),
            tooltip: 'Modifier',
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: () => _delete(context),
            tooltip: 'Supprimer',
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF176B4D),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                const Icon(Icons.grass, color: Color(0xFFB9E4C7), size: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    parcelle.nom,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Informations principales',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF17352B),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.location_on_outlined,
            label: 'Ville',
            value: parcelle.ville,
          ),
          _InfoTile(
            icon: Icons.grass,
            label: 'Culture',
            value: parcelle.culture,
          ),
          _InfoTile(
            icon: Icons.square_foot,
            label: 'Superficie',
            value: '${parcelle.superficie.toStringAsFixed(2)} hectares',
          ),
          const SizedBox(height: 28),
          Text(
            'Activités agricoles',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: const Color(0xFF17352B),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE2F1E5),
                child: Icon(Icons.history, color: Color(0xFF176B4D)),
              ),
              title: const Text('Voir l’historique'),
              subtitle: const Text('Consultez les interventions réalisées.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openActivities(context),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openActivities(context),
        icon: const Icon(Icons.add),
        label: const Text('Activité'),
      ),
    );
  }

  void _openActivities(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ActivitesScreen(
          parcelle: parcelle,
          repository: DatabaseHelper.instance,
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ParcelleFormScreen(parcelle: parcelle),
      ),
    );
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer la parcelle ?'),
        content: Text(
          'La parcelle « ${parcelle.nom} » sera supprimée définitivement.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }

    final deleted = await context.read<ParcelleProvider>().removeParcelle(
      parcelle,
    );
    if (!context.mounted) {
      return;
    }
    if (deleted) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.read<ParcelleProvider>().errorMessage ??
                'Impossible de supprimer la parcelle.',
          ),
        ),
      );
    }
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE2F1E5),
        child: Icon(icon, color: const Color(0xFF176B4D)),
      ),
      title: Text(label, style: const TextStyle(color: Color(0xFF63746B))),
      subtitle: Text(
        value,
        style: const TextStyle(
          color: Color(0xFF17352B),
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
