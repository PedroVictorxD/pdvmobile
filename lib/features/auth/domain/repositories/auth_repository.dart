import 'package:pdvmobile/features/auth/domain/entities/auth_session.dart';

abstract interface class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<AuthSession?> restoreSession();
}
