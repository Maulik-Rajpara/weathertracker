import 'package:equatable/equatable.dart';

class WeatherForecast extends Equatable {
  final List<DailyWeatherForecast> dailyForecast;

  const WeatherForecast({
    required this.dailyForecast,
  });

  @override
  List<Object?> get props => [dailyForecast];
}

class DailyWeatherForecast extends Equatable {
  final DateTime dateTime;
  final double temperature;
  final String description;
  final String icon;
  final int humidity;
  final int pressure;
  final double windSpeed;

  const DailyWeatherForecast({
    required this.dateTime,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
  });

  @override
  List<Object?> get props => [dateTime, temperature, description, icon, humidity, pressure, windSpeed];
} 