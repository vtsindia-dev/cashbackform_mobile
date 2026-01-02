import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;

import '../../../common/api_constant.dart';


class AboutController extends GetxController {
  var isLoading = false.obs;
  var title = ''.obs;
  var content = ''.obs;

  @override
  void onInit() {
    fetchAboutPage();
    super.onInit();
  }

  Future<void> fetchAboutPage() async {
    isLoading.value = true;

    try {
      final response = await dio.Dio().get(
        ApiUrl.aboutUs,
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
      Get.snackbar('Error', 'Failed to load About Us page');
    } finally {
      isLoading.value = false;
    }
  }
}
