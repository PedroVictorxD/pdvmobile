import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';
import 'package:pdvmobile/features/stores/domain/repositories/store_repository.dart';
import 'package:pdvmobile/features/stores/presentation/store_selection_gate.dart';

void main() {
  group('StoreSelectionGate', () {
    testWidgets('mostra a selecao quando nao existe loja salva', (
      WidgetTester tester,
    ) async {
      final repository = _FakeStoreRepository();

      await tester.pumpWidget(_buildApp(repository));
      await tester.pumpAndSettle();

      expect(find.text('Selecionar loja'), findsOneWidget);
      expect(find.text('Loja Centro'), findsOneWidget);
      expect(find.text('Loja Praia'), findsOneWidget);
    });

    testWidgets('entra direto quando existe loja previamente salva', (
      WidgetTester tester,
    ) async {
      final repository = _FakeStoreRepository(selectedStoreId: 'store-2');

      await tester.pumpWidget(_buildApp(repository));
      await tester.pumpAndSettle();

      expect(find.text('Loja ativa: Loja Praia'), findsOneWidget);
      expect(find.text('Selecionar loja'), findsNothing);
    });

    testWidgets('salva a escolha e entra no app', (
      WidgetTester tester,
    ) async {
      final repository = _FakeStoreRepository();

      await tester.pumpWidget(_buildApp(repository));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Entrar nesta loja').first);
      await tester.pumpAndSettle();

      expect(repository.savedStoreId, 'store-1');
      expect(find.text('Loja ativa: Loja Centro'), findsOneWidget);
    });
  });
}

Widget _buildApp(StoreRepository repository) {
  return MaterialApp(
    home: StoreSelectionGate(
      storeRepository: repository,
      onStoreSelected: (context, store) => Scaffold(
        body: Center(
          child: Text('Loja ativa: ${store.name}'),
        ),
      ),
    ),
  );
}

final class _FakeStoreRepository implements StoreRepository {
  _FakeStoreRepository({this.selectedStoreId});

  final String? selectedStoreId;
  String? savedStoreId;

  @override
  Future<List<StoreSummary>> listStores() async {
    return const [
      StoreSummary(
        id: 'store-1',
        name: 'Loja Centro',
        slug: 'loja-centro',
        isOpen: true,
        tableMode: 'TAB',
        acceptedPayments: ['PIX', 'CASH'],
      ),
      StoreSummary(
        id: 'store-2',
        name: 'Loja Praia',
        slug: 'loja-praia',
        isOpen: true,
        tableMode: 'INSTANT',
        acceptedPayments: ['PIX'],
      ),
    ];
  }

  @override
  Future<String?> readSelectedStoreId() async => selectedStoreId ?? savedStoreId;

  @override
  Future<void> saveSelectedStoreId(String storeId) async {
    savedStoreId = storeId;
  }
}
