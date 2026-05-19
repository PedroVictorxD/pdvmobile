import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/core/network/api_client.dart';
import 'package:pdvmobile/features/tables/data/datasources/table_remote_data_source.dart';

void main() {
  group('HttpTableRemoteDataSource', () {
    test('busca mesas autenticadas da loja', () async {
      final apiClient = _FakeApiClient();
      final dataSource = HttpTableRemoteDataSource(apiClient);

      final tables = await dataSource.listTables(
        storeId: 'store-1',
        accessToken: 'jwt-token',
      );

      expect(apiClient.lastPath, '/stores/store-1/tables');
      expect(apiClient.lastHeaders, {'Authorization': 'Bearer jwt-token'});
      expect(tables, hasLength(2));
      expect(tables.first.number, 1);
      expect(tables.first.status, 'AVAILABLE');
    });

    test('busca sessoes abertas autenticadas da loja', () async {
      final apiClient = _FakeApiClient();
      final dataSource = HttpTableRemoteDataSource(apiClient);

      final sessions = await dataSource.listOpenSessions(
        storeId: 'store-1',
        accessToken: 'jwt-token',
      );

      expect(apiClient.lastPath, '/stores/store-1/tables/sessions');
      expect(apiClient.lastHeaders, {'Authorization': 'Bearer jwt-token'});
      expect(sessions, hasLength(1));
      expect(sessions.first.tableNumber, 2);
      expect(sessions.first.orderCount, 2);
      expect(sessions.first.total, 58);
    });

    test('tolera ids e numeros serializados como texto', () async {
      final apiClient = _FakeApiClient(useStringPayload: true);
      final dataSource = HttpTableRemoteDataSource(apiClient);

      final tables = await dataSource.listTables(
        storeId: 'store-1',
        accessToken: 'jwt-token',
      );
      final sessions = await dataSource.listOpenSessions(
        storeId: 'store-1',
        accessToken: 'jwt-token',
      );

      expect(tables.first.id, '10');
      expect(tables.first.number, 7);
      expect(sessions.first.id, '20');
      expect(sessions.first.tableNumber, 7);
      expect(sessions.first.total, 105.5);
    });
  });
}

final class _FakeApiClient implements ApiClient {
  _FakeApiClient({this.useStringPayload = false});

  String? lastPath;
  Map<String, String>? lastHeaders;
  final bool useStringPayload;

  @override
  Future<Object?> get(String path, {Map<String, String>? headers}) async {
    lastPath = path;
    lastHeaders = headers;

    if (path.endsWith('/sessions')) {
      if (useStringPayload) {
        return const [
          {
            'id': 20,
            'tableNumber': '7',
            'tableLabel': 'Salao principal',
            'status': 'OPEN',
            'total': '105.5',
            'orders': [
              {'id': 'order-1'},
            ],
          },
        ];
      }

      return const [
        {
          'id': 'session-1',
          'tableNumber': 2,
          'tableLabel': 'Salao',
          'status': 'OPEN',
          'total': 58.0,
          'orders': [
            {'id': 'order-1'},
            {'id': 'order-2'},
          ],
        },
      ];
    }

    if (useStringPayload) {
      return const [
        {
          'id': 10,
          'number': '7',
          'label': 'Janela',
          'status': 'AVAILABLE',
          'qrCodeToken': 12345,
        },
      ];
    }

    return const [
      {
        'id': 'table-1',
        'number': 1,
        'label': 'Varanda',
        'status': 'AVAILABLE',
        'qrCodeToken': 'qr-1',
      },
      {
        'id': 'table-2',
        'number': 2,
        'label': 'Salao',
        'status': 'OCCUPIED',
        'qrCodeToken': 'qr-2',
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
