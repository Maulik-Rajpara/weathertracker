import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/location.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_local_data_source.dart';
import '../datasources/location_remote_data_source.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource remoteDataSource;
  final LocationLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  LocationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, Location>> getCurrentLocation() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteLocation = await remoteDataSource.getCurrentLocation();
        localDataSource.cacheLocation(remoteLocation);
        return Right(remoteLocation);
      } catch (e) {
        if (e.toString().contains('Location services are disabled')) {
          return Left(LocationFailure(e.toString()));
        } else if (e.toString().contains('Location permissions')) {
          return Left(PermissionFailure(e.toString()));
        } else {
          return Left(ServerFailure(e.toString()));
        }
      }
    } else {
      try {
        final localLocation = await localDataSource.getLastLocation();
        return Right(localLocation);
      } catch (e) {
        return Left(CacheFailure(e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<Location>>> searchLocations({
    required String query,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final locations = await remoteDataSource.searchLocations(query: query);
        return Right(locations);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Location>> getLocationFromCoordinates({required double latitude, required double longitude}) {
    // TODO: implement getLocationFromCoordinates
    throw UnimplementedError();
  }
} 