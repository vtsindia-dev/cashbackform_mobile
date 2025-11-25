import 'package:dio/dio.dart';

class ApiService {
  static final dio = Dio(
    BaseOptions(
      connectTimeout: Duration(seconds: 20),
      receiveTimeout: Duration(seconds: 20),
      headers: {"Accept": "application/json"},
    ),
  );

  static Future<Response> postRequest(String url, Map<String, dynamic> data) async {
    return await dio.post(url, data: data);
  }

  static Future<Response> postMultipart(String url, FormData formData) async {
    return await dio.post(url, data: formData);
  }
}
