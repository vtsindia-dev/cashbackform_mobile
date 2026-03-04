import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
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

  // ===============================
  // TRANSACTION LISTS
  // ===============================
  final RxList<Transaction> giooTransactions = <Transaction>[].obs;
  final RxList<Transaction> syndicateTransactions = <Transaction>[].obs;
  final RxList<Transaction> residentialTransactions = <Transaction>[].obs;
  final RxList<Transaction> marketTransactions = <Transaction>[].obs;

  // ===============================
  // PAGINATION METADATA
  // ===============================
  final Rx<TransactionMeta> giooMeta = TransactionMeta(
    currentPage: 1,
    lastPage: 1,
    perPage: 10,
    total: 0,
  ).obs;

  final Rx<TransactionMeta> syndicateMeta = TransactionMeta(
    currentPage: 1,
    lastPage: 1,
    perPage: 10,
    total: 0,
  ).obs;

  final Rx<TransactionMeta> residentialMeta = TransactionMeta(
    currentPage: 1,
    lastPage: 1,
    perPage: 10,
    total: 0,
  ).obs;

  final Rx<TransactionMeta> marketMeta = TransactionMeta(
    currentPage: 1,
    lastPage: 1,
    perPage: 10,
    total: 0,
  ).obs;

  // ===============================
  // ERROR STATES
  // ===============================
  final RxString giooError = ''.obs;
  final RxString syndicateError = ''.obs;
  final RxString residentialError = ''.obs;
  final RxString marketError = ''.obs;

  // ===============================
  // CURRENT TAB
  // ===============================
  final RxInt currentTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Fetch initial data for the first tab
    fetchAllTransactions();
  }

  // ===============================
  // FETCH ALL TRANSACTIONS
  // ===============================
  Future<void> fetchAllTransactions() async {
    await fetchGiooTransactions();
    await fetchSyndicateTransactions();
    await fetchResidentialTransactions();
    await fetchMarketTransactions();
  }

  // ===============================
  // FETCH GIOO TRANSACTIONS
  // ===============================
  Future<void> fetchGiooTransactions({int page = 1}) async {
    if (isLoadingGioo.value) return;

    try {
      isLoadingGioo(true);
      giooError('');

      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final response = await ApiService.getRequest(
        '${ApiUrl.baseUrl}/api/v2/my-gioo-transactions?page=$page',
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 && response.data != null) {
        final transactionResponse = TransactionResponse.fromJson(response.data);

        if (page == 1) {
          giooTransactions.assignAll(transactionResponse.data);
        } else {
          giooTransactions.addAll(transactionResponse.data);
        }

        giooMeta.value = transactionResponse.meta;

        print('✅ Gioo transactions loaded successfully');
        print('   📊 Total: ${transactionResponse.meta.total}');
        print('   📄 Page: ${transactionResponse.meta.currentPage}/${transactionResponse.meta.lastPage}');
      } else {
        giooError.value = response.data?['message'] ?? 'Failed to load Gioo transactions';
        print('❌ Failed to load Gioo transactions: ${response.data}');
      }
    } on DioException catch (e) {
      giooError.value = _handleDioError(e);
      print('❌ DioException fetching Gioo transactions: ${e.message}');
    } catch (e) {
      giooError.value = 'Failed to load transactions: ${e.toString()}';
      print('❌ Error fetching Gioo transactions: $e');
    } finally {
      isLoadingGioo(false);
    }
  }

  // ===============================
  // FETCH SYNDICATE TRANSACTIONS
  // ===============================
  Future<void> fetchSyndicateTransactions({int page = 1}) async {
    if (isLoadingSyndicate.value) return;

    try {
      isLoadingSyndicate(true);
      syndicateError('');

      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final response = await ApiService.getRequest(
        '${ApiUrl.baseUrl}/api/v2/my-syndicate-transactions?page=$page',
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 && response.data != null) {
        final transactionResponse = TransactionResponse.fromJson(response.data);

        if (page == 1) {
          syndicateTransactions.assignAll(transactionResponse.data);
        } else {
          syndicateTransactions.addAll(transactionResponse.data);
        }

        syndicateMeta.value = transactionResponse.meta;

        print('✅ Syndicate transactions loaded successfully');
        print('   📊 Total: ${transactionResponse.meta.total}');
      } else {
        syndicateError.value = response.data?['message'] ?? 'Failed to load Syndicate transactions';
        print('❌ Failed to load Syndicate transactions: ${response.data}');
      }
    } on DioException catch (e) {
      syndicateError.value = _handleDioError(e);
      print('❌ DioException fetching Syndicate transactions: ${e.message}');
    } catch (e) {
      syndicateError.value = 'Failed to load transactions: ${e.toString()}';
      print('❌ Error fetching Syndicate transactions: $e');
    } finally {
      isLoadingSyndicate(false);
    }
  }

  // ===============================
  // FETCH RESIDENTIAL TRANSACTIONS
  // ===============================
  Future<void> fetchResidentialTransactions({int page = 1}) async {
    if (isLoadingResidential.value) return;

    try {
      isLoadingResidential(true);
      residentialError('');

      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final response = await ApiService.getRequest(
        '${ApiUrl.baseUrl}/api/v2/my-residential-transactions?page=$page',
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 && response.data != null) {
        final transactionResponse = TransactionResponse.fromJson(response.data);

        if (page == 1) {
          residentialTransactions.assignAll(transactionResponse.data);
        } else {
          residentialTransactions.addAll(transactionResponse.data);
        }

        residentialMeta.value = transactionResponse.meta;

        print('✅ Residential transactions loaded successfully');
        print('   📊 Total: ${transactionResponse.meta.total}');
      } else {
        residentialError.value = response.data?['message'] ?? 'Failed to load Residential transactions';
        print('❌ Failed to load Residential transactions: ${response.data}');
      }
    } on DioException catch (e) {
      residentialError.value = _handleDioError(e);
      print('❌ DioException fetching Residential transactions: ${e.message}');
    } catch (e) {
      residentialError.value = 'Failed to load transactions: ${e.toString()}';
      print('❌ Error fetching Residential transactions: $e');
    } finally {
      isLoadingResidential(false);
    }
  }

  // ===============================
  // FETCH MARKET TRANSACTIONS
  // ===============================
  Future<void> fetchMarketTransactions({int page = 1}) async {
    if (isLoadingMarket.value) return;

    try {
      isLoadingMarket(true);
      marketError('');

      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found');
      }

      final response = await ApiService.getRequest(
        '${ApiUrl.baseUrl}/api/v2/my-market-transactions?page=$page',
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 && response.data != null) {
        final transactionResponse = TransactionResponse.fromJson(response.data);

        if (page == 1) {
          marketTransactions.assignAll(transactionResponse.data);
        } else {
          marketTransactions.addAll(transactionResponse.data);
        }

        marketMeta.value = transactionResponse.meta;

        print('✅ Market transactions loaded successfully');
        print('   📊 Total: ${transactionResponse.meta.total}');
      } else {
        marketError.value = response.data?['message'] ?? 'Failed to load Market transactions';
        print('❌ Failed to load Market transactions: ${response.data}');
      }
    } on DioException catch (e) {
      marketError.value = _handleDioError(e);
      print('❌ DioException fetching Market transactions: ${e.message}');
    } catch (e) {
      marketError.value = 'Failed to load transactions: ${e.toString()}';
      print('❌ Error fetching Market transactions: $e');
    } finally {
      isLoadingMarket(false);
    }
  }

  // ===============================
  // LOAD MORE FOR PAGINATION
  // ===============================
  Future<void> loadMoreTransactions(TransactionType type) async {
    switch (type) {
      case TransactionType.gioo:
        if (giooMeta.value.currentPage < giooMeta.value.lastPage) {
          await fetchGiooTransactions(page: giooMeta.value.currentPage + 1);
        }
        break;
      case TransactionType.syndicate:
        if (syndicateMeta.value.currentPage < syndicateMeta.value.lastPage) {
          await fetchSyndicateTransactions(page: syndicateMeta.value.currentPage + 1);
        }
        break;
      case TransactionType.residential:
        if (residentialMeta.value.currentPage < residentialMeta.value.lastPage) {
          await fetchResidentialTransactions(page: residentialMeta.value.currentPage + 1);
        }
        break;
      case TransactionType.market:
        if (marketMeta.value.currentPage < marketMeta.value.lastPage) {
          await fetchMarketTransactions(page: marketMeta.value.currentPage + 1);
        }
        break;
    }
  }

  // ===============================
  // DOWNLOAD INVOICE
  // ===============================
  Future<void> downloadInvoice(String invoiceUrl) async {
    try {
      print('📄 Downloading invoice: $invoiceUrl');

      if (await canLaunchUrl(Uri.parse(invoiceUrl))) {
        await launchUrl(
          Uri.parse(invoiceUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        SnackBarHelper.showError('Could not open invoice');
      }
    } catch (e) {
      print('❌ Invoice download error: $e');
      SnackBarHelper.showError('Failed to download invoice');
    }
  }

  // ===============================
  // REFRESH METHODS
  // ===============================
  Future<void> refreshCurrentTab() async {
    switch (currentTabIndex.value) {
      case 0:
        await fetchGiooTransactions();
        break;
      case 1:
        await fetchSyndicateTransactions();
        break;
      case 2:
        await fetchResidentialTransactions();
        break;
      case 3:
        await fetchMarketTransactions();
        break;
    }
  }

  Future<void> refreshAllTabs() async {
    await fetchAllTransactions();
  }

  // ===============================
  // ERROR HANDLING
  // ===============================
  String _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Connection error. Please check your internet connection.';
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return 'Server took too long to respond.';
    } else if (e.type == DioExceptionType.badResponse) {
      if (e.response?.statusCode == 401) {
        return 'Session expired. Please login again.';
      } else if (e.response?.statusCode == 404) {
        return 'Endpoint not found.';
      } else if (e.response?.statusCode == 500) {
        return 'Server error. Please try again later.';
      }
    }
    return 'Network error occurred. Please try again.';
  }

  // ===============================
  // GETTERS FOR CONVENIENCE
  // ===============================
  bool get isGiooLoading => isLoadingGioo.value;
  bool get isSyndicateLoading => isLoadingSyndicate.value;
  bool get isResidentialLoading => isLoadingResidential.value;
  bool get isMarketLoading => isLoadingMarket.value;

  String get giooErrorMessage => giooError.value;
  String get syndicateErrorMessage => syndicateError.value;
  String get residentialErrorMessage => residentialError.value;
  String get marketErrorMessage => marketError.value;

  List<Transaction> get currentTabTransactions {
    switch (currentTabIndex.value) {
      case 0:
        return giooTransactions;
      case 1:
        return syndicateTransactions;
      case 2:
        return residentialTransactions;
      case 3:
        return marketTransactions;
      default:
        return [];
    }
  }

  bool get isCurrentTabLoading {
    switch (currentTabIndex.value) {
      case 0:
        return isLoadingGioo.value;
      case 1:
        return isLoadingSyndicate.value;
      case 2:
        return isLoadingResidential.value;
      case 3:
        return isLoadingMarket.value;
      default:
        return false;
    }
  }

  String get currentTabErrorMessage {
    switch (currentTabIndex.value) {
      case 0:
        return giooError.value;
      case 1:
        return syndicateError.value;
      case 2:
        return residentialError.value;
      case 3:
        return marketError.value;
      default:
        return '';
    }
  }

  int get currentTabTotal {
    switch (currentTabIndex.value) {
      case 0:
        return giooMeta.value.total;
      case 1:
        return syndicateMeta.value.total;
      case 2:
        return residentialMeta.value.total;
      case 3:
        return marketMeta.value.total;
      default:
        return 0;
    }
  }

  // ===============================
  // CHANGE TAB
  // ===============================
  void changeTab(int index) {
    currentTabIndex.value = index;
  }
}