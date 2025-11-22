/// Application-wide constants
class AppConstants {
  // App Information
  static const String appName = 'Health Insights';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String themePreferenceKey = 'theme_mode';
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);
  
  // UI Constants
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Chart Constants
  static const int maxChartDataPoints = 10;
  static const double chartMinY = 0;
  
  // Status Messages
  static const String loadingMessage = 'Loading health data...';
  static const String errorMessage = 'Failed to load health data';
  static const String noDataMessage = 'No health data available';
  static const String dataRefreshedMessage = 'Data refreshed successfully';
}

