import 'package:flutter/material.dart';
import 'package:pdvmobile/features/auth/domain/entities/auth_session.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/closed_table_session_summary.dart';
import 'package:pdvmobile/features/tables/domain/entities/store_table.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_dashboard_entry.dart';
import 'package:pdvmobile/features/tables/domain/entities/table_session_summary.dart';
import 'package:pdvmobile/features/tables/domain/repositories/table_repository.dart';
import 'package:pdvmobile/features/tables/presentation/orders_queue_page.dart';
import 'package:pdvmobile/features/tables/presentation/pix_payments_page.dart';
import 'package:pdvmobile/features/tables/presentation/table_details_page.dart';

class TablesDashboardPage extends StatefulWidget {
  const TablesDashboardPage({
    super.key,
    required this.session,
    required this.store,
    required this.tableRepository,
    this.environmentBadge,
  });

  final AuthSession session;
  final StoreSummary store;
  final TableRepository tableRepository;
  final Widget? environmentBadge;

  @override
  State<TablesDashboardPage> createState() => _TablesDashboardPageState();
}

enum _DashboardSection { tables, closed }

enum _BottomNavItem { tables, orders, help, pix }

class _TablesDashboardPageState extends State<TablesDashboardPage> {
  final _searchController = TextEditingController();
  _DashboardSection _section = _DashboardSection.tables;
  late Future<_DashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DashboardData>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        final dashboardData = snapshot.data ?? const _DashboardData.empty();
        final entries = dashboardData.entries;
        final closedSessions = dashboardData.closedSessions;
        final pendingOrdersCount = entries.fold<int>(
          0,
          (sum, entry) => sum + (entry.session?.orderCount ?? 0),
        );

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7FB),
          bottomNavigationBar: _DashboardBottomBar(
            selectedItem: _BottomNavItem.tables,
            pendingOrdersCount: pendingOrdersCount,
            onSelected: (item) => _handleBottomNavigation(item, entries),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
                  child: Column(
                    children: [
                      _DashboardHeader(
                        storeName: widget.store.name,
                        operatorName: widget.session.userName,
                        environmentBadge: widget.environmentBadge,
                        onHomeTap: _showHomeSnackBar,
                      ),
                      const SizedBox(height: 16),
                      _DashboardSearchField(
                        controller: _searchController,
                        hintText: _section == _DashboardSection.tables
                            ? 'Digite a mesa desejada'
                            : 'Buscar mesa fechada',
                        onChanged: (_) => setState(() {}),
                        onClear: _clearSearch,
                      ),
                      const SizedBox(height: 14),
                      _SectionSwitcher(
                        selectedSection: _section,
                        openCount: entries.length,
                        closedCount: closedSessions.length,
                        onChanged: _updateSection,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    child: _buildBody(snapshot, entries, closedSessions),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    AsyncSnapshot<_DashboardData> snapshot,
    List<TableDashboardEntry> entries,
    List<ClosedTableSessionSummary> closedSessions,
  ) {
    if (snapshot.connectionState != ConnectionState.done) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 96),
        children: const [Center(child: CircularProgressIndicator())],
      );
    }

    if (snapshot.hasError) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
        children: [
          _DashboardMessage(
            title: 'Nao foi possivel carregar as mesas',
            description:
                'Puxe para atualizar ou tente novamente em alguns instantes.',
            actionLabel: 'Tentar novamente',
            onAction: _retry,
          ),
        ],
      );
    }

    if (_section == _DashboardSection.closed) {
      final filteredClosedSessions = _applyClosedFilters(closedSessions);
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          if (closedSessions.isEmpty)
            const _DashboardMessage(
              title: 'Nenhum fechamento recente',
              description:
                  'As mesas fechadas do turno aparecem aqui para conferencia, caixa e reabertura.',
            )
          else if (filteredClosedSessions.isEmpty)
            const _DashboardMessage(
              title: 'Nenhum fechamento encontrado',
              description:
                  'Ajuste a busca para localizar outra mesa ou pedido fechado.',
            )
          else
            ...filteredClosedSessions.map(
              (session) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ClosedSessionCard(
                  session: session,
                  onPrint: () => _showPrintSnackBar(session),
                  onCashier: () => _showCashierSnackBar(session),
                  onReopen: () => _reopenClosedSession(session),
                ),
              ),
            ),
        ],
      );
    }

    final filteredEntries = _applyFilters(entries);
    if (entries.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: const [
          _DashboardMessage(
            title: 'Nenhuma mesa cadastrada',
            description:
                'Cadastre mesas para iniciar a operacao de salao e comandas.',
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
      children: [
        _DashboardSummary(entries: entries),
        const SizedBox(height: 18),
        if (filteredEntries.isEmpty)
          const _DashboardMessage(
            title: 'Nenhuma mesa encontrada',
            description:
                'Ajuste a busca para localizar outras mesas ou comandas abertas.',
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width >= 680
                  ? 4
                  : width >= 480
                  ? 3
                  : width >= 300
                  ? 2
                  : 1;
              final spacing = 12.0;
              final itemWidth =
                  (width - ((crossAxisCount - 1) * spacing)) / crossAxisCount;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: filteredEntries
                    .map(
                      (entry) => SizedBox(
                        width: itemWidth,
                        child: _TableCard(
                          entry: entry,
                          onTap: () => _openTableDetails(entry),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
      ],
    );
  }

  List<TableDashboardEntry> _applyFilters(List<TableDashboardEntry> entries) {
    final query = _searchController.text.trim().toLowerCase();
    return entries.where((entry) {
      if (query.isEmpty) {
        return true;
      }

      final tableLabel = entry.table.label.toLowerCase();
      final tableNumber = entry.table.number.toString();
      final sessionLabel = entry.session?.tableLabel.toLowerCase() ?? '';
      return tableLabel.contains(query) ||
          tableNumber.contains(query) ||
          sessionLabel.contains(query);
    }).toList();
  }

  List<ClosedTableSessionSummary> _applyClosedFilters(
    List<ClosedTableSessionSummary> sessions,
  ) {
    final query = _searchController.text.trim().toLowerCase();
    return sessions.where((session) {
      if (query.isEmpty) {
        return true;
      }

      return session.tableNumber.toString().contains(query) ||
          session.tableLabel.toLowerCase().contains(query) ||
          session.ticketNumber.toLowerCase().contains(query);
    }).toList();
  }

  Future<_DashboardData> _loadDashboard() async {
    final results = await Future.wait([
      widget.tableRepository.listTables(widget.store.id),
      widget.tableRepository.listOpenSessions(widget.store.id),
      widget.tableRepository.listClosedSessions(widget.store.id),
    ]);

    final tables = results[0] as List<StoreTable>;
    final sessions = results[1] as List<TableSessionSummary>;
    final closedSessions = results[2] as List<ClosedTableSessionSummary>;
    final sessionsByTable = {
      for (final session in sessions) _sessionKey(session): session,
    };

    final entries =
        tables
            .map(
              (table) => TableDashboardEntry(
                table: table,
                session: sessionsByTable[_tableKey(table)],
              ),
            )
            .toList()
          ..sort(
            (left, right) => left.table.number.compareTo(right.table.number),
          );

    final sortedClosedSessions = List<ClosedTableSessionSummary>.of(
      closedSessions,
    )..sort((left, right) => right.closedAt.compareTo(left.closedAt));

    return _DashboardData(
      entries: entries,
      closedSessions: sortedClosedSessions,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _dashboardFuture = _loadDashboard();
    });
    await _dashboardFuture;
  }

  void _retry() {
    setState(() {
      _dashboardFuture = _loadDashboard();
    });
  }

  void _clearSearch() {
    if (_searchController.text.isEmpty) {
      return;
    }

    _searchController.clear();
    setState(() {});
  }

  void _updateSection(_DashboardSection section) {
    if (_section == section) {
      return;
    }

    setState(() {
      _section = section;
    });
  }

  Future<void> _handleBottomNavigation(
    _BottomNavItem item,
    List<TableDashboardEntry> entries,
  ) async {
    if (item == _BottomNavItem.tables) {
      return;
    }

    if (item == _BottomNavItem.help) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A area de ajuda entra na proxima etapa da navegacao.'),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => switch (item) {
          _BottomNavItem.orders => OrdersQueuePage(
            store: widget.store,
            entries: entries,
          ),
          _BottomNavItem.pix => PixPaymentsPage(
            store: widget.store,
            entries: entries,
          ),
          _BottomNavItem.help ||
          _BottomNavItem.tables => const SizedBox.shrink(),
        },
      ),
    );
  }

  void _showHomeSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('A volta para a home entra na proxima etapa do fluxo.'),
      ),
    );
  }

  Future<void> _openTableDetails(TableDashboardEntry entry) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            TableDetailsPage(store: widget.store, entry: entry),
      ),
    );
  }

  void _showPrintSnackBar(ClosedTableSessionSummary session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'A impressao do pedido #${session.ticketNumber} entra na proxima etapa.',
        ),
      ),
    );
  }

  void _showCashierSnackBar(ClosedTableSessionSummary session) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'A conferencia de caixa do pedido #${session.ticketNumber} entra na proxima etapa.',
        ),
      ),
    );
  }

  Future<void> _reopenClosedSession(ClosedTableSessionSummary session) async {
    await widget.tableRepository.reopenClosedSession(
      storeId: widget.store.id,
      sessionId: session.id,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _dashboardFuture = _loadDashboard();
    });
  }

  String _sessionKey(TableSessionSummary session) {
    return session.tableNumber.toString();
  }

  String _tableKey(StoreTable table) {
    return table.number.toString();
  }
}

