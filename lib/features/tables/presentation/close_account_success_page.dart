import 'package:flutter/material.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_dashboard_entry.dart';

class CloseAccountSuccessPage extends StatelessWidget {
  const CloseAccountSuccessPage({
    super.key,
    required this.store,
    required this.entry,
    required this.paymentMethod,
  });

  final StoreSummary store;
  final TableDashboardEntry entry;
  final String paymentMethod;

  @override
  Widget build(BuildContext context) {
    final session = entry.session;
    final total = session?.total ?? 0;

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
              'Conta fechada',
              style: TextStyle(
                color: Color(0xFF172033),
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 18),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF26CFE1), Color(0xFF16B8D0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2216C8D2),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mesa ${entry.table.number}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatCurrency(total),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pagamento confirmado em ${_formatPaymentLabel(paymentMethod)}.',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryRow(
                      label: 'Forma de pagamento',
                      value: _formatPaymentLabel(paymentMethod),
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      label: 'Pedidos encerrados',
                      value: '${session?.orderCount ?? 0}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              icon: const Icon(Icons.table_restaurant_rounded),
              label: const Text('Voltar para mesas'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

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

String _formatPaymentLabel(String payment) {
  switch (payment) {
    case 'PIX':
      return 'Pix';
    case 'CASH':
      return 'Dinheiro';
    default:
      return payment;
  }
}
