import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/app/app.dart';
import 'package:pdvmobile/core/env/app_config.dart';
import 'package:pdvmobile/core/env/app_environment.dart';

void main() {
  group('PdvMobileApp', () {
    testWidgets('renderiza a home inicial do PDV com identidade do app', (
      WidgetTester tester,
    ) async {
      const config = AppConfig(
        environment: AppEnvironment.dev,
        apiBaseUrl: 'https://dev.api.pdvmobile.local',
      );

      await tester.pumpWidget(const PdvMobileApp(config: config));

      expect(find.text('PDV Mobile'), findsOneWidget);
      expect(find.text('Operacao de mesa pronta para Android'), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('mostra fita de ambiente fora de producao', (
      WidgetTester tester,
    ) async {
      const config = AppConfig(
        environment: AppEnvironment.staging,
        apiBaseUrl: 'https://staging.api.pdvmobile.local',
      );

      await tester.pumpWidget(const PdvMobileApp(config: config));

      expect(find.byKey(const Key('environment-badge')), findsOneWidget);
      expect(find.text('STAGING'), findsNWidgets(2));
    });

    testWidgets('nao mostra fita de ambiente em producao', (
      WidgetTester tester,
    ) async {
      const config = AppConfig(
        environment: AppEnvironment.production,
        apiBaseUrl: 'https://api.pdvmobile.com',
      );

      await tester.pumpWidget(const PdvMobileApp(config: config));

      expect(find.byKey(const Key('environment-badge')), findsNothing);
    });
  });
}
