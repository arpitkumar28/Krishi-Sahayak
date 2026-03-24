import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiClient {
  final Dio _dio;
  
  // Your backend is live on Render
  static const String baseUrl = 'https://krishi-backend-1-3a18.onrender.com';

  ApiClient(this._dio) {
    _dio.options.baseUrl = baseUrl;
    // Reduced timeouts for better responsiveness
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (kDebugMode) {
          print('🌐 [API REQUEST] ${options.method} ${options.uri}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('✅ [API RESPONSE] ${response.statusCode}');
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (kDebugMode) {
          print('❌ [API ERROR] ${e.type} | ${e.message}');
        }
        return handler.next(e);
      },
    ));
  }

  Future<Response> post(String path, {Map<String, dynamic>? data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> postImage(String path, String filePath, {Map<String, dynamic>? extraData}) async {
    final Map<String, dynamic> map = {
      'file': await MultipartFile.fromFile(filePath),
    };
    if (extraData != null) {
      map.addAll(extraData);
    }
    
    final formData = FormData.fromMap(map);
    return await _dio.post(path, data: formData);
  }

  Future<Response> get(String path) async {
    return await _dio.get(path);
  }
}

final apiClientProvider = Provider((ref) => ApiClient(Dio()));
