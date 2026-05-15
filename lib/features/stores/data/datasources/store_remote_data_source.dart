import 'package:pdvmobile/core/network/api_client.dart';
import 'package:pdvmobile/features/stores/data/models/store_summary_model.dart';

abstract interface class StoreRemoteDataSource {
  Future<List<StoreSummaryModel>> listStores({
    required String accessToken,
  });
}

class HttpStoreRemoteDataSource implements StoreRemoteDataSource {
  const HttpStoreRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<List<StoreSummaryModel>> listStores({
    required String accessToken,
  }) async {
    final response = await _apiClient.get(
      '/stores',
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response is! List) {
      throw const FormatException('Resposta invalida para lojas');
    }

    return response
        .whereType<Map<String, dynamic>>()
        .map(StoreSummaryModel.fromJson)
        .toList();
  }
}
