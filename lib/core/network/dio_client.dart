import 'package:dio/dio.dart';
import 'package:e_ticketing/core/services/local_storage_service.dart';

class DioClient {
  late final Dio _dio;
  final LocalStorageService _storage = LocalStorageService();

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl:
            'https://api-dummy.com/api', // Ganti dengan URL API backend nanti
        connectTimeout: const Duration(seconds: 15),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }
  Dio get dio => _dio;
}
