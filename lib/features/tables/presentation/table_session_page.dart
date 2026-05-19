import 'package:flutter/material.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_dashboard_entry.dart';

class TableSessionPage extends StatelessWidget {
  const TableSessionPage({super.key, required this.store, required this.entry});

  final StoreSummary store;
  final TableDashboardEntry entry;

  @override
  Widget build(BuildContext context) {
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
              session == null ? 'Nova comanda' : 'Comanda da mesa',
              style: const TextStyle(
                color: Color(0xFF172033),
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Mesa ${entry.table.number}',
              style: const TextStyle(
                color: Color(0xFF657285),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 18),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: session == null
                      ? const [Color(0xFF26CFE1), Color(0xFF16B8D0)]
                      : const [Color(0xFFF55D73), Color(0xFFD8455F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x2216C8D2),
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
                    Text(
                      entry.table.label.isEmpty
                          ? 'Sem label'
                          : entry.table.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (session != null) ...[
                      Text(
                        _formatCurrency(session.total),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${session.orderCount} pedidos',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Pronta para iniciar atendimento e vincular pedidos.',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            if (session != null) ...[
              _SessionActionCard(
                label: 'Adicionar item',
                description: 'Lancamento rapido no pedido da mesa.',
                icon: Icons.add_shopping_cart_rounded,
                onTap: () => _showComingSoon(
                  context,
                  'A inclusao de itens entra na proxima etapa.',
                ),
              ),
              const SizedBox(height: 12),
              _SessionActionCard(
                label: 'Fechar conta',
                description: 'Encaminha o atendimento para fechamento.',
                icon: Icons.point_of_sale_rounded,
                onTap: () => _showComingSoon(
                  context,
                  'O fechamento da conta entra na proxima etapa.',
                ),
              ),
            ] else ...[
              _SessionActionCard(
                label: 'Abrir atendimento',
                description: 'Inicia a comanda e libera o fluxo de pedidos.',
                icon: Icons.play_circle_fill_rounded,
                onTap: () => _showComingSoon(
                  context,
                  'A abertura efetiva da comanda entra na proxima etapa.',
                ),
              ),
              const SizedBox(height: 12),
              _SessionActionCard(
                label: 'Escanear QR da mesa',
                description: 'Valida identificacao fisica da mesa.',
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
}

class _SessionActionCard extends StatelessWidget {
  const _SessionActionCard({
    required this.label,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
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
                child: Icon(icon, color: const Color(0xFF16B8D0)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Color(0xFF172033),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF657285),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
