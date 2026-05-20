import 'package:pdvmobile/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:pdvmobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:pdvmobile/features/auth/data/models/auth_session_model.dart';
import 'package:pdvmobile/features/auth/domain/entities/auth_session.dart';
import 'package:pdvmobile/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
    this.developmentBypass,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final DevelopmentLoginBypass? developmentBypass;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final bypass = developmentBypass;
    final session =
        bypass != null &&
            email.trim().toLowerCase() == bypass.email.trim().toLowerCase() &&
            password == bypass.password
        ? bypass.session
        : await _remoteDataSource.login(email: email, password: password);
    await _localDataSource.saveSession(session);
    return session;
  }

  @override
  Future<AuthSession?> restoreSession() {
    return _localDataSource.readSession();
  }
}

class DevelopmentLoginBypass {
  const DevelopmentLoginBypass({
    required this.email,
    required this.password,
    required this.session,
  });

  final String email;
  final String password;
  final AuthSessionModel session;
}
