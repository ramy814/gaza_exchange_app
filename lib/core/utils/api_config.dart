class ApiConfig {
  static const String serverUrl = 'http://localhost:8000'; // Base server URL
  static const String baseUrl = 'http://localhost:8000/api/'; // API endpoints
  static const String storageUrl = 'http://localhost:8000/storage/';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
