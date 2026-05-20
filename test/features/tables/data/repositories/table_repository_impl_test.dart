import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:pdvmobile/features/auth/data/models/auth_session_model.dart';
import 'package:pdvmobile/features/tables/data/datasources/table_remote_data_source.dart';
import 'package:pdvmobile/features/tables/data/models/closed_table_session_summary_model.dart';
import 'package:pdvmobile/features/tables/data/models/store_table_model.dart';
import 'package:pdvmobile/features/tables/data/models/table_session_summary_model.dart';
import 'package:pdvmobile/features/tables/data/repositories/table_repository_impl.dart';

void main() {
  group('TableRepositoryImpl', () {
    test(
      'lista historico fechado usando o token salvo na sessao local',
      () async {
        final remote = _FakeTableRemoteDataSource();
        final repository = TableRepositoryImpl(
          remoteDataSource: remote,
          authLocalDataSource: _FakeAuthLocalDataSource(),
        );

        final sessions = await repository.listClosedSessions('store-1');

        expect(sessions, hasLength(1));
        expect(sessions.first.ticketNumber, '47003471');
        expect(remote.lastAccessToken, 'access-token');
      },
    );

    test(
      'reabre comanda fechada usando o token salvo na sessao local',
      () async {
        final remote = _FakeTableRemoteDataSource();
        final repository = TableRepositoryImpl(
          remoteDataSource: remote,
          authLocalDataSource: _FakeAuthLocalDataSource(),
        );

        await repository.reopenClosedSession(
          storeId: 'store-1',
          sessionId: 'closed-1',
        );

        expect(remote.reopenedSessionId, 'closed-1');
        expect(remote.lastAccessToken, 'access-token');
      },
    );

    test(
      'retorna mesas e sessoes demo quando a sessao usa token local de desenvolvimento',
      () async {
        final remote = _FakeTableRemoteDataSource();
        final repository = TableRepositoryImpl(
          remoteDataSource: remote,
          authLocalDataSource: _FakeAuthLocalDataSource.dev(),
        );

        final tables = await repository.listTables('demo-store-1');
        final sessions = await repository.listOpenSessions('demo-store-1');
        final closedSessions = await repository.listClosedSessions(
          'demo-store-1',
        );

        expect(tables, isNotEmpty);
        expect(tables.first.label, 'Varanda');
        expect(sessions, isNotEmpty);
        expect(sessions.first.items, isNotEmpty);
        expect(closedSessions, isNotEmpty);
        expect(remote.lastAccessToken, isNull);
      },
    );

    test('reabre sessao demo sem chamar a API remota', () async {
      final remote = _FakeTableRemoteDataSource();
      final repository = TableRepositoryImpl(
        remoteDataSource: remote,
        authLocalDataSource: _FakeAuthLocalDataSource.dev(),
      );

      await repository.reopenClosedSession(
        storeId: 'demo-store-1',
        sessionId: 'closed-demo-1',
      );

      final closedSessions = await repository.listClosedSessions(
        'demo-store-1',
      );
      final openSessions = await repository.listOpenSessions('demo-store-1');

      expect(
        closedSessions.where((session) => session.id == 'closed-demo-1'),
        isEmpty,
      );
      expect(
        openSessions.any((session) => session.id == 'reopened-closed-demo-1'),
        isTrue,
      );
      expect(remote.reopenedSessionId, isNull);
    });
  });
}

final class _FakeTableRemoteDataSource implements TableRemoteDataSource {
  String? lastAccessToken;
  String? reopenedSessionId;

  @override
  Future<List<ClosedTableSessionSummaryModel>> listClosedSessions({
    required String storeId,
    required String accessToken,
  }) async {
    lastAccessToken = accessToken;
    return const [
      ClosedTableSessionSummaryModel(
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
  Future<List<TableSessionSummaryModel>> listOpenSessions({
    required String storeId,
    required String accessToken,
  }) async {
    lastAccessToken = accessToken;
    return const [];
  }

  @override
  Future<List<StoreTableModel>> listTables({
    required String storeId,
    required String accessToken,
  }) async {
    lastAccessToken = accessToken;
    return const [];
  }

  @override
  Future<void> reopenClosedSession({
    required String storeId,
    required String sessionId,
    required String accessToken,
  }) async {
    lastAccessToken = accessToken;
    reopenedSessionId = sessionId;
  }
}

final class _FakeAuthLocalDataSource implements AuthLocalDataSource {
  _FakeAuthLocalDataSource() : _session = _defaultSession;

  _FakeAuthLocalDataSource.dev() : _session = _developmentSession;

  final AuthSessionModel _session;

  @override
  Future<void> clearSession() async {}

  @override
  Future<AuthSessionModel?> readSession() async => _session;

  @override
  Future<void> saveSession(AuthSessionModel session) async {}
}

const _defaultSession = AuthSessionModel(
  accessToken: 'access-token',
  refreshToken: 'refresh-token',
  userName: 'Merchant',
  userEmail: 'merchant@test.com',
  role: 'MERCHANT',
);

const _developmentSession = AuthSessionModel(
  accessToken: 'dev-garcom-token',
  refreshToken: 'dev-garcom-refresh',
  userName: 'Garcom Teste',
  userEmail: 'garcon@teste.com',
  role: 'MERCHANT',
);
