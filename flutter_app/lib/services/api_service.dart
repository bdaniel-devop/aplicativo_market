import 'package:dio/dio.dart';
import 'dart:io';

class ApiService {
  late Dio _dio;
  
  // Use 10.0.2.2 for Android Emulator, localhost for others
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/';
    }
    return 'http://localhost:8000/api/';
  }

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
    ));
  }

  Future<Response> getProducts({String? categoryId}) async {
    Map<String, dynamic> query = {};
    if (categoryId != null) query['category'] = categoryId;
    return await _dio.get('products/', queryParameters: query);
  }

  Future<Response> getCategories() async {
    return await _dio.get('categories/');
  }

  Future<Response> login(String email, String password) async {
    // This will be implemented with JWT later
    return await _dio.post('profiles/login/', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> getMe() async {
    return await _dio.get('profiles/me/');
  }
}
