import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:agrivision_drc/services/weather_service.dart';

void main() {
  test('parse les conditions actuelles et les prévisions', () async {
    final service = WeatherService(
      apiKey: 'test-key',
      client: FakeWeatherClient(),
    );

    final weather = await service.fetchWeather('Kinshasa');

    expect(weather.city, 'Kinshasa');
    expect(weather.temperature, 28.4);
    expect(weather.humidity, 72);
    expect(weather.rain, 1.2);
    expect(weather.forecasts, hasLength(1));
    expect(weather.forecasts.first.temperature, 27.1);
  });

  test('retourne une erreur claire pour une ville inconnue', () async {
    final service = WeatherService(
      apiKey: 'test-key',
      client: FakeWeatherClient(statusCode: 404),
    );

    expect(
      () => service.fetchWeather('Ville inconnue'),
      throwsA(
        isA<WeatherException>().having(
          (error) => error.message,
          'message',
          contains('Ville introuvable'),
        ),
      ),
    );
  });
}

class FakeWeatherClient extends http.BaseClient {
  FakeWeatherClient({this.statusCode = 200});

  final int statusCode;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final isForecast = request.url.path.endsWith('/forecast');
    final payload = isForecast ? _forecastPayload : _currentPayload;
    final body = statusCode == 200 ? jsonEncode(payload) : '{}';
    return http.StreamedResponse(
      Stream.value(utf8.encode(body)),
      statusCode,
      headers: {'content-type': 'application/json'},
      request: request,
    );
  }
}

const _currentPayload = {
  'name': 'Kinshasa',
  'main': {'temp': 28.4, 'feels_like': 30.0, 'humidity': 72},
  'wind': {'speed': 2.5},
  'rain': {'1h': 1.2},
  'weather': [
    {'description': 'partiellement couvert', 'icon': '02d'},
  ],
};

const _forecastPayload = {
  'list': [
    {
      'dt_txt': '2026-09-16 12:00:00',
      'main': {'temp': 27.1},
      'weather': [
        {'description': 'nuageux', 'icon': '03d'},
      ],
    },
  ],
};
