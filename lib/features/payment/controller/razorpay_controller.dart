import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayController extends GetxController {
  late Razorpay _razorpay;
  var isProcessing = false.obs;
  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS,_handleSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  void openCheckout({
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required int amount,
    String description = "Payment",
  }) {
    try {
      isProcessing.value = true;
      var options = {
        'key': 'rzp_test_t8LKc2rPhJVv2N',
        'amount': amount,
        'name': customerName,
        'description': description,
        'prefill': {
          'contact': customerPhone,
          'email': customerEmail,
        },
        'theme': {"color": "#0C7B73"},
      };
      _razorpay.open(options);
    } catch (e) {
      isProcessing.value = false;
      print("Razorpay ERROR: $e");
    }
  }
  void _handleSuccess(PaymentSuccessResponse response) {
    isProcessing.value = false;

    print("Payment Successful: ${response.paymentId}");

    Get.snackbar("Success", "Payment successful!");
  }
  void _handleError(PaymentFailureResponse response) {
    isProcessing.value = false;

    print("Payment Failed: ${response.message}");
    Get.snackbar("Failed", "Payment failed.");
  }
  void _handleExternalWallet(ExternalWalletResponse response) {
    isProcessing.value = false;
    Get.snackbar("Wallet", response.walletName ?? "");
  }
  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }
}
