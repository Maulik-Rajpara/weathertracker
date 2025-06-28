import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../core/utils/screen_size_util.dart';
import '../../../location/presentation/bloc/location_bloc.dart';
import '../../domain/entities/weather_forecast.dart';
import '../bloc/weather_bloc.dart';
import 'package:home_widget/home_widget.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/dialog_widget.dart';
import 'package:flutter/foundation.dart';

Future<void> updateWeatherWidget(String city, String temp, String desc, String wind, String humidity) async {
  await HomeWidget.saveWidgetData<String>('city', city);
  await HomeWidget.saveWidgetData<String>('temp', temp);
  await HomeWidget.saveWidgetData<String>('desc', desc);
  await HomeWidget.saveWidgetData<String>('wind', wind);
  await HomeWidget.saveWidgetData<String>('humidity', humidity);
  await HomeWidget.updateWidget(
    androidName: 'WeatherWidgetProvider',
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  late LocationBloc _locationBloc;
  late WeatherBloc _weatherBloc;
  PermissionStatus? _permissionStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _locationBloc = context.read<LocationBloc>();
    _weatherBloc = context.read<WeatherBloc>();
    if (!kIsWeb) {
      _requestPermissionAndFetchLocation();
    } else {
      // On web, skip permission logic and just fetch weather for a default location or show search UI
      setState(() {
        _permissionStatus = PermissionStatus.granted;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _requestPermissionAndFetchLocation();
    }
  }

  Future<void> _requestPermissionAndFetchLocation() async {
    final status = await Permission.location.request();
    setState(() {
      _permissionStatus = status;
    });

    if (status.isGranted) {
      // Check if location services are enabled
      final isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled && mounted) {
        // Show dialog instead of SnackBar
        showDialog(
          context: context,
          builder: (context) => AppDialog(
            title: AppStrings.permissionDialogTitle,
            message: AppStrings.locationServicesDisabled,
            confirmText: AppStrings.enable,
            onConfirm: () {
              Geolocator.openLocationSettings();
              Navigator.of(context).pop();
            },
          ),
        );
        return;
      }
      _locationBloc.add(GetCurrentLocationEvent());
    }
  }

  void _onSearch(String query) {
    if (query.isNotEmpty) {
      _weatherBloc.add(GetWeatherByCityEvent(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenSizeUtil().init(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: AppStrings.viewWeatherMap,
            onPressed: () => context.push('/map'),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (kIsWeb) {
      // On web, skip permission UI and just show weather UI or search
      return _buildWeatherUI();
    }
    if (_permissionStatus == null) {
      return const LoadingWidget(message: AppStrings.checkingPermissions);
    }
    if (_permissionStatus!.isGranted) {
      return BlocConsumer<LocationBloc, LocationState>(
        listener: (context, state) {
          if (state is CurrentLocationLoaded) {
            _weatherBloc.add(GetCurrentWeatherEvent(
              latitude: state.location.latitude,
              longitude: state.location.longitude,
            ));
          }
        },
        builder: (context, state) {
          if (state is LocationLoading || state is LocationInitial) {
            return const LoadingWidget(message: AppStrings.fetchingLocation);
          }
          if (state is LocationError) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: () {
                _locationBloc.add(GetCurrentLocationEvent());
              },
            );
          }
          if (state is CurrentLocationLoaded || state is LocationsSearchLoaded) {
            return _buildWeatherUI();
          }
          return const SizedBox.shrink();
        },
      );
    } else {
      return _buildPermissionDeniedUI();
    }
  }

  Widget _buildWeatherUI() {
    return SafeArea(
      child: Padding(
        padding: ScreenSizeUtil.getResponsivePadding(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search Bar - Sticky at top
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: AppStrings.searchHint,
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: AppStrings.clear,
                        onPressed: () {
                          _searchController.clear();
                        },
                      ),
                    ),
                    onSubmitted: _onSearch,
                    textInputAction: TextInputAction.search,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            // Scrollable Content
            Expanded(
              flex: 1,
              child: RefreshIndicator(
                onRefresh: () async {
                  // Re-fetch location and weather
                  _locationBloc.add(GetCurrentLocationEvent());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Current Weather
                      BlocBuilder<WeatherBloc, WeatherState>(
                        builder: (context, state) {
                          if (state is WeatherLoading) {
                            return const LoadingWidget(
                                message: AppStrings.loadingWeather);
                          } else if (state is WeatherError) {
                            return CustomErrorWidget(
                              message: state.message,
                              onRetry: () {
                                _locationBloc.add(GetCurrentLocationEvent());
                              },
                            );
                          } else if (state is WeatherLoaded &&
                              state.weather != null) {
                            final weather = state.weather!;
                            // Update the Android home widget with the latest weather data
                            updateWeatherWidget(
                              weather.cityName,
                              '${weather.temperature.toStringAsFixed(1)}°C',
                              weather.description,
                              '${weather.windSpeed.toStringAsFixed(1)} m/s',
                              '${weather.humidity.toStringAsFixed(0)}%',
                            );
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      weather.cityName,
                                      style: TextStyle(
                                        fontSize: ScreenSizeUtil
                                            .getResponsiveFontSize(24),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.network(
                                          'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                                          width: 64,
                                          height: 64,
                                          errorBuilder: (context, error,
                                                  stackTrace) =>
                                              const Icon(Icons.wb_cloudy,
                                                  size: 64),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${weather.temperature.toStringAsFixed(1)}°C',
                                          style: TextStyle(
                                            fontSize: ScreenSizeUtil
                                                .getResponsiveFontSize(40),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      weather.description,
                                      style: TextStyle(
                                        fontSize: ScreenSizeUtil
                                            .getResponsiveFontSize(18),
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.water_drop,
                                            color: Colors.blue[300]),
                                        const SizedBox(width: 4),
                                        Text(
                                            '${AppStrings.humidity}: ${weather.humidity.toStringAsFixed(0)}%'),
                                        const SizedBox(width: 16),
                                        Icon(Icons.air,
                                            color: Colors.grey[400]),
                                        const SizedBox(width: 4),
                                        Text(
                                            '${AppStrings.wind}: ${weather.windSpeed.toStringAsFixed(1)} m/s'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: 24),
                      // 5-Day Forecast with Tabs
                      BlocBuilder<WeatherBloc, WeatherState>(
                        builder: (context, state) {
                          if (state is WeatherLoaded &&
                              state.forecast != null) {
                            final forecast = state.forecast!;
                            return _ForecastTabChart(forecast: forecast);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionDeniedUI() {
    if (kIsWeb) {
      // On web, never show permission denied UI
      return const SizedBox.shrink();
    }
    String message;
    String buttonText;
    VoidCallback onPressed;

    if (_permissionStatus!.isPermanentlyDenied) {
      message = AppStrings.permissionPermanentlyDenied;
      buttonText = AppStrings.openSettings;
      onPressed = openAppSettings;
    } else {
      message = AppStrings.permissionDenied;
      buttonText = AppStrings.requestPermission;
      onPressed = _requestPermissionAndFetchLocation;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onPressed,
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}

class _ForecastTabChart extends StatefulWidget {
  final WeatherForecast forecast;
  const _ForecastTabChart({required this.forecast});

  @override
  State<_ForecastTabChart> createState() => _ForecastTabChartState();
}

class _ForecastTabChartState extends State<_ForecastTabChart> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  final List<String> _tabs = ['Temp', 'Humidity', 'Pressure', 'Wind'];
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this, initialIndex: _selectedIndex);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final forecast = widget.forecast;
    // Prepare data for each tab
    List<double> values;
    String yLabel;
    String chartTitle;
    String unit;
    switch (_selectedIndex) {
      case 1:
        values = forecast.dailyForecast.map((e) => e.humidity.toDouble()).toList();
        yLabel = 'Humidity (%)';
        chartTitle = 'Humidity vs Date';
        unit = '%';
        break;
      case 2:
        values = forecast.dailyForecast.map((e) => e.pressure.toDouble()).toList();
        yLabel = 'Pressure (hPa)';
        chartTitle = 'Pressure vs Date';
        unit = 'hPa';
        break;
      case 3:
        values = forecast.dailyForecast.map((e) => e.windSpeed).toList();
        yLabel = 'Wind (m/s)';
        chartTitle = 'Wind vs Date';
        unit = 'm/s';
        break;
      default:
        values = forecast.dailyForecast.map((e) => e.temperature).toList();
        yLabel = 'Temperature (°C)';
        chartTitle = 'Temp vs Date';
        unit = '°C';
    }
    final minY = values.reduce((a, b) => a < b ? a : b) - 2;
    final maxY = values.reduce((a, b) => a > b ? a : b) + 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TabBar(dividerColor: Colors.white,

          controller: _tabController, labelStyle: TextStyle(fontSize: 14),
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.blue[200],
          ),indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.blue[900],
          unselectedLabelColor: Colors.black54,
          tabs: _tabs.map((t) => Tab(text: t,)).toList(),
        ),
        const SizedBox(height: 8),
        Text(
          chartTitle,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height / 2.5,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 1,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true, interval: 5,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}$unit', style: const TextStyle(fontSize: 12));
                        },
                      ),
                      axisNameWidget: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(yLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      axisNameSize: 24,
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true, interval: 8,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= widget.forecast.dailyForecast.length) {
                            return const SizedBox.shrink();
                          }
                          final day = widget.forecast.dailyForecast[index].dateTime;
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${day.day}/${day.month}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                      axisNameWidget: const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      axisNameSize: 24,
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  minX: 0,
                  maxX: (values.length - 1).toDouble(),
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (int i = 0; i < values.length; i++)
                          FlSpot(i.toDouble(), values[i]),
                      ],
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [Colors.blue, Colors.lightBlueAccent],
                      ),
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                          radius: 2,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: Colors.blue,
                        ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.withOpacity(0.2),
                            Colors.lightBlueAccent.withOpacity(0.05)
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((LineBarSpot touchedSpot) {
                          final index = touchedSpot.x.toInt();
                          final day = widget.forecast.dailyForecast[index].dateTime;
                          return LineTooltipItem(
                            '${day.day}/${day.month}\n${touchedSpot.y.toStringAsFixed(1)}$unit',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
