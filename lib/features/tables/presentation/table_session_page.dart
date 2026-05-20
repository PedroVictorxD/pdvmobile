import 'package:flutter/material.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_dashboard_entry.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_session_line_item.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_session_summary.dart';
import 'package:pdvmobile/features/tables/presentation/close_account_page.dart';
import 'package:pdvmobile/features/tables/presentation/open_service_page.dart';
import 'package:pdvmobile/features/tables/presentation/table_menu_page.dart';

class TableSessionPage extends StatefulWidget {
  const TableSessionPage({super.key, required this.store, required this.entry});

  final StoreSummary store;
  final TableDashboardEntry entry;

  @override
  State<TableSessionPage> createState() => _TableSessionPageState();
}

class _TableSessionPageState extends State<TableSessionPage> {
  late TableDashboardEntry _entry;

  @override
  void initState() {
    super.initState();
    _entry = widget.entry;
  }

  @override
  Widget build(BuildContext context) {
    final session = _entry.session;

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
              'Mesa ${_entry.table.number}',
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
                      _entry.table.label.isEmpty
                          ? 'Sem label'
                          : _entry.table.label,
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
                onTap: () => _openMenu(context),
              ),
              const SizedBox(height: 12),
              _SessionActionCard(
                label: 'Fechar conta',
                description: 'Encaminha o atendimento para fechamento.',
                icon: Icons.point_of_sale_rounded,
                onTap: () => _openCloseAccount(context),
              ),
              const SizedBox(height: 18),
              const Text(
                'Itens lancados',
                style: TextStyle(
                  color: Color(0xFF172033),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              if (session.items.isEmpty)
                const _EmptyItemsCard()
              else
                ...session.items.asMap().entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SessionLineItemCard(
                      item: entry.value,
                      onCancel: () => _cancelItem(entry.key),
                    ),
                  ),
                ),
            ] else ...[
              _SessionActionCard(
                label: 'Abrir atendimento',
                description: 'Inicia a comanda e libera o fluxo de pedidos.',
                icon: Icons.play_circle_fill_rounded,
                onTap: () => _openService(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openMenu(BuildContext context) async {
    final updatedEntry = await Navigator.of(context).push<TableDashboardEntry>(
      MaterialPageRoute(
        builder: (context) => TableMenuPage(store: widget.store, entry: _entry),
      ),
    );

    if (!context.mounted || updatedEntry == null) {
      return;
    }

    setState(() {
      _entry = updatedEntry;
    });
  }

  Future<void> _openCloseAccount(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            CloseAccountPage(store: widget.store, entry: _entry),
      ),
    );
  }

  Future<void> _openService(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            OpenServicePage(store: widget.store, entry: _entry),
      ),
    );
  }

  void _cancelItem(int itemIndex) {
    final session = _entry.session;
    if (session == null || itemIndex >= session.items.length) {
      return;
    }

    final currentItem = session.items[itemIndex];
    final items = [...session.items];

    if (currentItem.quantity > 1) {
      items[itemIndex] = TableSessionLineItem(
        name: currentItem.name,
        quantity: currentItem.quantity - 1,
        unitPrice: currentItem.unitPrice,
        note: currentItem.note,
      );
    } else {
      items.removeAt(itemIndex);
    }

    setState(() {
      _entry = TableDashboardEntry(
        table: _entry.table,
        session: TableSessionSummary(
          id: session.id,
          tableNumber: session.tableNumber,
          tableLabel: session.tableLabel,
          status: session.status,
          total: (session.total - currentItem.unitPrice).clamp(
            0,
            double.infinity,
          ),
          orderCount: session.orderCount > 0 ? session.orderCount - 1 : 0,
          items: items,
        ),
      );
    });
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

class _SessionLineItemCard extends StatelessWidget {
  const _SessionLineItemCard({required this.item, required this.onCancel});

  final TableSessionLineItem item;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
                    item.name,
                    style: const TextStyle(
                      color: Color(0xFF172033),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (item.note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      item.note,
                      style: const TextStyle(
                        color: Color(0xFF657285),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    'Qtd ${item.quantity} • ${_formatCurrency(item.totalPrice)}',
                    style: const TextStyle(
                      color: Color(0xFFD94E60),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            TextButton(onPressed: onCancel, child: const Text('Cancelar')),
          ],
        ),
      ),
    );
  }
}

class _EmptyItemsCard extends StatelessWidget {
  const _EmptyItemsCard();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Nenhum item lancado ainda.',
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
