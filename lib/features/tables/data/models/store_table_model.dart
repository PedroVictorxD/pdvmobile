import 'package:pdvmobile/features/tables/domain/entities/store_table.dart';

class StoreTableModel extends StoreTable {
  const StoreTableModel({
    required super.id,
    required super.number,
    required super.label,
    required super.status,
    required super.qrCodeToken,
  });

  factory StoreTableModel.fromJson(Map<String, dynamic> json) {
    return StoreTableModel(
      id: json['id']?.toString() ?? '',
      number: _parseInt(json['number']),
      label: json['label']?.toString() ?? '',
      status: json['status']?.toString() ?? 'AVAILABLE',
      qrCodeToken: json['qrCodeToken']?.toString() ?? '',
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
}
