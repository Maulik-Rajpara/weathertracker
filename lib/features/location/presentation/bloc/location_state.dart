part of 'location_bloc.dart';

abstract class LocationState extends Equatable {
  const LocationState();
  
  @override
  List<Object> get props => [];
}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class CurrentLocationLoaded extends LocationState {
  final Location location;

  const CurrentLocationLoaded(this.location);

  @override
  List<Object> get props => [location];
}

class LocationsSearchLoaded extends LocationState {
  final List<Location> locations;

  const LocationsSearchLoaded(this.locations);

  @override
  List<Object> get props => [locations];
}

class LocationError extends LocationState {
  final String message;

  const LocationError(this.message);

  @override
  List<Object> get props => [message];
} 