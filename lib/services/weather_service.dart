import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather.dart';

class WeatherException implements Exception {
  const WeatherException(this.message);

  final String message;

  @override
  String toString() => message;
}

class WeatherService {
  WeatherService({required this.apiKey, http.Client? client})
    : _client = client ?? http.Client();

  final String apiKey;
  final http.Client _client;
  static const _baseUrl = 'api.openweathermap.org';

  Future<Weather> fetchWeather(String city) async {
    final normalizedCity = city.trim();
    if (normalizedCity.isEmpty) {
      throw const WeatherException('Saisissez une ville à rechercher.');
    }
    if (apiKey.trim().isEmpty) {
      throw const WeatherException(
        'La clé météo est absente. Lancez l’application avec --dart-define=OPENWEATHER_API_KEY=votre_cle.',
      );
    }

    try {
      final query = {
        'q': normalizedCity,
        'appid': apiKey,
        'units': 'metric',
        'lang': 'fr',
      };
      final currentResponse = await _client
          .get(Uri.https(_baseUrl, '/data/2.5/weather', query))
          .timeout(const Duration(seconds: 10));
      _ensureSuccess(currentResponse);

      final forecastResponse = await _client
          .get(Uri.https(_baseUrl, '/data/2.5/forecast', query))
          .timeout(const Duration(seconds: 10));
      _ensureSuccess(forecastResponse);

      return _parseWeather(
        jsonDecode(currentResponse.body) as Map<String, dynamic>,
        jsonDecode(forecastResponse.body) as Map<String, dynamic>,
      );
    } on WeatherException {
      rethrow;
    } on http.ClientException {
      throw const WeatherException(
        'Connexion impossible. Vérifiez votre accès Internet.',
      );
    } on FormatException {
      throw const WeatherException('Les données météo sont invalides.');
    } catch (_) {
      throw const WeatherException(
        'La météo est momentanément indisponible. Réessayez plus tard.',
      );
    }
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode == 404) {
      throw const WeatherException(
        'Ville introuvable. Vérifiez l’orthographe.',
      );
    }
    if (response.statusCode == 401) {
      throw const WeatherException('La clé météo est invalide ou expirée.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const WeatherException('Le service météo a rencontré une erreur.');
    }
  }

  Weather _parseWeather(
    Map<String, dynamic> current,
    Map<String, dynamic> forecast,
  ) {
    final currentMain = current['main'] as Map<String, dynamic>;
    final currentWind = current['wind'] as Map<String, dynamic>? ?? {};
    final currentWeather =
        (current['weather'] as List<dynamic>).first as Map<String, dynamic>;
    final forecastItems = forecast['list'] as List<dynamic>? ?? const [];

    return Weather(
      city: (current['name'] as String?) ?? '',
      temperature: (currentMain['temp'] as num).toDouble(),
      feelsLike: (currentMain['feels_like'] as num).toDouble(),
      humidity: (currentMain['humidity'] as num).toInt(),
      description: (currentWeather['description'] as String?) ?? '',
      windSpeed: ((currentWind['speed'] as num?) ?? 0).toDouble(),
      rain: _rainAmount(current['rain'] as Map<String, dynamic>?),
      iconCode: (currentWeather['icon'] as String?) ?? '01d',
      forecasts: forecastItems
          .whereType<Map<String, dynamic>>()
          .where((item) => item['dt_txt'] != null)
          .take(5)
          .map(_parseForecast)
          .toList(growable: false),
    );
  }

  WeatherForecast _parseForecast(Map<String, dynamic> item) {
    final main = item['main'] as Map<String, dynamic>;
    final weather =
        (item['weather'] as List<dynamic>).first as Map<String, dynamic>;
    return WeatherForecast(
      date: DateTime.parse(item['dt_txt'] as String),
      temperature: (main['temp'] as num).toDouble(),
      description: (weather['description'] as String?) ?? '',
      iconCode: (weather['icon'] as String?) ?? '01d',
    );
  }

  double _rainAmount(Map<String, dynamic>? rain) {
    if (rain == null) {
      return 0;
    }
    return ((rain['1h'] ?? rain['3h'] ?? 0) as num).toDouble();
  }
}
