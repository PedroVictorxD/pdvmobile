enum TableSessionLineItemStatus { pending, preparing, delivered }

class TableSessionLineItem {
  const TableSessionLineItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.note = '',
    this.status = TableSessionLineItemStatus.pending,
  });

  final String name;
  final int quantity;
  final double unitPrice;
  final String note;
  final TableSessionLineItemStatus status;

  double get totalPrice => unitPrice * quantity;
}
