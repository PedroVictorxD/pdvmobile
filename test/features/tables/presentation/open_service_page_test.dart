import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/store_table.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_dashboard_entry.dart';
import 'package:pdvmobile/features/tables/presentation/open_service_page.dart';
import 'package:pdvmobile/features/tables/presentation/table_session_page.dart';

void main() {
  testWidgets('mostra abertura e inicia uma nova comanda', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OpenServicePage(
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

    expect(find.text('Abrir atendimento'), findsWidgets);
    expect(find.text('Mesa 1'), findsOneWidget);
    expect(find.text('Sem cliente vinculado ainda.'), findsOneWidget);
    expect(find.text('Iniciar comanda'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Cliente Balcao');
    await tester.tap(find.text('Iniciar comanda'));
    await tester.pumpAndSettle();

    expect(find.byType(TableSessionPage), findsOneWidget);
    expect(find.text('Comanda da mesa'), findsOneWidget);
    expect(find.text('Adicionar item'), findsOneWidget);
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
