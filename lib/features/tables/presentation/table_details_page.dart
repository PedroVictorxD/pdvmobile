import 'package:flutter/material.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_dashboard_entry.dart';
import 'package:pdvmobile/features/tables/presentation/table_session_page.dart';

class TableDetailsPage extends StatelessWidget {
  const TableDetailsPage({super.key, required this.store, required this.entry});

  final StoreSummary store;
  final TableDashboardEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = entry.session;

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
            Text(
              'Mesa ${entry.table.number}',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: const Color(0xFF172033),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              entry.table.label.isEmpty ? 'Sem label' : entry.table.label,
              style: theme.textTheme.titleLarge?.copyWith(
                color: const Color(0xFF5D6675),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: session == null
                      ? const [Color(0xFF26CFE1), Color(0xFF16B8D0)]
                      : const [Color(0xFFF55D73), Color(0xFFD8455F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2216C8D2),
                    blurRadius: 18,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session == null ? 'Mesa disponivel' : 'Comanda aberta',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      session == null
                          ? 'Pronta para iniciar um novo atendimento.'
                          : _sessionStatusLabel(session.status),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (session != null) ...[
                      const SizedBox(height: 20),
                      _MetricRow(
                        label: 'Total aberto',
                        value: _formatCurrency(session.total),
                      ),
                      const SizedBox(height: 10),
                      _MetricRow(
                        label: 'Pedidos',
                        value: '${session.orderCount} pedidos lancados',
                      ),
                    ] else ...[
                      const SizedBox(height: 20),
                      _MetricRow(
                        label: 'Status da mesa',
                        value: _statusLabel(entry.table.status),
                      ),
                      const SizedBox(height: 10),
                      _MetricRow(
                        label: 'QR da mesa',
                        value: entry.table.qrCodeToken.isEmpty
                            ? 'Nao configurado'
                            : 'Disponivel',
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Proximas acoes',
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF172033),
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            if (session != null) ...[
              _ActionButton(
                label: 'Ver pedidos',
                icon: Icons.receipt_long_rounded,
                onTap: () => _openSession(context),
              ),
              const SizedBox(height: 12),
              _ActionButton(
                label: 'Fechar conta',
                icon: Icons.point_of_sale_rounded,
                onTap: () => _showComingSoon(
                  context,
                  'O fechamento da conta entra na proxima etapa.',
                ),
              ),
            ] else ...[
              _ActionButton(
                label: 'Abrir comanda',
                icon: Icons.add_card_rounded,
                onTap: () => _openSession(context),
              ),
              const SizedBox(height: 12),
              _ActionButton(
                label: 'Escanear QR da mesa',
                icon: Icons.qr_code_scanner_rounded,
                onTap: () => _showComingSoon(
                  context,
                  'A leitura do QR da mesa entra na proxima etapa.',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openSession(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TableSessionPage(store: store, entry: entry),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.88),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFD94E60)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF172033),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF98A1AF)),
            ],
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

String _statusLabel(String status) {
  switch (status) {
    case 'OCCUPIED':
      return 'Ocupada';
    case 'RESERVED':
      return 'Reservada';
    default:
      return 'Disponivel';
  }
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
