import 'package:pdvmobile/core/network/api_client.dart';
import 'package:pdvmobile/features/tables/data/models/closed_table_session_summary_model.dart';
import 'package:pdvmobile/features/tables/data/models/store_table_model.dart';
import 'package:pdvmobile/features/tables/data/models/table_session_summary_model.dart';

abstract interface class TableRemoteDataSource {
  Future<List<ClosedTableSessionSummaryModel>> listClosedSessions({
    required String storeId,
    required String accessToken,
  });

  Future<List<StoreTableModel>> listTables({
    required String storeId,
    required String accessToken,
  });

  Future<List<TableSessionSummaryModel>> listOpenSessions({
    required String storeId,
    required String accessToken,
  });

  Future<void> reopenClosedSession({
    required String storeId,
    required String sessionId,
    required String accessToken,
  });
}

class HttpTableRemoteDataSource implements TableRemoteDataSource {
  const HttpTableRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<ClosedTableSessionSummaryModel>> listClosedSessions({
    required String storeId,
    required String accessToken,
  }) async {
    final response = await _apiClient.get(
      '/stores/$storeId/tables/sessions/closed',
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response is! List) {
      throw const FormatException(
        'Resposta invalida para historico de mesas fechadas',
      );
    }

    return response
        .whereType<Map<String, dynamic>>()
        .map(ClosedTableSessionSummaryModel.fromJson)
        .toList();
  }

  @override
  Future<List<TableSessionSummaryModel>> listOpenSessions({
    required String storeId,
    required String accessToken,
  }) async {
    final response = await _apiClient.get(
      '/stores/$storeId/tables/sessions',
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response is! List) {
      throw const FormatException('Resposta invalida para sessoes de mesas');
    }

    return response
        .whereType<Map<String, dynamic>>()
        .map(TableSessionSummaryModel.fromJson)
        .toList();
  }

  @override
  Future<List<StoreTableModel>> listTables({
    required String storeId,
    required String accessToken,
  }) async {
    final response = await _apiClient.get(
      '/stores/$storeId/tables',
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response is! List) {
      throw const FormatException('Resposta invalida para mesas');
    }

    return response
        .whereType<Map<String, dynamic>>()
        .map(StoreTableModel.fromJson)
        .toList();
  }

  @override
  Future<void> reopenClosedSession({
    required String storeId,
    required String sessionId,
    required String accessToken,
  }) async {
    await _apiClient.post(
      '/stores/$storeId/tables/sessions/$sessionId/reopen',
      headers: {'Authorization': 'Bearer $accessToken'},
    );
  }
}
