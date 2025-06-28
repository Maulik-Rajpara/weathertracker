import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/location.dart';
import '../repositories/location_repository.dart';

class SearchLocations implements UseCase<List<Location>, String> {
  final LocationRepository repository;

  SearchLocations(this.repository);

  @override
  Future<Either<Failure, List<Location>>> call(String query) async {
    return await repository.searchLocations(query: query);
  }
} 