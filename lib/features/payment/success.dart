import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import '../gioo_plots/controller/gioo_controller.dart';
import '../plot_market/controller/plot_market_controller.dart';
import '../rental_yeild/controller/rental_yield_controller.dart';
import '../residential_plots/controller/residential_add_controller.dart';
import '../syndicate_plot/controller/syndicate_controller.dart';
import 'controller/razorpay_controller.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final double amount;
  final String transactionId;
  final PaymentType type;

  const PaymentSuccessScreen({
    super.key,
    required this.amount,
    required this.transactionId,
    required this.type,
  });

  @override
  State<PaymentSuccessScreen> createState() =>
      _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();

  late ConfettiController _controllerLeft;
  late ConfettiController _controllerRight;
  late AnimationController _iconAnimationController;


  bool get isZeroPay => widget.amount == 0;

  @override
  void initState() {
    super.initState();

    _controllerLeft =
        ConfettiController(duration: const Duration(seconds: 2));
    _controllerRight =
        ConfettiController(duration: const Duration(seconds: 2));

    _iconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _startCelebration();
  }

  void _startCelebration() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _controllerLeft.play();
    _controllerRight.play();
    _playSuccessEffect();
  }

  Future<void> _playSuccessEffect() async {
    try {
      await _audioPlayer.play(
        AssetSource('sounds/payment done.mp3'),
      );
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _controllerLeft.dispose();
    _controllerRight.dispose();
    _iconAnimationController.dispose();
    super.dispose();
  }


  String _getPaymentTitle() {
    if (isZeroPay) return 'Booking Confirmed 🎉';

    switch (widget.type) {
      case PaymentType.plotPayment:
        return 'Syndicate Plot Payment Success!';
      case PaymentType.giooPayment:
        return 'Gioo Plot Payment Success!';
      case PaymentType.documentPayment:
        return 'Document Payment Success!';
      case PaymentType.marketVerification:
        return 'Verification Payment Success!';
      default:
        return 'Payment Success!';
    }
  }


  String _getPaymentTypeName() {
    if (isZeroPay) return 'FREE BOOKING';

    switch (widget.type) {
      case PaymentType.plotPayment:
        return 'SYNDICATE PLOT';
      case PaymentType.giooPayment:
        return 'GIOO PLOT';
      case PaymentType.documentPayment:
        return 'DOCUMENT';
      case PaymentType.marketVerification:
        return 'MARKET VERIFICATION';
      default:
        return widget.type.name.toUpperCase();
    }
  }


  String _getHomeRoute() {
    switch (widget.type) {
      case PaymentType.plotPayment:
        return '/ownedSyndicatePlotList';
      case PaymentType.giooPayment:
        return '/ownedplotlist';
      case PaymentType.rentalDocumentPayment:
        return '/rentalYieldList';
      default:
        return '/home';
    }
  }


  String _getButtonText() {
    return "VIEW";
  }


  void _refreshDestinationData() {
    switch (widget.type) {
      case PaymentType.plotPayment:
        try {
          Get.find<SyndicatePlotController>()
              .fetchSyndicateBuyingList();
        } catch (e) {
          print('Error: $e');
        }
        break;

      case PaymentType.giooPayment:
        try {
          Get.find<GiooPlotController>()
              .fetchGiooBuyingList();
        } catch (e) {
          print('Error: $e');
        }
        break;

      case PaymentType.marketVerification:
        try {
          Get.find<PlotMarketController>().fetchMarketPlots();
        } catch (e) {
          print('Error: $e');
        }
        break;

      case PaymentType.residentialVerification:
        try {
          Get.find<ResidentialPropertyFormController>()
              .fetchMyProperties();
        } catch (e) {
          print('Error: $e');
        }
        break;

      case PaymentType.rentalDocumentPayment:
        try {
          Get.find<RentalYieldController>().fetchProperties();
        } catch (e) {
          print('Error: $e');
        }
        break;

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFD4EBD9).withOpacity(0.5),
                  Colors.white
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: ConfettiWidget(
              confettiController: _controllerLeft,
              blastDirection: 0,
              emissionFrequency: 0.05,
              numberOfParticles: 15,
              gravity: 0.3,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ConfettiWidget(
              confettiController: _controllerRight,
              blastDirection: pi,
              emissionFrequency: 0.05,
              numberOfParticles: 15,
              gravity: 0.3,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),

                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _iconAnimationController,
                      curve: Curves.elasticOut,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50.r,
                        backgroundColor: Colors.green,
                        child: Icon(
                          Icons.check_rounded,
                          size: 70.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30.h),

                  Text(
                    _getPaymentTitle(),
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  Text(
                    "Transaction ID: ${widget.transactionId}",
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600]),
                  ),

                  SizedBox(height: 40.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Amount Paid",
                          style: TextStyle(
                              color: Colors.grey, fontSize: 14.sp),
                        ),

                        SizedBox(height: 8.h),

                        Text(
                          isZeroPay
                              ? "FREE"
                              : "₹${widget.amount.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 38.sp,
                            fontWeight: FontWeight.w900,
                            color: isZeroPay
                                ? Colors.green
                                : const Color(0xFF1B2533),
                          ),
                        ),

                        if (isZeroPay)
                          Padding(
                            padding: EdgeInsets.only(top: 6.h),
                            child: Text(
                              "Fully covered by discounts & wallet",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: const Divider(thickness: 1.2),
                        ),

                        _buildDetailRow(
                            "Payment Mode", _getPaymentTypeName()),
                        SizedBox(height: 15.h),
                        _buildDetailRow("Status", "COMPLETED",
                            color: Colors.green),
                      ],
                    ),
                  ),

                  const Spacer(),

                  SizedBox(
                    width: double.infinity,
                    height: 55.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.offNamed(_getHomeRoute());
                        _refreshDestinationData();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        _getButtonText(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
              color: Colors.grey[500],
              fontSize: 13.sp,
              fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color ?? const Color(0xFF1B2533),
            fontSize: 13.sp,
          ),
        ),
      ],
    );
  }
}