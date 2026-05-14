import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/core/env/app_config.dart';
import 'package:pdvmobile/core/env/app_environment.dart';

void main() {
  group('AppEnvironment', () {
    test('converte valores conhecidos', () {
      expect(AppEnvironment.fromValue('dev'), AppEnvironment.dev);
      expect(AppEnvironment.fromValue('staging'), AppEnvironment.staging);
      expect(AppEnvironment.fromValue('prod'), AppEnvironment.production);
      expect(
        AppEnvironment.fromValue('production'),
        AppEnvironment.production,
      );
    });

    test('faz fallback para dev quando valor e invalido', () {
      expect(AppEnvironment.fromValue('qa'), AppEnvironment.dev);
      expect(AppEnvironment.fromValue(''), AppEnvironment.dev);
    });
  });

  group('AppConfig', () {
    test('retorna nome legivel do ambiente', () {
      const config = AppConfig(
        environment: AppEnvironment.staging,
        apiBaseUrl: 'https://staging.api.pdvmobile.local',
      );

      expect(config.environmentLabel, 'STAGING');
      expect(config.appName, 'PDV Mobile');
    });

    test('detecta quando ambiente e producao', () {
      const config = AppConfig(
        environment: AppEnvironment.production,
        apiBaseUrl: 'https://api.pdvmobile.com',
      );

      expect(config.isProduction, isTrue);
    });
  });
}
