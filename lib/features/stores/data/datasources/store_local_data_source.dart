import 'package:pdvmobile/core/network/key_value_store.dart';

abstract interface class StoreLocalDataSource {
  Future<String?> readSelectedStoreId();

  Future<void> saveSelectedStoreId(String storeId);
}

class KeyValueStoreLocalDataSource implements StoreLocalDataSource {
  KeyValueStoreLocalDataSource(this._store);

  static const _selectedStoreIdKey = 'store.selected_id';

  final KeyValueStore _store;

  @override
  Future<String?> readSelectedStoreId() {
    return _store.read(_selectedStoreIdKey);
  }

  @override
  Future<void> saveSelectedStoreId(String storeId) {
    return _store.write(_selectedStoreIdKey, storeId);
  }
}
