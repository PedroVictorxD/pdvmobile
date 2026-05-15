import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/core/network/api_client.dart';
import 'package:pdvmobile/features/auth/data/datasources/auth_remote_data_source.dart';

void main() {
  group('HttpAuthRemoteDataSource', () {
    test('envia login para o endpoint real da VPS', () async {
      final apiClient = _FakeApiClient();
      final dataSource = HttpAuthRemoteDataSource(apiClient);

      final session = await dataSource.login(
        email: 'merchant@test.com',
        password: '123456',
      );

      expect(apiClient.lastPath, '/auth/login');
      expect(apiClient.lastData, {
        'email': 'merchant@test.com',
        'password': '123456',
      });
      expect(session.accessToken, 'access-token');
      expect(session.refreshToken, 'refresh-token');
    });
  });
}

final class _FakeApiClient implements ApiClient {
  String? lastPath;
  Map<String, dynamic>? lastData;

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    lastPath = path;
    lastData = data;

    return const {
      'token': 'access-token',
      'refreshToken': 'refresh-token',
      'name': 'Merchant',
      'email': 'merchant@test.com',
      'role': 'MERCHANT',
    };
  }
}
