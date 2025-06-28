import 'dart:developer';

import 'package:dio/dio.dart';
import '../models/weather_model.dart';
import '../models/weather_forecast_model.dart';
import '../../../../core/constants/app_constants.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getCurrentWeather({
    required double latitude,
    required double longitude,
  });

  Future<WeatherForecastModel> getWeatherForecast({
    required double latitude,
    required double longitude,
  });

  Future<WeatherModel> getWeatherByCity({
    required String cityName,
  });
}

class WeatherRemoteDataSourceImpl implements WeatherRemoteDataSource {
  final Dio dio;
  final String apiKey;

  WeatherRemoteDataSourceImpl(this.dio, {required this.apiKey});

  @override
  Future<WeatherModel> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      log("openWeatherApiKey ${apiKey}");
      final response = await dio.get(
        AppConstants.currentWeatherEndpoint,
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': apiKey,
          'units': 'metric',
        },
      );
      log("currentWeatherEndpoint $response");
      if (response.statusCode == 200) {
        return WeatherModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load weather data');
      }
    } on DioException catch (e) {
      log("currentWeatherEndpoint $e");
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid API key');
      } else if (e.response?.statusCode == 429) {
        throw Exception('API rate limit exceeded');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<WeatherForecastModel> getWeatherForecast({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await dio.get(
        AppConstants.forecastEndpoint,
        queryParameters: {
          'lat': latitude,
          'lon': longitude,
          'appid': apiKey,
          'units': 'metric',
        },
      );
      log("getWeatherForecast $response");
      if (response.statusCode == 200) {
        return WeatherForecastModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load forecast data');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid API key');
      } else if (e.response?.statusCode == 429) {
        throw Exception('API rate limit exceeded');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<WeatherModel> getWeatherByCity({
    required String cityName,
  }) async {
    try {
      final response = await dio.get(
        AppConstants.currentWeatherEndpoint,
        queryParameters: {
          'q': cityName,
          'appid': apiKey,
          'units': 'metric',
        },
      );

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load weather data');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Invalid API key');
      } else if (e.response?.statusCode == 404) {
        throw Exception('City not found');
      } else if (e.response?.statusCode == 429) {
        throw Exception('API rate limit exceeded');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
} 