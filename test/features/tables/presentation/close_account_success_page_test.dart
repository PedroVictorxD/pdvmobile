import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/store_table.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_dashboard_entry.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_session_summary.dart';
import 'package:pdvmobile/features/tables/presentation/close_account_success_page.dart';

void main() {
  testWidgets('mostra fechamento concluido com resumo final', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CloseAccountSuccessPage(
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
          paymentMethod: 'PIX',
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Conta fechada'), findsOneWidget);
    expect(find.text('Mesa 5'), findsOneWidget);
    expect(find.text('R\$ 76,98'), findsOneWidget);
    expect(find.text('Pix'), findsOneWidget);
    expect(find.text('Voltar para mesas'), findsOneWidget);
  });
}

const _store = StoreSummary(
  id: 'store-1',
  name: 'Acai do Teste',
  slug: 'acai-do-teste',
  isOpen: true,
  tableMode: 'TAB',
  acceptedPayments: ['PIX', 'CASH'],
);
