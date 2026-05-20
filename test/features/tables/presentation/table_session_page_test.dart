import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/store_table.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_dashboard_entry.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_session_line_item.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_session_summary.dart';
import 'package:pdvmobile/features/tables/presentation/close_account_page.dart';
import 'package:pdvmobile/features/tables/presentation/open_service_page.dart';
import 'package:pdvmobile/features/tables/presentation/table_menu_page.dart';
import 'package:pdvmobile/features/tables/presentation/table_session_page.dart';

void main() {
  group('TableSessionPage', () {
    testWidgets('mostra sessao ativa quando a mesa esta ocupada', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TableSessionPage(
            store: _store,
            entry: TableDashboardEntry(
              table: const StoreTable(
                id: 'table-2',
                number: 5,
                label: 'Salao',
                status: 'OCCUPIED',
                qrCodeToken: 'qr-2',
              ),
              session: const TableSessionSummary(
                id: 'session-1',
                tableNumber: 5,
                tableLabel: 'Salao',
                status: 'OPEN',
                total: 76.98,
                orderCount: 3,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Comanda da mesa'), findsOneWidget);
      expect(find.text('Mesa 5'), findsOneWidget);
      expect(find.text('3 pedidos'), findsOneWidget);
      expect(find.text('Adicionar item'), findsOneWidget);
      expect(find.text('Fechar conta'), findsOneWidget);
      expect(find.text('Nenhum item lancado ainda.'), findsOneWidget);
    });

    testWidgets('mostra abertura de comanda quando a mesa esta livre', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TableSessionPage(
            store: _store,
            entry: TableDashboardEntry(
              table: const StoreTable(
                id: 'table-1',
                number: 1,
                label: 'Varanda',
                status: 'AVAILABLE',
                qrCodeToken: 'qr-1',
              ),
              session: null,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Nova comanda'), findsOneWidget);
      expect(find.text('Mesa 1'), findsOneWidget);
      expect(find.text('Abrir atendimento'), findsOneWidget);
      expect(find.text('Escanear QR da mesa'), findsNothing);
    });

    testWidgets('abre fluxo de atendimento ao tocar em abrir atendimento', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TableSessionPage(
            store: _store,
            entry: TableDashboardEntry(
              table: const StoreTable(
                id: 'table-1',
                number: 1,
                label: 'Varanda',
                status: 'AVAILABLE',
                qrCodeToken: 'qr-1',
              ),
              session: null,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Abrir atendimento'));
      await tester.pumpAndSettle();

      expect(find.byType(OpenServicePage), findsOneWidget);
      expect(find.text('Iniciar comanda'), findsOneWidget);
    });

    testWidgets('abre catalogo ao tocar em adicionar item', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TableSessionPage(
            store: _store,
            entry: TableDashboardEntry(
              table: const StoreTable(
                id: 'table-2',
                number: 5,
                label: 'Salao',
                status: 'OCCUPIED',
                qrCodeToken: 'qr-2',
              ),
              session: const TableSessionSummary(
                id: 'session-1',
                tableNumber: 5,
                tableLabel: 'Salao',
                status: 'OPEN',
                total: 76.98,
                orderCount: 3,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Adicionar item'));
      await tester.pumpAndSettle();

      expect(find.byType(TableMenuPage), findsOneWidget);
      expect(find.text('Adicionar itens'), findsOneWidget);
    });

    testWidgets('atualiza a comanda ao lancar um item do catalogo', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TableSessionPage(
            store: _store,
            entry: TableDashboardEntry(
              table: const StoreTable(
                id: 'table-2',
                number: 5,
                label: 'Salao',
                status: 'OCCUPIED',
                qrCodeToken: 'qr-2',
              ),
              session: const TableSessionSummary(
                id: 'session-1',
                tableNumber: 5,
                tableLabel: 'Salao',
                status: 'OPEN',
                total: 76.98,
                orderCount: 3,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Adicionar item'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Adicionar').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirmar item'));
      await tester.pumpAndSettle();

      expect(find.byType(TableMenuPage), findsNothing);
      expect(find.text('4 pedidos'), findsOneWidget);
      expect(find.text('R\$ 84,48'), findsOneWidget);
      expect(find.text('Coca-Cola 350ml'), findsOneWidget);
      expect(find.text('Qtd 1 • R\$ 7,50'), findsOneWidget);
    });

    testWidgets('mostra observacao personalizada no item lancado', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TableSessionPage(
            store: _store,
            entry: TableDashboardEntry(
              table: const StoreTable(
                id: 'table-2',
                number: 5,
                label: 'Salao',
                status: 'OCCUPIED',
                qrCodeToken: 'qr-2',
              ),
              session: const TableSessionSummary(
                id: 'session-1',
                tableNumber: 5,
                tableLabel: 'Salao',
                status: 'OPEN',
                total: 76.98,
                orderCount: 3,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Adicionar item'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Adicionar').first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Sem gelo');
      await tester.tap(find.text('Confirmar item'));
      await tester.pumpAndSettle();

      expect(find.byType(TableMenuPage), findsNothing);
      expect(find.text('Coca-Cola 350ml'), findsOneWidget);
      expect(find.text('Sem gelo'), findsOneWidget);
    });

    testWidgets('permite cancelar um item ja lancado na comanda', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: TableSessionPage(
            store: _store,
            entry: TableDashboardEntry(
              table: const StoreTable(
                id: 'table-2',
                number: 5,
                label: 'Salao',
                status: 'OCCUPIED',
                qrCodeToken: 'qr-2',
              ),
              session: const TableSessionSummary(
                id: 'session-1',
                tableNumber: 5,
                tableLabel: 'Salao',
                status: 'OPEN',
                total: 7.5,
                orderCount: 1,
                items: [
                  TableSessionLineItem(
                    name: 'Coca-Cola 350ml',
                    quantity: 1,
                    unitPrice: 7.5,
                    note: 'Sem acucar',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Coca-Cola 350ml'), findsOneWidget);
      final cancelButton = find.widgetWithText(TextButton, 'Cancelar');
      expect(cancelButton, findsOneWidget);

      await tester.scrollUntilVisible(
        cancelButton,
        120,
        scrollable: find.byType(Scrollable),
      );
      await tester.tap(cancelButton);
      await tester.pumpAndSettle();

      expect(find.text('Coca-Cola 350ml'), findsNothing);
      expect(find.text('0 pedidos'), findsOneWidget);
      expect(find.text('R\$ 0,00'), findsOneWidget);
      expect(find.text('Nenhum item lancado ainda.'), findsOneWidget);
    });

    testWidgets('permite aumentar a quantidade de um item lancado', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TableSessionPage(
            store: _store,
            entry: TableDashboardEntry(
              table: const StoreTable(
                id: 'table-2',
                number: 5,
                label: 'Salao',
                status: 'OCCUPIED',
                qrCodeToken: 'qr-2',
              ),
              session: const TableSessionSummary(
                id: 'session-1',
                tableNumber: 5,
                tableLabel: 'Salao',
                status: 'OPEN',
                total: 7.5,
                orderCount: 1,
                items: [
                  TableSessionLineItem(
                    name: 'Coca-Cola 350ml',
                    quantity: 1,
                    unitPrice: 7.5,
                    note: 'Sem acucar',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('increase_item_0')));
      await tester.pumpAndSettle();

      expect(find.text('Qtd 2 • R\$ 15,00'), findsOneWidget);
      expect(find.text('2 pedidos'), findsOneWidget);
      expect(find.text('R\$ 15,00'), findsWidgets);
    });

    testWidgets('permite reduzir a quantidade de um item sem remover a linha', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TableSessionPage(
            store: _store,
            entry: TableDashboardEntry(
              table: const StoreTable(
                id: 'table-2',
                number: 5,
                label: 'Salao',
                status: 'OCCUPIED',
                qrCodeToken: 'qr-2',
              ),
              session: const TableSessionSummary(
                id: 'session-1',
                tableNumber: 5,
                tableLabel: 'Salao',
                status: 'OPEN',
                total: 15,
                orderCount: 2,
                items: [
                  TableSessionLineItem(
                    name: 'Coca-Cola 350ml',
                    quantity: 2,
                    unitPrice: 7.5,
                    note: 'Sem acucar',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('decrease_item_0')));
      await tester.pumpAndSettle();

      expect(find.text('Coca-Cola 350ml'), findsOneWidget);
      expect(find.text('Qtd 1 • R\$ 7,50'), findsOneWidget);
      expect(find.text('1 pedidos'), findsOneWidget);
      expect(find.text('R\$ 7,50'), findsWidgets);
    });

    testWidgets('abre fechamento ao tocar em fechar conta', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TableSessionPage(
            store: _store,
            entry: TableDashboardEntry(
              table: const StoreTable(
                id: 'table-2',
                number: 5,
                label: 'Salao',
                status: 'OCCUPIED',
                qrCodeToken: 'qr-2',
              ),
              session: const TableSessionSummary(
                id: 'session-1',
                tableNumber: 5,
                tableLabel: 'Salao',
                status: 'OPEN',
                total: 76.98,
                orderCount: 3,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Fechar conta'));
      await tester.pumpAndSettle();

      expect(find.byType(CloseAccountPage), findsOneWidget);
      expect(find.text('Confirmar fechamento'), findsOneWidget);
    });
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
