import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/features/auth/application/login_use_case.dart';
import 'package:pdvmobile/features/auth/application/restore_session_use_case.dart';
import 'package:pdvmobile/features/auth/domain/entities/auth_session.dart';
import 'package:pdvmobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:pdvmobile/features/auth/presentation/auth_gate.dart';
import 'package:pdvmobile/core/env/app_config.dart';
import 'package:pdvmobile/core/env/app_environment.dart';
import 'package:pdvmobile/features/home/presentation/pdv_home_page.dart';

void main() {
  group('AuthGate', () {
    testWidgets('mostra login quando nao existe sessao restaurada', (
      WidgetTester tester,
    ) async {
      final repository = _FakeAuthRepository();

      await tester.pumpWidget(
        _buildTestApp(repository: repository),
      );
      await tester.pumpAndSettle();

      expect(find.text('Entrar no PDV'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('abre a area interna quando a sessao e restaurada', (
      WidgetTester tester,
    ) async {
      final repository = _FakeAuthRepository(
        initialSession: const AuthSession(
          accessToken: 'token',
          userName: 'Garcom Teste',
          userEmail: 'garcom@pdv.com',
        ),
      );

      await tester.pumpWidget(
        _buildTestApp(repository: repository),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PdvHomePage), findsOneWidget);
      expect(find.text('Operacao de mesa pronta para Android'), findsOneWidget);
    });

    testWidgets('valida credenciais antes de tentar login', (
      WidgetTester tester,
    ) async {
      final repository = _FakeAuthRepository();

      await tester.pumpWidget(
        _buildTestApp(repository: repository),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Entrar'));
      await tester.pump();

      expect(find.text('Informe um email valido'), findsOneWidget);
      expect(find.text('Informe ao menos 6 caracteres'), findsOneWidget);
      expect(repository.loginCallCount, 0);
    });

    testWidgets('faz login e navega para a area interna', (
      WidgetTester tester,
    ) async {
      final repository = _FakeAuthRepository();

      await tester.pumpWidget(
        _buildTestApp(repository: repository),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('login-email-field')),
        'garcom@pdv.com',
      );
      await tester.enterText(
        find.byKey(const Key('login-password-field')),
        '123456',
      );
      await tester.tap(find.text('Entrar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(repository.loginCallCount, 1);
      expect(find.byType(PdvHomePage), findsOneWidget);
    });
  });
}

Widget _buildTestApp({required AuthRepository repository}) {
  return MaterialApp(
    home: AuthGate(
      loginUseCase: LoginUseCase(repository),
      restoreSessionUseCase: RestoreSessionUseCase(repository),
      authenticatedBuilder: (context, session) => PdvHomePage(
        config: const AppConfig(
          environment: AppEnvironment.dev,
          apiBaseUrl: 'https://dev.api.pdvmobile.local',
        ),
        session: session,
      ),
    ),
  );
}

final class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.initialSession});

  final AuthSession? initialSession;
  int loginCallCount = 0;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    loginCallCount += 1;

    return AuthSession(
      accessToken: 'token',
      userName: 'Garcom Teste',
      userEmail: email,
    );
  }

  @override
  Future<AuthSession?> restoreSession() async => initialSession;
}
