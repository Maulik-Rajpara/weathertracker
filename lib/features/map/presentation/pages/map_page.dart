import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../weather/presentation/bloc/weather_bloc.dart';
import '../../../location/presentation/bloc/location_bloc.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/utils/screen_size_util.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/dialog_widget.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final TextEditingController _searchController = TextEditingController();
  late WeatherBloc _weatherBloc;
  late LocationBloc _locationBloc;
  LatLng? _center;
  bool _showInfo = false;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _weatherBloc = context.read<WeatherBloc>();
    _locationBloc = context.read<LocationBloc>();

    final currentState = _weatherBloc.state;
    if (currentState is WeatherLoaded && currentState.weather != null) {
      final weather = currentState.weather!;
      _center = LatLng(weather.latitude, weather.longitude);
    } else {
    _locationBloc.add(GetCurrentLocationEvent());
    }
  }

  void _onSearch(String query) {
    if (query.isNotEmpty) {
      _locationBloc.add(SearchLocationsEvent(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenSizeUtil().init(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather Map'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop();
            }

          },
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<LocationBloc, LocationState>(
            listener: (context, state) {
              if(context.mounted){
                if (state is CurrentLocationLoaded) {
                  _updateMapCenter(state.location.latitude, state.location.longitude);
                } else if (state is LocationsSearchLoaded) {
                  if (state.locations.isNotEmpty) {
                    final firstResult = state.locations.first;
                    _updateMapCenter(firstResult.latitude, firstResult.longitude);
                  }
                }
              }

            },
          ),
        ],
        child: BlocBuilder<WeatherBloc, WeatherState>(
          builder: (context, state) {
            if (_center == null) {
              return const LoadingWidget(message: AppStrings.loadingWeather);
            }
            return _center != null? Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _center!,
                    initialZoom: 10,
                    onTap: (tapPosition, point) {
                      _updateMapCenter(point.latitude, point.longitude);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.weathertracker',
                    ),
                    if (state is WeatherLoaded && state.weather != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _center!,
                            width: 140,
                            height: 140,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showInfo = true;
                                });
                              },
                              child: Icon(
                                Icons.location_on,
                                color: Theme.of(context).primaryColor,
                                size: 80,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                Positioned(
                  top: 10,
                  left: 15,
                  right: 15,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: AppStrings.searchHint,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.zero,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        ),
                      ),
                      onSubmitted: _onSearch,
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                ),
                if (_showInfo && state is WeatherLoaded && state.weather != null)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: ScreenSizeUtil.getResponsivePadding(vertical: 24),
                      child: Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                state.weather!.cityName,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${state.weather!.temperature.round()}°C',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                state.weather!.description,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Humidity: ${state.weather!.humidity}%',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                if (state is WeatherLoading)
                  const Center(child: LoadingWidget(message: AppStrings.fetchingLocation)),
                if (state is WeatherError)
                  Center(child: CustomErrorWidget(message: state.message, onRetry: _retryFetch)),
              ],
            ):SizedBox.shrink();
          },
        ),
      ),
    );
  }

  void _updateMapCenter(double latitude, double longitude) {
    setState(() {
      _center = LatLng(latitude, longitude);
      _showInfo = false;
    });
    _weatherBloc.add(GetCurrentWeatherEvent(latitude: latitude, longitude: longitude));
    if(context.mounted){
      if (_center != null && _mapController!=null) {
        _mapController.move(_center!, 10);
      }
    }
  }

  void _retryFetch() {
    if (_center != null) {
      _weatherBloc.add(GetCurrentWeatherEvent(latitude: _center!.latitude, longitude: _center!.longitude));
    }
  }


} 