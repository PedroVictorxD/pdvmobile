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
              else ...[
                _StatusSection(
                  title: 'Pendentes',
                  entries: session.items
                      .asMap()
                      .entries
                      .where(
                        (entry) =>
                            entry.value.status ==
                            TableSessionLineItemStatus.pending,
                      )
                      .toList(),
                  onDecrease: _decreaseItem,
                  onIncrease: _increaseItem,
                  onAdvance: _advanceItemStatus,
                  onCancel: _cancelItem,
                ),
                _StatusSection(
                  title: 'Em preparo',
                  entries: session.items
                      .asMap()
                      .entries
                      .where(
                        (entry) =>
                            entry.value.status ==
                            TableSessionLineItemStatus.preparing,
                      )
                      .toList(),
                  onDecrease: _decreaseItem,
                  onIncrease: _increaseItem,
                  onAdvance: _advanceItemStatus,
                  onCancel: _cancelItem,
                ),
                _StatusSection(
                  title: 'Entregues',
                  entries: session.items
                      .asMap()
                      .entries
                      .where(
                        (entry) =>
                            entry.value.status ==
                            TableSessionLineItemStatus.delivered,
                      )
                      .toList(),
                  onDecrease: _decreaseItem,
                  onIncrease: _increaseItem,
                  onAdvance: _advanceItemStatus,
                  onCancel: _cancelItem,
                ),
              ],
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
    final items = [...session.items]..removeAt(itemIndex);

    setState(() {
      _entry = TableDashboardEntry(
        table: _entry.table,
        session: TableSessionSummary(
          id: session.id,
          tableNumber: session.tableNumber,
          tableLabel: session.tableLabel,
          status: session.status,
          total: (session.total - currentItem.totalPrice).clamp(
            0,
            double.infinity,
          ),
          orderCount: session.orderCount - currentItem.quantity < 0
              ? 0
              : session.orderCount - currentItem.quantity,
          items: items,
        ),
      );
    });
  }

  void _increaseItem(int itemIndex) {
    final session = _entry.session;
    if (session == null || itemIndex >= session.items.length) {
      return;
    }

    final currentItem = session.items[itemIndex];
    final items = [...session.items];
    items[itemIndex] = TableSessionLineItem(
      name: currentItem.name,
      quantity: currentItem.quantity + 1,
      unitPrice: currentItem.unitPrice,
      note: currentItem.note,
      status: currentItem.status,
    );

    setState(() {
      _entry = TableDashboardEntry(
        table: _entry.table,
        session: TableSessionSummary(
          id: session.id,
          tableNumber: session.tableNumber,
          tableLabel: session.tableLabel,
          status: session.status,
          total: session.total + currentItem.unitPrice,
          orderCount: session.orderCount + 1,
          items: items,
        ),
      );
    });
  }

  void _decreaseItem(int itemIndex) {
    final session = _entry.session;
    if (session == null || itemIndex >= session.items.length) {
      return;
    }

    final currentItem = session.items[itemIndex];
    if (currentItem.quantity <= 1) {
      return;
    }

    final items = [...session.items];
    items[itemIndex] = TableSessionLineItem(
      name: currentItem.name,
      quantity: currentItem.quantity - 1,
      unitPrice: currentItem.unitPrice,
      note: currentItem.note,
      status: currentItem.status,
    );

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

  void _advanceItemStatus(int itemIndex) {
    final session = _entry.session;
    if (session == null || itemIndex >= session.items.length) {
      return;
    }

    final currentItem = session.items[itemIndex];
    if (currentItem.status == TableSessionLineItemStatus.delivered) {
      return;
    }

    final nextStatus = switch (currentItem.status) {
      TableSessionLineItemStatus.pending =>
        TableSessionLineItemStatus.preparing,
      TableSessionLineItemStatus.preparing =>
        TableSessionLineItemStatus.delivered,
      TableSessionLineItemStatus.delivered =>
        TableSessionLineItemStatus.delivered,
    };

    final items = [...session.items];
    items[itemIndex] = TableSessionLineItem(
      name: currentItem.name,
      quantity: currentItem.quantity,
      unitPrice: currentItem.unitPrice,
      note: currentItem.note,
      status: nextStatus,
    );

    setState(() {
      _entry = TableDashboardEntry(
        table: _entry.table,
        session: TableSessionSummary(
          id: session.id,
          tableNumber: session.tableNumber,
          tableLabel: session.tableLabel,
          status: session.status,
          total: session.total,
          orderCount: session.orderCount,
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
  const _SessionLineItemCard({
    required this.itemIndex,
    required this.item,
    required this.onDecrease,
    required this.onIncrease,
    required this.onAdvance,
    required this.onCancel,
  });

  final int itemIndex;
  final TableSessionLineItem item;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onAdvance;
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
                  const SizedBox(height: 6),
                  Text(
                    _statusLabel(item.status),
                    style: const TextStyle(
                      color: Color(0xFF16B8D0),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      key: ValueKey('decrease_item_$itemIndex'),
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      onPressed: item.quantity > 1 ? onDecrease : null,
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                    ),
                    Text(
                      '${item.quantity}',
                      style: const TextStyle(
                        color: Color(0xFF172033),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    IconButton(
                      key: ValueKey('increase_item_$itemIndex'),
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      onPressed: onIncrease,
                      icon: const Icon(Icons.add_circle_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (item.status != TableSessionLineItemStatus.delivered)
                  FilledButton(
                    key: ValueKey('advance_item_$itemIndex'),
                    onPressed: onAdvance,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      item.status == TableSessionLineItemStatus.pending
                          ? 'Preparar'
                          : 'Entregar',
                    ),
                  )
                else
                  const Text(
                    'Item entregue',
                    style: TextStyle(
                      color: Color(0xFF16B8D0),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusSection extends StatelessWidget {
  const _StatusSection({
    required this.title,
    required this.entries,
    required this.onDecrease,
    required this.onIncrease,
    required this.onAdvance,
    required this.onCancel,
  });

  final String title;
  final List<MapEntry<int, TableSessionLineItem>> entries;
  final ValueChanged<int> onDecrease;
  final ValueChanged<int> onIncrease;
  final ValueChanged<int> onAdvance;
  final ValueChanged<int> onCancel;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF657285),
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        ...entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _SessionLineItemCard(
              itemIndex: entry.key,
              item: entry.value,
              onDecrease: () => onDecrease(entry.key),
              onIncrease: () => onIncrease(entry.key),
              onAdvance: () => onAdvance(entry.key),
              onCancel: () => onCancel(entry.key),
            ),
          ),
        ),
      ],
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

String _statusLabel(TableSessionLineItemStatus status) {
  return switch (status) {
    TableSessionLineItemStatus.pending => 'Pendente',
    TableSessionLineItemStatus.preparing => 'Em preparo',
    TableSessionLineItemStatus.delivered => 'Entregue',
  };
}
