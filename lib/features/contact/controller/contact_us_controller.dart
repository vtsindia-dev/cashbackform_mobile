 import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;

import '../../../common/api_constant.dart';


class ContactController extends GetxController {
  var isLoading = false.obs;
  var title = ''.obs;
  var content = ''.obs;

  @override
  void onInit() {
    fetchContactPage();
    super.onInit();
  }

  Future<void> fetchContactPage() async {
    isLoading.value = true;

    try {
      final response = await dio.Dio().get(
        ApiUrl.contactUs, // 👉 contact page API
        options: dio.Options(
          headers: {
            "Accept": "application/json",
          },
        ),
      );

      final data = response.data;

      if (response.statusCode == 200 && data['status'] == true) {
        title.value = data['data']['title'] ?? '';
        content.value = data['data']['content'] ?? '';
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load Contact Us page');
    } finally {
      isLoading.value = false;
    }
  }
}
