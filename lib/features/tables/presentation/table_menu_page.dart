import 'package:flutter/material.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_dashboard_entry.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_session_line_item.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_session_summary.dart';

class TableMenuPage extends StatefulWidget {
  const TableMenuPage({super.key, required this.store, required this.entry});

  final StoreSummary store;
  final TableDashboardEntry entry;

  @override
  State<TableMenuPage> createState() => _TableMenuPageState();
}

class _TableMenuPageState extends State<TableMenuPage> {
  String _selectedCategory = 'Bebidas';

  static const _menuItems = <_MenuItem>[
    _MenuItem(
      name: 'Coca-Cola 350ml',
      category: 'Bebidas',
      description: 'Sem acucar',
      price: 7.5,
    ),
    _MenuItem(
      name: 'Suco de Caja 300ml',
      category: 'Bebidas',
      description: 'Natural e gelado',
      price: 9,
    ),
    _MenuItem(
      name: 'Coxinha Crocante',
      category: 'Salgados',
      description: 'Frango cremoso',
      price: 12,
    ),
    _MenuItem(
      name: 'Tapioca Rendada',
      category: 'Cozinha',
      description: 'Queijo coalho e manteiga',
      price: 18.5,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredItems = _menuItems
        .where((item) => item.category == _selectedCategory)
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
              'Adicionar itens',
              style: TextStyle(
                color: Color(0xFF172033),
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mesa ${widget.entry.table.number} • ${widget.entry.table.label}',
              style: const TextStyle(
                color: Color(0xFF657285),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Categorias',
              style: TextStyle(
                color: Color(0xFF172033),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Bebidas', 'Salgados', 'Cozinha']
                  .map(
                    (category) => ChoiceChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            ...filteredItems.map(
              (item) => _MenuItemCard(
                item: item,
                onAdd: () => _addItem(context, item),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addItem(BuildContext context, _MenuItem item) {
    final session = widget.entry.session;
    if (session == null) {
      return;
    }

    final items = [...session.items];
    final existingIndex = items.indexWhere(
      (currentItem) =>
          currentItem.name == item.name && currentItem.note == item.description,
    );

    if (existingIndex >= 0) {
      final existingItem = items[existingIndex];
      items[existingIndex] = TableSessionLineItem(
        name: existingItem.name,
        quantity: existingItem.quantity + 1,
        unitPrice: existingItem.unitPrice,
        note: existingItem.note,
      );
    } else {
      items.add(
        TableSessionLineItem(
          name: item.name,
          quantity: 1,
          unitPrice: item.price,
          note: item.description,
        ),
      );
    }

    Navigator.of(context).pop(
      TableDashboardEntry(
        table: widget.entry.table,
        session: TableSessionSummary(
          id: session.id,
          tableNumber: session.tableNumber,
          tableLabel: session.tableLabel,
          status: session.status,
          total: session.total + item.price,
          orderCount: session.orderCount + 1,
          items: items,
        ),
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({required this.item, required this.onAdd});

  final _MenuItem item;
  final VoidCallback onAdd;

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
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: const TextStyle(
                        color: Color(0xFF657285),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatCurrency(item.price),
                      style: const TextStyle(
                        color: Color(0xFFD94E60),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              FilledButton(onPressed: onAdd, child: const Text('Adicionar')),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.name,
    required this.category,
    required this.description,
    required this.price,
  });

  final String name;
  final String category;
  final String description;
  final double price;
}

String _formatCurrency(double value) {
  final formatted = value.toStringAsFixed(2).replaceAll('.', ',');
  return 'R\$ $formatted';
}
