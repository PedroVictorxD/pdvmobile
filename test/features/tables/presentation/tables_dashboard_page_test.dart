import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/features/auth/domain/entities/auth_session.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/closed_table_session_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/store_table.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_session_line_item.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_session_summary.dart';
import 'package:pdvmobile/features/tables/domain/repositories/table_repository.dart';
import 'package:pdvmobile/features/tables/presentation/tables_dashboard_page.dart';

void main() {
  group('TablesDashboardPage', () {
    testWidgets('mostra mesas e resumo da sessao aberta', (tester) async {
      final repository = _FakeTableRepository();

      await tester.pumpWidget(_buildApp(repository));
      await tester.pumpAndSettle();

      expect(find.text('Acai do Teste'), findsOneWidget);
      expect(find.text('Mesa 1'), findsOneWidget);
      expect(find.text('Mesa 2'), findsOneWidget);
      expect(find.text('R\$ 58,00'), findsWidgets);
      expect(find.text('Fechamento solicitado'), findsOneWidget);
    });

    testWidgets('filtra mesas por busca', (tester) async {
      final repository = _FakeTableRepository();

      await tester.pumpWidget(_buildApp(repository));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'var');
      await tester.pumpAndSettle();

      expect(find.text('Mesa 1'), findsOneWidget);
      expect(find.text('Mesa 2'), findsNothing);
    });

    testWidgets('mostra estado vazio quando nao ha mesas', (tester) async {
      final repository = _FakeTableRepository.empty();

      await tester.pumpWidget(_buildApp(repository));
      await tester.pumpAndSettle();

      expect(find.text('Nenhuma mesa cadastrada'), findsOneWidget);
    });

    testWidgets('mostra historico e acoes na aba fechadas', (tester) async {
      final repository = _FakeTableRepository();

      await tester.pumpWidget(_buildApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Fechadas'));
      await tester.pumpAndSettle();

      expect(find.text('Balcao'), findsOneWidget);
      expect(find.text('#47003471'), findsOneWidget);
      expect(find.text('Imprimir'), findsOneWidget);
      expect(find.text('Caixa'), findsOneWidget);
      expect(find.text('Reabrir'), findsOneWidget);
    });

    testWidgets('mostra badge de pedidos com itens ainda nao entregues', (
      tester,
    ) async {
      final repository = _FakeTableRepository();

      await tester.pumpWidget(_buildApp(repository));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('bottom_badge_Pedidos')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('bottom_badge_Pedidos')),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('reabre comanda fechada pela aba fechadas', (tester) async {
      final repository = _FakeTableRepository();

      await tester.pumpWidget(_buildApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Fechadas'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reabrir'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(repository.reopenedSessionId, 'closed-1');
      expect(find.text('#47003471'), findsNothing);
    });
  });
}

Widget _buildApp(TableRepository repository) {
  return MaterialApp(
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
      tableRepository: repository,
    ),
  );
}

final class _FakeTableRepository implements TableRepository {
  _FakeTableRepository() : returnEmpty = false;

  _FakeTableRepository.empty() : returnEmpty = true;

  final bool returnEmpty;
  String? reopenedSessionId;
  final List<ClosedTableSessionSummary> _closedSessions = [
    const ClosedTableSessionSummary(
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

  @override
  Future<List<TableSessionSummary>> listOpenSessions(String storeId) async {
    if (returnEmpty) {
      return const [];
    }

    return const [
      TableSessionSummary(
        id: 'session-1',
        tableNumber: 2,
        tableLabel: 'Salao interno',
        status: 'CLOSE_REQUESTED',
        total: 58,
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
    ];
  }

  @override
  Future<List<ClosedTableSessionSummary>> listClosedSessions(
    String storeId,
  ) async {
    if (returnEmpty) {
      return const [];
    }

    return List<ClosedTableSessionSummary>.of(_closedSessions);
  }

  @override
  Future<List<StoreTable>> listTables(String storeId) async {
    if (returnEmpty) {
      return const [];
    }

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
  }) async {
    reopenedSessionId = sessionId;
    _closedSessions.removeWhere((session) => session.id == sessionId);
  }
}
