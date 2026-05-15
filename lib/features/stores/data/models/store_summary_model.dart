import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';

class StoreSummaryModel extends StoreSummary {
  const StoreSummaryModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.isOpen,
    required super.tableMode,
    required super.acceptedPayments,
  });

  factory StoreSummaryModel.fromJson(Map<String, dynamic> json) {
    final acceptedPaymentsRaw = json['acceptedPayments'];
    final acceptedPayments = acceptedPaymentsRaw is List
        ? acceptedPaymentsRaw.map((item) => item.toString()).toList()
        : <String>[];

    return StoreSummaryModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      isOpen: json['open'] as bool? ?? false,
      tableMode: json['tableMode'] as String? ?? 'DISABLED',
      acceptedPayments: acceptedPayments,
    );
  }
}
