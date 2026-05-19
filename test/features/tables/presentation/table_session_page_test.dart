import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/store_table.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_dashboard_entry.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_session_summary.dart';
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
      expect(find.text('Escanear QR da mesa'), findsOneWidget);
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
