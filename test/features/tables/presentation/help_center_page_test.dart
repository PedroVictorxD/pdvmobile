import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/closed_table_session_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/store_table.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_dashboard_entry.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_session_summary.dart';
import 'package:pdvmobile/features/tables/presentation/help_center_page.dart';

void main() {
  testWidgets('mostra resumo operacional e atalhos de ajuda', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HelpCenterPage(
          store: _store,
          operatorName: 'Operador',
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
                status: 'CLOSE_REQUESTED',
                total: 76.98,
                orderCount: 3,
              ),
            ),
          ],
          closedSessions: const [
            ClosedTableSessionSummary(
              id: 'closed-1',
              tableNumber: 5,
              tableLabel: 'Balcao',
              ticketNumber: '47003471',
              total: 35.98,
              paid: 35.98,
              closedAt: '2026-05-15T02:27:00Z',
              status: 'CLOSED',
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Ajuda'), findsOneWidget);
    expect(find.text('Operador'), findsOneWidget);
    expect(find.text('Chamar gerente'), findsOneWidget);
    expect(find.text('Recarregar mesas'), findsOneWidget);
    expect(find.text('Pedidos pendentes'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Pagamentos Pix'),
      200,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Pagamentos Pix'), findsOneWidget);
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
