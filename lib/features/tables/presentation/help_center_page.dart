import 'package:flutter/material.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/closed_table_session_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_dashboard_entry.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({
    super.key,
    required this.store,
    required this.operatorName,
    required this.entries,
    required this.closedSessions,
  });

  final StoreSummary store;
  final String operatorName;
  final List<TableDashboardEntry> entries;
  final List<ClosedTableSessionSummary> closedSessions;

  @override
  Widget build(BuildContext context) {
    final openSessions = entries.where((entry) => entry.session != null).length;
    final pendingOrders = entries.fold<int>(
      0,
      (sum, entry) => sum + (entry.session?.orderCount ?? 0),
    );
    final pendingPix = entries
        .where((entry) => entry.session?.status == 'CLOSE_REQUESTED')
        .length;

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
              'Ajuda',
              style: TextStyle(
                color: Color(0xFF172033),
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              operatorName,
              style: const TextStyle(
                color: Color(0xFF657285),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF16C8D2), Color(0xFF2EE3D7)],
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
                    const Text(
                      'Resumo operacional',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _HelpMetric(
                            label: 'Comandas',
                            value: openSessions.toString(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _HelpMetric(
                            label: 'Fechadas',
                            value: closedSessions.length.toString(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Atalhos',
              style: TextStyle(
                color: Color(0xFF172033),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            _HelpActionCard(
              label: 'Chamar gerente',
              description: 'Aciona suporte da operacao para esta loja.',
              icon: Icons.support_agent_rounded,
              onTap: () => _showComingSoon(
                context,
                'O chamado do gerente entra na proxima etapa.',
              ),
            ),
            const SizedBox(height: 12),
            _HelpActionCard(
              label: 'Recarregar mesas',
              description:
                  'Atualiza o painel principal e os status das comandas.',
              icon: Icons.refresh_rounded,
              onTap: () => _showComingSoon(
                context,
                'A recarga remota do painel entra na proxima etapa.',
              ),
            ),
            const SizedBox(height: 12),
            _HelpActionCard(
              label: 'Pedidos pendentes',
              description: '$pendingOrders itens aguardando acompanhamento.',
              icon: Icons.receipt_long_rounded,
              onTap: () => _showComingSoon(
                context,
                'O atalho detalhado de pedidos entra na proxima etapa.',
              ),
            ),
            const SizedBox(height: 12),
            _HelpActionCard(
              label: 'Pagamentos Pix',
              description: '$pendingPix contas aguardando conferencia.',
              icon: Icons.attach_money_rounded,
              onTap: () => _showComingSoon(
                context,
                'O atalho detalhado de Pix entra na proxima etapa.',
              ),
            ),
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

class _HelpMetric extends StatelessWidget {
  const _HelpMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpActionCard extends StatelessWidget {
  const _HelpActionCard({
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
