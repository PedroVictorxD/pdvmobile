import 'package:pdvmobile/features/tables/domain/entities/table_session_summary.dart';

class TableSessionSummaryModel extends TableSessionSummary {
  const TableSessionSummaryModel({
    required super.id,
    required super.tableNumber,
    required super.tableLabel,
    required super.status,
    required super.total,
    required super.orderCount,
  });

  factory TableSessionSummaryModel.fromJson(Map<String, dynamic> json) {
    final orders = json['orders'];
    return TableSessionSummaryModel(
      id: json['id']?.toString() ?? '',
      tableNumber: _parseInt(json['tableNumber']),
      tableLabel: json['tableLabel']?.toString() ?? '',
      status: json['status']?.toString() ?? 'OPEN',
      total: _parseDouble(json['total']),
      orderCount: orders is List ? orders.length : 0,
    );
  }

  static int _parseInt(Object? value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  static double _parseDouble(Object? value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0;
    }
    return 0;
  }
}
