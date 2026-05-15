import 'package:pdvmobile/core/error/app_exception.dart';
import 'package:pdvmobile/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:pdvmobile/features/stores/data/datasources/store_local_data_source.dart';
import 'package:pdvmobile/features/stores/data/datasources/store_remote_data_source.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/stores/domain/repositories/store_repository.dart';

class StoreRepositoryImpl implements StoreRepository {
  StoreRepositoryImpl({
    required StoreRemoteDataSource remoteDataSource,
    required StoreLocalDataSource localDataSource,
    required AuthLocalDataSource authLocalDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _authLocalDataSource = authLocalDataSource;

  final StoreRemoteDataSource _remoteDataSource;
  final StoreLocalDataSource _localDataSource;
  final AuthLocalDataSource _authLocalDataSource;

  @override
  Future<List<StoreSummary>> listStores() async {
    final session = await _authLocalDataSource.readSession();
    if (session == null || session.accessToken.isEmpty) {
      throw const AppException('Autenticacao necessaria');
    }

    return _remoteDataSource.listStores(accessToken: session.accessToken);
  }

  @override
  Future<String?> readSelectedStoreId() {
    return _localDataSource.readSelectedStoreId();
  }

  @override
  Future<void> saveSelectedStoreId(String storeId) {
    return _localDataSource.saveSelectedStoreId(storeId);
  }
}
