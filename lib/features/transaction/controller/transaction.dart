import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../../../common/api_constant.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';
import '../model/transaction_model.dart';

class TransactionController extends GetxController {
  // ===============================
  // LOADING STATES
  // ===============================
  final RxBool isLoadingGioo = false.obs;
  final RxBool isLoadingSyndicate = false.obs;
  final RxBool isLoadingResidential = false.obs;
  final RxBool isLoadingMarket = false.obs;
  final RxBool isLoadingRental = false.obs;

  // ===============================
  // TRANSACTION LISTS
  // ===============================
  final RxList<Transaction> giooTransactions = <Transaction>[].obs;
  final RxList<Transaction> syndicateTransactions = <Transaction>[].obs;
  final RxList<Transaction> residentialTransactions = <Transaction>[].obs;
  final RxList<Transaction> marketTransactions = <Transaction>[].obs;
  final RxList<Transaction> rentalTransactions = <Transaction>[].obs;

  // ===============================
  // PAGINATION METADATA
  // ===============================
  final Rx<TransactionMeta> giooMeta = TransactionMeta(currentPage: 1, lastPage: 1, perPage: 10, total: 0).obs;
  final Rx<TransactionMeta> syndicateMeta = TransactionMeta(currentPage: 1, lastPage: 1, perPage: 10, total: 0).obs;
  final Rx<TransactionMeta> residentialMeta = TransactionMeta(currentPage: 1, lastPage: 1, perPage: 10, total: 0).obs;
  final Rx<TransactionMeta> marketMeta = TransactionMeta(currentPage: 1, lastPage: 1, perPage: 10, total: 0).obs;
  final Rx<TransactionMeta> rentalMeta = TransactionMeta(currentPage: 1, lastPage: 1, perPage: 10, total: 0).obs;

  // ===============================
  // ERROR STATES
  // ===============================
  final RxString giooError = ''.obs;
  final RxString syndicateError = ''.obs;
  final RxString residentialError = ''.obs;
  final RxString marketError = ''.obs;
  final RxString rentalError = ''.obs;

  // ===============================
  // CURRENT TAB
  // ===============================
  final RxInt currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllTransactions();
  }

  Future<void> fetchAllTransactions() async {
    await Future.wait([
      fetchGiooTransactions(),
      fetchSyndicateTransactions(),
      fetchResidentialTransactions(),
      fetchMarketTransactions(),
      fetchRentalTransactions(),
    ]);
  }

  // ===============================
  // FETCH METHODS
  // ===============================
  Future<void> fetchGiooTransactions({int page = 1}) async {
    if (isLoadingGioo.value) return;
    try {
      isLoadingGioo(true); giooError('');
      final token = await _getToken();
      final response = await ApiService.getRequest(
        '${ApiUrl.baseUrl}/api/v2/my-gioo-transactions?page=$page',
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200 && response.data != null) {
        final res = TransactionResponse.fromJson(response.data);
        if (page == 1) giooTransactions.assignAll(res.data); else giooTransactions.addAll(res.data);
        giooMeta.value = res.meta;
      } else { giooError.value = response.data?['message'] ?? 'Failed to load'; }
    } on DioException catch (e) { giooError.value = _handleDioError(e);
    } catch (e) { giooError.value = e.toString();
    } finally { isLoadingGioo(false); }
  }

  Future<void> fetchSyndicateTransactions({int page = 1}) async {
    if (isLoadingSyndicate.value) return;
    try {
      isLoadingSyndicate(true); syndicateError('');
      final token = await _getToken();
      final response = await ApiService.getRequest(
        '${ApiUrl.baseUrl}/api/v2/my-syndicate-transactions?page=$page',
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200 && response.data != null) {
        final res = TransactionResponse.fromJson(response.data);
        if (page == 1) syndicateTransactions.assignAll(res.data); else syndicateTransactions.addAll(res.data);
        syndicateMeta.value = res.meta;
      } else { syndicateError.value = response.data?['message'] ?? 'Failed to load'; }
    } on DioException catch (e) { syndicateError.value = _handleDioError(e);
    } catch (e) { syndicateError.value = e.toString();
    } finally { isLoadingSyndicate(false); }
  }

  Future<void> fetchResidentialTransactions({int page = 1}) async {
    if (isLoadingResidential.value) return;
    try {
      isLoadingResidential(true); residentialError('');
      final token = await _getToken();
      final response = await ApiService.getRequest(
        '${ApiUrl.baseUrl}/api/v2/my-residential-transactions?page=$page',
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200 && response.data != null) {
        final res = TransactionResponse.fromJson(response.data);
        if (page == 1) residentialTransactions.assignAll(res.data); else residentialTransactions.addAll(res.data);
        residentialMeta.value = res.meta;
      } else { residentialError.value = response.data?['message'] ?? 'Failed to load'; }
    } on DioException catch (e) { residentialError.value = _handleDioError(e);
    } catch (e) { residentialError.value = e.toString();
    } finally { isLoadingResidential(false); }
  }

  Future<void> fetchMarketTransactions({int page = 1}) async {
    if (isLoadingMarket.value) return;
    try {
      isLoadingMarket(true); marketError('');
      final token = await _getToken();
      final response = await ApiService.getRequest(
        '${ApiUrl.baseUrl}/api/v2/my-market-transactions?page=$page',
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200 && response.data != null) {
        final res = TransactionResponse.fromJson(response.data);
        if (page == 1) marketTransactions.assignAll(res.data); else marketTransactions.addAll(res.data);
        marketMeta.value = res.meta;
      } else { marketError.value = response.data?['message'] ?? 'Failed to load'; }
    } on DioException catch (e) { marketError.value = _handleDioError(e);
    } catch (e) { marketError.value = e.toString();
    } finally { isLoadingMarket(false); }
  }

  Future<void> fetchRentalTransactions({int page = 1}) async {
    if (isLoadingRental.value) return;
    try {
      isLoadingRental(true); rentalError('');
      final token = await _getToken();
      final response = await ApiService.getRequest(
        '${ApiUrl.baseUrl}/api/v2/my-rental-transactions?page=$page',
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200 && response.data != null) {
        final res = TransactionResponse.fromJson(response.data);
        if (page == 1) rentalTransactions.assignAll(res.data); else rentalTransactions.addAll(res.data);
        rentalMeta.value = res.meta;
      } else { rentalError.value = response.data?['message'] ?? 'Failed to load'; }
    } on DioException catch (e) { rentalError.value = _handleDioError(e);
    } catch (e) { rentalError.value = e.toString();
    } finally { isLoadingRental(false); }
  }

  // ===============================
  // ADD PURCHASE DETAILS — multipart with image
  // ===============================
