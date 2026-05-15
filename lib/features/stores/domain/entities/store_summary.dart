class StoreSummary {
  const StoreSummary({
    required this.id,
    required this.name,
    required this.slug,
    required this.isOpen,
    required this.tableMode,
    required this.acceptedPayments,
  });

  final String id;
  final String name;
  final String slug;
  final bool isOpen;
  final String tableMode;
  final List<String> acceptedPayments;
}
