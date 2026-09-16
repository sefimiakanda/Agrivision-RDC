import 'package:flutter/material.dart';

import 'database/database_helper.dart';
import 'database/parcelle_repository.dart';
import 'views/parcelles/parcelles_screen.dart';

void main() {
  runApp(const AgrivisionApp());
}

class AgrivisionApp extends StatelessWidget {
  const AgrivisionApp({super.key, this.parcelleRepository});

  final ParcelleRepository? parcelleRepository;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF176B4D);

    return MaterialApp(
      title: 'Agrivision RDC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F8F3),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6F8F3),
          foregroundColor: Color(0xFF17352B),
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            side: BorderSide(color: Color(0xFFE3EAE3)),
          ),
        ),
      ),
      home: HomeScreen(
        parcelleRepository: parcelleRepository ?? DatabaseHelper.instance,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.parcelleRepository});

  final ParcelleRepository parcelleRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bonjour, agriculteur',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
            Text(
              'Agrivision RDC',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: CircleAvatar(
              backgroundColor: Color(0xFFDCEDE3),
              child: Icon(Icons.person_outline, color: Color(0xFF176B4D)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          const _WelcomeBanner(),
          const SizedBox(height: 24),
          Text(
            'Vos outils agricoles',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF17352B),
            ),
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            key: const ValueKey('carnet-card'),
            icon: Icons.menu_book_outlined,
            color: const Color(0xFFE2F1E5),
            iconColor: const Color(0xFF176B4D),
            title: 'Carnet agricole',
            description:
                'Gérez vos parcelles et gardez l’historique de vos activités.',
            onTap: () => _openCarnet(context),
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            key: const ValueKey('weather-card'),
            icon: Icons.wb_sunny_outlined,
            color: const Color(0xFFFFEED8),
            iconColor: const Color(0xFFB86B18),
            title: 'Météo agricole',
            description:
                'Consultez les conditions et prévisions de votre ville.',
            onTap: () => _openModule(context, 'Météo agricole'),
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            key: const ValueKey('assistant-card'),
            icon: Icons.chat_bubble_outline,
            color: const Color(0xFFE5E5F8),
            iconColor: const Color(0xFF4D4B91),
            title: 'Assistant agricole',
            description:
                'Posez vos questions et recevez des conseils en français.',
            onTap: () => _openModule(context, 'Assistant agricole'),
          ),
          const SizedBox(height: 24),
          const _OfflineNotice(),
        ],
      ),
    );
  }

  void _openModule(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ModulePlaceholderScreen(title: title),
      ),
    );
  }

  void _openCarnet(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ParcellesScreen(repository: parcelleRepository),
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF176B4D),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cultivez mieux,\ndécidez sereinement.',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Votre compagnon agricole au quotidien.',
                  style: TextStyle(color: Color(0xFFD8EFE1), height: 1.4),
                ),
              ],
            ),
          ),
          const Icon(Icons.eco_outlined, size: 64, color: Color(0xFFB9E4C7)),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    super.key,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color iconColor;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF17352B),
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF63746B),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF829189),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfflineNotice extends StatelessWidget {
  const _OfflineNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2EA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.cloud_done_outlined, color: Color(0xFF176B4D)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Votre carnet restera accessible hors connexion.',
              style: TextStyle(color: Color(0xFF365344), height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

class ModulePlaceholderScreen extends StatelessWidget {
  const ModulePlaceholderScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.construction_outlined,
                size: 48,
                color: Color(0xFF176B4D),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Ce module sera construit dans la prochaine étape.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
