import 'package:cashback_farms/common/model/logger_model.dart';
import 'package:cashback_farms/common/widget/toster.dart';
import 'package:cashback_farms/features/gift_coupon_and_encashment/model/encashment_model.dart';
import 'package:cashback_farms/repository/user_repository.dart';
import 'package:get/get.dart';

class EncashmentController extends GetxController {

  final UserRepository repo = UserRepository();

  bool isAppliedCoupon = false;
  bool isAppliedLoading = false;
  bool isShowForm = false;

  double couponDiscount = 0;
  double totalAmount = 0;
  double finalAmount = 0;

  Future<void> checkCoupon({
    required String couponCode,
  }) async {
    try {
      isAppliedLoading = true;
      update();

      final response = await repo.enhanceCouponCheckApi(code: couponCode);

      if (response['result'] == true) {
        final data = response['data'];
        couponDiscount = (data['coupon_discount'] ?? 0).toDouble();
        totalAmount = double.tryParse(data['total_amount'].toString()) ?? 0;
        finalAmount = (data['total_after_discount'] ?? 0).toDouble();
        isAppliedCoupon = true;
        isShowForm = true;
        SnackBarHelper.showSuccess('Coupon applied successfully. Complete the form to continue.');
        update();
      } else {
        SnackBarHelper.showError(response['message'] ?? 'Something went wrong, please try again.');
      }
    } catch (e) {
      Loggers.error('Error : $e');
      SnackBarHelper.showError('An error occurred, please try again.');
    } finally {
      isAppliedLoading = false;
      update();
    }
  }

  void removeCoupon({bool showMessage = true}) {
    isAppliedCoupon = false;
    isShowForm = false;
    couponDiscount = 0;
    totalAmount = 0;
    finalAmount = 0;
    update();
    if (showMessage == true) {
      SnackBarHelper.showInfo('Coupon removed successfully');
    }
  }

  bool isFormLoading = false;

  Future<bool> submitEncashment({
    required String code,
    required String paymentType,
    required String amount,
    required String tax,
    required String total,
    String? upiId,
    String? upiPhone,
    String? bankName,
    String? accountNumber,
    String? ifsc,
    String? beneficiary,
    String? bankPhone,
  }) async {
    try {
      isFormLoading = true;
      update();

      final response = await repo.encashmentSubmitApi(
        body: {
          "code": code,
          "payment_type": paymentType == "upi" ? "upi" : paymentType,
          "amount": amount,
          "tax": tax,
          "total": total,
          "gpay_upi_id": upiId,
          "gpay_phone_number": upiPhone,
          "bank_name": bankName,
          "bank_account_number": accountNumber,
          "bank_ifsc_code": ifsc,
          "bank_beneficiary_name": beneficiary,
          "bank_phone_number": bankPhone,
        },
      );

      if (response['result'] == true) {
        SnackBarHelper.showSuccess('Encashment request submitted');
        // Refresh the list after successful submission
        await getMyPurchasedVouchersList();
        return true;
      } else {
        SnackBarHelper.showError(response['message'] ?? 'Something went wrong, please try again.');
      }
      return false;
    } catch (e) {
      Loggers.error('Error submitting encashment: $e');
      SnackBarHelper.showError('An error occurred, please try again.');
      return false;
    } finally {
      isFormLoading = false;
      update();
    }
  }

  List<EnCashMentModel>? getMyEnCashMentList;
  bool isMyEnCashMentListLoading = false;

  Future<void> getMyPurchasedVouchersList() async {
    isMyEnCashMentListLoading = true;
    update();
    try {
      final response = await repo.getEnhanceCouponListApi();

      if (response['result'] == true && response['data'] != null) {
        final List<dynamic> jsonList = response['data'];
        getMyEnCashMentList = jsonList.map((e) => EnCashMentModel.fromJson(e)).toList();

        // Debug print to verify data
        print('Loaded ${getMyEnCashMentList?.length} encashment records');
        if (getMyEnCashMentList != null && getMyEnCashMentList!.isNotEmpty) {
          print('First record: ${getMyEnCashMentList!.first.name} - Status: ${getMyEnCashMentList!.first.status} - EnStatus: ${getMyEnCashMentList!.first.enStatus}');
        }
      } else {
        getMyEnCashMentList = [];
        print('No data found or result false: ${response['message']}');
      }
      update();
    } catch (e) {
      getMyEnCashMentList = [];
      Loggers.error('Error fetching encashment list: $e');
      update();
    } finally {
      isMyEnCashMentListLoading = false;
      update();
    }
  }

  // Helper method to get filtered list based on status
  List<EnCashMentModel> getFilteredList({int? status, int? enStatus}) {
    if (getMyEnCashMentList == null) return [];

    return getMyEnCashMentList!.where((item) {
      if (status != null && item.status != status) return false;
      if (enStatus != null && item.enStatus != enStatus) return false;
      return true;
    }).toList();
  }

  // Helper method to get summary statistics
  Map<String, dynamic> getSummary() {
    if (getMyEnCashMentList == null || getMyEnCashMentList!.isEmpty) {
      return {
        'total': 0,
        'success': 0,
        'pending': 0,
        'failed': 0,
        'rejected': 0,
      };
    }

    int success = getMyEnCashMentList!.where((item) => item.status == 1).length;
    int pending = getMyEnCashMentList!.where((item) => item.status == 0).length;
    int failed = getMyEnCashMentList!.where((item) => item.status == 2).length;
    int rejected = getMyEnCashMentList!.where((item) => item.reuse == 1).length;

    return {
      'total': getMyEnCashMentList!.length,
      'success': success,
      'pending': pending,
      'failed': failed,
      'rejected': rejected,
    };
  }
}