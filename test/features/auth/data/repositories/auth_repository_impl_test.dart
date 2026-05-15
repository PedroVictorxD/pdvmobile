import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:pdvmobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:pdvmobile/features/auth/data/models/auth_session_model.dart';
import 'package:pdvmobile/features/auth/data/repositories/auth_repository_impl.dart';

void main() {
  group('AuthRepositoryImpl', () {
    test('faz login remoto e persiste a sessao localmente', () async {
      final remote = _FakeAuthRemoteDataSource();
      final local = _FakeAuthLocalDataSource();
      final repository = AuthRepositoryImpl(
        remoteDataSource: remote,
        localDataSource: local,
      );

      final session = await repository.login(
        email: 'merchant@test.com',
        password: '123456',
      );

      expect(remote.lastEmail, 'merchant@test.com');
      expect(remote.lastPassword, '123456');
      expect(local.savedSession, isNotNull);
      expect(session.accessToken, 'access-token');
    });

    test('restaura a sessao salva localmente', () async {
      final local = _FakeAuthLocalDataSource(
        initialSession: const AuthSessionModel(
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
          userName: 'Merchant',
          userEmail: 'merchant@test.com',
          role: 'MERCHANT',
        ),
      );
      final repository = AuthRepositoryImpl(
        remoteDataSource: _FakeAuthRemoteDataSource(),
        localDataSource: local,
      );

      final session = await repository.restoreSession();

      expect(session?.userEmail, 'merchant@test.com');
      expect(session?.refreshToken, 'refresh-token');
    });
  });
}

final class _FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  String? lastEmail;
  String? lastPassword;

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    lastEmail = email;
    lastPassword = password;

    return const AuthSessionModel(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      userName: 'Merchant',
      userEmail: 'merchant@test.com',
      role: 'MERCHANT',
    );
  }
}

final class _FakeAuthLocalDataSource implements AuthLocalDataSource {
  _FakeAuthLocalDataSource({this.initialSession});

  final AuthSessionModel? initialSession;
  AuthSessionModel? savedSession;

  @override
  Future<void> clearSession() async {
    savedSession = null;
  }

  @override
  Future<AuthSessionModel?> readSession() async => initialSession ?? savedSession;

  @override
  Future<void> saveSession(AuthSessionModel session) async {
    savedSession = session;
  }
}
