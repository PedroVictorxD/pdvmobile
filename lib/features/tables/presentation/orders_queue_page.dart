import 'package:flutter/material.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_dashboard_entry.dart';

class OrdersQueuePage extends StatelessWidget {
  const OrdersQueuePage({
    super.key,
    required this.store,
    required this.entries,
  });

  final StoreSummary store;
  final List<TableDashboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    final sessions = entries.where((entry) => entry.session != null).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text(store.name),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            const Text(
              'Pedidos',
              style: TextStyle(
                color: Color(0xFF172033),
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            const _OrdersSectionHeader(),
            const SizedBox(height: 18),
            if (sessions.isEmpty)
              const _OrdersEmptyState()
            else
              ...sessions.map((entry) => _OrderSessionCard(entry: entry)),
          ],
        ),
      ),
    );
  }
}

class _OrdersSectionHeader extends StatelessWidget {
  const _OrdersSectionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Pendentes',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFD94E60),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFEFF3F8),
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Entregues',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF657285),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderSessionCard extends StatelessWidget {
  const _OrderSessionCard({required this.entry});

  final TableDashboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final session = entry.session!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6FAFB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Color(0xFF16B8D0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mesa ${entry.table.number}',
                      style: const TextStyle(
                        color: Color(0xFF172033),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.table.label,
                      style: const TextStyle(
                        color: Color(0xFF657285),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${session.orderCount} itens',
                      style: const TextStyle(
                        color: Color(0xFF172033),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(session.total),
                    style: const TextStyle(
                      color: Color(0xFFD94E60),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _sessionStatusLabel(session.status),
                    style: const TextStyle(
                      color: Color(0xFF657285),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrdersEmptyState extends StatelessWidget {
  const _OrdersEmptyState();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Nenhuma comanda aberta para acompanhamento no momento.',
          style: TextStyle(
            color: Color(0xFF657285),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

String _formatCurrency(double value) {
  final formatted = value.toStringAsFixed(2).replaceAll('.', ',');
  return 'R\$ $formatted';
}

String _sessionStatusLabel(String status) {
  switch (status) {
    case 'CLOSE_REQUESTED':
      return 'Fechamento solicitado';
    case 'CLOSED':
      return 'Fechada';
    default:
      return 'Aberta';
  }
}
