import 'package:dio/dio.dart';
import 'package:pdvmobile/core/error/app_exception.dart';

abstract interface class ApiClient {
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
  });

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  });
}

class DioApiClient implements ApiClient {
  DioApiClient({
    required String baseUrl,
    Dio? dio,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                contentType: 'application/json',
              ),
            );

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        options: Options(headers: headers),
      );

      return response.data ?? <String, dynamic>{};
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  @override
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        options: Options(headers: headers),
      );

      return response.data ?? <String, dynamic>{};
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  AppException _mapDioException(DioException error) {
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'];
      if (message is String && message.isNotEmpty) {
        return AppException(
          message,
          statusCode: error.response?.statusCode,
        );
      }
    }

    return AppException(
      'Falha ao comunicar com o servidor',
      statusCode: error.response?.statusCode,
    );
  }
}
