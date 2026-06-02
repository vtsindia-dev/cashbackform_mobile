import 'dart:ui';
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

class GiftScreen extends StatefulWidget {
  const GiftScreen({super.key});
  @override
  State<GiftScreen> createState() => _GiftScreenState();
}

class _GiftScreenState extends State<GiftScreen> with TickerProviderStateMixin {

  // ── Controllers ─────────────────────────────────────────────────────────
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  DashboardController dashboardController = Get.put(DashboardController());
  GiftController giftController = Get.put(GiftController());
  final ProfileController profileController = Get.put(ProfileController());
  late Razorpay _razorpay;

  // ── State ────────────────────────────────────────────────────────────────
  double amount = 0, gstValue = 0, gstAmount = 0, totalAmount = 0;
  double walletAmount = 0, minCouponValAmount = 0, maxCouponValAmount = 0;
  bool _isWalletTab = false;

  // ── Animation Controllers ────────────────────────────────────────────────
  late AnimationController _heroCtrl;   // page entrance
  late AnimationController _floatCtrl;  // ambient float / shimmer
  late AnimationController _pulseCtrl;  // CTA pulse

  late Animation<double>   _heroFade;
  late Animation<Offset>   _heroSlide;
  late Animation<double>   _floatAnim;
  late Animation<double>   _pulseAnim;

  final List<int> _quickAmounts = [500, 1000, 2000, 5000];

  String _fmt(double n) => '₹${NumberFormat('#,##,###').format(n.toInt())}';
  bool get _isInsufficient => _isWalletTab && walletAmount < amount;
  bool get _isValidAmount =>
      amount >= minCouponValAmount && amount <= maxCouponValAmount && amount > 0;