class _DashboardData {
  const _DashboardData({required this.entries, required this.closedSessions});

  const _DashboardData.empty()
    : entries = const <TableDashboardEntry>[],
      closedSessions = const <ClosedTableSessionSummary>[];

  final List<TableDashboardEntry> entries;
  final List<ClosedTableSessionSummary> closedSessions;
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.storeName,
    required this.operatorName,
    required this.environmentBadge,
    required this.onHomeTap,
  });

  final String storeName;
  final String operatorName;
  final Widget? environmentBadge;
  final VoidCallback onHomeTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                storeName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF172033),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Operador: $operatorName',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF687282),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (environmentBadge != null) ...[
                const SizedBox(height: 10),
                environmentBadge!,
              ],
            ],
          ),
        ),
        TextButton.icon(
          onPressed: onHomeTap,
          icon: const Icon(Icons.arrow_back, size: 18),
          label: const Text('Home'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFD94E60),
            textStyle: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _DashboardSearchField extends StatelessWidget {
  const _DashboardSearchField({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFDDE4EE)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFDDE4EE)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF34CBD2), width: 1.4),
        ),
      ),
    );
  }
}

class _SectionSwitcher extends StatelessWidget {
  const _SectionSwitcher({
    required this.selectedSection,
    required this.openCount,
    required this.closedCount,
    required this.onChanged,
  });

