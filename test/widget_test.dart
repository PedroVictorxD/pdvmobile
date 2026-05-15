import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/app/app.dart';
import 'package:pdvmobile/core/env/app_config.dart';
import 'package:pdvmobile/core/env/app_environment.dart';
import 'package:pdvmobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:pdvmobile/features/auth/domain/entities/auth_session.dart';

void main() {
  group('PdvMobileApp', () {
    testWidgets('abre login quando nao existe sessao ativa', (
      WidgetTester tester,
    ) async {
      const config = AppConfig(
        environment: AppEnvironment.dev,
        apiBaseUrl: 'https://dev.api.pdvmobile.local',
      );

      await tester.pumpWidget(
        PdvMobileApp(
          config: config,
          authRepository: _FakeAuthRepository(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Entrar no PDV'), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('mostra fita de ambiente fora de producao', (
      WidgetTester tester,
    ) async {
      const config = AppConfig(
        environment: AppEnvironment.staging,
        apiBaseUrl: 'https://staging.api.pdvmobile.local',
      );

      await tester.pumpWidget(
        PdvMobileApp(
          config: config,
          authRepository: _FakeAuthRepository(
            session: const AuthSession(
              accessToken: 'token',
              refreshToken: 'refresh-token',
              userName: 'Garcom Teste',
              userEmail: 'garcom@pdv.com',
              role: 'MERCHANT',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

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

      await tester.pumpWidget(
        PdvMobileApp(
          config: config,
          authRepository: _FakeAuthRepository(
            session: const AuthSession(
              accessToken: 'token',
              refreshToken: 'refresh-token',
              userName: 'Garcom Teste',
              userEmail: 'garcom@pdv.com',
              role: 'MERCHANT',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('environment-badge')), findsNothing);
    });
  });
}

final class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.session});

  final AuthSession? session;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    return AuthSession(
      accessToken: 'token',
      refreshToken: 'refresh-token',
      userName: 'Garcom Teste',
      userEmail: email,
      role: 'MERCHANT',
    );
  }

  @override
  Future<AuthSession?> restoreSession() async => session;
}
