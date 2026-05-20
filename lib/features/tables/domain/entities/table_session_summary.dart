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

  TableSessionSummary copyWith({
    String? id,
    int? tableNumber,
    String? tableLabel,
    String? status,
    double? total,
    int? orderCount,
    List<TableSessionLineItem>? items,
  }) {
    return TableSessionSummary(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      tableLabel: tableLabel ?? this.tableLabel,
      status: status ?? this.status,
      total: total ?? this.total,
      orderCount: orderCount ?? this.orderCount,
      items: items ?? this.items,
    );
  }
}
