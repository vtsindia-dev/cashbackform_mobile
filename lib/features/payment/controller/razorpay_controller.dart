import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../common/api_constant.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';
import 'package:flutter/material.dart';
import '../../gioo_plots/controller/gioo_controller.dart';
import '../../syndicate_plot/controller/syndicate_controller.dart';
import '../../plot_market/controller/plot_market_controller.dart';
import '../../plot_market/model/plot_market.dart';

class PaymentType {
  static const String plotPayment = 'plot_payment';
  static const String documentPayment = 'document_payment';
  static const String giooPayment = 'gioo_payment';
  static const String marketVerification = 'market_verification';
}

class RazorpayController extends GetxController {
  late Razorpay _razorpay;
  var isProcessing = false.obs;
  var paymentResponse = Rxn<Map<String, dynamic>>();
  var paymentID = "";
  var currentPaymentType = PaymentType.plotPayment.obs;
  var isTermsAccepted = false.obs;
  var _currentPaymentUrl = ''.obs;
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

    if (unitDetails != null) {
      this.unitDetails.value = List.from(unitDetails);
    } else {
      this.unitDetails.value = [];
    }

    if (type == 'syndicate') {
      currentPaymentType.value = PaymentType.plotPayment;
      _currentPaymentUrl.value = '${ApiUrl.baseUrl}/api/v2/syndicate_pay';
    } else if (type == 'gioo') {
      currentPaymentType.value = PaymentType.giooPayment;
      _currentPaymentUrl.value = '${ApiUrl.baseUrl}/api/v2/gioo_pay';
    }

    isTermsAccepted.value = false;
    print('✅ Setup ${type} payment for property $propertyId, units: $units, amount: $amount');
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
    _currentPaymentUrl.value = '${ApiUrl.baseUrl} ';
    isTermsAccepted.value = false;