// ===============================
// ADD PURCHASE DETAILS — multipart with image
// ===============================
  Future<void> addTransactionDetails(Map<String, dynamic> formData) async {
    try {
      final token = await _getToken();

      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      // Build FormData for multipart (needed for image upload)
      final multipart = FormData();

      // Scalar fields - Convert amount to number (int/double)
      multipart.fields.add(MapEntry('property_id', formData['property_id'].toString()));

      // IMPORTANT: Convert amount to number (remove any commas and ensure it's a number)
      String amountStr = formData['amount'].toString().trim();
      // Remove any commas if present
      amountStr = amountStr.replaceAll(',', '');
      // Parse to number (int if no decimal, otherwise double)
      num amountValue;
      if (amountStr.contains('.')) {
        amountValue = double.parse(amountStr);
      } else {
        amountValue = int.parse(amountStr);
      }
      multipart.fields.add(MapEntry('amount', amountValue.toString()));

      multipart.fields.add(MapEntry('payment_mode', formData['payment_mode'].toString()));
      multipart.fields.add(MapEntry('type', formData['type'].toString()));

      // Add transaction_id if present (for existing transactions)
      if (formData.containsKey('transaction_id') && formData['transaction_id'] != null) {
        multipart.fields.add(MapEntry('transaction_id', formData['transaction_id'].toString()));
      }

      if ((formData['other_details'] ?? '').toString().isNotEmpty) {
        multipart.fields.add(MapEntry('other_details', formData['other_details'].toString()));
      }

      // registration_date[] — array fields
      final List<String> regDates = List<String>.from(formData['registration_date'] ?? []);
      for (final date in regDates) {
        multipart.fields.add(MapEntry('registration_date[]', date));
      }

      // Image (optional)
      final File? imageFile = formData['image'] as File?;
      if (imageFile != null) {
        final fileName = imageFile.path.split('/').last;
        multipart.files.add(MapEntry(
          'image',
          await MultipartFile.fromFile(imageFile.path, filename: fileName),
        ));
      }

      final dio = Dio();
      final response = await dio.post(
        '${ApiUrl.baseUrl}/api/v2/purchase_bank_details',
        data: multipart,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        SnackBarHelper.showSuccess('Purchase details submitted successfully!');
        await refreshCurrentTab();
      } else {
        String errorMsg = response.data?['message'] ?? 'Submission failed';
        // Check for amount validation error
        if (errorMsg.toLowerCase().contains('amount') && errorMsg.toLowerCase().contains('number')) {
          errorMsg = 'Please enter a valid numeric amount';
        }
        SnackBarHelper.showError(errorMsg);
      }
    } on DioException catch (e) {
      Get.back();
      String errorMsg = _handleDioError(e);
      if (errorMsg.toLowerCase().contains('amount')) {
        errorMsg = 'Amount must be a valid number';
      }
      SnackBarHelper.showError(errorMsg);
    } catch (e) {
      Get.back();
      SnackBarHelper.showError('Error: ${e.toString()}');
    }
  }
  // ===============================
  // DOWNLOAD INVOICE — open in browser
  // ===============================
  Future<void> downloadInvoice(String invoiceUrl) async {
    if (invoiceUrl.isEmpty) {
      SnackBarHelper.showError('Invoice URL not available');
      return;
    }
    try {
      final Uri uri = Uri.parse(invoiceUrl);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      SnackBarHelper.showError('Could not open invoice');
    }
  }

  // ===============================
  // PAGINATION
  // ===============================
  Future<void> loadMoreTransactions(TransactionType type) async {
    switch (type) {
      case TransactionType.gioo:
        if (giooMeta.value.currentPage < giooMeta.value.lastPage)
          await fetchGiooTransactions(page: giooMeta.value.currentPage + 1);
        break;
      case TransactionType.syndicate:
        if (syndicateMeta.value.currentPage < syndicateMeta.value.lastPage)
          await fetchSyndicateTransactions(page: syndicateMeta.value.currentPage + 1);
        break;
      case TransactionType.residential:
        if (residentialMeta.value.currentPage < residentialMeta.value.lastPage)
          await fetchResidentialTransactions(page: residentialMeta.value.currentPage + 1);
        break;
      case TransactionType.market:
        if (marketMeta.value.currentPage < marketMeta.value.lastPage)
          await fetchMarketTransactions(page: marketMeta.value.currentPage + 1);
        break;
      case TransactionType.rental:
        if (rentalMeta.value.currentPage < rentalMeta.value.lastPage)
          await fetchRentalTransactions(page: rentalMeta.value.currentPage + 1);
        break;
    }
  }

  // ===============================
  // REFRESH
  // ===============================
  Future<void> refreshCurrentTab() async {
    switch (currentTabIndex.value) {
      case 0: await fetchGiooTransactions(); break;
      case 1: await fetchSyndicateTransactions(); break;
      case 2: await fetchResidentialTransactions(); break;
      case 3: await fetchMarketTransactions(); break;
      case 4: await fetchRentalTransactions(); break;
    }
  }

  Future<void> refreshAllTabs() async => await fetchAllTransactions();

  void changeTab(int index) => currentTabIndex.value = index;

  // ===============================
  // HELPERS
  // ===============================
  Future<String> _getToken() async {
    final token = await SessionManager.getToken();
    if (token == null || token.isEmpty) throw Exception('No authentication token found');
    return token;
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout: return 'Connection timeout. Check your internet.';
      case DioExceptionType.connectionError: return 'Connection error. Check your internet.';
      case DioExceptionType.receiveTimeout: return 'Server took too long to respond.';
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) return 'Session expired. Please login again.';
        if (e.response?.statusCode == 404) return 'Endpoint not found.';
        if (e.response?.statusCode == 500) return 'Server error. Try again later.';
        return e.response?.data?['message'] ?? 'Server error occurred';
      default: return 'Network error occurred. Please try again.';
    }
  }

  // ===============================
  // GETTERS
  // ===============================
  bool get isGiooLoading => isLoadingGioo.value;
  bool get isSyndicateLoading => isLoadingSyndicate.value;
  bool get isResidentialLoading => isLoadingResidential.value;
  bool get isMarketLoading => isLoadingMarket.value;
  bool get isRentalLoading => isLoadingRental.value;

  String get giooErrorMessage => giooError.value;
  String get syndicateErrorMessage => syndicateError.value;
  String get residentialErrorMessage => residentialError.value;
  String get marketErrorMessage => marketError.value;
  String get rentalErrorMessage => rentalError.value;

}