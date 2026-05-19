import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/store_table.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_dashboard_entry.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_session_summary.dart';
import 'package:pdvmobile/features/tables/presentation/orders_queue_page.dart';

void main() {
  testWidgets('mostra sessoes abertas na fila de pedidos', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OrdersQueuePage(
          store: _store,
          entries: const [
            TableDashboardEntry(
              table: StoreTable(
                id: 'table-2',
                number: 5,
                label: 'Salao',
                status: 'OCCUPIED',
                qrCodeToken: 'qr-2',
              ),
              session: TableSessionSummary(
                id: 'session-1',
                tableNumber: 5,
                tableLabel: 'Salao',
                status: 'OPEN',
                total: 76.98,
                orderCount: 3,
              ),
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pedidos'), findsOneWidget);
    expect(find.text('Pendentes'), findsOneWidget);
    expect(find.text('Mesa 5'), findsOneWidget);
    expect(find.text('3 itens'), findsOneWidget);
    expect(find.text('R\$ 76,98'), findsOneWidget);
  });
}

const _store = StoreSummary(
  id: 'store-1',
  name: 'Acai do Teste',
  slug: 'acai-do-teste',
  isOpen: true,
  tableMode: 'TAB',
  acceptedPayments: ['PIX'],
);
