import 'package:cashback_farms/common/api_constant.dart';
import 'package:cashback_farms/common/model/logger_model.dart';
import 'package:cashback_farms/features/legal_and_policies/model.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

class LegalAndPoliciesController extends GetxController {
  var isLoading = false.obs;
  var pageData = LegalAndPoliciesModel().obs;

  final Dio _dio = Dio();

  Future<void> getPage(String slug) async {
    try {
      isLoading.value = true;
      final response = await _dio.get("${ApiUrl.baseUrl}/api/v2/pages/slug/$slug",);
      if (response.data['status'] == true) {
        pageData.value = LegalAndPoliciesModel.fromJson(response.data['data']);
      }
    } catch (e) {
      Loggers.error("Error ==> $e");
    } finally {
      isLoading.value = false;
    }
  }
}