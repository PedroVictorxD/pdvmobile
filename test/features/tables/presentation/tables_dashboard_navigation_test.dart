import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/features/auth/domain/entities/auth_session.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/closed_table_session_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/store_table.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_session_summary.dart';
import 'package:pdvmobile/features/tables/domain/repositories/table_repository.dart';
import 'package:pdvmobile/features/tables/presentation/orders_queue_page.dart';
import 'package:pdvmobile/features/tables/presentation/pix_payments_page.dart';
import 'package:pdvmobile/features/tables/presentation/table_details_page.dart';
import 'package:pdvmobile/features/tables/presentation/tables_dashboard_page.dart';

void main() {
  testWidgets('abre o detalhe da mesa ao tocar no card', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TablesDashboardPage(
          session: const AuthSession(
            accessToken: 'token',
            refreshToken: 'refresh',
            userName: 'Operador',
            userEmail: 'teste@pdv.com',
            role: 'MERCHANT',
          ),
          store: const StoreSummary(
            id: 'store-1',
            name: 'Acai do Teste',
            slug: 'acai-do-teste',
            isOpen: true,
            tableMode: 'TAB',
            acceptedPayments: ['PIX'],
          ),
          tableRepository: _FakeTableRepository(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Mesa 2'));
    await tester.pumpAndSettle();

    expect(find.byType(TableDetailsPage), findsOneWidget);
    expect(find.text('Mesa 2'), findsOneWidget);
    expect(find.text('R\$ 58,00'), findsOneWidget);
  });

  testWidgets('abre a fila de pedidos pela barra inferior', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TablesDashboardPage(
          session: const AuthSession(
            accessToken: 'token',
            refreshToken: 'refresh',
            userName: 'Operador',
            userEmail: 'teste@pdv.com',
            role: 'MERCHANT',
          ),
          store: const StoreSummary(
            id: 'store-1',
            name: 'Acai do Teste',
            slug: 'acai-do-teste',
            isOpen: true,
            tableMode: 'TAB',
            acceptedPayments: ['PIX'],
          ),
          tableRepository: _FakeTableRepository(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Pedidos'));
    await tester.pumpAndSettle();

    expect(find.byType(OrdersQueuePage), findsOneWidget);
    expect(find.text('Mesa 2'), findsOneWidget);
  });

  testWidgets('abre pagamentos pix pela barra inferior', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TablesDashboardPage(
          session: const AuthSession(
            accessToken: 'token',
            refreshToken: 'refresh',
            userName: 'Operador',
            userEmail: 'teste@pdv.com',
            role: 'MERCHANT',
          ),
          store: const StoreSummary(
            id: 'store-1',
            name: 'Acai do Teste',
            slug: 'acai-do-teste',
            isOpen: true,
            tableMode: 'TAB',
            acceptedPayments: ['PIX'],
          ),
          tableRepository: _FakeTableRepository(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Pgtos Pix'));
    await tester.pumpAndSettle();

    expect(find.byType(PixPaymentsPage), findsOneWidget);
    expect(find.text('Checar agora'), findsOneWidget);
  });
}

final class _FakeTableRepository implements TableRepository {
  @override
  Future<List<ClosedTableSessionSummary>> listClosedSessions(
    String storeId,
  ) async {
    return const [
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
    ];
  }

  @override
  Future<List<TableSessionSummary>> listOpenSessions(String storeId) async {
    return const [
      TableSessionSummary(
        id: 'session-1',
        tableNumber: 2,
        tableLabel: 'Salao interno',
        status: 'CLOSE_REQUESTED',
        total: 58,
        orderCount: 2,
      ),
    ];
  }

  @override
  Future<List<StoreTable>> listTables(String storeId) async {
    return const [
      StoreTable(
        id: 'table-1',
        number: 1,
        label: 'Varanda',
        status: 'AVAILABLE',
        qrCodeToken: 'qr-1',
      ),
      StoreTable(
        id: 'table-2',
        number: 2,
        label: 'Salao',
        status: 'OCCUPIED',
        qrCodeToken: 'qr-2',
      ),
    ];
  }

  @override
  Future<void> reopenClosedSession({
    required String storeId,
    required String sessionId,
  }) async {}
}
