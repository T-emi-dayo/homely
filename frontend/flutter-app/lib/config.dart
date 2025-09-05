class AppConfig {
  // Uses Render API by default, but can be overridden at runtime.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://homely-0xi4.onrender.com',
  );

  static const Duration timeout = Duration(seconds: 20);
}
