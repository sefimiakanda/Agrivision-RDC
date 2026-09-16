class WeatherForecast {
  const WeatherForecast({
    required this.date,
    required this.temperature,
    required this.description,
    required this.iconCode,
  });

  final DateTime date;
  final double temperature;
  final String description;
  final String iconCode;
}

class Weather {
  const Weather({
    required this.city,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.description,
    required this.windSpeed,
    required this.rain,
    required this.iconCode,
    required this.forecasts,
  });

  final String city;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final String description;
  final double windSpeed;
  final double rain;
  final String iconCode;
  final List<WeatherForecast> forecasts;
}
