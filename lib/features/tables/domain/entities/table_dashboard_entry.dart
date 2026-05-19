import 'package:pdvmobile/features/tables/domain/entities/store_table.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_session_summary.dart';

class TableDashboardEntry {
  const TableDashboardEntry({
    required this.table,
    required this.session,
  });

  final StoreTable table;
  final TableSessionSummary? session;

  bool get hasActiveSession => session != null;
}
