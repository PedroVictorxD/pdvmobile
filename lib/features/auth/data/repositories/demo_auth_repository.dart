import 'package:pdvmobile/features/auth/domain/entities/auth_session.dart';
import 'package:pdvmobile/features/auth/domain/repositories/auth_repository.dart';

class DemoAuthRepository implements AuthRepository {
  AuthSession? _session;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    final userName = trimmedEmail.split('@').first;

    _session = AuthSession(
      accessToken: 'demo-token',
      userName: _capitalize(userName),
      userEmail: trimmedEmail,
    );

    return _session!;
  }

  @override
  Future<AuthSession?> restoreSession() async => _session;

  String _capitalize(String value) {
    if (value.isEmpty) {
      return 'Operador';
    }

    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
