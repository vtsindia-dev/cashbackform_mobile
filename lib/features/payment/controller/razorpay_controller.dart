import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../common/api_constant.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';
import '../../gioo_plots/controller/gioo_controller.dart';
import '../../syndicate_plot/controller/syndicate_controller.dart';
import '../../plot_market/controller/plot_market_controller.dart';
import '../success.dart';

// ✅ Use Enum for strict type safety
enum PaymentType {
  plotPayment,
  documentPayment,
  giooPayment,
  marketVerification,
}

class RazorpayController extends GetxController {
  late Razorpay _razorpay;
  var isProcessing = false.obs;
  var paymentResponse = Rxn<Map<String, dynamic>>();
  var paymentID = "";
  var currentPaymentType = PaymentType.plotPayment.obs;
  var isTermsAccepted = false.obs;
  final _currentPaymentUrl = ''.obs;
  var propertyId = 0.obs;
  var selectedUnits = <int>[].obs;
  var totalAmount = 0.0.obs;
  var unitDetails = <Map<String, dynamic>>[].obs;
  var propertyName = ''.obs;
  var propertyType = ''.obs;
  var documentAmount = 0.0.obs;
  var documentId = 0.obs;
  var documentType = ''.obs;
  var marketPlotId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void setupPlotPayment({
    required String type,
    required int propertyId,
    required List<int> units,
    required double amount,
    String propertyName = '',
    List<Map<String, dynamic>>? unitDetails,
  }) {
    this.propertyType.value = type;
    this.propertyId.value = propertyId;
    this.selectedUnits.value = List.from(units);
    this.propertyName.value = propertyName;
    this.totalAmount.value = amount;
    this.unitDetails.value = unitDetails != null ? List.from(unitDetails) : [];

    if (type == 'syndicate') {
      currentPaymentType.value = PaymentType.plotPayment;
      _currentPaymentUrl.value = '${ApiUrl.baseUrl}/api/v2/syndicate_pay';
    } else if (type == 'gioo') {
      currentPaymentType.value = PaymentType.giooPayment;
      _currentPaymentUrl.value = '${ApiUrl.baseUrl}/api/v2/gioo_pay';
    }
    isTermsAccepted.value = false;
  }

  void setupDocumentPayment({
    required int propertyId,
    required int documentId,
    required String documentType,
    required double amount,
  }) {
    this.propertyId.value = propertyId;
    this.documentId.value = documentId;
    this.documentType.value = documentType;
    this.documentAmount.value = amount;
    currentPaymentType.value = PaymentType.documentPayment;
    _currentPaymentUrl.value = '${ApiUrl.baseUrl}/api/v2/syndicate_document_pay';
    isTermsAccepted.value = false;
  }

  void setupMarketVerificationPayment({
    required int marketPlotId,
    required double amount,
    required String propertyName,
  }) {
    this.marketPlotId.value = marketPlotId;
    this.totalAmount.value = amount;
    this.propertyName.value = propertyName;
    currentPaymentType.value = PaymentType.marketVerification;
    _currentPaymentUrl.value = '${ApiUrl.baseUrl}/api/v2/market_plot_verify';
    isTermsAccepted.value = false;
  }

  void toggleTerms() => isTermsAccepted.value = !isTermsAccepted.value;

  void openCheckout({
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required int amount,
    String description = "",
  }) {
    if (!isTermsAccepted.value) {
      SnackBarHelper.showError("Please accept terms and conditions");
      return;
    }

    try {
      isProcessing.value = true;
      var options = {
        'key': 'rzp_test_t8LKc2rPhJVv2N',
        'amount': amount,
        'name': customerName,
        'description': description,
        'prefill': {'contact': customerPhone, 'email': customerEmail},
        'theme': {"color": "#4338CA"},
        'notes': {
          'property_id': propertyId.value.toString(),
          'payment_type': currentPaymentType.value.name, // Access enum name
        }
      };
      _razorpay.open(options);
    } catch (e) {
      isProcessing.value = false;
      SnackBarHelper.showError("Initialization failed: $e");
    }
  }

