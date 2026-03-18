// lib/config.dart
enum Environment { dev, sit, prod }

class Config {
  static late Environment environment;
  static late String baseUrl;

  static void setEnvironment(Environment env) {
    environment = env;
    switch (env) {
      case Environment.dev:
        baseUrl = 'https://dev-api.paymentportfolio.com';
        break;
      case Environment.sit:
        baseUrl = 'https://sit-api.paymentportfolio.com';
        break;
      case Environment.prod:
        baseUrl = 'https://api.paymentportfolio.com';
        break;
    }
  }

  static String get apiUrl => '$baseUrl/api/v1';
}
