class ApiConfig {
  ApiConfig._();

  static const String baseUrl = 'https://ocupa2.ia3x.com/apix';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
