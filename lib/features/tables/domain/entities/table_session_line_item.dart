class TableSessionLineItem {
  const TableSessionLineItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.note = '',
  });

  final String name;
  final int quantity;
  final double unitPrice;
  final String note;

  double get totalPrice => unitPrice * quantity;
}
