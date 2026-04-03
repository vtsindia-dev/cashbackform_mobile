import 'package:cashback_farms/common/widget/toster.dart';
import 'package:cashback_farms/features/gift_coupon_and_encashment/model/model.dart';
import 'package:cashback_farms/repository/user_repository.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class GiftController extends GetxController{

  final UserRepository repo = UserRepository();

  bool isLoading = false;


  Future<bool> giftVouchersBuyPostApi({
    required String amount,
    String? transactionId,
    String? paymentMethod,
    String? transactionDetails,
    required bool isFromWallet,
  }) async {

    Map<String, dynamic> body = {};
    try{
      if (isFromWallet == true) {
        body = {
          "amount": amount,
          "wallet": 'true',
        };
      } else {
        body = {
          "amount": amount,
          "transaction_id": transactionId,
          "payment_method": paymentMethod,
          "transaction_details": transactionDetails,
        };
      }

      final response = await repo.generateCouponPostApi(body: body);

      if (response['status'] == 200) {
        getMyPurchasedVouchersList();
        SnackBarHelper.showSuccess('Your gift voucher has been purchased successfully.',);
        return true;
      }else{
        SnackBarHelper.showError(response['message'] ?? 'Something went wrong, please try again.');
        return false;
      }
    }catch(e){
      debugPrint('Error :: ${e}');
      SnackBarHelper.showError('An error occurred, please try again.');
      return false;
    } finally {
      isLoading = false;
      update();
    }
  }


  bool isVouchersListLoading = false;
  bool isFetchingMoreVouchers = false;

  int currentPage = 1;
  int lastPage = 1;

  List<CouponList> couponList = [];


  Future<void> resetVouchers() async {
    couponList.clear();
    currentPage = 1;
    lastPage = 1;
    isFetchingMoreVouchers = false;
    isVouchersListLoading = true;
    update();

    await getMyPurchasedVouchersList(isInitialLoad: true);
  }

  Future<void> getMyPurchasedVouchersList({
    bool isInitialLoad = true,
  }) async {
    if (isInitialLoad) {
      isVouchersListLoading = true;
      currentPage = 1;
    } else {
      isFetchingMoreVouchers = true;
    }
    update();
    try {
      final response = await repo.getGiftVouchersApi(currentPage.toString());
      final List<CouponList> newList = response.data ?? [];
      lastPage = response.lastPage ?? 1;
      if (isInitialLoad) {
        couponList = newList;
      } else {
        couponList.addAll(newList);
      }
    } catch (e) {
      debugPrint('Error :: $e');
    }
    isVouchersListLoading = false;
    isFetchingMoreVouchers = false;
    update();
  }

  void loadMoreVouchers() {
    if (currentPage < lastPage && !isFetchingMoreVouchers) {
      currentPage++;
      getMyPurchasedVouchersList(isInitialLoad: false);
    }
  }

}