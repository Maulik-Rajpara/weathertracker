part of 'weather_bloc.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();
  
  @override
  List<Object?> get props => [];
}

class WeatherInitial extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final Weather? weather;
  final WeatherForecast? forecast;

  const WeatherLoaded({this.weather, this.forecast});

  WeatherLoaded copyWith({
    Weather? weather,
    WeatherForecast? forecast,
  }) {
    return WeatherLoaded(
      weather: weather ?? this.weather,
      forecast: forecast ?? this.forecast,
    );
  }

  @override
  List<Object?> get props => [weather, forecast];
}

class WeatherError extends WeatherState {
  final String message;

  const WeatherError(this.message);

  @override
  List<Object> get props => [message];
} 