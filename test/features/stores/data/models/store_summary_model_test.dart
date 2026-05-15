import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/features/stores/data/models/store_summary_model.dart';

void main() {
  group('StoreSummaryModel', () {
    test('mapeia a resposta real de lojas da API', () {
      final model = StoreSummaryModel.fromJson(const {
        'id': 'store-1',
        'name': 'Loja PDV 1234',
        'slug': 'loja-pdv-1234',
        'open': true,
        'tableMode': 'DISABLED',
        'acceptedPayments': ['PIX', 'CASH'],
      });

      expect(model.id, 'store-1');
      expect(model.name, 'Loja PDV 1234');
      expect(model.slug, 'loja-pdv-1234');
      expect(model.isOpen, isTrue);
      expect(model.tableMode, 'DISABLED');
      expect(model.acceptedPayments, ['PIX', 'CASH']);
    });
  });
}
