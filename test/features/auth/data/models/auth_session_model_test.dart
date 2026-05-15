import 'package:flutter_test/flutter_test.dart';
import 'package:pdvmobile/features/auth/data/models/auth_session_model.dart';

void main() {
  group('AuthSessionModel', () {
    test('mapeia o payload real do login da API', () {
      final model = AuthSessionModel.fromLoginJson(const {
        'token': 'access-token',
        'refreshToken': 'refresh-token',
        'name': 'Merchant',
        'email': 'merchant@test.com',
        'role': 'MERCHANT',
      });

      expect(model.accessToken, 'access-token');
      expect(model.refreshToken, 'refresh-token');
      expect(model.userName, 'Merchant');
      expect(model.userEmail, 'merchant@test.com');
      expect(model.role, 'MERCHANT');
    });

    test('serializa e desserializa a sessao para armazenamento local', () {
      const model = AuthSessionModel(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
        userName: 'Merchant',
        userEmail: 'merchant@test.com',
        role: 'MERCHANT',
      );

      final map = model.toStorageMap();
      final restored = AuthSessionModel.fromStorageMap(map);

      expect(restored, model);
    });
  });
}
