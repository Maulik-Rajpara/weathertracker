import 'package:equatable/equatable.dart';

class Weather extends Equatable {
  final double temperature;
  final double humidity;
  final double windSpeed;
  final String description;
  final String icon;
  final DateTime dateTime;
  final String cityName;
  final double latitude;
  final double longitude;

  const Weather({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
    required this.dateTime,
    required this.cityName,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [
    temperature,
    humidity,
    windSpeed,
    description,
    icon,
    dateTime,
    cityName,
    latitude,
    longitude,
  ];
} 