import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'database/database_helper.dart';
import 'database/parcelle_repository.dart';
import 'controllers/profile_provider.dart';
import 'controllers/weather_provider.dart';
import 'models/weather.dart';
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFDDE8DE)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x180F3D2B),
                blurRadius: 18,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: NavigationBar(
            height: 72,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            indicatorColor: const Color(0xFFDDF0DF),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (value) =>
                setState(() => _selectedIndex = value),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
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
        ),
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
          const SizedBox(height: 24),
          Consumer<ProfileProvider>(
            builder: (context, profileProvider, _) {
              return _HomeWeatherCard(
                key: ValueKey(profileProvider.profile.city),
                city: profileProvider.profile.city,
                service: weatherService,
              );
            },
          ),
          const SizedBox(height: 20),
          const _OfflineNotice(),
        ],
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
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.asset(
              'assets/icon/icone.png',
              width: 66,
              height: 66,
              fit: BoxFit.cover,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeWeatherCard extends StatelessWidget {
  const _HomeWeatherCard({
    super.key,
    required this.city,
    required this.service,
  });

  final String city;
  final WeatherService service;

  @override
  Widget build(BuildContext context) {
    if (city.trim().isEmpty) {
      return const _WeatherBadgePrompt();
    }
    return ChangeNotifierProvider(
      create: (_) => WeatherProvider(service)..search(city),
      child: Consumer<WeatherProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const _WeatherBadgeLoading();
          }
          if (provider.weather == null) {
            return const _WeatherBadgePrompt();
          }
          return _WeatherBadgeContent(weather: provider.weather!);
        },
      ),
    );
  }
}

class _WeatherBadgePrompt extends StatelessWidget {
  const _WeatherBadgePrompt();

  @override
  Widget build(BuildContext context) {
    return _HomeSection(
      icon: Icons.cloud_outlined,
      title: 'Météo de votre exploitation',
      child: const Text(
        'Ajoutez votre ville dans le profil pour afficher les conditions du jour.',
        style: TextStyle(color: Color(0xFF63746B), height: 1.35),
      ),
    );
  }
}

class _WeatherBadgeLoading extends StatelessWidget {
  const _WeatherBadgeLoading();

  @override
  Widget build(BuildContext context) {
    return _HomeSection(
      icon: Icons.cloud_sync_outlined,
      title: 'Météo de votre exploitation',
      child: const LinearProgressIndicator(minHeight: 4),
    );
  }
}

class _WeatherBadgeContent extends StatelessWidget {
  const _WeatherBadgeContent({required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    return _HomeSection(
      icon: Icons.wb_sunny_outlined,
      title: 'Météo à ${weather.city}',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _WeatherBadge(
            icon: Icons.thermostat_outlined,
            label: '${weather.temperature.round()}°C',
            color: const Color(0xFFFFE6C4),
          ),
          _WeatherBadge(
            icon: Icons.water_drop_outlined,
            label: '${weather.humidity}% humidité',
            color: const Color(0xFFDCEFF2),
          ),
          _WeatherBadge(
            icon: Icons.umbrella_outlined,
            label: '${weather.rain.toStringAsFixed(1)} mm pluie',
            color: const Color(0xFFE7E1F4),
          ),
          _WeatherBadge(
            icon: Icons.agriculture_outlined,
            label: _capitalize(weather.description),
            color: const Color(0xFFDDF0DF),
          ),
        ],
      ),
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _HomeSection extends StatelessWidget {
  const _HomeSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDDE8DE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF176B4D)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF17352B),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _WeatherBadge extends StatelessWidget {
  const _WeatherBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: const Color(0xFF17352B)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF17352B),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
