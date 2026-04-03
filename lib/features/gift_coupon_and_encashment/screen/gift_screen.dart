import 'package:cashback_farms/common/api_constant.dart';
import 'package:cashback_farms/common/colours.dart';
import 'package:cashback_farms/common/model/logger_model.dart';
import 'package:cashback_farms/common/widget/sessionhandler.dart';
import 'package:cashback_farms/features/gift_coupon_and_encashment/controller/gift_controller.dart';
import 'package:cashback_farms/features/gift_coupon_and_encashment/model/model.dart';
import 'package:cashback_farms/features/gift_coupon_and_encashment/screen/payment_status_screen.dart';
import 'package:cashback_farms/features/menu/controller/dashboard_menu_controller.dart';
import 'package:cashback_farms/features/profile/controller/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

enum PaymentType { online, wallet }


class _C {
  static const greenPrimary  = Color(0xFF4A7C3F);
  static const greenDark     = Color(0xFF2D5A22);
  static const greenLight    = Color(0xFF6AAB5C);
  static const greenSoft     = Color(0xFFE8F5E2);
  static const greenBorder   = Color(0xFFC5E0B8);
  static const bgPage        = Color(0xFFF5FAF3);
  static const textDark      = Color(0xFF1A2E14);
  static const textMid       = Color(0xFF4A5E43);
  static const textLight     = Color(0xFF8FAA87);
  static const red           = Color(0xFFE53935);
  static const warningBg     = Color(0xFFFFFBE6);
  static const warningBorder = Color(0xFFF0D060);
  static const warningText   = Color(0xFF7A6000);
}

class GiftScreen extends StatefulWidget {
  const GiftScreen({super.key});

  @override
  State<GiftScreen> createState() => _GiftScreenState();
}

class _GiftScreenState extends State<GiftScreen> with TickerProviderStateMixin {


  final TextEditingController _amountController = TextEditingController();
  DashboardController dashboardController = Get.put(DashboardController());
  GiftController giftController = Get.put(GiftController());
  final ProfileController profileController = Get.put(ProfileController());
  PaymentType? selectedPaymentType;

  late Razorpay _razorpay;
  final FocusNode _focusNode = FocusNode();


  double amount             = 0.0;
  double gstValue           = 0.0;
  double gstAmount          = 0.0;
  double totalAmount        = 0.0;
  double walletAmount       = 0.0;
  double minCouponValAmount = 0.0;
  double maxCouponValAmount = 0.0;


  bool _isWalletTab = false;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  final List<int> _quickAmounts = [500, 1000, 2000, 5000];


  String _fmt(double n) => '₹${NumberFormat('#,##,###').format(n.toInt())}';

  bool get _isInsufficient => _isWalletTab && walletAmount < amount;

  bool get _isValidAmount =>
      amount >= minCouponValAmount &&
          amount <= maxCouponValAmount &&
          amount > 0;


