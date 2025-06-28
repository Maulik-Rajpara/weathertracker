class AppConstants {
  // API Constants
  
  // Base URLs
  static const String openWeatherBaseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String googleMapsBaseUrl = 'https://maps.googleapis.com/maps/api';
  
  // Weather API Endpoints
  static const String currentWeatherEndpoint = '/weather';
  static const String forecastEndpoint = '/forecast';
  
  // Default Values
  static const double defaultLatitude = 40.7128;
  static const double defaultLongitude = -74.0060;
  static const String defaultCity = 'New York';
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Cache Duration
  static const Duration weatherCacheDuration = Duration(minutes: 10);
  
  // Error Messages
  static const String networkErrorMessage = 'No internet connection. Please check your connection and try again.';
  static const String locationErrorMessage = 'Unable to get your location. Please enable location services.';
  static const String apiErrorMessage = 'Something went wrong. Please try again later.';
  static const String permissionErrorMessage = 'Location permission denied. Please enable location access in settings.';
  
  // API Keys
  static const String openWeatherApiKeyWeb = 'b29f3884883dc96bb74bd5ba8e0c8c05';
} 