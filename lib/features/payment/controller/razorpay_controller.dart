import 'dart:ui';
import 'package:cashback_farms/common/model/logger_model.dart';
import 'package:cashback_farms/features/menu/controller/dashboard_menu_controller.dart';
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
import '../../rental_yeild/controller/rental_yield_controller.dart';
import '../../residential_plots/controller/residential_add_controller.dart';
import '../../syndicate_plot/controller/syndicate_controller.dart';
import '../../plot_market/controller/plot_market_controller.dart';
import '../success.dart';

enum PaymentType {
  plotPayment,
  documentPayment,
  giooPayment,
  marketVerification,
  residentialVerification,
  rentalDocumentPayment,
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
  var residentialPlotId = 0.obs;

  // REMOVED: var rentalPropertyId = 0.obs; // Not needed - use propertyId instead

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

    print(
      '🔧 setupPlotPayment: type=$type, propertyId=$propertyId, amount=$amount',
    );
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
    _currentPaymentUrl.value =
        '${ApiUrl.baseUrl}/api/v2/syndicate_document_pay';
    isTermsAccepted.value = false;

    print(
      '🔧 setupDocumentPayment: propertyId=$propertyId, documentId=$documentId, amount=$amount',
    );
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
    _currentPaymentUrl.value = '${ApiUrl.baseUrl}/api/v2/market_pay';
    isTermsAccepted.value = false;
  }

  void setupResidentialVerificationPayment({
    required int residentialPlotId,
    required double amount,
    required String propertyName,
  }) {
    this.residentialPlotId.value = residentialPlotId;
    this.totalAmount.value = amount;
    this.propertyName.value = propertyName;
    currentPaymentType.value = PaymentType.residentialVerification;
    _currentPaymentUrl.value = '${ApiUrl.baseUrl}/api/v2/residential_pay';
    isTermsAccepted.value = false;
  }

  void toggleTerms() => isTermsAccepted.value = !isTermsAccepted.value;

  String? localWalletAmount;
  String? localCouponCode;
  String? localSpicalDiscountAmount;

  final dashboardController = Get.put(DashboardController());

  void openCheckout({
    required String customerName,
    required String customerEmail,
    required String customerPhone,
    required int amount,
    String? walletAmount,
    String? couponCode,
    String? specialDiscountAmount,
    String description = "",
  }) {
    if (walletAmount != null) {
      localWalletAmount = walletAmount;
    }
    if (couponCode != null) {
      localCouponCode = couponCode;
    }
    if (specialDiscountAmount != null) {
      localSpicalDiscountAmount = specialDiscountAmount;
    }
    update();

    try {
      isProcessing.value = true;

      var options = {
        'key': '${dashboardController.businessSettings.value?.paymentApiKey}',
        'amount': amount,
        'name': customerName,
        'description': description,
        'prefill': {'contact': customerPhone, 'email': customerEmail},
        'theme': {"color": "#4338CA"},
        'notes': {
          'property_id': propertyId.value.toString(),
          'payment_type': currentPaymentType.value.name,
          'document_type': documentType.value,
          'document_id': documentId.value.toString(),
        },
      };
      _razorpay.open(options);
      Loggers.success('✅ Razorpay checkout opened successfully');
    } catch (e) {
      isProcessing.value = false;
      Loggers.error('❌ Razorpay initialization failed: $e');
      SnackBarHelper.showError("Payment initialization failed: $e");
    }
  }

  Future<void> _handleSuccess(PaymentSuccessResponse response) async {
    try {
      paymentID = response.paymentId ?? "N/A";
      _showVerifyingOverlay();

      print('razorpay response data ${response.data}');

      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        Loggers.error('❌ No token found - redirecting to login');
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
        case PaymentType.rentalDocumentPayment:
          await _handleRentalDocumentPaymentSuccess(response, token);
          break;
        case PaymentType.marketVerification:
          await _handleMarketVerificationSuccess(response, token);
          break;
        case PaymentType.residentialVerification:
          await _handleResidentialVerificationSuccess(response, token);
          break;
      }

      if (Get.isDialogOpen ?? false) Get.back();

      Get.off(
        () => PaymentSuccessScreen(
          amount:
              currentPaymentType.value == PaymentType.documentPayment ||
                  currentPaymentType.value == PaymentType.rentalDocumentPayment
              ? documentAmount.value
              : totalAmount.value,
          transactionId: paymentID,
          type: currentPaymentType.value,
        ),
      );
    } catch (e) {
      print('❌ Error in payment success handler: $e');
      _showSyncErrorSheet(e.toString());
    } finally {
      isProcessing.value = false;
    }
  }

  // Add this method to your RazorpayController class, alongside the other setup methods
  void setupRentalDocumentPayment({
    required int propertyId,
    required int documentId,
    required String documentType,
    required double amount,
    required String propertyName,
  }) {
    this.propertyId.value = propertyId;
    this.documentId.value = documentId;
    this.documentType.value = documentType;
    this.documentAmount.value = amount;
    this.propertyName.value = propertyName;
    currentPaymentType.value = PaymentType.rentalDocumentPayment;

    // FIXED: Use the correct API endpoint for rental document payments
    _currentPaymentUrl.value = '${ApiUrl.baseUrl}/api/v2/rental_document_pay';
    isTermsAccepted.value = false;

    print('🔧 setupRentalDocumentPayment:');
    print('   propertyId: $propertyId');
    print('   documentId: $documentId');
    print('   documentType: $documentType');
    print('   amount: $amount');
    print('   propertyName: $propertyName');
    print('✅ Payment setup complete:');
    print('   currentPaymentType: ${currentPaymentType.value}');
    print('   API URL: ${_currentPaymentUrl.value}');
  }

  Future<void> _handleSyndicatePaymentSuccess(
    PaymentSuccessResponse? response,
    String token,
  ) async {
    try {
      final apiResponse = await ApiService.postRequestWithToken(
        _currentPaymentUrl.value,
        token: token,
        data: {
          'status': 'success',
          'payment_id': response?.paymentId??'',
          'amount': totalAmount.value.toStringAsFixed(2),
          'property_id': propertyId.value.toString(),
          'units': selectedUnits.join(','),
        },
      );

      print('📥 Syndicate Payment API Response:');
      print('   Status: ${apiResponse.statusCode}');
      print('   Data: ${apiResponse.data}');

      if (apiResponse.statusCode == 200) {
        final responseData = apiResponse.data;

        if (responseData['status'] == 200 ||
            responseData['status'] == true ||
            responseData['success'] == true) {
          print('✅ Syndicate payment synced successfully');
          _markSyndicatePlotsAsBooked();
        } else {
          throw Exception(responseData['message'] ?? 'Sync failed');
        }
      } else {
        throw Exception('API Error: ${apiResponse.statusCode}');
      }
    } catch (e) {
      print('❌ Syndicate payment error: $e');
      throw Exception('Syndicate payment sync failed: $e');
    }
  }
  Future<void> handleZeroAmountPayment({
    String? couponCode,
    String? walletAmount,
    String? specialDiscountAmount,
  }) async {
    try {
      localCouponCode = couponCode;
      localWalletAmount = walletAmount;
      localSpicalDiscountAmount = specialDiscountAmount;


      paymentID = 'ZERO_PAY_${DateTime.now().millisecondsSinceEpoch}';

      _showVerifyingOverlay();

      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        Loggers.error('❌ No token found - redirecting to login');
        Get.offAllNamed('/login');
        return;
      }

      switch (currentPaymentType.value) {
        case PaymentType.giooPayment:
          await _handleGiooPaymentSuccess(null, token);
          break;
        case PaymentType.plotPayment:
          await _handleSyndicatePaymentSuccess(null, token);
          break;
        default:
          break;
      }

      if (Get.isDialogOpen ?? false) Get.back();

      Get.off(
            () => PaymentSuccessScreen(
          amount: totalAmount.value,
          transactionId: paymentID,
          type: currentPaymentType.value,
        ),
      );
    } catch (e) {
      Loggers.error('❌ Zero amount payment failed: $e');
      if (Get.isDialogOpen ?? false) Get.back();
      SnackBarHelper.showError("Payment failed: $e");
    } finally {
      isProcessing.value = false;
    }
  }


  Future<void> _handleGiooPaymentSuccess(
    PaymentSuccessResponse? response,
    String token,

  ) async {
    try {
      Map<String, dynamic> data = {
        'status': 'success',
        'payment_id': response?.paymentId ?? paymentID,
        'amount': totalAmount.value.toStringAsFixed(2),
        'property_id': propertyId.value.toString(),
        'units': selectedUnits.join(','),
      };
      if(localWalletAmount != null) {
        data['wallet_amount'] = localWalletAmount;
      }
      if(localCouponCode != null) {
        data['coupon_id'] = localCouponCode;
      }
      if(localSpicalDiscountAmount != null) {
        data['special_discount'] = localSpicalDiscountAmount;
      }

      final apiResponse = await ApiService.postRequestWithToken(
        _currentPaymentUrl.value,
        token: token,
        data: data,
      );

      if (apiResponse.statusCode == 200) {
        final responseData = apiResponse.data;

        if (responseData['status'] == 200 ||
            responseData['status'] == true ||
            responseData['success'] == true) {
          Loggers.success('✅ Gioo payment synced successfully');
          final gc = Get.find<GiooPlotController>();
          gc.fetchGiooPlotDetail(propertyId.value);
        } else {
          throw Exception(responseData['message'] ?? 'Sync failed');
        }
      } else {
        throw Exception('API Error: ${apiResponse.statusCode}');
      }
    } catch (e) {
      Loggers.error('❌ Gioo payment error: $e');
      throw Exception('Gioo payment sync failed: $e');
    }
  }

  Future<void> _handleDocumentPaymentSuccess(
    PaymentSuccessResponse response,
    String token,
  ) async {
    try {
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

      print('📥 Syndicate Document Payment API Response:');
      print('   Status: ${apiResponse.statusCode}');
      print('   Data: ${apiResponse.data}');

      if (apiResponse.statusCode == 200) {
        final responseData = apiResponse.data;

        if (responseData['status'] == 200 ||
            responseData['status'] == true ||
            responseData['success'] == true) {
          print('✅ Syndicate document payment synced successfully');
          // Refresh syndicate plots if needed
          try {
            final syndicateController = Get.find<SyndicatePlotController>();
            await syndicateController.fetchSyndicatePlots();
            print('✅ Refreshed syndicate plots list');
          } catch (e) {
            print('⚠️ Could not find syndicate controller: $e');
          }
        } else {
          throw Exception(responseData['message'] ?? 'Document sync failed');
        }
      } else {
        throw Exception('API Error: ${apiResponse.statusCode}');
      }
    } catch (e) {
      print('❌ Syndicate document payment error: $e');
      throw Exception('Syndicate document payment sync failed: $e');
    }
  }

  // FIXED: Handle rental document payment success
  Future<void> _handleRentalDocumentPaymentSuccess(
    PaymentSuccessResponse response,
    String token,
  ) async {
    print('🔄 Processing rental document payment success...');
    print(
      '📊 propertyId: ${propertyId.value}, documentId: ${documentId.value}',
    );
    print(
      '📊 documentType: ${documentType.value}, amount: ${documentAmount.value}',
    );
    print('🌐 API URL: ${_currentPaymentUrl.value}');

    try {
      // Prepare the payload exactly as you specified
      final payload = {
        'status': 'success',
        'payment_id': response.paymentId,
        // Assuming response.paymentId contains transactionId
        'transaction_details': 'test',
        // Hardcoded as "test" per your requirement
        'amount': documentAmount.value.toStringAsFixed(2),
        // Formatted amount
        'property_id': propertyId.value.toString(),
        // Additional fields for document context
        'document_id': documentId.value > 0 ? documentId.value.toString() : '0',
        'document_type': documentType.value,
        'property_name': propertyName.value,
      };

      print('📤 Sending payload: $payload');

      final apiResponse = await ApiService.postRequestWithToken(
        _currentPaymentUrl.value,
        token: token,
        data: payload, // Use the new payload structure
      );

      print('📥 Rental Document Payment API Response:');
      print('   Status: ${apiResponse.statusCode}');
      print('   Data: ${apiResponse.data}');

      if (apiResponse.statusCode == 200) {
        final responseData = apiResponse.data;

        if (responseData['status'] == 200 ||
            responseData['status'] == true ||
            responseData['success'] == true) {
          print('✅ Rental document payment synced successfully');

          // Show success message if available
          if (responseData['message'] != null) {
            print('📝 API Message: ${responseData['message']}');
            Get.snackbar(
              'Success',
              responseData['message'].toString(),
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          }

          // Refresh rental properties if needed
          try {
            final rentalController = Get.find<RentalYieldController>();
            await rentalController.fetchProperties();
            print('✅ Refreshed rental properties list');
          } catch (e) {
            print('⚠️ Could not find rental controller: $e');
          }
        } else {
          throw Exception(
            responseData['message'] ?? 'Rental document sync failed',
          );
        }
      } else {
        throw Exception('API Error: ${apiResponse.statusCode}');
      }
    } catch (e) {
      print('❌ Rental document payment error: $e');
      throw Exception('Rental document payment sync failed: $e');
    }
  }

  Future<void> _handleMarketVerificationSuccess(
    PaymentSuccessResponse response,
    String token,
  ) async {
    try {
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

      print('📥 Market Verification API Response:');
      print('   Status: ${apiResponse.statusCode}');
      print('   Data: ${apiResponse.data}');

      if (apiResponse.statusCode == 200) {
        final responseData = apiResponse.data;

        if (responseData['status'] == 200 ||
            responseData['status'] == true ||
            responseData['success'] == true) {
          print('✅ Market verification payment synced successfully');

          // Show success message if available
          if (responseData['message'] != null) {
            print('📝 API Message: ${responseData['message']}');
          }

          // Refresh market plots list
          try {
            final marketController = Get.find<PlotMarketController>();
            await marketController.fetchMarketPlots();
            print('✅ Refreshed market plots list');
          } catch (e) {
            print('⚠️ Could not find market controller: $e');
          }
        } else {
          throw Exception(
            responseData['message'] ?? 'Market verification failed',
          );
        }
      } else {
        throw Exception('API Error: ${apiResponse.statusCode}');
      }
    } catch (e) {
      print('❌ Market verification error: $e');
      throw Exception('Market verification sync failed: $e');
    }
  }

  Future<void> _handleResidentialVerificationSuccess(
    PaymentSuccessResponse response,
    String token,
  ) async {
    try {
      final apiResponse = await ApiService.postRequestWithToken(
        _currentPaymentUrl.value,
        token: token,
        data: {
          'status': 'success',
          'payment_id': response.paymentId,
          'transaction_details': response.paymentId,
          'property_id': residentialPlotId.value.toString(),
          'amount': totalAmount.value.toStringAsFixed(2),
        },
      );

      print('📥 Residential Verification API Response:');
      print('   Status: ${apiResponse.statusCode}');
      print('   Data: ${apiResponse.data}');

      if (apiResponse.statusCode == 200) {
        final responseData = apiResponse.data;

        // Check all possible success indicators
        if (responseData['status'] == 200 ||
            responseData['status'] == true ||
            responseData['success'] == true ||
            (responseData['message'] != null &&
                responseData['message'].toString().contains('Successfully'))) {
          print('✅ Residential verification payment synced successfully');

          // Show success message from API
          if (responseData['message'] != null) {
            print('📝 API Message: ${responseData['message']}');
          }

          // Refresh properties
          try {
            final residentialController =
                Get.find<ResidentialPropertyFormController>();
            await residentialController.fetchMyProperties();
            print('✅ Refreshed residential properties list');
          } catch (e) {
            print('⚠️ Could not find residential controller: $e');
          }

          // Return success - don't throw exception
          return;
        } else {
          throw Exception(responseData['message'] ?? 'Verification failed');
        }
      } else {
        throw Exception('API Error: ${apiResponse.statusCode}');
      }
    } catch (e) {
      print('❌ Residential verification error: $e');
      // Only rethrow if it's not a success message
      if (e.toString().contains('Successfully')) {
        print('⚠️ This is actually a success message, not an error');
        // It's actually a success, so we should return without throwing
        return;
      }
      throw Exception('Residential verification sync failed: $e');
    }
  }

  void _showVerifyingOverlay() {
    final isZeroPay = totalAmount.value == 0;

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
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 48,
                  width: 48,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF4338CA),
                    ),
                    backgroundColor: Color(0xFFE2E8F0),
                  ),
                ),
                SizedBox(height: 24.h),

                // ✅ Title
                Text(
                  isZeroPay
                      ? "Processing Free Booking"
                      : "Secure Payment Verification",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                    decoration: TextDecoration.none,
                  ),
                ),

                SizedBox(height: 8.h),

                // ✅ Description
                Text(
                  isZeroPay
                      ? "Applying discounts and confirming your booking. This will only take a moment."
                      : "We're confirming your payment with the bank. This usually takes a few seconds.",
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
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 24.h),

            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sync_problem_rounded,
                color: Colors.amber.shade800,
                size: 45.sp,
              ),
            ),
            SizedBox(height: 20.h),

            Text(
              "Syncing Issue",
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 12.h),

            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.blueGrey[600],
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: "Your payment"),
                  const TextSpan(
                    text:
                        " was successful, but your plot status hasn't updated yet.",
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildErrorRow(
                    "Payment ID",
                    paymentID ?? "N/A",
                    isCopyable: true,
                  ),
                  const Divider(height: 24),
                  _buildErrorRow(
                    "Status",
                    "Pending Update",
                    color: Colors.orange,
                  ),
                  const Divider(height: 24),
                  _buildErrorRow("Error", error, color: Colors.red),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      "Dismiss",
                      style: TextStyle(
                        color: Colors.blueGrey[800],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      // Try to manually refresh based on payment type
                      _refreshAfterPayment();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      "Refresh & Retry",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _refreshAfterPayment() {
    try {
      switch (currentPaymentType.value) {
        case PaymentType.marketVerification:
          Get.find<PlotMarketController>().fetchMarketPlots();
          break;
        case PaymentType.residentialVerification:
          Get.find<ResidentialPropertyFormController>().fetchMyProperties();
          break;
        case PaymentType.plotPayment:
          Get.find<SyndicatePlotController>().fetchSyndicatePlots();
          break;
        case PaymentType.documentPayment:
          Get.find<SyndicatePlotController>().fetchSyndicatePlots();
          break;
        case PaymentType.rentalDocumentPayment:
          Get.find<RentalYieldController>().fetchProperties();
          break;
        case PaymentType.giooPayment:
          Get.find<GiooPlotController>().fetchGiooBuyingListDetails();
          break;
      }
    } catch (e) {
      print('⚠️ Could not refresh data: $e');
    }
  }

  Widget _buildErrorRow(
    String label,
    String value, {
    bool isCopyable = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.blueGrey[400],
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: color ?? const Color(0xFF1E293B),
              ),
            ),
            if (isCopyable) ...[
              SizedBox(width: 8.w),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: value));
                  Get.snackbar(
                    "Copied",
                    "Payment ID copied to clipboard",
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 1),
                  );
                },
                child: Icon(
                  Icons.copy_rounded,
                  size: 14.sp,
                  color: Colors.blue,
                ),
              ),
            ],
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

    // void _markGiooUnitsAsBooked() {
    //   final gc = Get.find<GiooPlotController>();
    //   for (var id in selectedUnits) {
    //     int idx = gc.units.indexWhere((u) => u.id == id);
    //     if (idx != -1) gc.units[idx] = gc.units[idx].copyWith(status: 'Booked');
    //   }
    //   gc.units.refresh();
    // }

  void _handleError(PaymentFailureResponse response) {
    isProcessing.value = false;
    Loggers.error('❌ Payment Error: ${response.message}');
    SnackBarHelper.showError(response.message ?? "Payment Cancelled");
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    isProcessing.value = false;
    Loggers.error('ℹ️ External Wallet: ${response.walletName}');
  }

  Future<void> initiatePayment({
    String? walletAmount,
    String? couponCode,
    String? specialDiscountAmount,
  }) async {
    try {
      final userData = await SessionManager.getUserData();
      if (userData == null) {
        Loggers.error('❌ User data is null - user not logged in');
        return;
      }
      int rawAmount = 0;
      if (currentPaymentType.value == PaymentType.documentPayment ||
          currentPaymentType.value == PaymentType.rentalDocumentPayment) {
        rawAmount = (documentAmount.value * 100).toInt();
      } else {
        rawAmount = (totalAmount.value * 100).toInt();
      }
      if (rawAmount <= 0) {
        Loggers.error('❌ Invalid amount: $rawAmount');
        return;
      }

      String description = "";
      switch (currentPaymentType.value) {
        case PaymentType.rentalDocumentPayment:
          description = "Rental Document Payment for ${propertyName.value}";
          break;
        case PaymentType.documentPayment:
          description = "Document Payment for ${propertyName.value}";
          break;
        case PaymentType.marketVerification:
          description = "Market Verification for ${propertyName.value}";
          break;
        case PaymentType.residentialVerification:
          description = "Residential Verification for ${propertyName.value}";
          break;
        case PaymentType.plotPayment:
        case PaymentType.giooPayment:
          description = "Plot Payment for ${propertyName.value}";
          break;
        default:
          description = "Payment for ${propertyName.value}";
      }

      openCheckout(
        customerName: "${userData['first_name']} ${userData['last_name']}",
        customerEmail: userData['email'] ?? "",
        customerPhone: userData['phone'] ?? "",
        amount: rawAmount,
        description: description,
        walletAmount: walletAmount,
        couponCode: couponCode,
        specialDiscountAmount: specialDiscountAmount,
      );
    } catch (e) {
      Loggers.error('❌ Error in initiatePayment: $e');
    }
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }
}
