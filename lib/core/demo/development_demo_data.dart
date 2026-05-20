import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/closed_table_session_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/store_table.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_session_line_item.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_session_summary.dart';

class DevelopmentDemoData {
  DevelopmentDemoData()
    : _tables = List<StoreTable>.of(_initialTables),
      _openSessions = List<TableSessionSummary>.of(_initialOpenSessions),
      _closedSessions = List<ClosedTableSessionSummary>.of(
        _initialClosedSessions,
      );

  static bool matchesAccessToken(String accessToken) {
    return accessToken.startsWith('dev-');
  }

  static const stores = [
    StoreSummary(
      id: 'demo-store-1',
      name: 'Loja Demo Centro',
      slug: 'loja-demo-centro',
      isOpen: true,
      tableMode: 'TAB',
      acceptedPayments: ['PIX', 'CASH', 'CARD'],
    ),
  ];

  final List<StoreTable> _tables;
  final List<TableSessionSummary> _openSessions;
  final List<ClosedTableSessionSummary> _closedSessions;

  List<StoreSummary> listStores() {
    return List<StoreSummary>.of(stores);
  }

  List<StoreTable> listTables(String storeId) {
    if (!_isDemoStore(storeId)) {
      return const [];
    }

    return List<StoreTable>.of(_tables);
  }

  List<TableSessionSummary> listOpenSessions(String storeId) {
    if (!_isDemoStore(storeId)) {
      return const [];
    }

    return List<TableSessionSummary>.of(_openSessions);
  }

  List<ClosedTableSessionSummary> listClosedSessions(String storeId) {
    if (!_isDemoStore(storeId)) {
      return const [];
    }

    return List<ClosedTableSessionSummary>.of(_closedSessions);
  }

  void reopenClosedSession({
    required String storeId,
    required String sessionId,
  }) {
    if (!_isDemoStore(storeId)) {
      return;
    }

    final index = _closedSessions.indexWhere(
      (session) => session.id == sessionId,
    );
    if (index < 0) {
      return;
    }

    final closedSession = _closedSessions.removeAt(index);
    _openSessions.add(
      TableSessionSummary(
        id: 'reopened-${closedSession.id}',
        tableNumber: closedSession.tableNumber,
        tableLabel: closedSession.tableLabel,
        status: 'OPEN',
        total: closedSession.total,
        orderCount: 1,
        items: const [
          TableSessionLineItem(
            name: 'Comanda reaberta',
            quantity: 1,
            unitPrice: 0,
            note: 'Ajuste local do modo demo',
            status: TableSessionLineItemStatus.pending,
          ),
        ],
      ),
    );

    final tableIndex = _tables.indexWhere(
      (table) => table.number == closedSession.tableNumber,
    );
    if (tableIndex >= 0) {
      final table = _tables[tableIndex];
      _tables[tableIndex] = StoreTable(
        id: table.id,
        number: table.number,
        label: table.label,
        status: 'OCCUPIED',
        qrCodeToken: table.qrCodeToken,
      );
    } else {
      _tables.add(
        StoreTable(
          id: 'table-reopened-${closedSession.tableNumber}',
          number: closedSession.tableNumber,
          label: closedSession.tableLabel,
          status: 'OCCUPIED',
          qrCodeToken: 'demo-reopened-${closedSession.tableNumber}',
        ),
      );
      _tables.sort((left, right) => left.number.compareTo(right.number));
    }
  }

  bool _isDemoStore(String storeId) {
    return stores.any((store) => store.id == storeId);
  }
}

const _initialTables = [
  StoreTable(
    id: 'demo-table-1',
    number: 1,
    label: 'Varanda',
    status: 'AVAILABLE',
    qrCodeToken: 'demo-qr-1',
  ),
  StoreTable(
    id: 'demo-table-2',
    number: 2,
    label: 'Salao',
    status: 'OCCUPIED',
    qrCodeToken: 'demo-qr-2',
  ),
  StoreTable(
    id: 'demo-table-5',
    number: 5,
    label: 'Balcao',
    status: 'OCCUPIED',
    qrCodeToken: 'demo-qr-5',
  ),
  StoreTable(
    id: 'demo-table-13',
    number: 13,
    label: 'Terraco',
    status: 'AVAILABLE',
    qrCodeToken: 'demo-qr-13',
  ),
];

const _initialOpenSessions = [
  TableSessionSummary(
    id: 'demo-session-2',
    tableNumber: 2,
    tableLabel: 'Salao',
    status: 'OPEN',
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
  TableSessionSummary(
    id: 'demo-session-5',
    tableNumber: 5,
    tableLabel: 'Balcao',
    status: 'CLOSE_REQUESTED',
    total: 76.98,
    orderCount: 2,
    items: [
      TableSessionLineItem(
        name: 'Porcao de Salgados Fritos',
        quantity: 1,
        unitPrice: 35.99,
        note: 'Sai com molho da casa',
        status: TableSessionLineItemStatus.pending,
      ),
      TableSessionLineItem(
        name: 'Tapioca Rendada',
        quantity: 1,
        unitPrice: 19.99,
        note: 'Entrega no balcao',
        status: TableSessionLineItemStatus.preparing,
      ),
    ],
  ),
];

const _initialClosedSessions = [
  ClosedTableSessionSummary(
    id: 'closed-demo-1',
    tableNumber: 15,
    tableLabel: 'Mesa 15',
    ticketNumber: '46990402',
    total: 239.50,
    paid: 239.50,
    closedAt: '2026-05-15T12:39:00Z',
    status: 'CLOSED',
  ),
  ClosedTableSessionSummary(
    id: 'closed-demo-2',
    tableNumber: 5,
    tableLabel: 'Balcao',
    ticketNumber: '47003471',
    total: 35.98,
    paid: 35.98,
    closedAt: '2026-05-15T02:27:00Z',
    status: 'CLOSED',
  ),
];