  @override
  void initState() {
    super.initState();
    _fetchGstValue();
    _amountController.addListener(_calculateAmounts);

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);

    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    giftController.resetVouchers();
  }


  void _fetchGstValue() {
    setState(() {
      gstValue           = dashboardController.businessSettings.value?.couponServiceCharge ?? 0;
      minCouponValAmount = dashboardController.businessSettings.value?.minCouponVal ?? 0;
      maxCouponValAmount = dashboardController.businessSettings.value?.maxCouponVal ?? 0;
      walletAmount       = double.tryParse(dashboardController.profile.value?.walletBalance ?? "0",) ?? 0;
    });
  }

  void _calculateAmounts() {
    setState(() {
      amount = double.tryParse(_amountController.text) ?? 0.0;

      if (_isWalletTab) {
        gstAmount = 0.0;
        totalAmount = amount;
      } else {
        gstAmount = (amount * gstValue) / 100;
        totalAmount = amount + gstAmount;
      }
    });
  }

  Future<void> handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      giftController.isLoading = true;
      giftController.update();

      final enteredAmount = _amountController.text.trim();

      await giftController.giftVouchersBuyPostApi(
        amount: enteredAmount,
        transactionId: response.paymentId ?? '',
        paymentMethod: 'razor_pay',
        transactionDetails: response.paymentId ?? '',
        isFromWallet: false,
      );
      await dashboardController.fetchDashboard();

      final result = await Get.to(() => PaymentStatusScreen(
        isSuccess: true,
        paymentId: response.paymentId,
        amount: enteredAmount,
      ));
      if (result == true) {
        setState(() {
          walletAmount = double.tryParse(
              dashboardController.profile.value?.walletBalance ?? "0"
          ) ?? 0;
        });
      }

    } catch (e) {
      debugPrint('Error :: $e');
      Get.off(() => PaymentStatusScreen(
        isSuccess: false,
        paymentId: response.paymentId,
      ));
    } finally {
      giftController.isLoading = false;
      giftController.update();
    }
  }

  void handlePaymentError(PaymentFailureResponse response) {
    Get.to(() => PaymentStatusScreen(
      isSuccess: false,
      errorMessage: response.message,
    ));
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External wallet used: ${response.walletName}')),
    );
  }

  void openCheckout(String totalAmountStr) async {
    final userData = await SessionManager.getUserData();
    if (userData == null) {
      Loggers.error('User data is null - user not logged in');
      return;
    }
    var options = {
      'key': 'rzp_test_t8LKc2rPhJVv2N',
      'amount': (double.parse(totalAmountStr) * 100).toInt(),
      'name': "${userData['first_name']} ${userData['last_name']}",
      'timeout': 300,
      'prefill': {
        'contact': userData['phone'] ?? "",
        'email': userData['email'] ?? "",
      },
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Razorpay Error: $e");
    }
  }


  Future<void> _onPurchase() async {
    if (!_isValidAmount) {
      _showSnack(
        'Amount must be between ${_fmt(minCouponValAmount)} and ${_fmt(maxCouponValAmount)}',
        isError: true,
      );
      return;
    }
    if (_isInsufficient) return;

    if (_isWalletTab) {
      try {
        giftController.isLoading = true;
        giftController.update();

        final enteredAmount = _amountController.text.trim();

        await giftController.giftVouchersBuyPostApi(
          amount: enteredAmount,
          isFromWallet: true,
          transactionId: 'WALLET_${DateTime.now().millisecondsSinceEpoch}',
          paymentMethod: 'wallet',
          transactionDetails: 'wallet_payment',
        );
        await dashboardController.fetchDashboard();

        final result = await Get.to(() => PaymentStatusScreen(
          isSuccess: true,
          paymentId: 'WALLET',
          amount: enteredAmount,
        ));

        if (result == true) {

          setState(() {
            walletAmount = double.tryParse(
                dashboardController.profile.value?.walletBalance ?? "0"
            ) ?? 0;
          });
        }

      } catch (e) {
        debugPrint('Wallet Error :: $e');

        Get.to(() => PaymentStatusScreen(
          isSuccess: false,
          errorMessage: "Wallet payment failed",
        ));
      } finally {
        giftController.isLoading = false;
        giftController.update();
      }
    }else {
      openCheckout(totalAmount.toStringAsFixed(2));
    }
  }

  void _setQuickAmount(int amt) {
    _amountController.text = amt.toString();
    _amountController.selection = TextSelection.fromPosition(
      TextPosition(offset: _amountController.text.length),
    );
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: isError ? _C.red : _C.greenDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    _amountController.removeListener(_calculateAmounts);
    _amountController.dispose();
    _focusNode.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: RefreshIndicator(
          onRefresh: () async {
            await giftController.resetVouchers();
          },
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildTabToggle(),
                      const SizedBox(height: 18),
                      if (_isWalletTab) _buildWalletCard(),
                      if (_isInsufficient) _buildWarningBox(),
                      _buildAmountInput(),
                      const SizedBox(height: 6),
                      _buildLimitText(),
                      const SizedBox(height: 14),
                      _buildQuickChips(),
                      const SizedBox(height: 18),
                      if (_isValidAmount) ...[
                        _buildSummaryBox(),
                        const SizedBox(height: 18),
                      ],
                      _buildCTAButton(),
                      const SizedBox(height: 28),
                      const Divider(color: _C.greenBorder, thickness: 1),
                      const SizedBox(height: 20),
                      _buildMyCouponsHeader(),
                      const SizedBox(height: 14),
                      _buildCouponList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      elevation: 0,
      backgroundColor: _C.greenDark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration:  BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColor.primary, AppColor.primary],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -30, right: -30,
                child: Container(
                  width: 150, height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: -15, left: 70,
                child: Container(
                  width: 70, height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: 20, left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Gift Coupon',
                      style: TextStyle(
                        color: Colors.white, fontSize: 24,
                        fontWeight: FontWeight.w700, letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Purchase & manage your gift vouchers',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 13, fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildTabToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _C.greenSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _tabBtn(
            label: 'Razorpay',
            icon: Icons.credit_card_rounded,
            isActive: !_isWalletTab,
            onTap: () => setState(() => _isWalletTab = false),
          ),
          _tabBtn(
            label: 'Wallet',
            icon: Icons.account_balance_wallet_rounded,
            isActive: _isWalletTab,
              onTap: () {
                setState(() {
                  _isWalletTab = true;
                });
                _calculateAmounts();
              }
          ),
        ],
      ),
    );
  }

  Widget _tabBtn({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColor.orange : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive
                ? [BoxShadow(
              color: AppColor.orange.withOpacity(0.28),
              blurRadius: 16, offset: const Offset(0, 4),
            )]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: isActive ? Colors.white : _C.textMid),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : _C.textMid,
                  fontSize: 13, fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEAF5E5), Color(0xFFD9EECD)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.greenBorder, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Wallet Balance',
                  style: TextStyle(fontSize: 12, color: _C.textMid, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹${walletAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w700, color: _C.greenDark,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: _C.greenPrimary, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBox() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: _C.warningBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _C.warningBorder, width: 1.5),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: _C.warningText, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Insufficient balance. Please choose another payment method.',
              style: TextStyle(fontSize: 13, color: _C.warningText, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter Coupon Amount',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _C.textDark),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _C.greenBorder, width: 2),
            boxShadow: [BoxShadow(color: _C.greenPrimary.withOpacity(0.05), blurRadius: 8)],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                decoration: const BoxDecoration(
                  color: _C.greenSoft,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: const Text(
                  '₹',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _C.textMid),
                ),
              ),
              Container(width: 1.5, height: 52, color: _C.greenBorder),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  focusNode: _focusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w600, color: _C.textDark,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    hintText: '500',
                    hintStyle: TextStyle(color: _C.textLight),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildLimitText() {
    return Text.rich(
      TextSpan(
        text: 'Limit: ',
        style: const TextStyle(fontSize: 12, color: _C.textLight, fontWeight: FontWeight.w500),
        children: [
          TextSpan(
            text: _fmt(minCouponValAmount),
            style: const TextStyle(color: _C.greenPrimary, fontWeight: FontWeight.w600),
          ),
          const TextSpan(text: ' to '),
          TextSpan(
            text: _fmt(maxCouponValAmount),
            style: const TextStyle(color: _C.greenPrimary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }


  Widget _buildQuickChips() {
    final filtered = _quickAmounts
        .where((a) => a >= minCouponValAmount && a <= maxCouponValAmount)
        .toList();
    if (filtered.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8, runSpacing: 8,
      children: filtered.map((amt) {
        final isSelected = amount.toInt() == amt;
        return GestureDetector(
          onTap: () => _setQuickAmount(amt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? _C.greenPrimary : _C.greenSoft,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? _C.greenPrimary : _C.greenBorder, width: 1.5,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: _C.greenPrimary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3))]
                  : [],
            ),
            child: Text(
              _fmt(amt.toDouble()),
              style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : _C.greenPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.greenBorder, width: 1.5),
      ),
      child: Column(
        children: [
          _summaryRow('Amount', _fmt(amount)),
          if (!_isWalletTab) ...[
            const Divider(height: 1, color: _C.greenSoft),
            _summaryRow('GST (${gstValue.toInt()}%)', '+${_fmt(gstAmount)}', isGst: true),
          ],
          Container(
            decoration: const BoxDecoration(
              color: _C.greenSoft,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: _summaryRow(
              'Total Payable',
              _fmt(totalAmount),
              isTotal: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false, bool isGst = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
              color: isTotal ? _C.greenDark : _C.textMid,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16 : 13.5,
              fontWeight: FontWeight.w700,
              color: isGst ? _C.red : _C.greenDark,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCTAButton() {
    final disabled = !_isValidAmount || _isInsufficient;
    return GetBuilder<GiftController>(
      builder: (ctrl) {
        if (ctrl.isLoading) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [_C.greenPrimary, _C.greenLight]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
              ),
            ),
          );
        }
        return GestureDetector(
          onTap: disabled ? null : _onPurchase,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: disabled
                  ? null
                  : const LinearGradient(
                colors: [_C.greenPrimary, _C.greenLight],
                begin: Alignment.centerLeft, end: Alignment.centerRight,
              ),
              color: disabled ? _C.greenBorder : null,
              borderRadius: BorderRadius.circular(14),
              boxShadow: disabled
                  ? []
                  : [BoxShadow(color: _C.greenPrimary.withOpacity(0.30), blurRadius: 24, offset: const Offset(0, 6))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  amount > 0 ? 'Gift Coupon (${_fmt(amount)})' : 'Gift Coupon',
                  style: const TextStyle(
                    color: Colors.white, fontSize: 15,
                    fontWeight: FontWeight.w700, letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Widget _buildMyCouponsHeader() {
    return GetBuilder<GiftController>(
      builder: (ctrl) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'My Coupons',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _C.greenDark),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _C.greenPrimary, borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${ctrl.couponList.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.check_circle_outline_rounded, color: _C.greenPrimary, size: 22),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildCouponList() {
    return GetBuilder<GiftController>(
      builder: (ctrl) {
        if (ctrl.isVouchersListLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(color: _C.greenPrimary),
            ),
          );
        }
        if (ctrl.couponList.isEmpty) return _buildEmptyState();

        return NotificationListener<ScrollNotification>(
          onNotification: (info) {
            if (info.metrics.pixels >= info.metrics.maxScrollExtent - 100) {
              ctrl.loadMoreVouchers();
            }
            return false;
          },
          child: Column(
            children: [
              ...ctrl.couponList.asMap().entries.map(
                    (e) => _buildCouponCard(e.value, e.key),
              ),
              if (ctrl.isFetchingMoreVouchers)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(color: _C.greenPrimary, strokeWidth: 2),
                ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildCouponCard(CouponList coupon, int index) {
    final statusInfo = _getStatusInfo(coupon.status ?? 0, coupon.expiryDate,);
    final code = coupon.name ?? '';
    final amt  = double.tryParse(coupon.amount ?? '0') ?? 0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 280 + (index * 50)),
      curve: Curves.easeOut,
      builder: (ctx, val, child) => Opacity(
        opacity: val,
        child: Transform.translate(offset: Offset(0, 10 * (1 - val)), child: child),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.greenBorder, width: 1.5),
          boxShadow: [BoxShadow(
            color: _C.greenPrimary.withOpacity(0.07),
            blurRadius: 10, offset: const Offset(0, 2),
          )],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0, right: 0,
              child: Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [_C.greenPrimary.withOpacity(0.08), Colors.transparent],
                  ),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomLeft: Radius.circular(60),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(children: [
                          const TextSpan(
                            text: '₹',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: _C.textMid),
                          ),
                          TextSpan(
                            text: NumberFormat('#,##,###').format(amt.toInt()),
                            style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.w700, color: _C.greenDark,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ]),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusInfo['bg'] as Color,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusInfo['border'] as Color),
                        ),
                        child: Text(
                          statusInfo['label'] as String,
                          style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700,
                            color: statusInfo['text'] as Color, letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: _C.greenSoft,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: _C.greenPrimary, width: 1.5),
                          ),
                          child: Text(
                            code,
                            style: const TextStyle(
                              fontFamily: 'monospace', fontSize: 15,
                              fontWeight: FontWeight.w700, color: _C.greenPrimary, letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _iconBtn(Icons.copy_rounded, () {
                        Clipboard.setData(ClipboardData(text: code));
                        _showSnack('Code copied: $code');
                      }),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 12, color: _C.textLight),
                      const SizedBox(width: 4),
                      Text(
                        'Purchased: ${_formatDate(coupon.createdAt)}',
                        style: const TextStyle(fontSize: 11, color: _C.textLight, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 14),
                      const Icon(Icons.schedule_rounded, size: 12, color: _C.textLight),
                      const SizedBox(width: 4),
                      Text(
                        'Expires: ${_formatDate(coupon.expiryDate)}',
                        style: const TextStyle(fontSize: 11, color: _C.textLight, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: _C.greenSoft, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _actionBtn(Icons.download_rounded, 'Download', () {
                        _downloadVoucher(id: coupon.id.toString());
                      })),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _actionBtn(Icons.share_rounded, 'Share', () {
                          final shareText = '''
🎁 Coupon Code: $code
💰 Amount: ₹${amt.toInt()}
📅 Expires on: ${_formatDate(coupon.expiryDate)}

Use this coupon now!
''';

                          Share.share(shareText);
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _downloadVoucher({String? id}) async {
    String url =  '${ApiUrl.baseUrl}/api/v2/coupon-invoice-download/$id';
    if (id != null) {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        Fluttertoast.showToast(
          msg: "Could not open download link.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: _C.greenSoft, borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _C.greenBorder, width: 1.5),
      ),
      child: Icon(icon, size: 16, color: _C.greenPrimary),
    ),
  );

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _C.greenBorder, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 15, color: _C.greenPrimary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _C.greenPrimary)),
        ],
      ),
    ),
  );

  Widget _buildEmptyState() => const Center(
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(Icons.card_giftcard_outlined, size: 52, color: _C.textLight),
          SizedBox(height: 10),
          Text(
            'No coupons yet',
            style: TextStyle(fontSize: 13, color: _C.textLight, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ),
  );

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    try {
      final dt = DateTime.parse(raw);
      return '${dt.month}/${dt.day}/${dt.year}';
    } catch (_) {
      return raw;
    }
  }

  Map<String, dynamic> _getStatusInfo(int status, String? expiryDate) {
    // ✅ Check expiry first
    if (expiryDate != null && expiryDate.isNotEmpty) {
      try {
        final expDate = DateTime.parse(expiryDate);
        final now = DateTime.now();

        if (expDate.isBefore(now)) {
          return {
            'label': 'Expired',
            'bg': const Color(0xFFFDECEA),
            'border': const Color(0xFFF5C6C2),
            'text': const Color(0xFFC62828),
          };
        }
      } catch (_) {}
    }

    // ✅ If not expired → fallback to status
    switch (status) {
      case 0:
        return {
          'label': 'Active',
          'bg': const Color(0xFFE6F9E6),
          'border': const Color(0xFFA8DCA8),
          'text': const Color(0xFF2D7A2D),
        };
      case 1:
        return {
          'label': 'Used',
          'bg': const Color(0xFFF5F5F5),
          'border': const Color(0xFFDDDDDD),
          'text': const Color(0xFF888888),
        };
      default:
        return {
          'label': 'Expired',
          'bg': const Color(0xFFFDECEA),
          'border': const Color(0xFFF5C6C2),
          'text': const Color(0xFFC62828),
        };
    }
  }
}