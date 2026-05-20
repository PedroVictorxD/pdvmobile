import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/store_table.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_dashboard_entry.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_session_line_item.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_session_summary.dart';
import 'package:pdvmobile/features/tables/presentation/orders_queue_page.dart';

void main() {
  testWidgets('mostra itens pendentes e em preparo na fila de pedidos', (
    tester,
  ) async {
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
                items: [
                  TableSessionLineItem(
                    name: 'Coca-Cola 350ml',
                    quantity: 1,
                    unitPrice: 7.5,
                    note: 'Sem gelo',
                    status: TableSessionLineItemStatus.pending,
                  ),
                  TableSessionLineItem(
                    name: 'Coxinha Crocante',
                    quantity: 1,
                    unitPrice: 12,
                    note: 'Frango cremoso',
                    status: TableSessionLineItemStatus.preparing,
                  ),
                  TableSessionLineItem(
                    name: 'Suco de Caja 300ml',
                    quantity: 1,
                    unitPrice: 9,
                    note: 'Natural e gelado',
                    status: TableSessionLineItemStatus.delivered,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pedidos'), findsOneWidget);
    expect(find.text('Pendentes'), findsOneWidget);
    expect(find.text('Entregues'), findsOneWidget);
    expect(find.text('Mesa 5 • Salao'), findsWidgets);
    expect(find.text('Coca-Cola 350ml'), findsOneWidget);
    expect(find.text('Coxinha Crocante'), findsOneWidget);
    expect(find.text('Suco de Caja 300ml'), findsNothing);
    expect(find.text('Pendente'), findsOneWidget);
    expect(find.text('Em preparo'), findsOneWidget);
  });

  testWidgets('mostra itens entregues ao trocar a aba', (tester) async {
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
                items: [
                  TableSessionLineItem(
                    name: 'Coca-Cola 350ml',
                    quantity: 1,
                    unitPrice: 7.5,
                    note: 'Sem gelo',
                    status: TableSessionLineItemStatus.pending,
                  ),
                  TableSessionLineItem(
                    name: 'Suco de Caja 300ml',
                    quantity: 1,
                    unitPrice: 9,
                    note: 'Natural e gelado',
                    status: TableSessionLineItemStatus.delivered,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Entregues'));
    await tester.pumpAndSettle();

    expect(find.text('Suco de Caja 300ml'), findsOneWidget);
    expect(find.text('Entregue'), findsOneWidget);
    expect(find.text('Coca-Cola 350ml'), findsNothing);
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
