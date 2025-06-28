import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/weather.dart';
import '../entities/weather_forecast.dart';

abstract class WeatherRepository {
  Future<Either<Failure, Weather>> getCurrentWeather({
    required double latitude,
    required double longitude,
  });

  Future<Either<Failure, WeatherForecast>> getWeatherForecast({
    required double latitude,
    required double longitude,
  });

  Future<Either<Failure, Weather>> getWeatherByCity({
    required String cityName,
  });
} 