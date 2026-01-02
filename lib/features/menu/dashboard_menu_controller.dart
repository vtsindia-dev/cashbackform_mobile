import 'package:get/get.dart';

import '../../common/api_constant.dart';
import '../../common/widget/api_service.dart';
import '../../common/widget/sessionhandler.dart';
import '../../common/widget/toster.dart';
import 'model/dashboard_model.dart';

class DashboardController extends GetxController {
  // ===============================
  // STATE
  // ===============================

  final RxBool isLoading = false.obs;

  final Rx<Profile?> profile = Rx<Profile?>(null);

  final RxInt myProperties = 0.obs;
  final RxInt marketEnquiryCount = 0.obs;
  final RxInt materialEnquiryCount = 0.obs;
  final RxInt residentialEnquiry = 0.obs;

  final RxList<GiooBooked> giooBooked = <GiooBooked>[].obs;
  final RxList<MarketEnquiry> marketEnquiry = <MarketEnquiry>[].obs;

  bool _isRequestInProgress = false;

  // ===============================
  // LIFECYCLE
  // ===============================

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }

  // ===============================
  // API CALL
  // ===============================

  Future<void> fetchDashboard() async {
    if (_isRequestInProgress) {
      print('⏸️ Dashboard request already in progress');
      return;
    }

    try {
      _isRequestInProgress = true;
      isLoading(true);
      final token = await SessionManager.getToken();
      final response = await ApiService.getRequest(ApiUrl.dashBoard, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200 && response.data?['data'] != null) {
        final data = response.data['data'];

        profile.value = Profile.fromJson(data['profile']);

        myProperties.value = data['myproperties'] ?? 0;
        marketEnquiryCount.value = data['market_enquiry_count'] ?? 0;
        materialEnquiryCount.value = data['material_enquiry_count'] ?? 0;
        residentialEnquiry.value = data['residential_enquiry'] ?? 0;

        giooBooked.assignAll(
          (data['gioo_booked'] as List? ?? [])
              .map((e) => GiooBooked.fromJson(e))
              .toList(),
        );

        marketEnquiry.assignAll(
          (data['market_enquiry'] as List? ?? [])
              .map((e) => MarketEnquiry.fromJson(e))
              .toList(),
        );

        print('✅ Dashboard loaded successfully');
      } else {
        SnackBarHelper.showError('Failed to load dashboard');
        print('❌ Invalid dashboard response: ${response.data}');
      }
    } catch (e) {
      SnackBarHelper.showError('Network error');
      print('❌ Dashboard error: $e');
    } finally {
      isLoading(false);
      _isRequestInProgress = false;
    }
  }

  // ===============================
  // HELPERS
  // ===============================

  void refreshDashboard() {
    fetchDashboard();
  }
}
