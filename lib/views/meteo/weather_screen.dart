import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controllers/weather_provider.dart';
import '../../models/weather.dart';
import '../../services/weather_service.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key, required this.service});

  final WeatherService service;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => WeatherProvider(service),
      child: const _WeatherView(),
    );
  }
}

class _WeatherView extends StatefulWidget {
  const _WeatherView();

  @override
  State<_WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<_WeatherView> {
  final _cityController = TextEditingController(text: 'Kinshasa');

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Météo agricole')),
      body: Consumer<WeatherProvider>(
        builder: (context, provider, _) {
          return RefreshIndicator(
            onRefresh: () => provider.search(_cityController.text),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                Text(
                  'Les conditions de votre ville',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF17352B),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Consultez la météo avant de planifier vos activités agricoles.',
                  style: TextStyle(color: Color(0xFF63746B), height: 1.4),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _cityController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(context),
                  decoration: InputDecoration(
                    labelText: 'Rechercher une ville',
                    hintText: 'Ex. Kinshasa',
                    prefixIcon: const Icon(Icons.location_on_outlined),
                    suffixIcon: IconButton(
                      onPressed: provider.isLoading
                          ? null
                          : () => _search(context),
                      tooltip: 'Rechercher',
                      icon: const Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (provider.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (provider.errorMessage != null)
                  _WeatherError(message: provider.errorMessage!)
                else if (provider.weather == null)
                  const _WeatherInitialState()
                else
                  _WeatherContent(weather: provider.weather!),
              ],
            ),
          );
        },
      ),
    );
  }

  void _search(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<WeatherProvider>().search(_cityController.text);
  }
}

class _WeatherContent extends StatelessWidget {
  const _WeatherContent({required this.weather});

  final Weather weather;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                      weather.city,
                      style: const TextStyle(
                        color: Color(0xFFD8EFE1),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${weather.temperature.round()}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      _capitalize(weather.description),
                      style: const TextStyle(color: Color(0xFFD8EFE1)),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.wb_sunny_outlined,
                size: 70,
                color: Color(0xFFFFEED8),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Conditions actuelles',
          style: TextStyle(
            color: Color(0xFF17352B),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                icon: Icons.water_drop_outlined,
                label: 'Humidité',
                value: '${weather.humidity}%',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricTile(
                icon: Icons.air,
                label: 'Vent',
                value: '${weather.windSpeed.toStringAsFixed(1)} m/s',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MetricTile(
                icon: Icons.thermostat_outlined,
                label: 'Ressenti',
                value: '${weather.feelsLike.round()}°C',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricTile(
                icon: Icons.umbrella_outlined,
                label: 'Pluie',
                value: '${weather.rain.toStringAsFixed(1)} mm',
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Prévisions',
          style: TextStyle(
            color: Color(0xFF17352B),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        if (weather.forecasts.isEmpty)
          const Text('Aucune prévision disponible.')
        else
          ...weather.forecasts.map(_ForecastTile.new),
      ],
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF176B4D)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Color(0xFF63746B))),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFF17352B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForecastTile extends StatelessWidget {
  const _ForecastTile(this.forecast);

  final WeatherForecast forecast;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFFEED8),
          child: Icon(Icons.cloud_outlined, color: Color(0xFFB86B18)),
        ),
        title: Text(DateFormat('EEE dd/MM, HH:mm').format(forecast.date)),
        subtitle: Text(forecast.description),
        trailing: Text(
          '${forecast.temperature.round()}°C',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF176B4D),
          ),
        ),
      ),
    );
  }
}

class _WeatherInitialState extends StatelessWidget {
  const _WeatherInitialState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.cloud_outlined, size: 64, color: Color(0xFF176B4D)),
          SizedBox(height: 16),
          Text(
            'Recherchez une ville pour voir sa météo.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _WeatherError extends StatelessWidget {
  const _WeatherError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEED8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFB86B18)),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}
