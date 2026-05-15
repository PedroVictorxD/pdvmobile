import 'package:flutter/widgets.dart';
import 'package:pdvmobile/app/app.dart';
import 'package:pdvmobile/core/env/app_config.dart';
import 'package:pdvmobile/core/network/api_client.dart';
import 'package:pdvmobile/core/network/key_value_store.dart';
import 'package:pdvmobile/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:pdvmobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:pdvmobile/features/auth/data/repositories/auth_repository_impl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  final apiClient = DioApiClient(baseUrl: config.apiBaseUrl);
  final keyValueStore = FlutterSecureKeyValueStore();
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: HttpAuthRemoteDataSource(apiClient),
    localDataSource: SecureStorageAuthLocalDataSource(keyValueStore),
  );

  runApp(
    PdvMobileApp(
      config: config,
      authRepository: authRepository,
    ),
  );
}
