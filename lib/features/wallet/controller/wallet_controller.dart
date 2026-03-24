import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../common/api_constant.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';
import '../model/wallet_model.dart';

class WalletController extends GetxController {
  var isLoading = false.obs;
  var transactions = <WalletTransaction>[].obs;
  var pagination = Pagination(currentPage: 1, perPage: 10, total: 0, lastPage: 1).obs;
  var currentPage = 1.obs;
  var hasMore = true.obs;
  var walletBalance = 0.0.obs;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiUrl.baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  @override
  void onInit() {
    super.onInit();
    fetchWalletTransactions();
  }

  Future<void> fetchWalletTransactions({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        isLoading.value = true;
        currentPage.value = 1;
        transactions.clear();
      } else {
        if (!hasMore.value) return;
      }

      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        SnackBarHelper.showError("Session invalid. Please login again.");
        await SessionManager.clearSession();
        Get.offAllNamed('/login');
        throw Exception('Token not found');
      }

      final response = await _dio.get(
        '/api/v2/wallet-transactions',
        queryParameters: {'page': currentPage.value},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        final walletResponse = WalletTransactionResponse.fromJson(response.data);
        transactions.addAll(walletResponse.data);
        pagination.value = walletResponse.pagination;
        hasMore.value = walletResponse.pagination.hasNextPage;

        // Update wallet balance from latest transaction
        if (walletResponse.data.isNotEmpty) {
          walletBalance.value = walletResponse.data.last.balance;
        }

        if (!loadMore) {
          isLoading.value = false;
        }
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load transactions');
      }
    } catch (e) {
      isLoading.value = false;
      SnackBarHelper.showError('Failed to load wallet transactions: ${e.toString()}');
      debugPrint('Error fetching wallet transactions: $e');
    } finally {
      if (!loadMore) {
        isLoading.value = false;
      }
    }
  }

  Future<void> loadMoreTransactions() async {
    if (isLoading.value || !hasMore.value) return;
    currentPage.value++;
    await fetchWalletTransactions(loadMore: true);
  }

  Future<void> refreshTransactions() async {
    currentPage.value = 1;
    hasMore.value = true;
    await fetchWalletTransactions();
  }

  Future<void> requestWithdrawal(double amount) async {
    try {
      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        SnackBarHelper.showError("Session invalid. Please login again.");
        await SessionManager.clearSession();
        Get.offAllNamed('/login');
        throw Exception('Token not found');
      }

      isLoading.value = true;

      final response = await _dio.post(
        '/api/v2/wallet-withdraw',
        data: {'amount': amount},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['status'] == true) {
        SnackBarHelper.showSuccess(response.data['message'] ?? 'Withdrawal request submitted successfully');
        await refreshTransactions();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to process withdrawal');
      }
    } catch (e) {
      SnackBarHelper.showError('Failed to process withdrawal: ${e.toString()}');
      debugPrint('Error processing withdrawal: $e');
    } finally {
      isLoading.value = false;
    }
  }
}