import 'package:flutter/material.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_dashboard_entry.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_session_line_item.dart';

class OrdersQueuePage extends StatefulWidget {
  const OrdersQueuePage({
    super.key,
    required this.store,
    required this.entries,
  });

  final StoreSummary store;
  final List<TableDashboardEntry> entries;

  @override
  State<OrdersQueuePage> createState() => _OrdersQueuePageState();
}

class _OrdersQueuePageState extends State<OrdersQueuePage> {
  bool _showDelivered = false;
  late List<TableDashboardEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = widget.entries;
  }

  @override
  Widget build(BuildContext context) {
    final pendingCount = _entries.fold<int>(0, (sum, entry) {
      final session = entry.session;
      if (session == null) {
        return sum;
      }

      return sum +
          session.items.where((item) {
            return item.status != TableSessionLineItemStatus.delivered;
          }).length;
    });
    final deliveredCount = _entries.fold<int>(0, (sum, entry) {
      final session = entry.session;
      if (session == null) {
        return sum;
      }

      return sum +
          session.items.where((item) {
            return item.status == TableSessionLineItemStatus.delivered;
          }).length;
    });
    final queueItems = _entries
        .where((entry) => entry.session != null)
        .expand(
          (entry) => entry.session!.items.asMap().entries.map(
            (itemEntry) => _OrderQueueItem(
              entry: entry,
              itemIndex: itemEntry.key,
              item: itemEntry.value,
            ),
          ),
        )
        .where(
          (queueItem) => _showDelivered
              ? queueItem.item.status == TableSessionLineItemStatus.delivered
              : queueItem.item.status != TableSessionLineItemStatus.delivered,
        )
        .toList();

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
              'Pedidos',
              style: TextStyle(
                color: Color(0xFF172033),
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            _OrdersSectionHeader(
              showDelivered: _showDelivered,
              pendingCount: pendingCount,
              deliveredCount: deliveredCount,
              onSelectPending: () {
                setState(() {
                  _showDelivered = false;
                });
              },
              onSelectDelivered: () {
                setState(() {
                  _showDelivered = true;
                });
              },
            ),
            const SizedBox(height: 18),
            if (queueItems.isEmpty)
              _OrdersEmptyState(showDelivered: _showDelivered)
            else
              ...queueItems.map(
                (queueItem) => _OrderItemCard(
                  item: queueItem,
                  onAdvance:
                      queueItem.item.status ==
                          TableSessionLineItemStatus.delivered
                      ? null
                      : () => _advanceItem(queueItem),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _advanceItem(_OrderQueueItem queueItem) {
    final session = queueItem.entry.session;
    if (session == null) {
      return;
    }

    final nextStatus = switch (queueItem.item.status) {
      TableSessionLineItemStatus.pending =>
        TableSessionLineItemStatus.preparing,
      TableSessionLineItemStatus.preparing =>
        TableSessionLineItemStatus.delivered,
      TableSessionLineItemStatus.delivered =>
        TableSessionLineItemStatus.delivered,
    };

    final updatedEntries = [..._entries];
    final entryIndex = updatedEntries.indexOf(queueItem.entry);
    if (entryIndex < 0) {
      return;
    }

    final updatedItems = [...session.items];
    updatedItems[queueItem.itemIndex] = TableSessionLineItem(
      name: queueItem.item.name,
      quantity: queueItem.item.quantity,
      unitPrice: queueItem.item.unitPrice,
      note: queueItem.item.note,
      status: nextStatus,
    );

    updatedEntries[entryIndex] = TableDashboardEntry(
      table: queueItem.entry.table,
      session: session.copyWith(items: updatedItems),
    );

    setState(() {
      _entries = updatedEntries;
    });
  }
}

class _OrdersSectionHeader extends StatelessWidget {
  const _OrdersSectionHeader({
    required this.showDelivered,
    required this.pendingCount,
    required this.deliveredCount,
    required this.onSelectPending,
    required this.onSelectDelivered,
  });

  final bool showDelivered;
  final int pendingCount;
  final int deliveredCount;
  final VoidCallback onSelectPending;
  final VoidCallback onSelectDelivered;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QueueTab(
            label: 'Pendentes $pendingCount',
            selected: !showDelivered,
            onTap: onSelectPending,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QueueTab(
            label: 'Entregues $deliveredCount',
            selected: showDelivered,
            onTap: onSelectDelivered,
          ),
        ),
      ],
    );
  }
}

class _QueueTab extends StatelessWidget {
  const _QueueTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : const Color(0xFFEFF3F8),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected
                  ? const Color(0xFFD94E60)
                  : const Color(0xFF657285),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderItemCard extends StatelessWidget {
  const _OrderItemCard({required this.item, required this.onAdvance});

  final _OrderQueueItem item;
  final VoidCallback? onAdvance;

  @override
  Widget build(BuildContext context) {
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
                      item.item.name,
                      style: const TextStyle(
                        color: Color(0xFF172033),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mesa ${item.entry.table.number} • ${item.entry.table.label}',
                      style: const TextStyle(
                        color: Color(0xFF657285),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (item.item.note.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.item.note,
                        style: const TextStyle(
                          color: Color(0xFF657285),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Qtd ${item.item.quantity} • ${_formatCurrency(item.item.totalPrice)}',
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
                    _statusLabel(item.item.status),
                    style: TextStyle(
                      color:
                          item.item.status == TableSessionLineItemStatus.pending
                          ? const Color(0xFFD94E60)
                          : item.item.status ==
                                TableSessionLineItemStatus.preparing
                          ? const Color(0xFFF29F05)
                          : const Color(0xFF16B8D0),
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (onAdvance != null)
                    FilledButton(
                      key: ValueKey('advance_queue_item_${item.itemIndex}'),
                      onPressed: onAdvance,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 32),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        item.item.status == TableSessionLineItemStatus.pending
                            ? 'Preparar'
                            : 'Entregar',
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
  const _OrdersEmptyState({required this.showDelivered});

  final bool showDelivered;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          showDelivered
              ? 'Nenhum item entregue para acompanhamento no momento.'
              : 'Nenhum item pendente ou em preparo no momento.',
          style: const TextStyle(
            color: Color(0xFF657285),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _OrderQueueItem {
  const _OrderQueueItem({
    required this.entry,
    required this.itemIndex,
    required this.item,
  });

  final TableDashboardEntry entry;
  final int itemIndex;
  final TableSessionLineItem item;
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
