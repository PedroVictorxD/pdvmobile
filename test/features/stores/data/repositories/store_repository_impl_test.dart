import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:pdvmobile/features/auth/data/models/auth_session_model.dart';
import 'package:pdvmobile/features/stores/data/datasources/store_local_data_source.dart';
import 'package:pdvmobile/features/stores/data/datasources/store_remote_data_source.dart';
import 'package:pdvmobile/features/stores/data/models/store_summary_model.dart';
import 'package:pdvmobile/features/stores/data/repositories/store_repository_impl.dart';

void main() {
  group('StoreRepositoryImpl', () {
    test('lista lojas usando o token salvo na sessao local', () async {
      final repository = StoreRepositoryImpl(
        remoteDataSource: _FakeStoreRemoteDataSource(),
        localDataSource: _FakeStoreLocalDataSource(),
        authLocalDataSource: _FakeAuthLocalDataSource(),
      );

      final stores = await repository.listStores();

      expect(stores, hasLength(1));
      expect(stores.first.id, 'store-1');
    });

    test('persiste e restaura a loja ativa', () async {
      final local = _FakeStoreLocalDataSource();
      final repository = StoreRepositoryImpl(
        remoteDataSource: _FakeStoreRemoteDataSource(),
        localDataSource: local,
        authLocalDataSource: _FakeAuthLocalDataSource(),
      );

      await repository.saveSelectedStoreId('store-1');
      final selectedId = await repository.readSelectedStoreId();

      expect(local.savedStoreId, 'store-1');
      expect(selectedId, 'store-1');
    });

    test(
      'retorna lojas demo quando a sessao usa token local de desenvolvimento',
      () async {
        final remote = _FakeStoreRemoteDataSource();
        final repository = StoreRepositoryImpl(
          remoteDataSource: remote,
          localDataSource: _FakeStoreLocalDataSource(),
          authLocalDataSource: _FakeAuthLocalDataSource.dev(),
        );

        final stores = await repository.listStores();

        expect(stores, isNotEmpty);
        expect(stores.first.name, 'Loja Demo Centro');
        expect(remote.callCount, 0);
      },
    );
  });
}

final class _FakeStoreRemoteDataSource implements StoreRemoteDataSource {
  int callCount = 0;

  @override
  Future<List<StoreSummaryModel>> listStores({
    required String accessToken,
  }) async {
    callCount += 1;
    return const [
      StoreSummaryModel(
        id: 'store-1',
        name: 'Loja Centro',
        slug: 'loja-centro',
        isOpen: true,
        tableMode: 'TAB',
        acceptedPayments: ['PIX', 'CASH'],
      ),
    ];
  }
}

final class _FakeStoreLocalDataSource implements StoreLocalDataSource {
  String? savedStoreId;

  @override
  Future<String?> readSelectedStoreId() async => savedStoreId;

  @override
  Future<void> saveSelectedStoreId(String storeId) async {
    savedStoreId = storeId;
  }
}

final class _FakeAuthLocalDataSource implements AuthLocalDataSource {
  _FakeAuthLocalDataSource() : _session = _defaultSession;

  _FakeAuthLocalDataSource.dev() : _session = _developmentSession;

  final AuthSessionModel _session;

  @override
  Future<void> clearSession() async {}

  @override
  Future<AuthSessionModel?> readSession() async => _session;

  @override
  Future<void> saveSession(AuthSessionModel session) async {}
}

const _defaultSession = AuthSessionModel(
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
  userName: 'Merchant',
  userEmail: 'merchant@test.com',
  role: 'MERCHANT',
);

const _developmentSession = AuthSessionModel(
  accessToken: 'dev-garcom-token',
  refreshToken: 'dev-garcom-refresh',
  userName: 'Garcom Teste',
  userEmail: 'garcon@teste.com',
  role: 'MERCHANT',
);
