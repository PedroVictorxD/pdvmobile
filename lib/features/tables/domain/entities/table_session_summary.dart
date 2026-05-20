import 'package:pdvmobile/features/tables/domain/entities/table_session_line_item.dart';

class TableSessionSummary {
  const TableSessionSummary({
    required this.id,
    required this.tableNumber,
    required this.tableLabel,
    required this.status,
    required this.total,
    required this.orderCount,
    this.items = const [],
  });

  final String id;
  final int tableNumber;
  final String tableLabel;
  final String status;
  final double total;
  final int orderCount;
  final List<TableSessionLineItem> items;
}
