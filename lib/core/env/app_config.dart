import 'package:pdvmobile/core/env/app_environment.dart';

class AppConfig {
  const AppConfig({
    required this.environment,
    required this.apiBaseUrl,
  });

  factory AppConfig.fromEnvironment() {
    return AppConfig(
      environment: AppEnvironment.fromValue(
        const String.fromEnvironment('APP_ENV', defaultValue: 'dev'),
      ),
      apiBaseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        defaultValue: 'https://facilmenu.com.br/api',
      ),
    );
  }

  final AppEnvironment environment;
  final String apiBaseUrl;

  String get appName => 'PDV Mobile';

  String get environmentLabel {
    switch (environment) {
      case AppEnvironment.dev:
        return 'DEV';
      case AppEnvironment.staging:
        return 'STAGING';
      case AppEnvironment.production:
        return 'PROD';
    }
  }

  bool get isProduction => environment == AppEnvironment.production;
}
