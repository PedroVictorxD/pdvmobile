import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/features/auth/application/restore_session_use_case.dart';
import 'package:pdvmobile/features/auth/domain/entities/auth_session.dart';
import 'package:pdvmobile/features/auth/domain/repositories/auth_repository.dart';

void main() {
  group('RestoreSessionUseCase', () {
    test('retorna a sessao restaurada do repositorio', () async {
      const expected = AuthSession(
        accessToken: 'token',
        userName: 'Garcom Teste',
        userEmail: 'garcom@pdv.com',
      );
      final repository = _FakeAuthRepository(expected);
      final useCase = RestoreSessionUseCase(repository);

      final session = await useCase();

      expect(session, expected);
    });
  });
}

final class _FakeAuthRepository implements AuthRepository {
  const _FakeAuthRepository(this.session);

  final AuthSession? session;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AuthSession?> restoreSession() async => session;
}