  Future<void> _handleSuccess(PaymentSuccessResponse response) async {
    try {
      paymentID = response.paymentId ?? "N/A";
      _showVerifyingOverlay();

      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        Get.offAllNamed('/login');
        return;
      }

      switch (currentPaymentType.value) {
        case PaymentType.plotPayment:
          await _handleSyndicatePaymentSuccess(response, token);
          break;
        case PaymentType.giooPayment:
          await _handleGiooPaymentSuccess(response, token);
          break;
        case PaymentType.documentPayment:
          await _handleDocumentPaymentSuccess(response, token);
          break;
        case PaymentType.marketVerification:
          await _handleMarketVerificationSuccess(response, token);
          break;
      }

      if (Get.isDialogOpen ?? false) Get.back();

      // ✅ Pass the enum value directly, NOT .toString()
      Get.off(() => PaymentSuccessScreen(
        amount: currentPaymentType.value == PaymentType.documentPayment
            ? documentAmount.value
            : totalAmount.value,
        transactionId: paymentID,
        type: currentPaymentType.value,
      ));

    } catch (e) {
      _showSyncErrorSheet(e.toString());
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> _handleSyndicatePaymentSuccess(PaymentSuccessResponse response, String token) async {
    final apiResponse = await ApiService.postRequestWithToken(
      _currentPaymentUrl.value,
      token: token,
      data: {
        'status': 'success',
        'payment_id': response.paymentId,
        'amount': totalAmount.value.toStringAsFixed(2),
        'property_id': propertyId.value.toString(),
        'units': selectedUnits.join(','),
      },
    );
    if (apiResponse.statusCode == 200) {
      _markSyndicatePlotsAsBooked();
    } else {
      throw Exception(apiResponse.data?['message'] ?? 'Sync failed');
    }
  }

  Future<void> _handleGiooPaymentSuccess(PaymentSuccessResponse response, String token) async {
    final apiResponse = await ApiService.postRequestWithToken(
      _currentPaymentUrl.value,
      token: token,
      data: {
        'status': 'success',
        'payment_id': response.paymentId,
        'amount': totalAmount.value.toStringAsFixed(2),
        'property_id': propertyId.value.toString(),
        'units': selectedUnits.join(','),
      },
    );
    if (apiResponse.statusCode == 200) {
      _markGiooUnitsAsBooked();
    } else {
      throw Exception(apiResponse.data?['message'] ?? 'Sync failed');
    }
  }

  Future<void> _handleDocumentPaymentSuccess(PaymentSuccessResponse response, String token) async {
    final apiResponse = await ApiService.postRequestWithToken(
      _currentPaymentUrl.value,
      token: token,
      data: {
        'status': 'success',
        'payment_id': response.paymentId,
        'amount': documentAmount.value.toStringAsFixed(2),
        'property_id': propertyId.value.toString(),
      },
    );
    if (apiResponse.statusCode != 200) throw Exception('Document sync failed');
  }

  Future<void> _handleMarketVerificationSuccess(PaymentSuccessResponse response, String token) async {
    final apiResponse = await ApiService.postRequestWithToken(
      _currentPaymentUrl.value,
      token: token,
      data: {
        'status': 'success',
        'payment_id': response.paymentId,
        'amount': totalAmount.value.toStringAsFixed(2),
        'property_id': marketPlotId.value.toString(),
      },
    );
    if (apiResponse.statusCode == 200) {
      Get.find<PlotMarketController>().fetchMarketPlots();
    } else {
      throw Exception('Verification sync failed');
    }
  }

  void _showVerifyingOverlay() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 40.w),
            padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // High-end custom loader or branded color
                const SizedBox(
                  height: 48,
                  width: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4338CA)),
                    backgroundColor: Color(0xFFE2E8F0),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  "Secure Verification",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                    decoration: TextDecoration.none, // Removes yellow underline in dialogs
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "We're confirming your details with the bank. This usually takes a few seconds.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.5,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.normal,
                    decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
    );
  }
  void _showSyncErrorSheet(String error) {
    if (Get.isDialogOpen ?? false) Get.back();

    Get.bottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      Container(
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            SizedBox(height: 24.h),

            // Alert Icon with Glow
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.sync_problem_rounded, color: Colors.amber.shade800, size: 45.sp),
            ),
            SizedBox(height: 20.h),

            Text(
              "Syncing Issue",
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B)),
            ),
            SizedBox(height: 12.h),

            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(fontSize: 14.sp, color: Colors.blueGrey[600], height: 1.5),
                children: [
                  const TextSpan(text: "Your payment"),
                  const TextSpan(text: " was successful, but your plot status hasn't updated yet."),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Error Details Box
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildErrorRow("Payment ID", paymentID ?? "N/A", isCopyable: true),
                  const Divider(height: 24),
                  _buildErrorRow("Status", "Pending Update", color: Colors.orange),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    child: Text("Dismiss", style: TextStyle(color: Colors.blueGrey[800], fontWeight: FontWeight.w600)),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      // Optional: Link to a help/WhatsApp support
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    child: Text("Contact Support", style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorRow(String label, String value, {bool isCopyable = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.blueGrey[400], fontWeight: FontWeight.w500)),
        Row(
          children: [
            Text(value, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: color ?? const Color(0xFF1E293B))),
            if (isCopyable) ...[
              SizedBox(width: 8.w),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  Get.snackbar("Copied", "Payment ID copied to clipboard",
                      snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 1));
                },
                child: Icon(Icons.copy_rounded, size: 14.sp, color: Colors.blue),
              )
            ]
          ],
        ),
      ],
    );
  }
  void _markSyndicatePlotsAsBooked() {
    final sc = Get.find<SyndicatePlotController>();
    for (var id in selectedUnits) {
      int idx = sc.plots.indexWhere((p) => p["id"] == id);
      if (idx != -1) sc.plots[idx]["status"] = "booked";
    }
    sc.update();
  }

  void _markGiooUnitsAsBooked() {
    final gc = Get.find<GiooPlotController>();
    for (var id in selectedUnits) {
      int idx = gc.units.indexWhere((u) => u.id == id);
      if (idx != -1) gc.units[idx] = gc.units[idx].copyWith(status: 'Booked');
    }
    gc.units.refresh();
  }

  void _handleError(PaymentFailureResponse response) {
    isProcessing.value = false;
    SnackBarHelper.showError(response.message ?? "Payment Cancelled");
  }

  void _handleExternalWallet(ExternalWalletResponse response) => isProcessing.value = false;

  Future<void> initiatePayment() async {
    final userData = await SessionManager.getUserData();
    if (userData == null) return;

    int rawAmount = (currentPaymentType.value == PaymentType.documentPayment
        ? (documentAmount.value * 100).toInt()
        : (totalAmount.value * 100).toInt());

    openCheckout(
      customerName: "${userData['first_name']} ${userData['last_name']}",
      customerEmail: userData['email'] ?? "",
      customerPhone: userData['phone'] ?? "",
      amount: rawAmount,
      description: "Payment for $propertyName",
    );
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }
}