  // ── Lifecycle ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fetchGstValue();
    _amountController.addListener(_recalculate);

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaySuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPayError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);

    // Entrance
    _heroCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 680));
    _heroFade = CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut);
    _heroSlide = Tween<Offset>(begin: const Offset(0, 0.055), end: Offset.zero)
        .animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOutCubic));

    // Ambient float
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))
      ..repeat(reverse: true);
    _floatAnim = CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut);

    // CTA pulse
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.035)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _heroCtrl.forward();
    giftController.resetVouchers();
  }

  void _fetchGstValue() => setState(() {
    gstValue           = dashboardController.businessSettings.value?.couponServiceCharge ?? 0;
    minCouponValAmount = dashboardController.businessSettings.value?.minCouponVal ?? 0;
    maxCouponValAmount = dashboardController.businessSettings.value?.maxCouponVal ?? 0;
    walletAmount       = double.tryParse(dashboardController.profile.value?.walletBalance ?? '0') ?? 0;
  });

  void _recalculate() => setState(() {
    amount = double.tryParse(_amountController.text) ?? 0;
    if (_isWalletTab) { gstAmount = 0; totalAmount = amount; }
    else              { gstAmount = (amount * gstValue) / 100; totalAmount = amount + gstAmount; }
  });

  void _refreshWallet() => setState(() {
    walletAmount = double.tryParse(dashboardController.profile.value?.walletBalance ?? '0') ?? 0;
  });

  // ── Payment handlers ─────────────────────────────────────────────────────
  Future<void> _onPaySuccess(PaymentSuccessResponse r) async {
    try {
      giftController.isLoading = true; giftController.update();
      final amt = _amountController.text.trim();
      await giftController.giftVouchersBuyPostApi(
        amount: amt, transactionId: r.paymentId ?? '',
        paymentMethod: 'razor_pay', transactionDetails: r.paymentId ?? '', isFromWallet: false,
      );
      await dashboardController.fetchDashboard();
      final res = await Get.to(() => PaymentStatusScreen(isSuccess: true, paymentId: r.paymentId, amount: amt));
      if (res == true) _refreshWallet();
    } catch (_) { Get.off(() => PaymentStatusScreen(isSuccess: false, paymentId: r.paymentId)); }
    finally { giftController.isLoading = false; giftController.update(); }
  }

  void _onPayError(PaymentFailureResponse r) =>
      Get.to(() => PaymentStatusScreen(isSuccess: false, errorMessage: r.message));

  void _onExternalWallet(ExternalWalletResponse r) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Wallet: ${r.walletName}')));

  void _openCheckout(String total) async {
    final ud = await SessionManager.getUserData();
    if (ud == null) return;
    try {
      _razorpay.open({
        'key': '${dashboardController.businessSettings.value?.paymentApiKey}',
        'amount': (double.parse(total) * 100).toInt(),
        'name': '${ud['first_name']} ${ud['last_name']}',
        'timeout': 300,
        'prefill': {'contact': ud['phone'] ?? '', 'email': ud['email'] ?? ''},
      });
    } catch (e) { debugPrint('Razorpay: $e'); }
  }

  Future<void> _onPurchase() async {
    if (!_isValidAmount) {
      _toast('Amount must be ${_fmt(minCouponValAmount)} – ${_fmt(maxCouponValAmount)}', err: true);
      return;
    }
    if (_isInsufficient) return;
    if (_isWalletTab) {
      try {
        giftController.isLoading = true; giftController.update();
        final amt = _amountController.text.trim();
        await giftController.giftVouchersBuyPostApi(
          amount: amt, isFromWallet: true,
          transactionId: 'WALLET_${DateTime.now().millisecondsSinceEpoch}',
          paymentMethod: 'wallet', transactionDetails: 'wallet_payment',
        );
        await dashboardController.fetchDashboard();
        final res = await Get.to(() => PaymentStatusScreen(isSuccess: true, paymentId: 'WALLET', amount: amt));
        if (res == true) _refreshWallet();
      } catch (_) { Get.to(() => PaymentStatusScreen(isSuccess: false, errorMessage: 'Wallet payment failed')); }
      finally { giftController.isLoading = false; giftController.update(); }
    } else { _openCheckout(totalAmount.toStringAsFixed(2)); }
  }

  void _setQuick(int amt) {
    _amountController.text = amt.toString();
    _amountController.selection = TextSelection.collapsed(offset: amt.toString().length);
  }

  void _toast(String msg, {bool err = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(err ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w600))),
      ]),
      backgroundColor: err ? AppColor.red : AppColor.primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  void dispose() {
    _razorpay.clear();
    _amountController.removeListener(_recalculate);
    _amountController.dispose();
    _focusNode.dispose();
    _heroCtrl.dispose(); _floatCtrl.dispose(); _pulseCtrl.dispose();
    super.dispose();
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  BUILD
  // ══════════════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F2EA),
    body: FadeTransition(
      opacity: _heroFade,
      child: SlideTransition(
        position: _heroSlide,
        child: RefreshIndicator(
          color: AppColor.primary,
          onRefresh: () async => await giftController.resetVouchers(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _appBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 64),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _paymentToggle(),
                      const SizedBox(height: 22),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 340),
                        curve: Curves.easeOutCubic,
                        child: _isWalletTab
                            ? Column(children: [
                          _walletCard(),
                          if (_isInsufficient) ...[const SizedBox(height: 12), _warningBanner()],
                          const SizedBox(height: 22),
                        ])
                            : const SizedBox.shrink(),
                      ),
                      _amountSection(),
                      const SizedBox(height: 24),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        child: _isValidAmount
                            ? Column(children: [_summaryCard(), const SizedBox(height: 24)])
                            : const SizedBox.shrink(),
                      ),
                      _ctaButton(),
                      const SizedBox(height: 40),
                      _sectionHeader(),
                      const SizedBox(height: 18),
                      _couponList(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  // ── App Bar ──────────────────────────────────────────────────────────────
  Widget _appBar() => SliverAppBar(
    expandedHeight: 210,
    pinned: true,
    elevation: 0,
    backgroundColor: AppColor.primary,
    leading: Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 17),
        ),
      ),
    ),
    flexibleSpace: FlexibleSpaceBar(
      background: AnimatedBuilder(
        animation: _floatAnim,
        builder: (_, __) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF506030), AppColor.primary, Color(0xFF7CA44C)],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(children: [
            // Animated ambient orbs
            Positioned(top: -35 + (_floatAnim.value * 10), right: -25,
                child: _orb(200, Colors.white, 0.055)),
            Positioned(top: 30 - (_floatAnim.value * 8), right: 45,
                child: _orb(90, AppColor.orange, 0.20)),
            Positioned(bottom: -15 + (_floatAnim.value * 6), left: 20,
                child: _orb(130, AppColor.primarylite, 0.14)),
            Positioned(bottom: 20, right: 25,
                child: _orb(55, AppColor.orangeAccent, 0.15)),

            // Content
            Positioned(bottom: 26, left: 20, right: 90,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColor.orange.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: AppColor.orange.withOpacity(0.45)),
                  ),
                  child: const Text('✦  GIFT VOUCHERS',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800,
                          color: Color(0xFFFFE082), letterSpacing: 2.2)),
                ),
                const SizedBox(height: 10),
                const Text('Gift/Payment Coupon',
                    style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900,
                        height: 1.05, letterSpacing: -1.5)),
                const SizedBox(height: 6),
                Text('Buy, share & manage gift vouchers instantly',
                    style: TextStyle(color: Colors.white.withOpacity(0.52), fontSize: 12.5)),
              ]),
            ),

            // Floating icon (bobs up/down)
            Positioned(
              bottom: 26, right: 18,
              child: AnimatedBuilder(
                animation: _floatAnim,
                builder: (_, child) => Transform.translate(
                  offset: Offset(0, -5 * _floatAnim.value),
                  child: child,
                ),
                child: Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 8))],
                  ),
                  child: const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 32),
                ),
              ),
            ),
          ]),
        ),
      ),
    ),
  );

  Widget _orb(double size, Color c, double o) => Container(
    width: size, height: size,
    decoration: BoxDecoration(color: c.withOpacity(o), shape: BoxShape.circle),
  );

  // ── Payment Toggle ───────────────────────────────────────────────────────
  Widget _paymentToggle() => Container(
    padding: const EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(color: AppColor.primary.withOpacity(0.12), blurRadius: 18, offset: const Offset(0, 5)),
        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
      ],
    ),
    child: Row(children: [
      _tabBtn('Razorpay', Icons.credit_card_rounded, !_isWalletTab, () {
        setState(() => _isWalletTab = false); _recalculate();
      }),
      _tabBtn('Wallet', Icons.account_balance_wallet_rounded, _isWalletTab, () {
        setState(() => _isWalletTab = true); _recalculate();
      }),
    ]),
  );

  Widget _tabBtn(String label, IconData icon, bool active, VoidCallback onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280), curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          gradient: active ? const LinearGradient(
            colors: [Color(0xFF557035), AppColor.primary, Color(0xFF7CA44C)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ) : null,
          borderRadius: BorderRadius.circular(13),
          boxShadow: active ? [BoxShadow(color: AppColor.primary.withOpacity(0.42), blurRadius: 18, offset: const Offset(0, 5))] : [],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 16, color: active ? Colors.white : AppColor.grey),
          const SizedBox(width: 7),
          Text(label, style: TextStyle(
            color: active ? Colors.white : AppColor.textSecondary,
            fontSize: 13.5, fontWeight: FontWeight.w700,
          )),
        ]),
      ),
    ),
  );

  // ── Wallet Card ──────────────────────────────────────────────────────────
  Widget _walletCard() => AnimatedBuilder(
    animation: _floatAnim,
    builder: (_, __) => Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.lerp(const Color(0xFF3A5820), AppColor.primary, _floatAnim.value)!,
            Color.lerp(const Color(0xFF5A8030), const Color(0xFF7CA44C), _floatAnim.value)!,
          ],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(
          color: AppColor.primary.withOpacity(0.40),
          blurRadius: 26 + (_floatAnim.value * 8),
          offset: Offset(0, 9 + (_floatAnim.value * 3)),
        )],
      ),
      child: Stack(children: [
        Positioned(top: -22, right: -12, child: _orb(120, Colors.white, 0.06)),
        Positioned(bottom: -25, left: 50, child: _orb(100, AppColor.orange, 0.10)),
        Positioned(top: 8, right: 8,    child: _orb(42, AppColor.primarylite, 0.18)),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14), borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('WALLET BALANCE',
                  style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.8)),
            ),
            const SizedBox(height: 10),
            RichText(text: TextSpan(children: [
              const TextSpan(text: '₹ ', style: TextStyle(fontSize: 16, color: Colors.white54)),
              TextSpan(
                text: NumberFormat('#,##,###.##').format(walletAmount),
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white,
                    fontFeatures: [FontFeature.tabularFigures()]),
              ),
            ])),
            const SizedBox(height: 4),
            Text('Available to spend', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
          ])),
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14), borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.26)),
            ),
            child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 27),
          ),
        ]),
      ]),
    ),
  );

  // ── Warning ──────────────────────────────────────────────────────────────
  Widget _warningBanner() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF8E1),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColor.orange.withOpacity(0.4), width: 1.5),
    ),
    child: Row(children: [
      Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: AppColor.orange.withOpacity(0.14), shape: BoxShape.circle),
        child: const Icon(Icons.warning_amber_rounded, color: AppColor.orange, size: 18),
      ),
      const SizedBox(width: 12),
      const Expanded(child: Text(
        'Insufficient balance. Please switch to Razorpay.',
        style: TextStyle(fontSize: 12.5, color: Color(0xFF7A5000), fontWeight: FontWeight.w500),
      )),
    ]),
  );

  // ── Amount Section ───────────────────────────────────────────────────────
  Widget _amountSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Container(width: 4, height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColor.orange, AppColor.primary],
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        const Text('Coupon Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColor.textMain)),
      ]),
      const SizedBox(height: 12),

      // Input
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFDFDCD2), width: 1.5),
          boxShadow: [BoxShadow(color: AppColor.primary.withOpacity(0.09), blurRadius: 18, offset: const Offset(0, 6))],
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.07),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
            ),
            child: const Text('₹', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColor.primary)),
          ),
          Container(width: 1.5, height: 58, color: const Color(0xFFE8E5DC)),
          Expanded(child: TextField(
            controller: _amountController,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColor.textMain,
                fontFeatures: [FontFeature.tabularFigures()]),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              hintText: '0',
              hintStyle: TextStyle(color: AppColor.grey.withOpacity(0.45)),
            ),
          )),
          if (amount > 0)
            GestureDetector(
              onTap: () => _amountController.clear(),
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(color: AppColor.lightGrey, shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, size: 14, color: AppColor.grey),
                ),
              ),
            ),
        ]),
      ),
      const SizedBox(height: 10),

      Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Text(
          'Min: ${_fmt(minCouponValAmount)}    ·    Max: ${_fmt(maxCouponValAmount)}',
          style: const TextStyle(fontSize: 11.5, color: AppColor.grey, fontWeight: FontWeight.w500),
        ),
      ),
      const SizedBox(height: 18),

      _quickChips(),
    ],
  );

  Widget _quickChips() {
    final filtered = _quickAmounts.where((a) => a >= minCouponValAmount && a <= maxCouponValAmount).toList();
    if (filtered.isEmpty) return const SizedBox.shrink();
    return Wrap(spacing: 10, runSpacing: 10,
      children: filtered.map((amt) {
        final sel = amount.toInt() == amt;
        return GestureDetector(
          onTap: () => _setQuick(amt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 210), curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              gradient: sel ? const LinearGradient(
                colors: [AppColor.orange, AppColor.orangeAccent],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ) : null,
              color: sel ? null : Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: sel ? AppColor.orange : const Color(0xFFD8D4C8), width: 1.5),
              boxShadow: sel
                  ? [BoxShadow(color: AppColor.orange.withOpacity(0.36), blurRadius: 14, offset: const Offset(0, 5))]
                  : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Text(_fmt(amt.toDouble()), style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w700,
              color: sel ? Colors.white : AppColor.textSecondary,
            )),
          ),
        );
      }).toList(),
    );
  }

  // ── Summary Card ─────────────────────────────────────────────────────────
  Widget _summaryCard() => AnimatedBuilder(
    animation: _floatAnim,
    builder: (_, __) => Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE0DCD2), width: 1.5),
        boxShadow: [BoxShadow(
          color: AppColor.primary.withOpacity(0.09 + _floatAnim.value * 0.04),
          blurRadius: 20, offset: const Offset(0, 6),
        )],
      ),
      child: Column(children: [
        _sumRow('Coupon Value', _fmt(amount)),
        if (!_isWalletTab) ...[
          Divider(height: 1, thickness: 0.8, color: const Color(0xFFF2EDE4)),
          _sumRow('GST (${gstValue.toInt()}%)', '+${_fmt(gstAmount)}', highlight: AppColor.red),
        ],
        Divider(height: 1, thickness: 1.5, color: const Color(0xFFE8E2D8)),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF5F0E6), Color(0xFFEDF5E6)],
              begin: Alignment.centerLeft, end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
          ),
          child: _sumRow('Total Payable', _fmt(totalAmount), isTotal: true),
        ),
      ]),
    ),
  );

  Widget _sumRow(String label, String val, {bool isTotal = false, Color? highlight}) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: TextStyle(
            fontSize: 13.5, fontWeight: isTotal ? FontWeight.w700 : FontWeight.w400,
            color: isTotal ? AppColor.textMain : AppColor.textSecondary,
          )),
          Text(val, style: TextStyle(
            fontSize: isTotal ? 17 : 13.5, fontWeight: FontWeight.w800,
            color: highlight ?? (isTotal ? AppColor.primary : AppColor.textMain),
            fontFeatures: const [FontFeature.tabularFigures()],
          )),
        ]),
      );

  // ── CTA Button ───────────────────────────────────────────────────────────
  Widget _ctaButton() => GetBuilder<GiftController>(builder: (ctrl) {
    final disabled = !_isValidAmount || _isInsufficient;
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (_, child) => Transform.scale(
        scale: (disabled || ctrl.isLoading) ? 1.0 : _pulseAnim.value,
        child: child,
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: disabled ? null : const LinearGradient(
            colors: [Color(0xFF506030), AppColor.primary, Color(0xFF7CA44C)],
            begin: Alignment.topLeft, end: Alignment.bottomRight,
          ),
          color: disabled ? AppColor.lightGrey : null,
          borderRadius: BorderRadius.circular(18),
          boxShadow: disabled ? [] : [
            BoxShadow(color: AppColor.primary.withOpacity(0.44), blurRadius: 26, offset: const Offset(0, 10)),
            BoxShadow(color: AppColor.primary.withOpacity(0.15), blurRadius: 8),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: (disabled || ctrl.isLoading) ? null : _onPurchase,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: ctrl.isLoading
                  ? const Center(child: SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)))
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  amount > 0 ? 'Buy Gift Coupon  ·  ${_fmt(amount)}' : 'Buy Gift Coupon',
                  style: TextStyle(
                    color: disabled ? AppColor.grey : Colors.white,
                    fontSize: 15.5, fontWeight: FontWeight.w800, letterSpacing: 0.2,
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  });

  // ── Section Header ───────────────────────────────────────────────────────
  Widget _sectionHeader() => GetBuilder<GiftController>(builder: (ctrl) => Row(children: [
    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('My Vouchers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
          color: AppColor.textMain, letterSpacing: -0.6)),
      Text('${ctrl.couponList.length} coupons purchased',
          style: const TextStyle(fontSize: 12, color: AppColor.grey)),
    ])),
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColor.primary.withOpacity(0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.confirmation_num_outlined, size: 13, color: AppColor.primary),
        const SizedBox(width: 5),
        Text('${ctrl.couponList.length}', style: const TextStyle(
            color: AppColor.primary, fontSize: 13, fontWeight: FontWeight.w800)),
      ]),
    ),
  ]));

  // ── Coupon List ──────────────────────────────────────────────────────────
  Widget _couponList() => GetBuilder<GiftController>(builder: (ctrl) {
    if (ctrl.isVouchersListLoading) return const Center(
        child: Padding(padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(color: AppColor.primary)));
    if (ctrl.couponList.isEmpty) return _emptyState();
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        if (n.metrics.pixels >= n.metrics.maxScrollExtent - 100) ctrl.loadMoreVouchers();
        return false;
      },
      child: Column(children: [
        ...ctrl.couponList.asMap().entries.map((e) => _couponCard(e.value, e.key)),
        if (ctrl.isFetchingMoreVouchers) const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: CircularProgressIndicator(color: AppColor.primary, strokeWidth: 2),
        ),
      ]),
    );
  });

  // ── Coupon Card ──────────────────────────────────────────────────────────
  Widget _couponCard(CouponList coupon, int index) {
    final si = _statusInfo(coupon.status ?? 0, coupon.expiryDate);
    final code = coupon.name ?? '';
    final amt  = double.tryParse(coupon.amount ?? '0') ?? 0;
    final isActive = si['label'] == 'Active';

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + (index * 65).clamp(0, 500)),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(opacity: v,
          child: Transform.translate(offset: Offset(0, 22 * (1 - v)), child: child)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(
            color: isActive ? AppColor.primary.withOpacity(0.15) : Colors.black.withOpacity(0.07),
            blurRadius: 22, offset: const Offset(0, 7),
          )],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(children: [

            // ── Gradient header ──────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 22, 18, 20),
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(
                  colors: [Color(0xFF3D5E1E), AppColor.primary, Color(0xFF7CA44C)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                )
                    : const LinearGradient(colors: [Color(0xFF666666), Color(0xFF888888)]),
              ),
              child: Stack(children: [
                Positioned(top: -22, right: -12, child: _orb(110, Colors.white, 0.06)),
                Positioned(bottom: -28, left: 60, child: _orb(85, Colors.white, 0.04)),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('GIFT VOUCHER', style: TextStyle(
                      fontSize: 9, fontWeight: FontWeight.w800,
                      color: Colors.white.withOpacity(0.52), letterSpacing: 2.2,
                    )),
                    const SizedBox(height: 8),
                    RichText(text: TextSpan(children: [
                      const TextSpan(text: '₹', style: TextStyle(fontSize: 17, color: Colors.white70)),
                      TextSpan(
                        text: NumberFormat('#,##,###').format(amt.toInt()),
                        style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white,
                            fontFeatures: [FontFeature.tabularFigures()]),
                      ),
                    ])),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withOpacity(0.28)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Container(
                          width: 7, height: 7,
                          decoration: BoxDecoration(color: si['dot'] as Color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 5),
                        Text(si['label'] as String, style: const TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.5,
                        )),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    const Icon(Icons.card_giftcard_rounded, color: Colors.white24, size: 40),
                  ]),
                ]),
              ]),
            ),

            // ── Perforated tear line ─────────────────────────────────────────
            _TearLine(active: isActive),

            // ── Body ────────────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                // Coupon code row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  decoration: BoxDecoration(
                    color: isActive ? AppColor.primary.withOpacity(0.055) : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: isActive ? AppColor.primary.withOpacity(0.22) : const Color(0xFFDDDDDD),
                      width: 1.5,
                    ),
                  ),
                  child: Row(children: [
                    Expanded(child: Text(code, style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 2.5,
                      color: isActive ? AppColor.primary : AppColor.grey,
                    ))),
                    GestureDetector(
                      onTap: () { Clipboard.setData(ClipboardData(text: code)); _toast('Copied: $code'); },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: isActive ? AppColor.primary : AppColor.grey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(children: [
                          Icon(Icons.copy_rounded, size: 13, color: Colors.white),
                          SizedBox(width: 4),
                          Text('COPY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                              color: Colors.white, letterSpacing: 0.8)),
                        ]),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 14),

                // Date pills
                Row(children: [
                  _datePill(Icons.calendar_today_outlined, 'Issued', _fmtDate(coupon.createdAt), isActive, false),
                  const SizedBox(width: 10),
                  _datePill(Icons.schedule_rounded, 'Expires', _fmtDate(coupon.expiryDate), isActive, true),
                ]),
                const SizedBox(height: 16),
              ]),
            ),

            // ── Footer actions ───────────────────────────────────────────────
            Container(
              color: const Color(0xFFF7F4ED),
              padding: const EdgeInsets.fromLTRB(16, 11, 16, 13),
              child: Row(children: [
                Expanded(child: _actionBtn(Icons.download_rounded, 'Download', isActive, () {
                  _downloadVoucher(id: coupon.id.toString());
                })),
                const SizedBox(width: 10),
                Expanded(child: _actionBtn(Icons.ios_share_rounded, 'Share', isActive, () {
                  Share.share('🎁 Gift Coupon: $code\n💰 Value: ₹${amt.toInt()}\n📅 Expires: ${_fmtDate(coupon.expiryDate)}\n\nUse this voucher now!');
                })),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _datePill(IconData icon, String label, String val, bool active, bool accent) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: (accent && active) ? AppColor.orange.withOpacity(0.07) : const Color(0xFFF5F5F0),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: (accent && active) ? AppColor.orange.withOpacity(0.28) : const Color(0xFFE5E0D8),
            ),
          ),
          child: Row(children: [
            Icon(icon, size: 12, color: (accent && active) ? AppColor.orange : AppColor.grey),
            const SizedBox(width: 7),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(fontSize: 9, color: AppColor.grey,
                  fontWeight: FontWeight.w600, letterSpacing: 0.4)),
              const SizedBox(height: 1),
              Text(val, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700,
                  color: (accent && active) ? AppColor.orange : AppColor.textSecondary)),
            ])),
          ]),
        ),
      );

  Widget _actionBtn(IconData icon, String label, bool active, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFFDED9CF), width: 1.5),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 15, color: active ? AppColor.primary : AppColor.grey),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700,
                color: active ? AppColor.primary : AppColor.grey)),
          ]),
        ),
      );

  Widget _emptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Column(children: [
        Container(
          width: 84, height: 84,
          decoration: BoxDecoration(
            color: AppColor.primary.withOpacity(0.08),
            shape: BoxShape.circle,
            border: Border.all(color: AppColor.primary.withOpacity(0.2), width: 2),
          ),
          child: const Icon(Icons.card_giftcard_outlined, size: 38, color: AppColor.primary),
        ),
        const SizedBox(height: 16),
        const Text('No vouchers yet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColor.textSecondary)),
        const SizedBox(height: 4),
        const Text('Purchase your first gift coupon above', style: TextStyle(fontSize: 12, color: AppColor.grey)),
      ]),
    ),
  );

  // ── Helpers ──────────────────────────────────────────────────────────────
  void _downloadVoucher({String? id}) async {
    if (id == null) return;
    final uri = Uri.parse('${ApiUrl.baseUrl}/api/v2/coupon-invoice-download/$id');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
    else Fluttertoast.showToast(msg: 'Could not open download link.', gravity: ToastGravity.BOTTOM);
  }

  String _fmtDate(String? raw) {
    if (raw == null || raw.isEmpty) return '—';
    try { return DateFormat('dd MMM yyyy').format(DateTime.parse(raw).toLocal()); }
    catch (_) { return raw; }
  }

  Map<String, dynamic> _statusInfo(int status, String? expiry) {
    if (expiry != null && expiry.isNotEmpty) {
      try { if (DateTime.parse(expiry).isBefore(DateTime.now())) {
        return {'label': 'Expired', 'dot': AppColor.red};
      }} catch (_) {}
    }
    switch (status) {
      case 0:  return {'label': 'Active',  'dot': const Color(0xFF81C784)};
      case 1:  return {'label': 'Used',    'dot': AppColor.grey};
      default: return {'label': 'Expired', 'dot': AppColor.red};
    }
  }
}

