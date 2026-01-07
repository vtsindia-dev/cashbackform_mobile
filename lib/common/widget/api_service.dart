import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../api_constant.dart';
class ApiService {
  static final dio = Dio(
    BaseOptions(
      connectTimeout: Duration(seconds: 20),
      receiveTimeout: Duration(seconds: 20),
      headers: {"Accept": "application/json"},
      validateStatus: (status) => true,
    ),
  );
  static Future<Response> getRequest(String url, {Map<String, String>? headers}) async {
    try {
      final options = headers != null ? Options(headers: headers) : null;
      return await dio.get(url, options: options);
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!;
      }
      rethrow;
    }
  }
  static Future<Response> getAuthenticatedRequest(String url, String token) async {
    try {
      return await dio.get(
        url,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );
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
  static Future<Response> deleteRequest(String url) async {
    try {
      return await dio.delete(url);
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!;
      }
      rethrow;
    }
  }
  static Future<Response> putRequest(String url, Map<String, dynamic> data) async {
    try {
      return await dio.put(url, data: data);
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!;
      }
      rethrow;
    }
  }
  static Future<Response> putMultipart(String url, FormData formData) async {
    try {
      return await dio.put(url, data: formData);
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!;
      }
      rethrow;
    }
  }
  static Future<Response> getProfile(String token) async {
    try {
      return await dio.get(
        ApiUrl.getProfile,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );
    } on DioException catch (e) {
      return _createErrorResponse(
        path: ApiUrl.getProfile,
        error: e,
        defaultMessage: 'Failed to fetch profile',
      );
    }
  }

  static Future<Response> updateProfile({
    required Map<String, dynamic> data,
    required String token,
    File? profileImage,
  }) async {
    try {
      FormData formData = FormData.fromMap(data);
      if (profileImage != null) {
        formData.files.add(
          MapEntry(
            "image",
            await MultipartFile.fromFile(profileImage.path),
          ),
        );
      }
      return await dio.post(
        ApiUrl.profileUpdate,
        data: formData,
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );
    } on DioException catch (e) {
      return _createErrorResponse(
        path: ApiUrl.profileUpdate,
        error: e,
        defaultMessage: 'Failed to update profile',
      );
    }
  }
  static Future<Response> submitMaterialEnquiry({
    required String name,
    required int materialId,
    required String phone,
    required String quote,
    String? token,
  }) async {
    return _submitEnquiry(
      endpoint: ApiUrl.materialEnquiry,
      data: {
        'name': name,
        'material_id': materialId.toString(),
        'phone': phone,
        'quote': quote,
      },
      token: token,
    );
  }
  static Future<Response> submitServiceEnquiry({
    required String name,
    required int serviceId,
    required String phone,
    required String message,
    String? token,
  }) async {
    return _submitEnquiry(
      endpoint: ApiUrl.serviceEnquiry,
      data: {
        'name': name,
        'service_id': serviceId.toString(),
        'phone': phone,
        'message': message,
      },
      token: token,
    );
  }

  static Future<Response> submitPlotEnquiry({
    required String name,
    required int plotId,
    required String phone,
    required String message,
    String? token,
    String plotType = 'market',
  }) async {
    return _submitEnquiry(
      endpoint: ApiUrl.plotEnquiry,
      data: {
        'name': name,
        'plot_id': plotId.toString(),
        'plot_type': plotType,
        'phone': phone,
        'message': message,
      },
      token: token,
    );
  }
  static Future<Response> submitEnquiry({
    required String endpoint,
    required Map<String, dynamic> data,
    String? token,
  }) async {
    return _submitEnquiry(
      endpoint: endpoint,
      data: data,
      token: token,
    );
  }
  static Future<Response> _submitEnquiry({
    required String endpoint,
    required Map<String, dynamic> data,
    String? token,
  }) async {
    try {
      final formData = FormData.fromMap(data);

      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'multipart/form-data',
      };

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      return await dio.post(
        endpoint,
        data: formData,
        options: Options(headers: headers),
      );
    } on DioException catch (e) {
      return _createErrorResponse(
        path: endpoint,
        error: e,
        defaultMessage: 'Failed to submit enquiry',
      );
    }
  }
  static Future<Response> getMaterialDetail(int materialId) async {
    try {
      return await dio.get('${ApiUrl.materialDetail}/$materialId');
    } on DioException catch (e) {
      return _createErrorResponse(
        path: '${ApiUrl.materialDetail}/$materialId',
        error: e,
        defaultMessage: 'Failed to fetch material details',
      );
    }
  }
  static Future<Response> getServiceDetail(int serviceId) async {
    try {
      return await dio.get('${ApiUrl.serviceDetail}/$serviceId');
    } on DioException catch (e) {
      return _createErrorResponse(
        path: '${ApiUrl.serviceDetail}/$serviceId',
        error: e,
        defaultMessage: 'Failed to fetch service details',
      );
    }
  }
  static Response _createErrorResponse({
    required String path,
    required DioException error,
    required String defaultMessage,
  }) {
    return error.response ?? Response(
      requestOptions: RequestOptions(path: path),
      statusCode: 500,
      statusMessage: 'Network error',
      data: {
        'success': false,
        'message': error.message ?? defaultMessage,
        'data': null,
      },
    );
  }
  static void updateBaseUrl(String newBaseUrl) {

  }
  static String getCurrentBaseUrl() {
    return ApiUrl.baseUrl;
  }
  // Add this to your ApiService class
  static Future<Response> postRequestWithToken(
      String url,
      {
        required Map<String, dynamic> data,
        required String token,
      }
      ) async {
    try {
      final options = Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      return await dio.post(
        url,
        data: jsonEncode(data),
        options: options,
      );
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!;
      }
      rethrow;
    }
  }

// Or if you prefer FormData (for file uploads)
  static Future<Response> postFormDataWithToken(
      String url,
      {
        required Map<String, dynamic> data,
        required String token,
      }
      ) async {
    try {
      final formData = FormData.fromMap(data);

      final options = Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        },
      );

      return await dio.post(
        url,
        data: formData,
        options: options,
      );
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!;
      }
      rethrow;
    }
  }
  // In your ApiService class
  static Future<Response> EnquirypostRequest(String url, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final options = Options(
        headers: headers,
        contentType: Headers.jsonContentType,
      );

      return await dio.post(
        url,
        data: data,
        options: options,
      );
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!;
      }
      rethrow;
    }
  }
}