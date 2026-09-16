import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/parcelle_provider.dart';
import '../../database/parcelle_repository.dart';
import '../../models/parcelle.dart';
import 'parcelle_details_screen.dart';
import 'parcelle_form_screen.dart';

class ParcellesScreen extends StatelessWidget {
  const ParcellesScreen({super.key, required this.repository});

  final ParcelleRepository repository;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ParcelleProvider(repository)..loadParcelles(),
      child: const _ParcellesView(),
    );
  }
}

class _ParcellesView extends StatelessWidget {
  const _ParcellesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes parcelles'),
        actions: [
          IconButton(
            onPressed: () => context.read<ParcelleProvider>().loadParcelles(),
            tooltip: 'Actualiser',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<ParcelleProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.parcelles.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null && provider.parcelles.isEmpty) {
            return _ErrorState(message: provider.errorMessage!);
          }
          if (provider.parcelles.isEmpty) {
            return const _EmptyState();
          }

          return RefreshIndicator(
            onRefresh: provider.loadParcelles,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              itemCount: provider.parcelles.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final parcelle = provider.parcelles[index];
                return _ParcelleCard(parcelle: parcelle);
              },
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

  Future<void> _openForm(BuildContext context, {Parcelle? parcelle}) async {
    final provider = context.read<ParcelleProvider>();
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: provider,
          child: ParcelleFormScreen(parcelle: parcelle),
        ),
      ),
    );
  }
}

class _ParcelleCard extends StatelessWidget {
  const _ParcelleCard({required this.parcelle});

  final Parcelle parcelle;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ParcelleProvider>();
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (_) => ChangeNotifierProvider.value(
                value: provider,
                child: ParcelleDetailsScreen(parcelle: parcelle),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2F1E5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.grass, color: Color(0xFF176B4D)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      parcelle.nom,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF17352B),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${parcelle.culture} • ${parcelle.ville}',
                      style: const TextStyle(color: Color(0xFF63746B)),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${parcelle.superficie.toStringAsFixed(2)} ha',
                      style: const TextStyle(
                        color: Color(0xFF176B4D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF829189)),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.agriculture_outlined,
              size: 64,
              color: Color(0xFF176B4D),
            ),
            const SizedBox(height: 18),
            Text(
              'Aucune parcelle enregistrée',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Ajoutez votre première parcelle pour commencer votre carnet agricole.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF63746B), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 56,
              color: Color(0xFFB86B18),
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.read<ParcelleProvider>().loadParcelles(),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}
