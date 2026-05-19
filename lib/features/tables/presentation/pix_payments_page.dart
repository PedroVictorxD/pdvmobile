import 'package:flutter/material.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_dashboard_entry.dart';

class PixPaymentsPage extends StatelessWidget {
  const PixPaymentsPage({
    super.key,
    required this.store,
    required this.entries,
  });

  final StoreSummary store;
  final List<TableDashboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    final pixEntries = entries
        .where((entry) => entry.session?.status == 'CLOSE_REQUESTED')
        .toList();

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
              'Pagamentos Pix',
              style: TextStyle(
                color: Color(0xFF172033),
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            if (pixEntries.isEmpty)
              const _PixEmptyState()
            else
              ...pixEntries.map((entry) => _PixPaymentCard(entry: entry)),
          ],
        ),
      ),
    );
  }
}

class _PixPaymentCard extends StatelessWidget {
  const _PixPaymentCard({required this.entry});

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
                      _formatCurrency(session.total),
                      style: const TextStyle(
                        color: Color(0xFFD94E60),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(
                onPressed: () => _showComingSoon(context),
                child: const Text('Checar agora'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('A conciliacao detalhada do Pix entra na proxima etapa.'),
      ),
    );
  }
}

class _PixEmptyState extends StatelessWidget {
  const _PixEmptyState();

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
          'Nenhuma conta com fechamento solicitado para conferencia Pix.',
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
