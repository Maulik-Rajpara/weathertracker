import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/weather.dart';
import '../../domain/entities/weather_forecast.dart';
import '../../domain/usecases/get_current_weather.dart';
import '../../domain/usecases/get_weather_forecast.dart';
import '../../domain/usecases/get_weather_by_city.dart';

part 'weather_event.dart';
part 'weather_state.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final GetCurrentWeather getCurrentWeather;
  final GetWeatherForecast getWeatherForecast;
  final GetWeatherByCity getWeatherByCity;

  WeatherBloc({
    required this.getCurrentWeather,
    required this.getWeatherForecast,
    required this.getWeatherByCity,
  }) : super(WeatherInitial()) {
    on<GetCurrentWeatherEvent>(_onGetCurrentWeather);
    on<GetWeatherForecastEvent>(_onGetWeatherForecast);
    on<GetWeatherByCityEvent>(_onGetWeatherByCity);
  }

  Future<void> _onGetCurrentWeather(
    GetCurrentWeatherEvent event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());
    
    final result = await getCurrentWeather(
      WeatherParams(
        latitude: event.latitude,
        longitude: event.longitude,
      ),
    );

    result.fold(
      (failure) => emit(WeatherError(failure.message)),
      (weather) {
        final currentState = state;
        if (currentState is WeatherLoaded) {
          emit(currentState.copyWith(weather: weather));
        } else {
          emit(WeatherLoaded(weather: weather));
        }
        add(GetWeatherForecastEvent(
          latitude: event.latitude,
          longitude: event.longitude,
        ));
      },
    );
  }

  Future<void> _onGetWeatherForecast(
    GetWeatherForecastEvent event,
    Emitter<WeatherState> emit,
  ) async {
    final result = await getWeatherForecast(
      WeatherParams(
        latitude: event.latitude,
        longitude: event.longitude,
      ),
    );

    result.fold(
      (failure) => emit(WeatherError(failure.message)),
      (forecast) {
        final currentState = state;
        if (currentState is WeatherLoaded) {
          emit(currentState.copyWith(forecast: forecast));
        } else {
          emit(WeatherLoaded(forecast: forecast));
        }
      },
    );
  }

  Future<void> _onGetWeatherByCity(
    GetWeatherByCityEvent event,
    Emitter<WeatherState> emit,
  ) async {
    emit(WeatherLoading());

    final result = await getWeatherByCity(event.cityName);

    result.fold(
      (failure) => emit(WeatherError(failure.message)),
      (weather) {
        emit(WeatherLoaded(weather: weather));
        add(GetWeatherForecastEvent(
            latitude: weather.latitude, longitude: weather.longitude));
      },
    );
  }
} 