import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:shimmer/shimmer.dart';
import '../gioo_plots/controller/gioo_controller.dart';
import '../plot_market/controller/plot_market_controller.dart';
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
    required this.type
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> with TickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Two controllers for left and right blasts
  late ConfettiController _controllerLeft;
  late ConfettiController _controllerRight;

  late AnimationController _iconAnimationController;

  @override
  void initState() {
    super.initState();

    _controllerLeft = ConfettiController(duration: const Duration(seconds: 2));
    _controllerRight = ConfettiController(duration: const Duration(seconds: 2));

    _iconAnimationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 800)
    )..forward();

    _startCelebration();
  }

  void _startCelebration() async {
    // Small delay to let the screen load
    await Future.delayed(const Duration(milliseconds: 300));
    _controllerLeft.play();
    _controllerRight.play();
    _playSuccessEffect();
  }

  Future<void> _playSuccessEffect() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/payment done.mp3'));
      await HapticFeedback.heavyImpact();
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  // Get the appropriate route based on PaymentType
  String _getHomeRoute() {
    switch (widget.type) {
      case PaymentType.plotPayment:
        return '/syndicate-plots'; // Syndicate plots screen
      case PaymentType.giooPayment:
        return '/gioo-plots'; // Gioo plots screen
      case PaymentType.documentPayment:
        return '/my-documents'; // Documents screen
      case PaymentType.marketVerification:
        return '/market-plots'; // Market plots screen
      default:
        return '/home'; // Fallback to main home
    }
  }

  // Get screen title based on PaymentType
  String _getPaymentTitle() {
    switch (widget.type) {
      case PaymentType.plotPayment:
        return 'Plot Payment Success!';
      case PaymentType.giooPayment:
        return 'Gioo Payment Success!';
      case PaymentType.documentPayment:
        return 'Document Payment Success!';
      case PaymentType.marketVerification:
        return 'Verification Payment Success!';
      default:
        return 'Payment Success!';
    }
  }

  // Get payment type display name
  String _getPaymentTypeName() {
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

  @override
  void dispose() {
    _audioPlayer.dispose();
    _controllerLeft.dispose();
    _controllerRight.dispose();
    _iconAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Vibrant Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFD4EBD9).withOpacity(0.5), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // 2. Confetti Cannons (Left and Right)
          Align(
            alignment: Alignment.centerLeft,
            child: ConfettiWidget(
              confettiController: _controllerLeft,
              blastDirection: 0, // Blast to the right
              emissionFrequency: 0.05,
              numberOfParticles: 15,
              maxBlastForce: 20,
              minBlastForce: 10,
              gravity: 0.3,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ConfettiWidget(
              confettiController: _controllerRight,
              blastDirection: pi, // Blast to the left
              emissionFrequency: 0.05,
              numberOfParticles: 15,
              maxBlastForce: 20,
              minBlastForce: 10,
              gravity: 0.3,
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange],
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              child: Column(
                children: [
                  SizedBox(height: 20.h),

                  // 3. Native Animated Tick
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
                        child: Icon(Icons.check_rounded, size: 70.sp, color: Colors.white),
                      ),
                    ),
                  ),

                  SizedBox(height: 30.h),

                  Text(_getPaymentTitle(),
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF2E7D32),
                      )),

                  SizedBox(height: 10.h),
                  Text("Transaction ID: ${widget.transactionId}",
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),

                  SizedBox(height: 40.h),

                  // 4. Clean Receipt Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))
                      ],
                    ),
                    child: Column(
                      children: [
                        Text("Amount Paid", style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                        SizedBox(height: 8.h),
                        Text("₹${widget.amount.toStringAsFixed(2)}",
                            style: TextStyle(fontSize: 38.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1B2533))),

                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: const Divider(thickness: 1.2),
                        ),

                        _buildDetailRow("Payment Mode", _getPaymentTypeName()),
                        SizedBox(height: 15.h),
                        _buildDetailRow("Status", "COMPLETED", color: Colors.green),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // 5. Dual Action Buttons
                  Row(
                    children: [
                      // View Details Button
                      Expanded(
                        child: Container(
                          height: 55.h,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.green[700]!),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              // Navigate to transaction details or history
                              Get.offAllNamed('/payment-history');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                            ),
                            child: Text("VIEW DETAILS",
                                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.green[700])),
                          ),
                        ),
                      ),

                      SizedBox(width: 15.w),

                      // Back to Home Button (Dynamic)
                      Expanded(
                        child: Container(
                          height: 55.h,
                          decoration: BoxDecoration(
                            color: Colors.green[700],
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              // Dynamic routing based on payment type
                              final route = _getHomeRoute();

                              // Clear all previous screens and navigate to the appropriate home
                              Get.offAllNamed(route);

                              // Optional: Refresh the data on the destination screen
                              _refreshDestinationData();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                            ),
                            child: Text(
                              _getButtonText(),
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
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

  String _getButtonText() {
    switch (widget.type) {
      case PaymentType.plotPayment:
        return 'VIEW SYNDICATE';
      case PaymentType.giooPayment:
        return 'VIEW GIOO';
      case PaymentType.documentPayment:
        return 'VIEW DOCUMENTS';
      case PaymentType.marketVerification:
        return 'VIEW MARKET';
      default:
        return 'BACK TO HOME';
    }
  }

  void _refreshDestinationData() {
    switch (widget.type) {
      case PaymentType.plotPayment:
      // Refresh syndicate plots
        try {
          final controller = Get.find<SyndicatePlotController>();
          controller.fetchSyndicatePlots();
        } catch (e) {
          print('Could not refresh syndicate plots: $e');
        }
        break;
      case PaymentType.giooPayment:
      // Refresh gioo plots
        try {
          final controller = Get.find<GiooPlotController>();
          controller.fetchGiooPlots();
        } catch (e) {
          print('Could not refresh gioo plots: $e');
        }
        break;
      case PaymentType.documentPayment:
      // Refresh documents
        try {
          // Assuming you have a DocumentsController
          // Get.find<DocumentsController>().fetchDocuments();
        } catch (e) {
          print('Could not refresh documents: $e');
        }
        break;
      case PaymentType.marketVerification:
      // Refresh market plots
        try {
          final controller = Get.find<PlotMarketController>();
          controller.fetchMarketPlots();
        } catch (e) {
          print('Could not refresh market plots: $e');
        }
        break;
    }
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 13.sp, fontWeight: FontWeight.w500)),
        Text(value, style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color ?? const Color(0xFF1B2533),
            fontSize: 13.sp
        )),
      ],
    );
  }
}