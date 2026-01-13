class AppConstants {
  AppConstants._(); // Private constructor - can't instantiate

  // Storage Keys
  static const String requestsBox = 'requests';
  static const String collectionsBox = 'collections';
  static const String settingsBox = 'settings';

  // API Configuration
  static const int requestTimeout = 30; // seconds
  static const int maxRetries = 3;

  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;

  // Validation
  static const int minNameLength = 3;
  static const int maxNameLength = 50;
}
