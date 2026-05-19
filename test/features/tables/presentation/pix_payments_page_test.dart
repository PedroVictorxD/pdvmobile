import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/store_table.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_dashboard_entry.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_session_summary.dart';
import 'package:pdvmobile/features/tables/presentation/pix_payments_page.dart';

void main() {
  testWidgets('lista mesas com fechamento solicitado para conferencia pix', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PixPaymentsPage(
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
                status: 'CLOSE_REQUESTED',
                total: 76.98,
                orderCount: 3,
              ),
            ),
            TableDashboardEntry(
              table: StoreTable(
                id: 'table-3',
                number: 6,
                label: 'Varanda',
                status: 'OCCUPIED',
                qrCodeToken: 'qr-3',
              ),
              session: TableSessionSummary(
                id: 'session-2',
                tableNumber: 6,
                tableLabel: 'Varanda',
                status: 'OPEN',
                total: 42,
                orderCount: 1,
              ),
            ),
          ],
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Pagamentos Pix'), findsOneWidget);
    expect(find.text('Mesa 5'), findsOneWidget);
    expect(find.text('R\$ 76,98'), findsOneWidget);
    expect(find.text('Checar agora'), findsOneWidget);
    expect(find.text('Mesa 6'), findsNothing);
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
