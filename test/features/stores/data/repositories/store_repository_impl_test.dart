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
  });
}

final class _FakeStoreRemoteDataSource implements StoreRemoteDataSource {
  @override
  Future<List<StoreSummaryModel>> listStores({
    required String accessToken,
  }) async {
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
  @override
  Future<void> clearSession() async {}

  @override
  Future<AuthSessionModel?> readSession() async {
    return const AuthSessionModel(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      userName: 'Merchant',
      userEmail: 'merchant@test.com',
      role: 'MERCHANT',
    );
  }

  @override
  Future<void> saveSession(AuthSessionModel session) async {}
}
