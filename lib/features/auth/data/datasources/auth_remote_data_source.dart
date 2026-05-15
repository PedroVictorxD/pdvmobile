import 'package:pdvmobile/core/network/api_client.dart';
import 'package:pdvmobile/features/auth/data/models/auth_session_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  });
}

class HttpAuthRemoteDataSource implements AuthRemoteDataSource {
  const HttpAuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<AuthSessionModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    if (response is! Map<String, dynamic>) {
      throw const FormatException('Resposta invalida para login');
    }

    return AuthSessionModel.fromLoginJson(response);
  }
}
