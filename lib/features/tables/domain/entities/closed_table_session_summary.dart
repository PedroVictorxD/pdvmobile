class ClosedTableSessionSummary {
  const ClosedTableSessionSummary({
    required this.id,
    required this.tableNumber,
    required this.tableLabel,
    required this.ticketNumber,
    required this.total,
    required this.paid,
    required this.closedAt,
    required this.status,
  });

  final String id;
  final int tableNumber;
  final String tableLabel;
  final String ticketNumber;
  final double total;
  final double paid;
  final String closedAt;
  final String status;
}
