import 'package:pdvmobile/core/error/app_exception.dart';
import 'package:pdvmobile/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:pdvmobile/features/tables/data/datasources/table_remote_data_source.dart';
import 'package:pdvmobile/features/tables/domain/entities/store_table.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_session_summary.dart';
import 'package:pdvmobile/features/tables/domain/repositories/table_repository.dart';

class TableRepositoryImpl implements TableRepository {
  TableRepositoryImpl({
    required TableRemoteDataSource remoteDataSource,
    required AuthLocalDataSource authLocalDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _authLocalDataSource = authLocalDataSource;

  final TableRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _authLocalDataSource;

  @override
  Future<List<TableSessionSummary>> listOpenSessions(String storeId) async {
    final session = await _authLocalDataSource.readSession();
    if (session == null || session.accessToken.isEmpty) {
      throw const AppException('Autenticacao necessaria');
    }

    return _remoteDataSource.listOpenSessions(
      storeId: storeId,
      accessToken: session.accessToken,
    );
  }

  @override
  Future<List<StoreTable>> listTables(String storeId) async {
    final session = await _authLocalDataSource.readSession();
    if (session == null || session.accessToken.isEmpty) {
      throw const AppException('Autenticacao necessaria');
    }

    return _remoteDataSource.listTables(
      storeId: storeId,
      accessToken: session.accessToken,
    );
  }
}
