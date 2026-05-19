import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/closed_table_session_summary.dart';
import 'package:pdvmobile/features/tables/presentation/cashier_review_page.dart';

void main() {
  testWidgets('mostra conferencia financeira da comanda fechada', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CashierReviewPage(store: _store, session: _session),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Caixa'), findsOneWidget);
    expect(find.text('Balcao'), findsOneWidget);
    expect(find.text('#47003471'), findsOneWidget);
    expect(find.text('R\$ 35,98'), findsWidgets);
    expect(find.text('Conferir pagamento'), findsOneWidget);
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

const _session = ClosedTableSessionSummary(
  id: 'closed-1',
  tableNumber: 5,
  tableLabel: 'Balcao',
  ticketNumber: '47003471',
  total: 35.98,
  paid: 35.98,
  closedAt: '2026-05-15T02:27:00Z',
  status: 'CLOSED',
);
