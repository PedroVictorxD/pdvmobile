import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/features/auth/application/login_use_case.dart';
import 'package:pdvmobile/features/auth/domain/entities/auth_session.dart';
import 'package:pdvmobile/features/auth/domain/repositories/auth_repository.dart';

void main() {
  group('LoginUseCase', () {
    test('encaminha email e senha para o repositorio', () async {
      final repository = _FakeAuthRepository();
      final useCase = LoginUseCase(repository);

      final session = await useCase(
        email: 'garcom@pdv.com',
        password: '123456',
      );

      expect(repository.loginCallCount, 1);
      expect(repository.lastEmail, 'garcom@pdv.com');
      expect(repository.lastPassword, '123456');
      expect(session.userName, 'Garcom Teste');
    });
  });
}

final class _FakeAuthRepository implements AuthRepository {
  int loginCallCount = 0;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    loginCallCount += 1;
    lastEmail = email;
    lastPassword = password;

    return const AuthSession(
      accessToken: 'token',
      userName: 'Garcom Teste',
      userEmail: 'garcom@pdv.com',
    );
  }

  @override
  Future<AuthSession?> restoreSession() async => null;
}
