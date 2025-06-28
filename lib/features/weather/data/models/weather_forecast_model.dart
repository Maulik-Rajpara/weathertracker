import '../../domain/entities/weather_forecast.dart';

class WeatherForecastModel extends WeatherForecast {
  const WeatherForecastModel({required super.dailyForecast});

  factory WeatherForecastModel.fromJson(Map<String, dynamic> json) {
    final daily = (json['list'] as List)
        .map((item) => DailyWeatherForecastModel.fromJson(item))
        .toList();
    return WeatherForecastModel(dailyForecast: daily);
  }

  Map<String, dynamic> toJson() {
    return {
      'list': dailyForecast
          .map((forecast) => (forecast as DailyWeatherForecastModel).toJson())
          .toList(),
    };
  }
}

class DailyWeatherForecastModel extends DailyWeatherForecast {
  const DailyWeatherForecastModel({
    required super.dateTime,
    required super.temperature,
    required super.description,
    required super.icon,
    required super.humidity,
    required super.pressure,
    required super.windSpeed,
  });

  factory DailyWeatherForecastModel.fromJson(Map<String, dynamic> json) {
    return DailyWeatherForecastModel(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: (json['main']['temp'] as num).toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
      humidity: json['main']['humidity'] as int,
      pressure: json['main']['pressure'] as int,
      windSpeed: (json['wind']['speed'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dt': dateTime.millisecondsSinceEpoch ~/ 1000,
      'main': {
        'temp': temperature,
        'humidity': humidity,
        'pressure': pressure,
      },
      'weather': [
        {
          'description': description,
          'icon': icon,
        }
      ],
      'wind': {
        'speed': windSpeed,
      },
    };
  }
} 