import 'dart:convert';

import 'package:pdvmobile/core/network/key_value_store.dart';
import 'package:pdvmobile/features/auth/data/models/auth_session_model.dart';

abstract interface class AuthLocalDataSource {
  Future<void> saveSession(AuthSessionModel session);

  Future<AuthSessionModel?> readSession();

  Future<void> clearSession();
}

class SecureStorageAuthLocalDataSource implements AuthLocalDataSource {
  SecureStorageAuthLocalDataSource(this._store);

  static const _sessionKey = 'auth.session';

  final KeyValueStore _store;

  @override
  Future<void> clearSession() {
    return _store.delete(_sessionKey);
  }

  @override
  Future<AuthSessionModel?> readSession() async {
    final rawValue = await _store.read(_sessionKey);
    if (rawValue == null || rawValue.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(rawValue);
    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    return AuthSessionModel.fromStorageMap(decoded);
  }

  @override
  Future<void> saveSession(AuthSessionModel session) {
    final value = jsonEncode(session.toStorageMap());
    return _store.write(_sessionKey, value);
  }
}
