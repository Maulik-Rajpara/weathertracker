import 'package:flutter_test/flutter_test.dart';
import 'package:weathertracker/features/weather/data/models/weather_model.dart';
import 'package:weathertracker/features/weather/domain/entities/weather.dart';

void main() {
  group('WeatherModel', () {
    final tWeatherJson = {
      "coord": {"lon": -0.1257, "lat": 51.5085},
      "weather": [
        {"id": 803, "main": "Clouds", "description": "broken clouds", "icon": "04d"}
      ],
      "base": "stations",
      "main": {"temp": 289.59, "humidity": 72},
      "wind": {"speed": 3.6, "deg": 240},
      "dt": 1661870592,
      "name": "London",
    };

    final tWeatherModel = WeatherModel(
      temperature: 289.59,
      humidity: 72,
      windSpeed: 3.6,
      description: 'broken clouds',
      icon: '04d',
      dateTime: DateTime.fromMillisecondsSinceEpoch(1661870592 * 1000),
      cityName: 'London',
      latitude: 51.5085,
      longitude: -0.1257,
    );

    test('should be a subclass of Weather entity', () {

      expect(tWeatherModel, isA<Weather>());
    });

    test('should return a valid model from JSON', () {

      final result = WeatherModel.fromJson(tWeatherJson);
      // assert
      expect(result, tWeatherModel);
    });

    test('should return a JSON map containing the proper data', () {

      final result = tWeatherModel.toJson();
      // assert
      final expectedJsonMap = {
        'main': {'temp': 289.59, 'humidity': 72.0},
        'wind': {'speed': 3.6},
        'weather': [{'description': 'broken clouds', 'icon': '04d'}],
        'dt': 1661870592,
        'name': 'London',
        'coord': {'lat': 51.5085, 'lon': -0.1257}
      };
      expect(result, expectedJsonMap);
    });
  });
} 