// ─── Tear Line Widget ─────────────────────────────────────────────────────────
class _TearLine extends StatelessWidget {
  final bool active;
  const _TearLine({required this.active});

  @override
  Widget build(BuildContext context) {
    final lineColor = active ? AppColor.primary : Colors.grey.shade400;
    return Container(
      height: 22,
      color: Colors.white,
      child: Stack(children: [
        Positioned(left: -13, top: 1, bottom: 1, child: _notch()),
        Positioned(right: -13, top: 1, bottom: 1, child: _notch()),
        Center(child: CustomPaint(
          size: Size(MediaQuery.of(context).size.width - 36, 1.5),
          painter: _DashPainter(color: lineColor.withOpacity(0.3)),
        )),
      ]),
    );
  }

  Widget _notch() => Container(
    width: 26, height: 26,
    decoration: const BoxDecoration(color: Color(0xFFF5F2EA), shape: BoxShape.circle),
  );
}

class _DashPainter extends CustomPainter {
  final Color color;
  const _DashPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color..strokeWidth = 1.5;
    double x = 0;
    while (x < size.width) { canvas.drawLine(Offset(x, 0), Offset(x + 6, 0), p); x += 11; }
  }
  @override
  bool shouldRepaint(_DashPainter o) => o.color != color;
}