    print('✅ Setup market plot VERIFICATION payment for plot $marketPlotId, amount: $amount, name: $propertyName');
  }

  void toggleTerms() {
    isTermsAccepted.value = !isTermsAccepted.value;
  }

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
      String paymentDescription;
      if (description.isNotEmpty) {
        paymentDescription = description;
      } else {
        switch (currentPaymentType.value) {
          case PaymentType.plotPayment:
            paymentDescription = "Syndicate Plot Payment";
            break;
          case PaymentType.giooPayment:
            paymentDescription = "Gioo Plot Payment";
            break;
          case PaymentType.documentPayment:
            paymentDescription = "Document Payment";
            break;
          case PaymentType.marketVerification: // Only verification case
            paymentDescription = "Market Plot Verification";
            break;
          default:
            paymentDescription = "Payment";
        }
      }
      var options = {
        'key': 'rzp_test_t8LKc2rPhJVv2N',
        'amount': amount,
        'name': customerName,
        'description': paymentDescription,
        'prefill': {
          'contact': customerPhone,
          'email': customerEmail,
        },
        'theme': {"color": "#0C7B73"},
        'notes': {
          'property_type': propertyType.value,
          'property_id': propertyId.value.toString(),
          'payment_type': currentPaymentType.value,
          'market_plot_id': marketPlotId.value.toString(),
        }
      };

      print('💳 Opening Razorpay checkout for ${currentPaymentType.value}');
      _razorpay.open(options);
    } catch (e) {
      isProcessing.value = false;
      print("Razorpay ERROR: $e");
      SnackBarHelper.showError("Payment initialization failed: $e");
    }
  }


  Future<void> _handleSuccess(PaymentSuccessResponse response) async {
    try {
      isProcessing.value = true;
      paymentID = response.paymentId ?? "N/A";
      print("✅ Payment Successful: ${response.paymentId}");
      print("📝 Payment Type: ${currentPaymentType.value}");
      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        SnackBarHelper.showError("Session expired. Please login again.");
        Get.offAllNamed('/login');
        isProcessing.value = false;
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
        default:
          throw Exception('Unknown payment type: ${currentPaymentType.value}');
      }

    } catch (e) {
      print(" $e");
      Get.snackbar(
        "Warning",
        "Payment succeeded but sync failed: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> _handleSyndicatePaymentSuccess(PaymentSuccessResponse response, String token) async {
    try {
      final paymentData = {
        'status': 'success',
        'payment_id': response.paymentId ?? 'N/A',
        'transaction_details': 'Razorpay Payment - ${response.paymentId}',
        'amount': totalAmount.value.toStringAsFixed(2),
        'property_id': propertyId.value.toString(),
        'units': selectedUnits.join(','),
      };

      print('📤 Sending syndicate payment data: $paymentData');

      final apiResponse = await ApiService.postRequestWithToken(
        _currentPaymentUrl.value,
        data: paymentData,
        token: token,
      );

      print('📥 API Response Status: ${apiResponse.statusCode}');
      print('📥 API Response Data: ${apiResponse.data}');

      if (apiResponse.statusCode == 200) {
        paymentResponse.value = apiResponse.data is Map<String, dynamic>
            ? apiResponse.data
            : {'message': 'Plot payment recorded successfully'};
        _markSyndicatePlotsAsBooked();
        Get.snackbar(
          "Success",
          "Plot payment successful! Plots reserved.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        showPaymentSuccessDialog(isPlotPayment: true, isGioo: false);
      } else if (apiResponse.statusCode == 401) {
        SnackBarHelper.showError("Session expired. Please login again.");
        await SessionManager.clearSession();
        Get.offAllNamed('/login');
      } else {
        final errorMsg = apiResponse.data?['message'] ?? 'Failed to record payment';
        throw Exception('API Error: $errorMsg');
      }
    } catch (e) {
      print("❌ Syndicate payment processing error: $e");
      rethrow;
    }
  }

  Future<void> _handleGiooPaymentSuccess(PaymentSuccessResponse response, String token) async {
    try {
      final paymentData = {
        'status': 'success',
        'payment_id': response.paymentId ?? 'N/A',
        'transaction_details': 'Razorpay Payment - ${response.paymentId}',
        'amount': totalAmount.value.toStringAsFixed(2),
        'property_id': propertyId.value.toString(),
        'units': selectedUnits.join(','),
      };
      print('📤 Sending Gioo payment data: $paymentData');
      print('🌐 API URL: ${_currentPaymentUrl.value}');

      final apiResponse = await ApiService.postRequestWithToken(
        _currentPaymentUrl.value,
        data: paymentData,
        token: token,
      );
      print('📥 API Response Status: ${apiResponse.statusCode}');
      print('📥 API Response Data: ${apiResponse.data}');
      if (apiResponse.statusCode == 200) {
        paymentResponse.value = apiResponse.data is Map<String, dynamic>
            ? apiResponse.data
            : {'message': 'Gioo plot payment recorded successfully'};
        _markGiooUnitsAsBooked();
        Get.snackbar(
          "Success",
          "Gioo plot payment successful! Units reserved.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        showPaymentSuccessDialog(isPlotPayment: true, isGioo: true);
      } else if (apiResponse.statusCode == 401) {
        SnackBarHelper.showError("Session expired. Please login again.");
        await SessionManager.clearSession();
        Get.offAllNamed('/login');
      } else {
        final errorMsg = apiResponse.data?['message'] ?? 'Failed to record payment';
        throw Exception('API Error: $errorMsg');
      }

    } catch (e) {
      print("❌ Gioo payment processing error: $e");
      rethrow;
    }
  }

  Future<void> _handleDocumentPaymentSuccess(PaymentSuccessResponse response, String token) async {
    try {
      final paymentData = {
        'status': 'success',
        'payment_id': response.paymentId ?? 'N/A',
        'transaction_details': 'Razorpay Document Payment - ${response.paymentId}',
        'amount': documentAmount.value.toStringAsFixed(2),
        'property_id': propertyId.value.toString(),
      };
      print('📤 Sending document payment data: $paymentData');
      final apiResponse = await ApiService.postRequestWithToken(
        _currentPaymentUrl.value,
        data: paymentData,
        token: token,
      );
      print('📥 API Response Status: ${apiResponse.statusCode}');
      print('📥 API Response Data: ${apiResponse.data}');
      if (apiResponse.statusCode == 200) {
        paymentResponse.value = apiResponse.data is Map<String, dynamic>
            ? apiResponse.data
            : {'message': 'Document payment recorded successfully'};
        Get.snackbar(
          "Success",
          "Document payment successful!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        showPaymentSuccessDialog(isPlotPayment: false, isGioo: false);
      } else if (apiResponse.statusCode == 401) {
        SnackBarHelper.showError("Session expired. Please login again.");
        await SessionManager.clearSession();
        Get.offAllNamed('/login');
      } else {
        final errorMsg = apiResponse.data?['message'] ?? 'Failed to record payment';
        throw Exception('API Error: $errorMsg');
      }
    } catch (e) {
      print("❌ Document payment processing error: $e");
      rethrow;
    }
  }

  // Handler for market plot VERIFICATION success
  Future<void> _handleMarketVerificationSuccess(PaymentSuccessResponse response, String token) async {
    try {
      final paymentData = {
        'status': 'success',
        'payment_id': response.paymentId ?? 'N/A',
        'transaction_details': 'Razorpay Verification Payment - ${response.paymentId}',
        'amount': totalAmount.value.toStringAsFixed(2),
        'property_id': marketPlotId.value.toString(),
      };

      print('📤 Sending market verification payment data: $paymentData');
      print('🌐 API URL: ${_currentPaymentUrl.value}');

      final apiResponse = await ApiService.postRequestWithToken(
        _currentPaymentUrl.value,
        data: paymentData,
        token: token,
      );

      print('📥 API Response Status: ${apiResponse.statusCode}');
      print('📥 API Response Data: ${apiResponse.data}');

      if (apiResponse.statusCode == 200) {
        paymentResponse.value = apiResponse.data is Map<String, dynamic>
            ? apiResponse.data
            : {'message': 'Plot verification payment recorded successfully'};

        // Update plot verification status locally
        _updatePlotVerificationStatus();

        Get.snackbar(
          "Success",
          "Verification payment successful! Plot is now under review.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );

        showVerificationSuccessDialog();

      } else if (apiResponse.statusCode == 401) {
        SnackBarHelper.showError("Session expired. Please login again.");
        await SessionManager.clearSession();
        Get.offAllNamed('/login');
      } else {
        final errorMsg = apiResponse.data?['message'] ?? 'Failed to record verification payment';
        throw Exception('API Error: $errorMsg');
      }

    } catch (e) {
      print("❌ Market verification payment processing error: $e");
      rethrow;
    }
  }

  void _updatePlotVerificationStatus() {
    try {
      final plotMarketController = Get.put(PlotMarketController());

      // Find the plot in the list
      final plotIndex = plotMarketController.marketPlots.indexWhere((plot) => plot.id == marketPlotId.value);
      if (plotIndex != -1) {
        // Since MarketPlot is immutable, we need to refresh the list from API
        // The actual status update should come from the backend after verification
        print('✅ Plot ${marketPlotId.value} verification payment recorded');

        // We'll refresh the data from API to get updated status
        plotMarketController.fetchMarketPlots();
      }
    } catch (e) {
      print('❌ Error updating plot verification status: $e');
    }
  }

  void _markSyndicatePlotsAsBooked() {
    try {
      final syndicateController = Get.put(SyndicatePlotController());
      for (final plotId in selectedUnits) {
        final index = syndicateController.plots.indexWhere((plot) => plot["id"] == plotId);
        if (index != -1) {
          syndicateController.plots[index]["status"] = "booked";
        }
      }
      syndicateController.selectedPlots.clear();
      syndicateController.update();
      print('✅ Syndicate plots ${selectedUnits.join(', ')} marked as booked');
    } catch (e) {
      print('❌ Error marking syndicate plots as booked: $e');
    }
  }

  void _markGiooUnitsAsBooked() {
    try {
      final giooController = Get.put(GiooPlotController());
      for (var unitId in selectedUnits) {
        final unitIndex = giooController.units.indexWhere((unit) => unit.id == unitId);
        if (unitIndex != -1) {
          giooController.units[unitIndex] = giooController.units[unitIndex].copyWith(status: 'Booked');
        }
      }
      giooController.selectedUnits.clear();
      giooController.calculateTotals();
      giooController.units.value = List.from(giooController.units);
      print('✅ Gioo units ${selectedUnits.join(', ')} marked as booked');
    } catch (e) {
      print('❌ Error marking Gioo units as booked: $e');
    }
  }

  void _handleError(PaymentFailureResponse response) {
    isProcessing.value = false;
    print("❌ Payment Failed: ${response.message}");
    Get.snackbar(
      "Payment Failed",
      response.message ?? "Payment was cancelled or failed",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    isProcessing.value = false;
    Get.snackbar(
      "External Wallet",
      response.walletName ?? "",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void showPaymentSuccessDialog({required bool isPlotPayment, required bool isGioo}) {
    Get.defaultDialog(
      title: "Payment Successful! 🎉",
      titleStyle: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
      content: Column(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 60.w,
          ),
          SizedBox(height: 15.h),
          Text(
            // "Payment ID: ${paymentResponse.value?['payment_id'] ?? 'N/A'}",
            "Payment ID: ${paymentID}",
            style: TextStyle(fontSize: 12.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            "Amount: ₹${isPlotPayment ? totalAmount.value.toStringAsFixed(2) : documentAmount.value.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          if (isPlotPayment)
            Text(
              "${isGioo ? 'Units' : 'Plots'} Reserved: ${selectedUnits.join(', ')}",
              style: TextStyle(fontSize: 12.sp),
            ),
          if (!isPlotPayment && currentPaymentType.value != PaymentType.marketVerification)
            Text(
              "Document Type: $documentType",
              style: TextStyle(fontSize: 12.sp),
            ),
          if (currentPaymentType.value == PaymentType.marketVerification)
            Text(
              "Plot Verification",
              style: TextStyle(fontSize: 12.sp),
            ),
          SizedBox(height: 8.h),
          Text(
            "Property: $propertyName",
            style: TextStyle(fontSize: 12.sp),
          ),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () {
          Get.back();
          if (isPlotPayment && isGioo) {
            final giooController = Get.put(GiooPlotController());

            if (giooController.giooPlotDetail.value != null) {
              giooController.fetchGiooPlotDetail(giooController.giooPlotDetail.value!.id);
            }
          } else if (isPlotPayment && !isGioo) {
            Get.put(SyndicatePlotController()).fetchSyndicateDetail(propertyId.value);
          } else if (currentPaymentType.value == PaymentType.marketVerification) {
            // Refresh market plots after verification payment
            Get.find<PlotMarketController>().fetchMarketPlots();
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Text(
          "OK",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  // Special dialog for verification success
  void showVerificationSuccessDialog() {
    Get.defaultDialog(
      title: "Verification Started! 🔍",
      titleStyle: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
      content: Column(
        children: [
          Icon(
            Icons.verified_outlined,
            color: Colors.blue,
            size: 60.w,
          ),
          SizedBox(height: 15.h),
          Text(
            "Thank you for verifying your plot!",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            "Payment ID: ${paymentResponse.value?['payment_id'] ?? 'N/A'}",
            style: TextStyle(fontSize: 12.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            "Amount: ₹${totalAmount.value.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Plot: $propertyName",
            style: TextStyle(fontSize: 12.sp),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              "Your plot is now under review. Verification usually takes 2-3 business days.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () {
          Get.back();
          // Refresh the market plots list
          Get.put(PlotMarketController()).fetchMarketPlots();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: Text(
          "OK",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> initiatePayment() async {
    try {
      final userData = await SessionManager.getUserData();
      if (userData == null) {
        SnackBarHelper.showError("Please login to proceed with payment");
        Get.toNamed('/login');
        return;
      }
      final firstName = userData['first_name'] ?? '';
      final lastName = userData['last_name'] ?? '';
      final userName = '$firstName $lastName'.trim();
      final userEmail = userData['email'] ?? '';
      final userPhone = userData['phone'] ?? '';
      final amount = (totalAmount.value * 100).toInt();
      String description;

      switch (currentPaymentType.value) {
        case PaymentType.plotPayment:
          description = "Payment for ${selectedUnits.length} plot(s) in $propertyName";
          break;
        case PaymentType.giooPayment:
          description = "Payment for ${selectedUnits.length} unit(s) in $propertyName";
          break;
        case PaymentType.marketVerification:
          description = "Verification payment for plot: $propertyName";
          break;
        default:
          description = "Document payment for $propertyName";
      }

      openCheckout(
        customerName: userName.isNotEmpty ? userName : 'User',
        customerEmail: userEmail,
        customerPhone: userPhone,
        amount: amount,
        description: description,
      );
    } catch (e) {
      print("❌ Error initiating payment: $e");
      SnackBarHelper.showError("Failed to initiate payment: $e");
    }
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }
}