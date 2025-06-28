part of 'weather_bloc.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object> get props => [];
}

class GetCurrentWeatherEvent extends WeatherEvent {
  final double latitude;
  final double longitude;

  const GetCurrentWeatherEvent({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [latitude, longitude];
}

class GetWeatherForecastEvent extends WeatherEvent {
  final double latitude;
  final double longitude;

  const GetWeatherForecastEvent({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [latitude, longitude];
}

class GetWeatherByCityEvent extends WeatherEvent {
  final String cityName;

  const GetWeatherByCityEvent(this.cityName);

  @override
  List<Object> get props => [cityName];
} 