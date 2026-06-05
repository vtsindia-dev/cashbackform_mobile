import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';

import '../../../common/api_constant.dart';
import '../../../common/route/router.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';

class DeleteAccountController extends GetxController {
  final RxBool isDeleting = false.obs;

  Future<void> deleteAccount() async {
    if (isDeleting.value) return;

    try {
      isDeleting(true);

      // 🔐 Get token manually
      final token = await SessionManager.getToken();

      // 🔐 Get user ID from session
      final userId = await SessionManager.getUserId();

      if (userId == null || userId.isEmpty) {
        SnackBarHelper.showError('User not found. Please login again.');
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      // Option 1: Send as query parameter
      final response = await dio.Dio().post(
        '${ApiUrl.removeAccount}?id=$userId',
        options: dio.Options(
          headers: {
            "Accept": "application/json",
            if (token != null && token.isNotEmpty)
              "Authorization": "Bearer $token",
          },
        ),
      );

      // Check for both 200 and 201 status codes
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null &&
          response.data['status'] == 200) {

        final message =
            response.data['message'] ?? 'Account has been removed!';

        SnackBarHelper.showSuccess(message);

        // 🔥 Clear session
        await SessionManager.clearSession();

        // 🔥 Redirect to login
        Get.offAllNamed(AppRoutes.login);
      } else {
        final errorMessage =
            response.data?['message'] ?? 'Unable to delete account';
        SnackBarHelper.showError(errorMessage);
      }
    } catch (e) {
      SnackBarHelper.showError('Network error. Please try again.');
      print('❌ Delete account exception: $e');
    } finally {
      isDeleting(false);
    }
  }
}