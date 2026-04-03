import 'package:cashback_farms/common/api_constant.dart';
import 'package:cashback_farms/common/widget/api_service.dart';
import 'package:cashback_farms/common/widget/sessionhandler.dart';
import 'package:cashback_farms/features/gift_coupon_and_encashment/model/model.dart';



class UserRepository {

  Future<Map<String, dynamic>> generateCouponPostApi(
      {required Map<String, dynamic> body}) async {
    final token = await SessionManager.getToken();
    final response = await ApiService.postRequestWithToken(
      ApiUrl.generateCoupon,
      data: body,
      token: token ?? '',
    );
    return response.data;
  }


  Future<CouponListModel> getGiftVouchersApi(String page) async {
    final token = await SessionManager.getToken();
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
    final response = await ApiService.getRequest(
      "${ApiUrl.couponList}?page=$page",
      headers: headers,
    );
    if (response.data != null && response.data['data'] != null) {
      return CouponListModel.fromJson(response.data['data']);
    } else {
      throw Exception("Failed to load coupon list");
    }
  }

  Future<Map<String, dynamic>> enhanceCouponCheckApi(
      {required String code}) async {
    final token = await SessionManager.getToken();
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
    final response = await ApiService.getRequest(
      '${ApiUrl.enhanceCouponCheckApi}?generate_coupon_code=$code',
      headers: headers,
    );
    if (response.data != null) {
      return response.data;
    } else {
      throw Exception("Failed to load coupon list");
    }
  }


  Future<Map<String, dynamic>> encashmentSubmitApi(
      {required Map<String, dynamic> body}) async {
    final token = await SessionManager.getToken();
    final response = await ApiService.postRequestWithToken(
      ApiUrl.enhancePostApi,
      data: body,
      token: token ?? '',
    );
    return response.data;
  }


  Future<Map<String, dynamic>> getEnhanceCouponListApi() async {
    final token = await SessionManager.getToken();
    final userId = await SessionManager.getUserId();
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
    final response = await ApiService.getRequest(
      '${ApiUrl.enhancementListApi}?id=$userId',
      headers: headers,
    );
    if (response.data != null) {
      return response.data;
    } else {
      throw Exception("Failed to load coupon list");
    }
  }
}