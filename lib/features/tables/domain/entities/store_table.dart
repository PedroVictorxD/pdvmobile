class StoreTable {
  const StoreTable({
    required this.id,
    required this.number,
    required this.label,
    required this.status,
    required this.qrCodeToken,
  });

  final String id;
  final int number;
  final String label;
  final String status;
  final String qrCodeToken;
}
