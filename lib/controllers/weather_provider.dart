import 'package:flutter/foundation.dart';

import '../models/weather.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherProvider(this._service);

  final WeatherService _service;
  Weather? _weather;
  bool _isLoading = false;
  String? _errorMessage;

  Weather? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> search(String city) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _weather = await _service.fetchWeather(city);
    } on WeatherException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Impossible de récupérer la météo.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
