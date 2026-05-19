import 'package:flutter/material.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/closed_table_session_summary.dart';

class CashierReviewPage extends StatelessWidget {
  const CashierReviewPage({
    super.key,
    required this.store,
    required this.session,
  });

  final StoreSummary store;
  final ClosedTableSessionSummary session;

  @override
  Widget build(BuildContext context) {
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
              'Caixa',
              style: TextStyle(
                color: Color(0xFF172033),
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.tableLabel,
                      style: const TextStyle(
                        color: Color(0xFF172033),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#${session.ticketNumber}',
                      style: const TextStyle(
                        color: Color(0xFF657285),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _CashierMetric(
                      label: 'Total da conta',
                      value: _formatCurrency(session.total),
                    ),
                    const SizedBox(height: 10),
                    _CashierMetric(
                      label: 'Pago',
                      value: _formatCurrency(session.paid),
                    ),
                    const SizedBox(height: 10),
                    _CashierMetric(
                      label: 'Fechado em',
                      value: _formatClosedDate(session.closedAt),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => _showComingSoon(context),
              icon: const Icon(Icons.verified_rounded),
              label: const Text('Conferir pagamento'),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'A conciliacao completa do caixa entra na proxima etapa.',
        ),
      ),
    );
  }
}

class _CashierMetric extends StatelessWidget {
  const _CashierMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF657285),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF172033),
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

String _formatCurrency(double value) {
  final formatted = value.toStringAsFixed(2).replaceAll('.', ',');
  return 'R\$ $formatted';
}

String _formatClosedDate(String rawValue) {
  final date = DateTime.tryParse(rawValue);
  if (date == null) {
    return rawValue;
  }

  final localDate = date.toLocal();
  final day = localDate.day.toString().padLeft(2, '0');
  final month = localDate.month.toString().padLeft(2, '0');
  final year = (localDate.year % 100).toString().padLeft(2, '0');
  final hour = localDate.hour.toString().padLeft(2, '0');
  final minute = localDate.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}
