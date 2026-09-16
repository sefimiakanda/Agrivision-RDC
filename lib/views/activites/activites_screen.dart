import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controllers/activite_provider.dart';
import '../../database/parcelle_repository.dart';
import '../../models/activite.dart';
import '../../models/parcelle.dart';
import 'activite_form_screen.dart';

class ActivitesScreen extends StatelessWidget {
  const ActivitesScreen({
    super.key,
    required this.parcelle,
    required this.repository,
  });

  final Parcelle parcelle;
  final ParcelleRepository repository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ActiviteProvider(repository)..loadActivites(parcelle.id!),
      child: _ActivitesView(parcelle: parcelle),
    );
  }
}

class _ActivitesView extends StatelessWidget {
  const _ActivitesView({required this.parcelle});

  final Parcelle parcelle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activités agricoles')),
      body: Consumer<ActiviteProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.activites.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null && provider.activites.isEmpty) {
            return _ActivityError(
              parcelleId: parcelle.id!,
              message: provider.errorMessage!,
            );
          }
          if (provider.activites.isEmpty) {
            return const _ActivityEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadActivites(parcelle.id!),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: provider.activites.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _ActivityCard(
                activite: provider.activites[index],
                onEdit: () => _openForm(context, provider.activites[index]),
                onDelete: () => _delete(context, provider.activites[index]),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }

  Future<void> _openForm(BuildContext context, [Activite? activite]) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            ActiviteFormScreen(parcelleId: parcelle.id!, activite: activite),
      ),
    );
  }

  Future<void> _delete(BuildContext context, Activite activite) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer l’activité ?'),
        content: const Text('Cette action est définitive.'),
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
    if (confirmed == true && context.mounted) {
      await context.read<ActiviteProvider>().removeActivite(activite);
    }
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.activite,
    required this.onEdit,
    required this.onDelete,
  });

  final Activite activite;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFE2F1E5),
              child: Icon(Icons.agriculture_outlined, color: Color(0xFF176B4D)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activite.type,
                    style: const TextStyle(
                      color: Color(0xFF17352B),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy').format(activite.date),
                    style: const TextStyle(color: Color(0xFF176B4D)),
                  ),
                  if (activite.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      activite.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Color(0xFF63746B)),
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else {
                  onDelete();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Modifier')),
                PopupMenuItem(value: 'delete', child: Text('Supprimer')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityEmptyState extends StatelessWidget {
  const _ActivityEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history, size: 60, color: Color(0xFF176B4D)),
            const SizedBox(height: 16),
            Text(
              'Aucune activité enregistrée',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Conservez ici les interventions réalisées sur cette parcelle.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF63746B), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityError extends StatelessWidget {
  const _ActivityError({required this.parcelleId, required this.message});

  final int parcelleId;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 52, color: Color(0xFFB86B18)),
            const SizedBox(height: 14),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            FilledButton(
              onPressed: () =>
                  context.read<ActiviteProvider>().loadActivites(parcelleId),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