  final _DashboardSection selectedSection;
  final int openCount;
  final int? closedCount;
  final ValueChanged<_DashboardSection> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFDECEF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _SectionChip(
                label: 'Mesas',
                count: openCount,
                selected: selectedSection == _DashboardSection.tables,
                onTap: () => onChanged(_DashboardSection.tables),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SectionChip(
                label: 'Fechadas',
                count: closedCount,
                selected: selectedSection == _DashboardSection.closed,
                onTap: () => onChanged(_DashboardSection.closed),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionChip extends StatelessWidget {
  const _SectionChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: selected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: selected
                        ? const Color(0xFFD94E60)
                        : const Color(0xFF5E6676),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 8),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFFBE0E5)
                        : const Color(0xFFE5EAF1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    child: Text(
                      count.toString(),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF4A5568),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardSummary extends StatelessWidget {
  const _DashboardSummary({required this.entries});

  final List<TableDashboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    final activeSessions = entries
        .where((entry) => entry.session != null)
        .length;
    final occupiedCount = entries
        .where((entry) => entry.table.status == 'OCCUPIED')
        .length;
    final totalOpen = entries.fold<double>(
      0,
      (sum, entry) => sum + (entry.session?.total ?? 0),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF16C8D2), Color(0xFF2EE3D7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2216C8D2),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Operacao de mesas',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$activeSessions comandas abertas e $occupiedCount mesas ocupadas.',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryPill(
                    label: 'Mesas',
                    value: entries.length.toString(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryPill(
                    label: 'Total aberto',
                    value: _formatCurrency(totalOpen),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({required this.entry, required this.onTap});

  final TableDashboardEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final session = entry.session;
    final palette = _paletteFor(entry.table.status, session != null);

    return AspectRatio(
      aspectRatio: 0.92,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [palette.start, palette.end],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: palette.end.withValues(alpha: 0.22),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      'Mesa ${entry.table.number}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    entry.table.label.isEmpty ? 'Sem label' : entry.table.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      height: 1,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                  const SizedBox(height: 10),
                  if (session != null) ...[
                    Text(
                      _formatCurrency(session.total),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _sessionStatusLabel(session.status),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ] else ...[
                    Text(
                      _statusLabel(entry.table.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sem comanda aberta',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _CardPalette _paletteFor(String status, bool hasSession) {
    if (hasSession || status == 'OCCUPIED') {
      return const _CardPalette(
        start: Color(0xFFF55D73),
        end: Color(0xFFD8455F),
      );
    }

    if (status == 'RESERVED') {
      return const _CardPalette(
        start: Color(0xFFFFC65C),
        end: Color(0xFFF59E0B),
      );
    }

    return const _CardPalette(start: Color(0xFF26CFE1), end: Color(0xFF16B8D0));
  }
}

class _ClosedSessionCard extends StatelessWidget {
  const _ClosedSessionCard({
    required this.session,
    required this.onPrint,
    required this.onCashier,
    required this.onReopen,
  });

  final ClosedTableSessionSummary session;
  final VoidCallback onPrint;
  final VoidCallback onCashier;
  final VoidCallback onReopen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.tableLabel.isEmpty
                            ? 'Mesa ${session.tableNumber}'
                            : session.tableLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF172033),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '#${session.ticketNumber}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF657285),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatClosedDate(session.closedAt),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF172033),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatCurrency(session.total)} / ${_formatCurrency(session.paid)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF657285),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.paid >= session.total
                          ? '100% Fechada'
                          : _closedStatusLabel(session.status),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF16B8D0),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPrint,
                    icon: const Icon(Icons.print_rounded, size: 18),
                    label: const Text('Imprimir'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCashier,
                    icon: const Icon(Icons.point_of_sale_rounded, size: 18),
                    label: const Text('Caixa'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onReopen,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Reabrir'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardBottomBar extends StatelessWidget {
  const _DashboardBottomBar({
    required this.selectedItem,
    required this.pendingOrdersCount,
    required this.onSelected,
  });

  final _BottomNavItem selectedItem;
  final int pendingOrdersCount;
  final ValueChanged<_BottomNavItem> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 24,
              offset: Offset(0, -6),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
        child: Row(
          children: [
            Expanded(
              child: _BottomBarButton(
                label: 'Mesas',
                icon: Icons.table_restaurant_rounded,
                selected: selectedItem == _BottomNavItem.tables,
                onTap: () => onSelected(_BottomNavItem.tables),
              ),
            ),
            Expanded(
              child: _BottomBarButton(
                label: 'Pedidos',
                icon: Icons.receipt_long_rounded,
                badgeCount: pendingOrdersCount,
                selected: selectedItem == _BottomNavItem.orders,
                onTap: () => onSelected(_BottomNavItem.orders),
              ),
            ),
            Expanded(
              child: _BottomBarButton(
                label: 'Ajuda',
                icon: Icons.help_outline_rounded,
                selected: selectedItem == _BottomNavItem.help,
                onTap: () => onSelected(_BottomNavItem.help),
              ),
            ),
            Expanded(
              child: _BottomBarButton(
                label: 'Pgtos Pix',
                icon: Icons.attach_money_rounded,
                selected: selectedItem == _BottomNavItem.pix,
                onTap: () => onSelected(_BottomNavItem.pix),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBarButton extends StatelessWidget {
  const _BottomBarButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFFD94E60);
    final inactiveColor = const Color(0xFF627083);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: selected
                      ? Border.all(color: activeColor.withValues(alpha: 0.35))
                      : null,
                  color: selected
                      ? activeColor.withValues(alpha: 0.08)
                      : Colors.transparent,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      icon,
                      color: selected ? activeColor : inactiveColor,
                      size: 22,
                    ),
                    if (badgeCount > 0)
                      Positioned(
                        right: -10,
                        top: -8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFFD94E60),
                            borderRadius: BorderRadius.all(
                              Radius.circular(999),
                            ),
                          ),
                          child: Text(
                            badgeCount > 99 ? '99+' : badgeCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected ? activeColor : inactiveColor,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardMessage extends StatelessWidget {
  const _DashboardMessage({
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: const Color(0xFF172033),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: const Color(0xFF627083),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 18),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _CardPalette {
  const _CardPalette({required this.start, required this.end});

  final Color start;
  final Color end;
}

String _statusLabel(String status) {
  switch (status) {
    case 'OCCUPIED':
      return 'Ocupada';
    case 'RESERVED':
      return 'Reservada';
    default:
      return 'Disponivel';
  }
}

String _sessionStatusLabel(String status) {
  switch (status) {
    case 'CLOSE_REQUESTED':
      return 'Fechamento solicitado';
    case 'CLOSED':
      return 'Fechada';
    default:
      return 'Aberta';
  }
}

String _closedStatusLabel(String status) {
  switch (status) {
    case 'REOPENED':
      return 'Reaberta';
    default:
      return 'Fechada';
  }
}

String _formatClosedDate(String rawValue) {
  final date = DateTime.tryParse(rawValue);
  if (date == null) {
    return rawValue;
  }

  final localDate = date.toLocal();
  final day = localDate.day.toString().padLeft(2, '0');
  final month = localDate.month.toString().padLeft(2, '0');
  final year = (localDate.year % 100).toString().padLeft(2, '0');
  final hour = localDate.hour.toString().padLeft(2, '0');
  final minute = localDate.minute.toString().padLeft(2, '0');
  return '$day/$month/$year $hour:$minute';
}

String _formatCurrency(double value) {
  final formatted = value.toStringAsFixed(2).replaceAll('.', ',');
  return 'R\$ $formatted';
}
