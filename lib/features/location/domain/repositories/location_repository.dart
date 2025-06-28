import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/location.dart';

abstract class LocationRepository {
  Future<Either<Failure, Location>> getCurrentLocation();
  
  Future<Either<Failure, Location>> getLocationFromCoordinates({
    required double latitude,
    required double longitude,
  });
  
  Future<Either<Failure, List<Location>>> searchLocations({
    required String query,
  });
} 