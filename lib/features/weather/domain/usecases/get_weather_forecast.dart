import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/weather_forecast.dart';
import '../repositories/weather_repository.dart';
import 'get_current_weather.dart';

class GetWeatherForecast implements UseCase<WeatherForecast, WeatherParams> {
  final WeatherRepository repository;

  GetWeatherForecast(this.repository);

  @override
  Future<Either<Failure, WeatherForecast>> call(WeatherParams params) async {
    return await repository.getWeatherForecast(
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
} 