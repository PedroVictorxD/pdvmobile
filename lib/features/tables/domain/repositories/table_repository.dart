import 'package:pdvmobile/features/tables/domain/entities/store_table.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_session_summary.dart';

abstract interface class TableRepository {
  Future<List<StoreTable>> listTables(String storeId);

  Future<List<TableSessionSummary>> listOpenSessions(String storeId);
}
