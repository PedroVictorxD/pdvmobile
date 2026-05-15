import 'package:pdvmobile/features/stores/domain/entities/store_summary.dart';

abstract interface class StoreRepository {
  Future<List<StoreSummary>> listStores();

  Future<String?> readSelectedStoreId();

  Future<void> saveSelectedStoreId(String storeId);
}
