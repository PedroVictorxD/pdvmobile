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
    expect(find.text('Pendentes 2'), findsOneWidget);
    expect(find.text('Entregues 1'), findsOneWidget);
    expect(find.text('Mesa 5 • Salao'), findsWidgets);
    expect(find.text('Coca-Cola 350ml'), findsOneWidget);
    expect(find.text('Coxinha Crocante'), findsOneWidget);
    expect(find.text('Suco de Caja 300ml'), findsNothing);
    expect(find.text('Pendente'), findsOneWidget);
    expect(find.text('Em preparo'), findsOneWidget);
    expect(find.text('Preparar'), findsOneWidget);
    expect(find.text('Entregar'), findsOneWidget);
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
    await tester.tap(find.text('Entregues 1'));
    await tester.pumpAndSettle();

    expect(find.text('Suco de Caja 300ml'), findsOneWidget);
    expect(find.text('Entregue'), findsOneWidget);
    expect(find.text('Coca-Cola 350ml'), findsNothing);
  });

  testWidgets('permite avancar item pendente para em preparo na fila', (
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
                orderCount: 1,
                items: [
                  TableSessionLineItem(
                    name: 'Coca-Cola 350ml',
                    quantity: 1,
                    unitPrice: 7.5,
                    note: 'Sem gelo',
                    status: TableSessionLineItemStatus.pending,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('advance_queue_item_0')));
    await tester.pumpAndSettle();

    expect(find.text('Em preparo'), findsWidgets);
    expect(find.text('Entregar'), findsOneWidget);
  });

  testWidgets('permite entregar item em preparo e move para aba entregues', (
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
                orderCount: 1,
                items: [
                  TableSessionLineItem(
                    name: 'Coxinha Crocante',
                    quantity: 1,
                    unitPrice: 12,
                    note: 'Frango cremoso',
                    status: TableSessionLineItemStatus.preparing,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('advance_queue_item_0')));
    await tester.pumpAndSettle();

    expect(find.text('Coxinha Crocante'), findsNothing);

    await tester.tap(find.text('Entregues 1'));
    await tester.pumpAndSettle();

    expect(find.text('Coxinha Crocante'), findsOneWidget);
    expect(find.text('Entregue'), findsOneWidget);
  });

  testWidgets('atualiza contadores das abas ao avancar itens', (tester) async {
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
                orderCount: 2,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pendentes 2'), findsOneWidget);
    expect(find.text('Entregues 0'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('advance_queue_item_0')));
    await tester.pumpAndSettle();

    expect(find.text('Pendentes 2'), findsOneWidget);
    expect(find.text('Entregues 0'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('advance_queue_item_1')));
    await tester.pumpAndSettle();

    expect(find.text('Pendentes 1'), findsOneWidget);
    expect(find.text('Entregues 1'), findsOneWidget);
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
