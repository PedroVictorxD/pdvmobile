import 'package:flutter/material.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_dashboard_entry.dart';

class CloseAccountPage extends StatefulWidget {
  const CloseAccountPage({super.key, required this.store, required this.entry});

  final StoreSummary store;
  final TableDashboardEntry entry;

  @override
  State<CloseAccountPage> createState() => _CloseAccountPageState();
}

class _CloseAccountPageState extends State<CloseAccountPage> {
  late String _selectedPayment;

  @override
  void initState() {
    super.initState();
    _selectedPayment = widget.store.acceptedPayments.firstOrNull ?? 'PIX';
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.entry.session;
    final total = session?.total ?? 0;
    final tableLabel = widget.entry.table.label.isEmpty
        ? 'Sem label'
        : widget.entry.table.label;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: Text(widget.store.name),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            const Text(
              'Fechar conta',
              style: TextStyle(
                color: Color(0xFF172033),
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mesa ${widget.entry.table.number}',
              style: const TextStyle(
                color: Color(0xFF657285),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF55D73), Color(0xFFD8455F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22D8455F),
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
                      tableLabel,
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
                    const SizedBox(height: 6),
                    Text(
                      '${session?.orderCount ?? 0} pedidos para conferir no fechamento.',
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
                    const Text(
                      'Pagamento',
                      style: TextStyle(
                        color: Color(0xFF172033),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: widget.store.acceptedPayments
                          .map(
                            (payment) => ChoiceChip(
                              label: Text(payment),
                              selected: _selectedPayment == payment,
                              onSelected: (_) {
                                setState(() {
                                  _selectedPayment = payment;
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 18),
                    _SummaryRow(
                      label: 'Forma escolhida',
                      value: _formatPaymentLabel(_selectedPayment),
                    ),
                    const SizedBox(height: 10),
                    _SummaryRow(
                      label: 'Pedidos lancados',
                      value: '${session?.orderCount ?? 0}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => _confirmClose(context),
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('Confirmar fechamento'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClose(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'O fechamento via $_selectedPayment entra na proxima etapa.',
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
