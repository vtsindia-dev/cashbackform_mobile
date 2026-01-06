import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:shimmer/shimmer.dart';
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

                  Text("Payment Success!",
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

                        _buildDetailRow("Payment Mode", widget.type.name.toUpperCase()),
                        SizedBox(height: 15.h),
                        _buildDetailRow("Status", "COMPLETED", color: Colors.green),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // 5. Shiny Shimmer Button
                  Container(
                    width: double.infinity,
                    height: 55.h,
                    decoration: BoxDecoration(
                      color: Colors.green[700],
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      ),
                      child: Text("BACK TO HOME",
                          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white)),
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