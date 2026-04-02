import 'dart:convert';
import 'package:cashback_farms/common/api_constant.dart';
import 'package:cashback_farms/common/widget/api_service.dart';
import 'package:cashback_farms/common/widget/sessionhandler.dart';
import 'package:cashback_farms/features/gift_coupon_and_encashment/model/model.dart';



class UserRepository {

  Future<Map<String, dynamic>> generateCouponPostApi({required Map<String,dynamic> body}) async {
    final token = await SessionManager.getToken();
    final response = await ApiService.postRequestWithToken(
      ApiUrl.generateCoupon,
      data: body,
      token: token ?? '',
    );
    return jsonDecode(response.data);
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

}