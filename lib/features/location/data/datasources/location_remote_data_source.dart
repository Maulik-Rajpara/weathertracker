import 'package:geocoding/geocoding.dart' as G;
import 'package:geolocator/geolocator.dart' as G;
import '../models/location_model.dart';

abstract class LocationRemoteDataSource {
  Future<LocationModel> getCurrentLocation();
  Future<List<LocationModel>> searchLocations({required String query});
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  @override
  Future<LocationModel> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await G.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check location permission
      G.LocationPermission permission = await G.Geolocator.checkPermission();
      if (permission == G.LocationPermission.denied) {
        permission = await G.Geolocator.requestPermission();
        if (permission == G.LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == G.LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      G.Position position = await G.Geolocator.getCurrentPosition(
        desiredAccuracy: G.LocationAccuracy.high,
      );

      // Get address from coordinates
      List<G.Placemark> placemarks = await G.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        G.Placemark placemark = placemarks.first;
        return LocationModel(
          latitude: position.latitude,
          longitude: position.longitude,
          name: placemark.locality ?? 'Unknown Location',
        );
      } else {
        return LocationModel(
          latitude: position.latitude,
          longitude: position.longitude,
          name: 'Unknown Location',
        );
      }
    } catch (e) {
      throw Exception('Failed to get current location: $e');
    }
  }

  @override
  Future<List<LocationModel>> searchLocations({
    required String query,
  }) async {
    try {
      List<G.Location> locations = await G.locationFromAddress(query);

      return locations.map((location) {
        return LocationModel(
          latitude: location.latitude,
          longitude: location.longitude,
          name: query,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to search locations: $e');
    }
  }
} 