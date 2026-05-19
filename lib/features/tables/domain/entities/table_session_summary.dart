class TableSessionSummary {
  const TableSessionSummary({
    required this.id,
    required this.tableNumber,
    required this.tableLabel,
    required this.status,
    required this.total,
    required this.orderCount,
  });

  final String id;
  final int tableNumber;
  final String tableLabel;
  final String status;
  final double total;
  final int orderCount;
}
