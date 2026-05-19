import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/closed_table_session_summary.dart';
import 'package:pdvmobile/features/tables/presentation/receipt_preview_page.dart';

void main() {
  testWidgets('mostra comprovante resumido da comanda fechada', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ReceiptPreviewPage(store: _store, session: _session),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Impressao'), findsOneWidget);
    expect(find.text('Acai do Teste'), findsWidgets);
    expect(find.text('#47003471'), findsOneWidget);
    expect(find.text('Mesa 5'), findsOneWidget);
    expect(find.text('Enviar para impressora'), findsOneWidget);
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
