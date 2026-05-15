import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/core/network/api_client.dart';
import 'package:pdvmobile/features/stores/data/datasources/store_remote_data_source.dart';

void main() {
  group('HttpStoreRemoteDataSource', () {
    test('busca lojas autenticadas com bearer token', () async {
      final apiClient = _FakeApiClient();
      final dataSource = HttpStoreRemoteDataSource(apiClient);

      final stores = await dataSource.listStores(
        accessToken: 'jwt-token',
      );

      expect(apiClient.lastPath, '/stores');
      expect(
        apiClient.lastHeaders,
        {'Authorization': 'Bearer jwt-token'},
      );
      expect(stores, hasLength(2));
      expect(stores.first.name, 'Loja Centro');
    });
  });
}

final class _FakeApiClient implements ApiClient {
  String? lastPath;
  Map<String, String>? lastHeaders;

  @override
  Future<Object?> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    lastPath = path;
    lastHeaders = headers;

    return const [
      {
        'id': 'store-1',
        'name': 'Loja Centro',
        'slug': 'loja-centro',
        'open': true,
        'tableMode': 'TAB',
        'acceptedPayments': ['PIX', 'CASH'],
      },
      {
        'id': 'store-2',
        'name': 'Loja Praia',
        'slug': 'loja-praia',
        'open': true,
        'tableMode': 'INSTANT',
        'acceptedPayments': ['PIX'],
      },
    ];
  }

  @override
  Future<Object?> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) {
    throw UnimplementedError();
  }
}
