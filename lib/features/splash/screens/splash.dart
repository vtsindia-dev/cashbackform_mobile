import 'package:cashback_farms/common/colours.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/app_constant.dart';
import '../../../common/images.dart';
import '../../../common/route/router.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../deeplink/deeplink_service/service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _textFadeOutAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }



  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
      ),
    );

    _textFadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 700), () {
          _checkAuthenticationStatus();
        });
      }
    });
  }

  Future<void> _checkAuthenticationStatus() async {
    try {
      if (DeepLinkService().isHandlingLink) {
        debugPrint('🔗 Splash: deep link handling in progress — skipping');
        return;
      }
      final isLoggedIn = await SessionManager.isLoggedIn();
      final userData = await SessionManager.getUserData();
      if (DeepLinkService().isHandlingLink) {
        debugPrint('🔗 Splash: deep link fired during auth check — aborting');
        return;
      }
      if (isLoggedIn && userData != null) {
        final isExpired = await SessionManager.isSessionExpired();
        if (DeepLinkService().isHandlingLink) {
          debugPrint('🔗 Splash: deep link fired during session check — aborting');
          return;
        }
        if (isExpired) {
          debugPrint('❌ Session expired');
          await SessionManager.clearSession();
          Get.offAllNamed(AppRoutes.login);
        } else {
          debugPrint('✅ Session valid');
          final hasPendingDeepLink = DeepLinkService().pendingUri != null;
          Get.offAllNamed(AppRoutes.dashboard);
          if (hasPendingDeepLink) {
            Future.delayed(const Duration(milliseconds: 600), () {
              DeepLinkService().consumePendingUri();
            });
          }
        }
      } else {
        Get.offAllNamed(AppRoutes.login);
      }
    } catch (e) {
      debugPrint('❌ Error checking authentication: $e');
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _logoFadeAnimation.value,
                    child: Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Image.asset(
                        Images.logo,
                        width: 180,
                        height: 180,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                double textOpacity =
                    _textFadeAnimation.value * _textFadeOutAnimation.value;
                return Opacity(
                  opacity: textOpacity,
                  child: Text(
                    Constant.appName,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: AppColor.primary,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}