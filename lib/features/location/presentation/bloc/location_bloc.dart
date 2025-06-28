import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/location.dart';
import '../../domain/usecases/get_current_location.dart';
import '../../domain/usecases/search_locations.dart';

part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  final GetCurrentLocation getCurrentLocation;
  final SearchLocations searchLocations;

  LocationBloc({
    required this.getCurrentLocation,
    required this.searchLocations,
  }) : super(LocationInitial()) {
    on<GetCurrentLocationEvent>(_onGetCurrentLocation);
    on<SearchLocationsEvent>(_onSearchLocations);
  }

  Future<void> _onGetCurrentLocation(
    GetCurrentLocationEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    
    final result = await getCurrentLocation(const NoParams());

    result.fold(
      (failure) => emit(LocationError(failure.message)),
      (location) => emit(CurrentLocationLoaded(location)),
    );
  }

  Future<void> _onSearchLocations(
    SearchLocationsEvent event,
    Emitter<LocationState> emit,
  ) async {
    emit(LocationLoading());
    
    final result = await searchLocations(event.query);

    result.fold(
      (failure) => emit(LocationError(failure.message)),
      (locations) => emit(LocationsSearchLoaded(locations)),
    );
  }
} 