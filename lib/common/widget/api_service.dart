import 'package:dio/dio.dart';

class ApiService {
  static final dio = Dio(
    BaseOptions(
      connectTimeout: Duration(seconds: 20),
      receiveTimeout: Duration(seconds: 20),
      headers: {"Accept": "application/json"},
      validateStatus: (status) => true,
    ),
  );

  static Future<Response> getRequest(String url) async {
    try {
      return await dio.get(url);
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!;
      }
      rethrow;
    }
  }

  static Future<Response> postRequest(String url, Map<String, dynamic> data) async {
    try {
      return await dio.post(url, data: data);
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!;
      }
      rethrow;
    }
  }

  static Future<Response> postMultipart(String url, FormData formData) async {
    try {
      return await dio.post(url, data: formData);
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!;
      }
      rethrow;
    }
  }
}