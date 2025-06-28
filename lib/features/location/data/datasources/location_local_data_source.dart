import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/failures.dart';
import '../models/location_model.dart';

abstract class LocationLocalDataSource {
  Future<void> cacheLocation(LocationModel locationToCache);
  Future<LocationModel> getLastLocation();
}

const CACHED_LOCATION = 'CACHED_LOCATION';

class LocationLocalDataSourceImpl implements LocationLocalDataSource {
  final SharedPreferences sharedPreferences;

  LocationLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheLocation(LocationModel locationToCache) {
    return sharedPreferences.setString(
      CACHED_LOCATION,
      json.encode(locationToCache.toJson()),
    );
  }

  @override
  Future<LocationModel> getLastLocation() {
    final jsonString = sharedPreferences.getString(CACHED_LOCATION);
    if (jsonString != null) {
      return Future.value(LocationModel.fromJson(json.decode(jsonString)));
    } else {
      throw CacheFailure("");
    }
  }
} 