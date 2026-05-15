import 'package:flutter/widgets.dart';
import 'package:pdvmobile/app/app.dart';
import 'package:pdvmobile/core/env/app_config.dart';
import 'package:pdvmobile/core/network/api_client.dart';
import 'package:pdvmobile/core/network/key_value_store.dart';
import 'package:pdvmobile/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:pdvmobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:pdvmobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pdvmobile/features/stores/data/datasources/store_local_data_source.dart';
import 'package:pdvmobile/features/stores/data/datasources/store_remote_data_source.dart';
import 'package:pdvmobile/features/stores/data/repositories/store_repository_impl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  final apiClient = DioApiClient(baseUrl: config.apiBaseUrl);
  final keyValueStore = FlutterSecureKeyValueStore();
  final authLocalDataSource = SecureStorageAuthLocalDataSource(keyValueStore);
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: HttpAuthRemoteDataSource(apiClient),
    localDataSource: authLocalDataSource,
  );
  final storeRepository = StoreRepositoryImpl(
    remoteDataSource: HttpStoreRemoteDataSource(apiClient),
    localDataSource: KeyValueStoreLocalDataSource(keyValueStore),
    authLocalDataSource: authLocalDataSource,
  );

  runApp(
    PdvMobileApp(
      config: config,
      authRepository: authRepository,
      storeRepository: storeRepository,
    ),
  );
}
