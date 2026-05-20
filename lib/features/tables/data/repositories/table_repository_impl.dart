import 'package:pdvmobile/core/error/app_exception.dart';
import 'package:pdvmobile/core/demo/development_demo_data.dart';
import 'package:pdvmobile/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:pdvmobile/features/tables/data/datasources/table_remote_data_source.dart';
import 'package:pdvmobile/features/tables/domain/entities/closed_table_session_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/store_table.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_session_summary.dart';
import 'package:pdvmobile/features/tables/domain/repositories/table_repository.dart';

class TableRepositoryImpl implements TableRepository {
  TableRepositoryImpl({
    required TableRemoteDataSource remoteDataSource,
    required AuthLocalDataSource authLocalDataSource,
    DevelopmentDemoData? developmentDemoData,
  }) : _remoteDataSource = remoteDataSource,
       _authLocalDataSource = authLocalDataSource,
       _developmentDemoData = developmentDemoData ?? DevelopmentDemoData();

  final TableRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _authLocalDataSource;
  final DevelopmentDemoData _developmentDemoData;

  @override
  Future<List<ClosedTableSessionSummary>> listClosedSessions(
    String storeId,
  ) async {
    final session = await _authLocalDataSource.readSession();
    if (session == null || session.accessToken.isEmpty) {
      throw const AppException('Autenticacao necessaria');
    }

    if (DevelopmentDemoData.matchesAccessToken(session.accessToken)) {
      return _developmentDemoData.listClosedSessions(storeId);
    }

    return _remoteDataSource.listClosedSessions(
      storeId: storeId,
      accessToken: session.accessToken,
    );
  }

  @override
  Future<List<TableSessionSummary>> listOpenSessions(String storeId) async {
    final session = await _authLocalDataSource.readSession();
    if (session == null || session.accessToken.isEmpty) {
      throw const AppException('Autenticacao necessaria');
    }

    if (DevelopmentDemoData.matchesAccessToken(session.accessToken)) {
      return _developmentDemoData.listOpenSessions(storeId);
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

    if (DevelopmentDemoData.matchesAccessToken(session.accessToken)) {
      return _developmentDemoData.listTables(storeId);
    }

    return _remoteDataSource.listTables(
      storeId: storeId,
      accessToken: session.accessToken,
    );
  }

  @override
  Future<void> reopenClosedSession({
    required String storeId,
    required String sessionId,
  }) async {
    final session = await _authLocalDataSource.readSession();
    if (session == null || session.accessToken.isEmpty) {
      throw const AppException('Autenticacao necessaria');
    }

    if (DevelopmentDemoData.matchesAccessToken(session.accessToken)) {
      _developmentDemoData.reopenClosedSession(
        storeId: storeId,
        sessionId: sessionId,
      );
      return;
    }

    await _remoteDataSource.reopenClosedSession(
      storeId: storeId,
      sessionId: sessionId,
      accessToken: session.accessToken,
    );
  }
}
