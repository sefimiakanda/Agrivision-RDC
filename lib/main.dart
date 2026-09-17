import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'database/database_helper.dart';
import 'database/parcelle_repository.dart';
import 'controllers/profile_provider.dart';
import 'services/gemini_service.dart';
import 'services/profile_store.dart';
import 'services/weather_service.dart';
import 'views/assistant/assistant_screen.dart';
import 'views/meteo/weather_screen.dart';
import 'views/parcelles/parcelles_screen.dart';
import 'views/profile/profile_screen.dart';

const openWeatherApiKey = String.fromEnvironment('OPENWEATHER_API_KEY');
const geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

void main() {
  runApp(const AgrivisionApp());
}

class AgrivisionApp extends StatelessWidget {
  const AgrivisionApp({
    super.key,
    this.parcelleRepository,
    this.weatherService,
    this.geminiService,
    this.profileStore,
  });

  final ParcelleRepository? parcelleRepository;
  final WeatherService? weatherService;
  final GeminiService? geminiService;
  final ProfileStore? profileStore;

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
      home: ChangeNotifierProvider(
        create: (_) =>
            ProfileProvider(profileStore ?? SharedPreferencesProfileStore())
              ..load(),
        child: MainNavigationShell(
          parcelleRepository: parcelleRepository ?? DatabaseHelper.instance,
          weatherService:
              weatherService ?? WeatherService(apiKey: openWeatherApiKey),
          geminiService: geminiService ?? GeminiService(apiKey: geminiApiKey),
        ),
      ),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({
    super.key,
    required this.parcelleRepository,
    required this.weatherService,
    required this.geminiService,
  });

  final ParcelleRepository parcelleRepository;
  final WeatherService weatherService;
  final GeminiService geminiService;

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(
        parcelleRepository: widget.parcelleRepository,
        weatherService: widget.weatherService,
        geminiService: widget.geminiService,
      ),
      ParcellesScreen(repository: widget.parcelleRepository),
      WeatherScreen(service: widget.weatherService),
      AssistantScreen(service: widget.geminiService),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (value) => setState(() => _selectedIndex = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'Carnet',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_outlined),
            selectedIcon: Icon(Icons.cloud),
            label: 'Météo',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Assistant',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.parcelleRepository,
    required this.weatherService,
    required this.geminiService,
  });

  final ParcelleRepository parcelleRepository;
  final WeatherService weatherService;
  final GeminiService geminiService;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: const Text(
          'Agrivision RDC',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: () => _openProfile(context),
            tooltip: 'Mon profil agricole',
            icon: const CircleAvatar(
              backgroundColor: Color(0xFFDCEDE3),
              child: Icon(Icons.person_outline, color: Color(0xFF176B4D)),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          const _WelcomeBanner(),
          const SizedBox(height: 18),
          Text(
            'Aujourd’hui, votre exploitation est au centre de votre activité.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF17352B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                'assets/icon/icone.png',
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Consumer<ProfileProvider>(
            builder: (context, profileProvider, _) {
              final name = profileProvider.profile.name.trim();
              final city = profileProvider.profile.city.trim();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bonjour, ${name.isEmpty ? 'agriculteur' : name}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF17352B),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  if (city.isNotEmpty)
                    Text(
                      'Votre zone : $city',
                      style: const TextStyle(
                        color: Color(0xFF63746B),
                        fontSize: 15,
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 20),
          const _OfflineNotice(),
        ],
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

  void _openWeather(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => WeatherScreen(service: weatherService),
      ),
    );
  }

  void _openAssistant(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AssistantScreen(service: geminiService),
      ),
    );
  }

  void _openProfile(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) =>
            ProfileScreen(provider: context.read<ProfileProvider>()),
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
