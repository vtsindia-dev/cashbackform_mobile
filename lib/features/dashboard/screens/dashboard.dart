import 'package:cashback_farms/common/colours.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/images.dart';
import '../../../common/route/router.dart';
import '../../home/screens/home.dart';
import '../../material_store/screens/material_store.dart';
import '../../menu/screens/menu.dart';
import '../../service/screen/service_screen.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _selectedIndex = 0;
  bool _isPlotExpanded = false;
  bool _isCartExpanded = false;
  double _animationValue = 0.0;
  double _menuAnimationValue = 0.0;
  double _fabDotAnimation = 0.0;

  final List<Widget> _screens = [
    Home(),
    ServiceScreen(),
    MaterialStore(),
    Menu()
  ];

  late AnimationController _animationController;
  late AnimationController _menuAnimationController;
  late AnimationController _fabDotAnimationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: Navigator.of(context),
    )..addListener(() {
      if (mounted) {
        setState(() {
          _animationValue = _animationController.value;
        });
      }
    })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && _isPlotExpanded) {
          _animationController.repeat();
        }
      });
    _menuAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: Navigator.of(context),
    )..addListener(() {
      if (mounted) {
        setState(() {
          _menuAnimationValue = _menuAnimationController.value;
        });
      }
    });

    _fabDotAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: Navigator.of(context),
    )..addListener(() {
      if (mounted) {
        setState(() {
          _fabDotAnimation = _fabDotAnimationController.value;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _menuAnimationController.dispose();
    _fabDotAnimationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index < 0 || index >= _screens.length) return;

    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        _isCartExpanded = !_isCartExpanded;
        _isPlotExpanded = false;
        _animationController.stop();
        _menuAnimationController.reverse();
        _fabDotAnimationController.reverse();
      } else {
        _isPlotExpanded = false;
        _isCartExpanded = false;
        _animationController.stop();
        _menuAnimationController.reverse();
        _fabDotAnimationController.reverse();
      }
    });
  }

  void _onFabTapped() {
    setState(() {
      _isPlotExpanded = !_isPlotExpanded;
      _isCartExpanded = false;
      if (_isPlotExpanded) {
        _animationController.repeat();
        _menuAnimationController.forward();
        _fabDotAnimationController.forward();
      } else {
        _animationController.stop();
        _animationController.value = 0.0;
        _menuAnimationController.reverse();
        _fabDotAnimationController.reverse();
      }
    });
  }

  void _closeAllMenus() {
    setState(() {
      _isPlotExpanded = false;
      _isCartExpanded = false;
      _animationController.stop();
      _animationController.value = 0.0;
      _menuAnimationController.reverse();
      _fabDotAnimationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: _closeAllMenus,
            child: _screens[_selectedIndex],
          ),
          if (_isPlotExpanded || _menuAnimationValue > 0)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Container(
                height: 120,
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: CustomPaint(
                        painter: _MenuLinePainter(
                          animationValue: _animationValue,
                          menuAnimationValue: _menuAnimationValue,
                        ),
                        size: Size(MediaQuery.of(context).size.width, 60),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Transform.translate(
                          offset: Offset(
                            -50 * (1 - _menuAnimationValue),
                            30 * (1 - _menuAnimationValue),
                          ),
                          child: Opacity(
                            opacity: _menuAnimationValue,
                            child: Transform.scale(
                              scale: 0.5 + 0.5 * _menuAnimationValue,
                              child: _buildPlotMenuItem(
                                Images.plotMarketplace,
                                "Plot Marketplace",
                                    () => _onPlotMenuItemTap(0),
                                alignment: Alignment.bottomLeft,
                              ),
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(
                            0,
                            -50 * (1 - Curves.elasticOut.transform(_menuAnimationValue)),
                          ),
                          child: Opacity(
                            opacity: _menuAnimationValue,
                            child: Transform.scale(
                              scale: 0.5 + 0.5 * Curves.elasticOut.transform(_menuAnimationValue),
                              child: _buildPlotMenuItem(
                                Images.GiooPlots,
                                "GIOO Plots",
                                    () => _onPlotMenuItemTap(1),
                                alignment: Alignment.topCenter,
                              ),
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(
                            50 * (1 - _menuAnimationValue),
                            30 * (1 - _menuAnimationValue),
                          ),
                          child: Opacity(
                            opacity: _menuAnimationValue,
                            child: Transform.scale(
                              scale: 0.5 + 0.5 * _menuAnimationValue,
                              child: _buildPlotMenuItem(
                                Images.syndicatePlots,
                                "Syndicate Plots",
                                    () => _onPlotMenuItemTap(2),
                                alignment: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Images.home, "Home", 0),
              _buildNavItem(Images.service, "Service", 1, isCart: false),
              const SizedBox(width: 40),
              _buildNavItem(Images.materialStore, "Material", 2),
              _buildNavItem(Images.profile, "Profile", 3),
            ],
          ),
        ),
      ),
      floatingActionButton: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: FloatingActionButton(
          onPressed: _onFabTapped,
          backgroundColor: _isPlotExpanded ? AppColor.primary.withOpacity(0.8) : AppColor.primary,
          elevation: _isPlotExpanded ? 12 : 4,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Main icon
              ImageIcon(
                AssetImage(Images.plot),
                size: 28,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem(String imagePath, String label, int index, {bool isCart = false}) {
    final isSelected = _selectedIndex == index;
    final isExpanded = (isCart && _isCartExpanded);

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              ImageIcon(
                AssetImage(imagePath),
                color: isSelected || isExpanded ? AppColor.primary : Colors.black,
              ),
              if (isExpanded)
                const Positioned(
                  top: -2,
                  right: -2,
                  child: CircleAvatar(radius: 4, backgroundColor: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isSelected || isExpanded ? AppColor.primary : Colors.black,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlotMenuItem(String imagePath, String label, VoidCallback onTap, {Alignment alignment = Alignment.center}) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: AppColor.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: ImageIcon(
                  AssetImage(imagePath),
                  size: 28,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPlotMenuItemTap(int menuIndex) {
    debugPrint('Plot menu item tapped: $menuIndex');

    setState(() {
      _isPlotExpanded = false;
      _animationController.stop();
      _animationController.value = 0.0;
      _menuAnimationController.reverse();
      _fabDotAnimationController.reverse();
    });

    switch (menuIndex) {
      case 0:
        debugPrint('Plot Marketplace tapped');
        Get.toNamed(AppRoutes.plotMarket);

        break;
      case 1:
        debugPrint('GIOO Plots tapped');
        Get.toNamed(AppRoutes.gioo);

        break;
      case 2:
        debugPrint('Syndicate Plots tapped');
        Get.toNamed(AppRoutes.syndicate);
        break;
      default:
        debugPrint('Unknown menu index: $menuIndex');
    }
  }
}

class _MenuLinePainter extends CustomPainter {
  final double animationValue;
  final double menuAnimationValue;

  _MenuLinePainter({required this.animationValue, required this.menuAnimationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColor.primary.withOpacity(0.3 * menuAnimationValue)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = AppColor.primary.withOpacity(menuAnimationValue)
      ..style = PaintingStyle.fill;
    final fabX = size.width / 2;
    final fabY = size.height;
    final paths = [
      _createCurvedPath(fabX, fabY, size.width * 0.2, size.height * 0.8, -40.0), // Left
      _createCurvedPath(fabX, fabY, fabX, size.height * 0.2, -60.0), // Top
      _createCurvedPath(fabX, fabY, size.width * 0.8, size.height * 0.8, -40.0), // Right
    ];
    for (final path in paths) {
      _drawDottedPath(canvas, linePaint, path);
    }
    if (menuAnimationValue > 0.5) {
      _drawSingleRunningDot(canvas, dotPaint, paths, animationValue);
    }
  }

  Path _createCurvedPath(double startX, double startY, double endX, double endY, double curveHeight) {
    final path = Path();
    final controlPoint = Offset(
      (startX + endX) / 2,
      (startY + endY) / 2 + curveHeight,
    );

    path.moveTo(startX, startY);
    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, endX, endY);
    return path;
  }

  void _drawDottedPath(Canvas canvas, Paint paint, Path path) {
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      final dashPath = Path();
      double distance = 0;
      const dashWidth = 4.0;
      const dashSpace = 3.0;

      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }

      canvas.drawPath(dashPath, paint);
    }
  }

  void _drawSingleRunningDot(Canvas canvas, Paint dotPaint, List<Path> paths, double animationValue) {
    final totalPaths = paths.length;
    final segmentDuration = 1.0 / totalPaths;

    final currentSegment = (animationValue / segmentDuration).floor();
    final segmentProgress = (animationValue % segmentDuration) / segmentDuration;

    if (currentSegment < paths.length) {
      final currentPath = paths[currentSegment];
      final pathMetrics = currentPath.computeMetrics();

      for (final pathMetric in pathMetrics) {
        final tangent = pathMetric.getTangentForOffset(pathMetric.length * segmentProgress);
        if (tangent != null) {
          canvas.drawCircle(tangent.position, 4, dotPaint);
          final glowPaint = Paint()
            ..color = AppColor.primary.withOpacity((0.5 - (segmentProgress * 0.3)) * menuAnimationValue)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(tangent.position, 6, glowPaint);

          if (segmentProgress > 0.1) {
            final leadProgress = segmentProgress - 0.1;
            final leadTangent = pathMetric.getTangentForOffset(pathMetric.length * leadProgress);
            if (leadTangent != null) {
              final leadPaint = Paint()
                ..color = AppColor.primary.withOpacity(0.3 * menuAnimationValue)
                ..style = PaintingStyle.fill;
              canvas.drawCircle(leadTangent.position, 2, leadPaint);
            }
          }
        }
      }
    }
  }
  @override
  bool shouldRepaint(covariant _MenuLinePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue || oldDelegate.menuAnimationValue != menuAnimationValue;
}