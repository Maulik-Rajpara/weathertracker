import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weathertracker/core/errors/failures.dart';

import '../models/weather_model.dart';
import '../models/weather_forecast_model.dart';


abstract class WeatherLocalDataSource {
  Future<void> cacheWeather(WeatherModel weatherToCache);
  Future<WeatherModel> getLastWeather();
  Future<void> cacheWeatherForecast(WeatherForecastModel forecastToCache);
  Future<WeatherForecastModel> getLastWeatherForecast();
}

const CACHED_WEATHER = 'CACHED_WEATHER';
const CACHED_WEATHER_FORECAST = 'CACHED_WEATHER_FORECAST';

class WeatherLocalDataSourceImpl implements WeatherLocalDataSource {
  final SharedPreferences sharedPreferences;

  WeatherLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheWeather(WeatherModel weatherToCache) {
    return sharedPreferences.setString(
      CACHED_WEATHER,
      json.encode(weatherToCache.toJson()),
    );
  }

  @override
  Future<WeatherModel> getLastWeather() {
    final jsonString = sharedPreferences.getString(CACHED_WEATHER);
    if (jsonString != null) {
      return Future.value(WeatherModel.fromJson(json.decode(jsonString)));
    } else {
      throw CacheFailure("");
    }
  }

  @override
  Future<void> cacheWeatherForecast(WeatherForecastModel forecastToCache) {
    return sharedPreferences.setString(
      CACHED_WEATHER_FORECAST,
      json.encode(forecastToCache.toJson()),
    );
  }

  @override
  Future<WeatherForecastModel> getLastWeatherForecast() {
    final jsonString = sharedPreferences.getString(CACHED_WEATHER_FORECAST);
    if (jsonString != null) {
      return Future.value(
          WeatherForecastModel.fromJson(json.decode(jsonString)));
    } else {
      throw CacheFailure("");
    }
  }
} 