import 'package:pdvmobile/features/tables/domain/entities/closed_table_session_summary.dart';

class ClosedTableSessionSummaryModel extends ClosedTableSessionSummary {
  const ClosedTableSessionSummaryModel({
    required super.id,
    required super.tableNumber,
    required super.tableLabel,
    required super.ticketNumber,
    required super.total,
    required super.paid,
    required super.closedAt,
    required super.status,
  });

  factory ClosedTableSessionSummaryModel.fromJson(Map<String, dynamic> json) {
    return ClosedTableSessionSummaryModel(
      id: json['id']?.toString() ?? '',
      tableNumber: _parseInt(json['tableNumber']),
      tableLabel: json['tableLabel']?.toString() ?? '',
      ticketNumber: json['ticketNumber']?.toString() ?? '',
      total: _parseDouble(json['total']),
      paid: _parseDouble(json['paid']),
      closedAt: json['closedAt']?.toString() ?? '',
      status: json['status']?.toString() ?? 'CLOSED',
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
