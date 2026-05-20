import 'package:flutter/material.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_dashboard_entry.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_session_summary.dart';
import 'package:pdvmobile/features/tables/presentation/table_session_page.dart';

class OpenServicePage extends StatefulWidget {
  const OpenServicePage({super.key, required this.store, required this.entry});

  final StoreSummary store;
  final TableDashboardEntry entry;

  @override
  State<OpenServicePage> createState() => _OpenServicePageState();
}

class _OpenServicePageState extends State<OpenServicePage> {
  final TextEditingController _customerController = TextEditingController();

  @override
  void dispose() {
    _customerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              'Abrir atendimento',
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
                  colors: [Color(0xFF26CFE1), Color(0xFF16B8D0)],
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
                      widget.entry.table.label.isEmpty
                          ? 'Sem label'
                          : widget.entry.table.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sem cliente vinculado ainda.',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Abra a comanda para liberar pedidos e fechamento.',
                      style: TextStyle(
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
                      'Cliente',
                      style: TextStyle(
                        color: Color(0xFF172033),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _customerController,
                      decoration: InputDecoration(
                        hintText: 'Nome do cliente ou referencia',
                        filled: true,
                        fillColor: const Color(0xFFF4F7FB),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () => _openSession(context),
              icon: const Icon(Icons.play_circle_fill_rounded),
              label: const Text('Iniciar comanda'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSession(BuildContext context) async {
    final entry = TableDashboardEntry(
      table: widget.entry.table,
      session: TableSessionSummary(
        id: 'local-session-${widget.entry.table.number}',
        tableNumber: widget.entry.table.number,
        tableLabel: _customerController.text.trim().isEmpty
            ? widget.entry.table.label
            : _customerController.text.trim(),
        status: 'OPEN',
        total: 0,
        orderCount: 0,
      ),
    );

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            TableSessionPage(store: widget.store, entry: entry),
      ),
    );
  }
}
