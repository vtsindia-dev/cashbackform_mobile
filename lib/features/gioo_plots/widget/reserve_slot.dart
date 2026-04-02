import 'dart:math';

import 'package:cashback_farms/common/widget/toster.dart';
import 'package:cashback_farms/features/gioo_plots/screens/gioterms.dart';
import 'package:cashback_farms/features/legal_and_policies/screen.dart';
import 'package:cashback_farms/features/menu/controller/dashboard_menu_controller.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../common/colours.dart';
import '../controller/gioo_controller.dart';
import 'package:lottie/lottie.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../model/gioo_plot.dart';

class ReserveSlot extends StatefulWidget {
  const ReserveSlot({super.key});

  @override
  State<ReserveSlot> createState() => _ReserveSlotState();
}

class _ReserveSlotState extends State<ReserveSlot> {
  final GiooPlotController controller = Get.put(GiooPlotController());
  int selectedPlotCount = 0;
  bool _isSelectionMode = false;
  List<int> _tempSelectedUnits = [];
  int _currentPage = 0;
  int _itemsPerPage = 100;
  final ScrollController _gridScrollController = ScrollController();
  bool _hasScrolledToAvailable = false;
  bool _isDisposed = false;

  DashboardController dashboardController = Get.put(DashboardController());

  @override
  void initState() {
    super.initState();
    ever(controller.units, (_) {
      if (_isDisposed) return;

      if (controller.units.isNotEmpty &&
          _currentPage * _itemsPerPage >= controller.units.length) {
        if (mounted) {
          setState(() {
            _currentPage = 0;
          });
        }
      }

      if (controller.units.isNotEmpty && !_hasScrolledToAvailable) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_isDisposed && mounted) {
            _scrollToFirstAvailablePlot();
          }
        });
      }
    });
    controller.resetValues();
    controller.walletBalance.value =
        double.tryParse(
          dashboardController.profile.value?.walletBalance ?? "0",
        ) ??
        0;
    controller.discountPercentage.value =
        double.tryParse(
          dashboardController.businessSettings.value?.discountPercentage
                  ?.toString() ??
              "0",
        ) ??
        0;
    controller.discountMaxCost.value =
        double.tryParse(
          dashboardController.businessSettings.value?.discountMaxCost
                  ?.toString() ??
              "0",
        ) ??
        0;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _gridScrollController.dispose();
    super.dispose();
  }

  void _scrollToFirstAvailablePlot() {
    if (_isDisposed || !mounted) return;
    if (_hasScrolledToAvailable || controller.units.isEmpty) return;
    int firstAvailableIndex = -1;
    for (int i = 0; i < controller.units.length; i++) {
      if (controller.units[i].status == 'Available') {
        firstAvailableIndex = i;
        break;
      }
    }

    if (firstAvailableIndex >= 0) {
      final pageForAvailable = (firstAvailableIndex / _itemsPerPage).floor();
      if (pageForAvailable != _currentPage) {
        if (mounted) {
          setState(() {
            _currentPage = pageForAvailable;
          });
        }
      }
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_isDisposed || !mounted) return;

        if (_gridScrollController.hasClients) {
          final rowIndex = (firstAvailableIndex % _itemsPerPage) ~/ 10;
          final scrollOffset = rowIndex * 100.0;
          _gridScrollController.animateTo(
            scrollOffset,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );

          _hasScrolledToAvailable = true;
        }
      });
    }
  }

  void _jumpToFirstAvailable() {
    if (_isDisposed || !mounted) return;
    if (controller.units.isEmpty) return;

    int firstAvailableIndex = -1;
    for (int i = 0; i < controller.units.length; i++) {
      if (controller.units[i].status == 'Available') {
        firstAvailableIndex = i;
        break;
      }
    }

    if (firstAvailableIndex >= 0) {
      final pageForAvailable = (firstAvailableIndex / _itemsPerPage).floor();

      if (mounted) {
        setState(() {
          _currentPage = pageForAvailable;
        });
      }

      Future.delayed(const Duration(milliseconds: 300), () {
        if (_isDisposed || !mounted) return;

        if (_gridScrollController.hasClients) {
          final rowIndex = (firstAvailableIndex % _itemsPerPage) ~/ 10;
          final scrollOffset = rowIndex * 100.0;

          _gridScrollController.animateTo(
            scrollOffset,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Container(
        constraints: BoxConstraints(maxWidth: 900.w),
        decoration: BoxDecoration(
          color: AppColor.backgroundLight,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Animate(
                    effects: [
                      FadeEffect(duration: 350.ms),
                      SlideEffect(
                        begin: const Offset(0, 0.15),
                        duration: 350.ms,
                      ),
                    ],
                    child: _buildLegend(controller),
                  ),
                  15.h.verticalSpace,
                  if (!_isSelectionMode)
                    Animate(
                      effects: [FadeEffect(duration: 350.ms)],
                      child: _buildPlotCountSelector(),
                    ),
                  if (_isSelectionMode)
                    Animate(
                      effects: [FadeEffect(duration: 350.ms)],
                      child: _buildSelectionHeader(),
                    ),

                  15.h.verticalSpace,

                  // Plot grid with animation
                  Animate(
                    effects: [FadeEffect(duration: 350.ms)],
                    child: _buildPlotGrid(controller),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Colors.black12),

            // Sidebar with animation
            Animate(
              effects: [
                FadeEffect(duration: 450.ms),
                SlideEffect(begin: const Offset(0, 0.1), duration: 450.ms),
              ],
              child: _buildSidebarCard(controller),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 1: SELECT NUMBER OF PLOTS (INCREMENTER) ----------------------------------------
  Widget _buildPlotCountSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "How many plots would you like to book?",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColor.textMain,
                ),
              ),
            ),
            // Auto-focus button
            if (controller.availableCount.value > 0)
              TextButton.icon(
                onPressed: _jumpToFirstAvailable,
                icon: const Icon(Icons.zoom_in_map, size: 14),
                label: Text(
                  'View Available',
                  style: TextStyle(fontSize: 12.sp),
                ),
                style: TextButton.styleFrom(foregroundColor: AppColor.orange),
              ),
          ],
        ),
        15.h.verticalSpace,

        // Number input field with increment/decrement buttons
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Decrement button
                  GestureDetector(
                    onTap: () {
                      if (selectedPlotCount > 0) {
                        setState(() {
                          selectedPlotCount--;
                        });
                      }
                    },
                    child: Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        color: selectedPlotCount > 0
                            ? AppColor.orange.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: selectedPlotCount > 0
                              ? AppColor.orange
                              : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.remove,
                          color: selectedPlotCount > 0
                              ? AppColor.orange
                              : Colors.grey,
                          size: 24.w,
                        ),
                      ),
                    ),
                  ),

                  20.w.horizontalSpace,

                  // Number display
                  Container(
                    width: 80.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        selectedPlotCount.toString(),
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColor.textMain,
                        ),
                      ),
                    ),
                  ),

                  20.w.horizontalSpace,

                  // Increment button
                  GestureDetector(
                    onTap: () {
                      final maxAvailable = controller.availableCount.value;
                      if (selectedPlotCount < maxAvailable) {
                        setState(() {
                          selectedPlotCount++;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Maximum ${maxAvailable} plots available',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        color:
                            selectedPlotCount < controller.availableCount.value
                            ? AppColor.orange.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color:
                              selectedPlotCount <
                                  controller.availableCount.value
                              ? AppColor.orange
                              : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add,
                          color:
                              selectedPlotCount <
                                  controller.availableCount.value
                              ? AppColor.orange
                              : Colors.grey,
                          size: 24.w,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              10.h.verticalSpace,

              // Available plots info
              Text(
                "${controller.availableCount.value} plots available for selection",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColor.textMain.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        15.h.verticalSpace,

        // Start selection button
        Row(
          children: [
            Expanded(
              child: Text(
                "Choose number of plots to book",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColor.textMain.withOpacity(0.6),
                ),
              ),
            ),
            if (selectedPlotCount > 0)
              ElevatedButton(
                onPressed: () {
                  if (selectedPlotCount > controller.availableCount.value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Only ${controller.availableCount.value} plots available',
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    return;
                  }
                  setState(() {
                    _tempSelectedUnits.clear();
                    // Auto-select available plots (if needed)
                    _autoSelectPlots();
                    _isSelectionMode = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      "Select $selectedPlotCount plot${selectedPlotCount > 1 ? 's' : ''}",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    5.w.horizontalSpace,
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectionHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Select $selectedPlotCount plot${selectedPlotCount > 1 ? 's' : ''}",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.textMain,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _isSelectionMode = false;
                  _tempSelectedUnits.clear();
                });
              },
              icon: Icon(Icons.close, size: 20.w),
            ),
          ],
        ),
        10.h.verticalSpace,
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColor.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.touch_app, size: 14.w, color: AppColor.orange),
                  5.w.horizontalSpace,
                  Text(
                    "Tap to select",
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColor.orange,
                    ),
                  ),
                ],
              ),
            ),
            10.w.horizontalSpace,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.drag_indicator,
                    size: 14.w,
                    color: AppColor.primary,
                  ),
                  5.w.horizontalSpace,
                  Text(
                    "Click & drag to select",
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColor.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        10.h.verticalSpace,
        Row(
          children: [
            Expanded(
              child: Container(
                height: 6.h,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3.r),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _tempSelectedUnits.length / selectedPlotCount,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.orange,
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                ),
              ),
            ),
            10.w.horizontalSpace,
            Text(
              "${_tempSelectedUnits.length}/$selectedPlotCount",
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.textMain,
              ),
            ),
          ],
        ),
        10.h.verticalSpace,
        if (_tempSelectedUnits.isNotEmpty)
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColor.orange.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColor.orange.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 16.w, color: AppColor.orange),
                8.w.horizontalSpace,
                Expanded(
                  child: Text(
                    "Selected plots: ${_tempSelectedUnits.join(', ')}",
                    style: TextStyle(fontSize: 12.sp, color: AppColor.textMain),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_tempSelectedUnits.length == selectedPlotCount)
                  TextButton(
                    onPressed: () {
                      // Confirm selection
                      _confirmSelection();
                    },
                    child: Text(
                      "CONFIRM",
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColor.orange,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  void _confirmSelection() {
    // Mark selected units as "Selected" in controller
    for (var unitId in _tempSelectedUnits) {
      final unitIndex = controller.units.indexWhere(
        (unit) => unit.id == unitId,
      );
      if (unitIndex != -1) {
        controller.units[unitIndex] = controller.units[unitIndex].copyWith(
          status: 'Selected',
        );
      }
    }

    // Update controller's selected units
    controller.selectedUnits.value = List.from(_tempSelectedUnits);
    controller.totalAmount.value =
        controller.selectedUnits.length * controller.pricePerUnit.value;
    controller.calculateFinalAmount();
    if (mounted) {
      setState(() {
        _isSelectionMode = false;
        _tempSelectedUnits.clear();
      });
    }

    controller.calculateTotals();
  }

  // LEGEND ----------------------------------------------------------------
  Widget _buildLegend(GiooPlotController controller) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "GreenHeap Plots",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColor.textMain,
            ),
          ),
          10.h.verticalSpace,
          Wrap(
            spacing: 12.w,
            runSpacing: 8.h,
            children: [
              _legendItem(
                AppColor.orange,
                _isSelectionMode
                    ? "Selecting (${_tempSelectedUnits.length})"
                    : "Selected (${controller.selectedCount.value})",
              ),
              _legendItem(
                AppColor.primary,
                "Booked (${controller.bookedCount.value + controller.adminBookedCount.value})",
              ),
              _legendItem(
                Colors.grey.withOpacity(0.5),
                "Available (${controller.availableCount.value})",
              ),
              _legendItem(
                Colors.blue.withOpacity(0.5),
                "Total Slot (${controller.totalPlotsCount.value})",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 18.w,
          height: 18.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        8.w.horizontalSpace,
        Text(
          text,
          style: TextStyle(fontSize: 12.sp, color: AppColor.textMain),
        ),
      ],
    );
  }

  Widget _buildPlotGrid(GiooPlotController controller) {
    return Obx(() {
      if (controller.units.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
        children: [
          if (controller.units.length > _itemsPerPage) ...[
            _buildPageNavigation(controller),
            15.h.verticalSpace,
          ],
          Container(height: 350.h, child: _buildGridForCurrentPage(controller)),
          if (controller.units.length > _itemsPerPage) ...[
            10.h.verticalSpace,
            _buildPageInfo(controller),
          ],
        ],
      );
    });
  }

  Widget _buildPageNavigation(GiooPlotController controller) {
    final totalPages = (controller.units.length / _itemsPerPage).ceil();
    int firstAvailablePlot = -1;
    int pageWithFirstAvailable = 0;
    for (int i = 0; i < controller.units.length; i++) {
      if (controller.units[i].status == 'Available') {
        firstAvailablePlot = i + 1; // +1 for 1-based plot numbering
        pageWithFirstAvailable = (i / _itemsPerPage).floor();
        break;
      }
    }

    return Column(
      children: [
        // Quick jump button (only show if not already on that page)
        if (firstAvailablePlot > 0 && pageWithFirstAvailable != _currentPage)
          Container(
            margin: EdgeInsets.only(bottom: 10.h),
            child: Material(
              color: AppColor.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.r),
              child: InkWell(
                borderRadius: BorderRadius.circular(20.r),
                onTap: () => _jumpToFirstAvailable(),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt, color: AppColor.orange, size: 16),
                      6.w.horizontalSpace,
                      Text(
                        'Jump to first available plot',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColor.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      4.w.horizontalSpace,
                      Text(
                        '(Plot $firstAvailablePlot)',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColor.orange.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Regular page navigation with swipe support
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _currentPage > 0
                  ? () {
                      if (mounted) {
                        setState(() {
                          _currentPage--;
                        });
                      }
                      // Reset scroll position when changing pages
                      if (_gridScrollController.hasClients) {
                        _gridScrollController.jumpTo(0);
                      }
                    }
                  : null,
              icon: const Icon(Icons.chevron_left),
              color: _currentPage > 0 ? AppColor.orange : Colors.grey,
            ),
            20.w.horizontalSpace,
            GestureDetector(
              onHorizontalDragEnd: (details) {
                final totalPages = (controller.units.length / _itemsPerPage)
                    .ceil();
                // Swipe right to left = next page
                if (details.primaryVelocity! < 0) {
                  if (_currentPage < totalPages - 1 && mounted) {
                    setState(() {
                      _currentPage++;
                    });
                    if (_gridScrollController.hasClients) {
                      _gridScrollController.jumpTo(0);
                    }
                  }
                }
                // Swipe left to right = previous page
                else if (details.primaryVelocity! > 0) {
                  if (_currentPage > 0 && mounted) {
                    setState(() {
                      _currentPage--;
                    });
                    if (_gridScrollController.hasClients) {
                      _gridScrollController.jumpTo(0);
                    }
                  }
                }
              },
              child: Text(
                'Plots ${_currentPage * _itemsPerPage + 1}-${min((_currentPage + 1) * _itemsPerPage, controller.units.length)}',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
              ),
            ),
            20.w.horizontalSpace,
            IconButton(
              onPressed: _currentPage < totalPages - 1
                  ? () {
                      if (mounted) {
                        setState(() {
                          _currentPage++;
                        });
                      }
                      // Reset scroll position when changing pages
                      if (_gridScrollController.hasClients) {
                        _gridScrollController.jumpTo(0);
                      }
                    }
                  : null,
              icon: const Icon(Icons.chevron_right),
              color: _currentPage < totalPages - 1
                  ? AppColor.orange
                  : Colors.grey,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridForCurrentPage(GiooPlotController controller) {
    final start = _currentPage * _itemsPerPage;
    final end = min(start + _itemsPerPage, controller.units.length);
    final pageUnits = controller.units.sublist(start, end);

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final totalPages = (controller.units.length / _itemsPerPage).ceil();
        // Swipe right to left = next page
        if (details.primaryVelocity! < 0) {
          if (_currentPage < totalPages - 1 && mounted) {
            setState(() {
              _currentPage++;
            });
            if (_gridScrollController.hasClients) {
              _gridScrollController.jumpTo(0);
            }
          }
        }
        // Swipe left to right = previous page
        else if (details.primaryVelocity! > 0) {
          if (_currentPage > 0 && mounted) {
            setState(() {
              _currentPage--;
            });
            if (_gridScrollController.hasClients) {
              _gridScrollController.jumpTo(0);
            }
          }
        }
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          // Allow scrolling within the grid
          return false;
        },
        child: GridView.builder(
          controller: _gridScrollController,
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 10,
            crossAxisSpacing: 6.w,
            mainAxisSpacing: 6.h,
            childAspectRatio: 1.0,
          ),
          itemCount: pageUnits.length,
          itemBuilder: (context, index) {
            final unit = pageUnits[index];
            final actualIndex = start + index;
            final actualUnit = controller.units[actualIndex];

            return _buildPlotUnitItem(controller, actualUnit, actualIndex);
          },
        ),
      ),
    );
  }

  Widget _buildPlotUnitItem(
    GiooPlotController controller,
    PlotUnit unit,
    int unitIndex,
  ) {
    final isTempSelected = _tempSelectedUnits.contains(unit.id);
    final isPermanentlySelected = controller.selectedUnits.contains(unit.id);

    // Check if this is the first available plot (for highlighting)
    bool isFirstAvailableInGrid = false;
    if (unit.status == 'Available') {
      // Find first available plot in the entire list
      for (int i = 0; i < controller.units.length; i++) {
        if (controller.units[i].status == 'Available') {
          if (i == unitIndex) {
            isFirstAvailableInGrid = true;
          }
          break;
        }
      }
    }

    Color color;
    IconData? icon;

    if (isPermanentlySelected) {
      color = AppColor.orange;
    } else if (unit.status == 'Booked') {
      color = AppColor.primary;
      icon = Icons.person;
    } else if (unit.status == 'AdminBooked') {
      color = AppColor.primary;
      icon = Icons.person;
    } else if (isTempSelected && _isSelectionMode) {
      color = AppColor.orange;
    } else {
      color = Colors.grey.withOpacity(0.5);
    }

    return GestureDetector(
      onTap: () {
        if (unit.status == 'Booked' || unit.status == 'AdminBooked') {
          String message = unit.status == 'AdminBooked'
              ? 'This plot is already booked'
              : 'This plot is already booked';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              duration: const Duration(seconds: 1),
            ),
          );
          return;
        }

        if (_isSelectionMode) {
          _handleTapSelection(unit.id);
        } else {
          controller.toggleUnitSelection(unit.id);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isFirstAvailableInGrid
                ? AppColor.orangeAccent
                : (isPermanentlySelected || isTempSelected
                      ? AppColor.orangeAccent
                      : Colors.transparent),
            width: isFirstAvailableInGrid
                ? 3.w
                : (isPermanentlySelected || isTempSelected ? 2.w : 0),
          ),
          boxShadow: isFirstAvailableInGrid
              ? [
                  BoxShadow(
                    color: AppColor.orangeAccent.withOpacity(0.5),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    unit.label,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (icon != null) Icon(icon, size: 12.w, color: Colors.white),
                ],
              ),
            ),
            if (isFirstAvailableInGrid)
              Positioned(
                top: 2.w,
                right: 2.w,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: AppColor.orangeAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.star, size: 8.w, color: Colors.white),
                ),
              ),
            if (isTempSelected)
              Positioned(
                top: 2.w,
                left: 2.w,
                child: Icon(Icons.check, size: 10.w, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageInfo(GiooPlotController controller) {
    final totalPages = (controller.units.length / _itemsPerPage).ceil();
    final availableCount = controller.availableCount.value;

    // For many pages, only show limited dots with current page indicator
    return Column(
      children: [
        // Show limited dots when there are too many pages
        if (totalPages <= 10)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < totalPages; i++)
                Container(
                  width: 6.w,
                  height: 6.w,
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _currentPage
                        ? AppColor.orange
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
            ],
          )
        else
          // Show limited dots with current page indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // First page
              Container(
                width: 6.w,
                height: 6.w,
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: 0 == _currentPage
                      ? AppColor.orange
                      : Colors.grey.withOpacity(0.3),
                ),
              ),

              // Show dots based on current page position
              if (_currentPage > 3) ...[
                SizedBox(width: 2.w),
                Text('...', style: TextStyle(fontSize: 10.sp)),
                SizedBox(width: 2.w),
              ],

              // Show 5 pages around current page
              for (
                int i = max(1, _currentPage - 2);
                i <= min(totalPages - 2, _currentPage + 2);
                i++
              )
                Container(
                  width: 6.w,
                  height: 6.w,
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _currentPage
                        ? AppColor.orange
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),

              // Show ellipsis if needed
              if (_currentPage < totalPages - 4) ...[
                SizedBox(width: 2.w),
                Text('...', style: TextStyle(fontSize: 10.sp)),
                SizedBox(width: 2.w),
              ],

              // Last page
              Container(
                width: 6.w,
                height: 6.w,
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (totalPages - 1) == _currentPage
                      ? AppColor.orange
                      : Colors.grey.withOpacity(0.3),
                ),
              ),
            ],
          ),

        // Page number text
        5.h.verticalSpace,
        Text(
          'Page ${_currentPage + 1} of $totalPages • $availableCount available plots',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColor.textMain.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  // Modify the auto-select method to exclude booked/admin-block units
  void _autoSelectPlots() {
    _tempSelectedUnits.clear();

    // Get available units (not booked and not already selected)
    final availableUnits = controller.units
        .where((unit) => unit.status == 'Available')
        .map((unit) => unit.id)
        .toList();

    // Sort by ID
    availableUnits.sort();

    // Take the first N available units
    if (availableUnits.length >= selectedPlotCount) {
      _tempSelectedUnits = availableUnits.take(selectedPlotCount).toList();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Not enough available plots. Only ${availableUnits.length} available.',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      // Select all available
      _tempSelectedUnits = availableUnits;
    }
  }

  // Update the tap selection to handle edge cases
  void _handleTapSelection(int unitId) {
    final unit = controller.units.firstWhere(
      (u) => u.id == unitId,
      orElse: () => PlotUnit(id: -1, label: '', status: 'Booked', area: 0),
    );

    if (unit.status == 'Booked') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('This plot is already booked'),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    if (_tempSelectedUnits.contains(unitId)) {
      if (mounted) {
        setState(() {
          _tempSelectedUnits.remove(unitId);
        });
      }
    } else if (_tempSelectedUnits.length < selectedPlotCount) {
      if (mounted) {
        setState(() {
          _tempSelectedUnits.add(unitId);
          _tempSelectedUnits.sort();
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You can only select $selectedPlotCount plots'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  // SIDEBAR ---------------------------------------------------------------
  Widget _buildSidebarCard(GiooPlotController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.w),
      decoration: BoxDecoration(
        color: AppColor.backgroundLight,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16.r),
          bottomRight: Radius.circular(16.r),
        ),
      ),
      child: Obx(() {
        final detail = controller.giooPlotDetail.value;

        if (detail == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationDetail(controller, detail),
            20.h.verticalSpace,
            _buildStatusAndUnitInfo(controller, detail),
            20.h.verticalSpace,
            _buildPriceSummary(controller),
            30.h.verticalSpace,
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: gioTermsCheckbox(),
              ),
            ),
            15.h.verticalSpace,
            _buildPayNowButton(controller),
          ],
        );
      }),
    );
  }

  Widget gioTermsCheckbox() {
    return Obx(
      () => Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: 0.9,
                child: Checkbox(
                  value: controller.gioTermsChecked.value,
                  activeColor: AppColor.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: (value) {
                    controller.gioTermsChecked.value = value ?? false;
                  },
                ),
              ),

              6.w.horizontalSpace,
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 12.sp, color: AppColor.textMain),
                    children: [
                      const TextSpan(text: "I accept the "),
                      TextSpan(
                        text: "Privacy Policy",
                        style: TextStyle(
                          color: AppColor.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.to(
                              () => LegalPageScreen(
                                slug: "gioo_nano_plots_booking_privacy_policy",
                                title: "Privacy Policy",
                              ),
                            );
                          },
                      ),
                      const TextSpan(text: " and "),
                      TextSpan(
                        text: "Terms & Conditions",
                        style: TextStyle(
                          color: AppColor.primary,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.to(
                              () => LegalPageScreen(
                                slug:
                                    "gioo_nano_plots_booking_terms_and_condition",
                                title: "Terms & Conditions",
                              ),
                            );
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationDetail(
    GiooPlotController controller,
    GiooPlotDetail detail,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.location_on_outlined, color: AppColor.black, size: 18.w),
            5.w.horizontalSpace,
            Text(
              "Property location",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.black,
              ),
            ),
          ],
        ),
        10.h.verticalSpace,
        Text(
          detail.address ?? "No address",
          style: TextStyle(fontSize: 12.sp, color: AppColor.black),
        ),
        5.h.verticalSpace,
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "ULPIN Number: ",
                style: GoogleFonts.montserrat(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColor.primary,
                ),
              ),
              TextSpan(
                text: detail.uldNo ?? "N/A",
                style: GoogleFonts.montserrat(
                  fontSize: 12.sp,
                  color: AppColor.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusAndUnitInfo(
    GiooPlotController controller,
    GiooPlotDetail detail,
  ) {
    final dateFormatter = DateFormat('dd MMM yyyy');

    /// Only DATE (no time)
    final createdDate = dateFormatter.format(detail.createdAt);
    final isVerified = detail.verify == 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// SELECTED UNITS
        _infoItem(
          isVerified ? Icons.verified : Icons.error_outline,
          isVerified ? "Verified" : "Not Verified",
          isVerified ? Colors.green : Colors.red,
        ),
        const SizedBox(height: 5),
        _infoItem(Icons.date_range, createdDate, AppColor.black),
        SizedBox(height: 5),

        _infoItem(
          Icons.location_city_outlined,
          controller.getSelectedUnitsText(),
          AppColor.black,
        ),

        /// SHOW MORE / LESS
        if (controller.selectedUnits.length > 5)
          GestureDetector(
            onTap: controller.toggleShowUnits,
            child: Padding(
              padding: EdgeInsets.only(left: 30.w, top: 6.h),
              child: Text(
                controller.showAllUnits.value ? "Show Less" : "Show More",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColor.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _infoItem(IconData icon, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 30.w,
          height: 30.w,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Icon(icon, size: 16.w, color: color),
          ),
        ),
        10.w.horizontalSpace,
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary(GiooPlotController controller) {
    final detail = controller.giooPlotDetail.value;
    if (detail == null) return const SizedBox();

    final selectedCount = _isSelectionMode
        ? _tempSelectedUnits.length
        : controller.selectedUnits.length;

    final pricePerUnit = controller.pricePerUnit.value;
    final totalPrice = selectedCount * pricePerUnit;

    if (controller.totalAmount.value != totalPrice.toDouble()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.totalAmount.value = totalPrice.toDouble();
        controller.calculateFinalAmount();
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Price of Selected Plots",
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
            color: AppColor.black,
          ),
        ),
        15.h.verticalSpace,
        _priceRow("Price per Unit:", "₹${pricePerUnit.toStringAsFixed(2)}"),
        5.h.verticalSpace,
        _priceRow("Number of Plots:", "$selectedCount x"),

        const Divider(height: 20, color: Colors.black12),
        Text("Apply Coupon", style: TextStyle(fontWeight: FontWeight.w600)),
        10.h.verticalSpace,
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50.h,
                child: Obx(
                  () => TextField(
                    controller: controller.couponController,
                    style: TextStyle(fontSize: 13.sp),
                    readOnly: controller.isApplied.value,
                    decoration: InputDecoration(
                      hintText: "Enter coupon code",
                      hintStyle: TextStyle(fontSize: 12.sp),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      filled: true,
                      fillColor: controller.isApplied.value
                          ? Colors.grey.shade200
                          : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            10.w.horizontalSpace,
            Obx(
              () => SizedBox(
                height: 45.h,
                width: 110.w,
                child: ElevatedButton(
                  onPressed: controller.isCouponLoading.value
                      ? null
                      : controller.isApplied.value
                      ? controller.removeCoupon
                      : controller.applyCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.isApplied.value
                        ? Colors.red
                        : AppColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: controller.isCouponLoading.value
                      ? SizedBox(
                          height: 18.w,
                          width: 18.w,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          controller.isApplied.value ? "Remove" : "Apply",
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
        10.h.verticalSpace,
        Obx(() {
          final wallet = controller.walletBalance.value;
          final isUsed = controller.useWallet.value;

          return Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isUsed
                        ? [Colors.green.shade50, Colors.green.shade100]
                        : [Colors.grey.shade50, Colors.grey.shade100],
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isUsed ? Colors.green : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: isUsed ? Colors.green : Colors.grey.shade300,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet,
                        color: isUsed ? Colors.white : Colors.black54,
                        size: 18.sp,
                      ),
                    ),
                    10.w.horizontalSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Wallet Balance",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            "₹${wallet.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: isUsed ? Colors.green : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: isUsed,
                        activeColor: Colors.green,
                        onChanged: (val) {
                          FocusScope.of(context).unfocus();
                          if (controller.selectedUnits.isEmpty) {
                            Fluttertoast.showToast(
                              msg: "Please select at least one plot",
                              gravity: ToastGravity.BOTTOM,
                            );
                            return;
                          }
                          controller.useWallet.value = val;

                          // ✅ Reset custom amount when toggled off
                          if (!val) {
                            controller.walletUsedAmount.value = 0.0;
                            controller.walletAmountController.clear();
                          } else {
                            // ✅ Default to full wallet balance when toggled on
                            controller.walletUsedAmount.value =
                                controller.walletBalance.value;
                            controller.walletAmountController.text = controller
                                .walletBalance
                                .value
                                .toStringAsFixed(0);
                          }
                          controller.calculateFinalAmount();
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // ✅ Custom amount input — only shown when wallet is ON
              if (isUsed) ...[
                8.h.verticalSpace,
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.green, size: 16.sp),
                      8.w.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Enter amount to use (Max: ₹${wallet.toStringAsFixed(0)})",
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            4.h.verticalSpace,
                            TextField(
                              controller: controller.walletAmountController,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                                prefixText: "₹ ",
                                prefixStyle: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade800,
                                ),
                                hintText: "0",
                                hintStyle: TextStyle(color: Colors.grey),
                              ),
                              onChanged: controller.onWalletAmountChanged,
                            ),
                          ],
                        ),
                      ),
                      // ✅ Use Max button
                      GestureDetector(
                        onTap: () {
                          controller.walletUsedAmount.value = wallet;
                          controller.walletAmountController.text = wallet
                              .toStringAsFixed(0);
                          controller.calculateFinalAmount();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            "MAX",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          );
        }),
        const Divider(height: 20, color: Colors.black12),
        _buildSpecialDiscountProgress(controller),
        10.h.verticalSpace,
        Obx(() {
          final total = controller.totalAmount.value;
          final couponDiscount = controller.discountAmount.value;
          final specialDiscount = controller.specialDiscountAmount.value;

          final walletUsed = controller.useWallet.value
              ? controller
                    .actualWalletUsed
                    .value // ✅ changed from walletUsedAmount
              : 0.0;

          final savings = specialDiscount + couponDiscount + walletUsed;

          return Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _priceRow("Total Amount", "₹${total.toStringAsFixed(2)}"),
                if (specialDiscount > 0)
                  _priceRow(
                    "Special Discount (${controller.discountPercentage.value.toInt()}%)",
                    "- ₹${specialDiscount.toStringAsFixed(2)}",
                    valueColor: Colors.green,
                  ),

                if (controller.isApplied.value && couponDiscount > 0)
                  _priceRow(
                    "Coupon Discount",
                    "- ₹${couponDiscount.toStringAsFixed(2)}",
                    valueColor: Colors.green,
                  ),

                if (controller.useWallet.value && walletUsed > 0)
                  _priceRow(
                    "Wallet Used",
                    "- ₹${walletUsed.toStringAsFixed(2)}",
                    valueColor: Colors.blue,
                  ),
                if (savings > 0)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "You Saved",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "₹${savings.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Text(
                          "Payable",
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Final Payable",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColor.black,
                      ),
                    ),
                    Text(
                      "₹${controller.finalPayable.value.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColor.orange,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _priceRow(
    String label,
    String value, {
    Color valueColor = Colors.black,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayNowButton(GiooPlotController controller) {
    final enabled = controller.selectedUnits.isNotEmpty && !_isSelectionMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Will Process your Registration After payment",
          style: TextStyle(fontSize: 10.sp, color: AppColor.black),
        ),
        10.h.verticalSpace,
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            if (controller.selectedUnits.isEmpty) {
              Fluttertoast.showToast(
                msg: "Please select at least one plot",
                gravity: ToastGravity.BOTTOM,
              );
              return;
            }
            if (!controller.gioTermsChecked.value) {
              Fluttertoast.showToast(
                msg: "Please accept terms and conditions",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                backgroundColor: Colors.black87,
                textColor: Colors.white,
                fontSize: 14,
              );
              return;
            }

            controller.proceedToPayment();
          },
          child: Container(
            height: 55.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: enabled
                  ? AppColor.orange
                  : AppColor.orange.withOpacity(0.5),
              borderRadius: BorderRadius.circular(35.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60.w,
                  height: 50.w,
                  child: Lottie.asset(
                    "assets/images/paynow.json",
                    repeat: true,
                  ),
                ),
                10.w.horizontalSpace,
                Text(
                  _isSelectionMode ? "Confirm Selection" : "Pay Now",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.black,
                  ),
                ),
                SizedBox(width: 30.w),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialDiscountProgress(GiooPlotController controller) {
    return Obx(() {
      final total = controller.totalAmount.value;
      final maxCost = controller.discountMaxCost.value;
      final percentage = controller.discountPercentage.value;
      final isUnlocked = controller.specialDiscountAmount.value > 0;

      if (maxCost <= 0 || percentage <= 0) return const SizedBox();

      final progress = (total / maxCost).clamp(0.0, 1.0);
      final remaining = maxCost - total;

      // ✅ Dynamic progress color
      List<Color> progressColors;
      if (progress >= 1.0) {
        progressColors = [Colors.greenAccent, Colors.green];
      } else if (progress >= 0.75) {
        progressColors = [Colors.blueAccent, Colors.blue];
      } else if (progress >= 0.50) {
        progressColors = [Colors.orangeAccent, Colors.orange];
      } else {
        progressColors = [Colors.amber, Colors.deepOrange];
      }

      return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isUnlocked
                ? [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)]
                : [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF303F9F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: isUnlocked
                  ? Colors.green.withOpacity(0.4)
                  : Colors.indigo.withOpacity(0.4),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(7.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                    color: Colors.white,
                    size: 16.sp,
                  ),
                ),
                8.w.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUnlocked
                            ? "🎉 Special Discount Unlocked!"
                            : "Unlock Special Discount",
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        isUnlocked
                            ? "You're saving ${percentage.toInt()}% on your order!"
                            : "Add ₹${remaining.toStringAsFixed(0)} more to get ${percentage.toInt()}% OFF",
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.white.withOpacity(0.4)),
                  ),
                  child: Text(
                    "${percentage.toInt()}% OFF",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            12.h.verticalSpace,

            // 🔹 Progress Bar
            Stack(
              children: [
                Container(
                  height: 10.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeOut,
                      height: 10.h,
                      width: constraints.maxWidth * progress,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: progressColors),
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: progressColors.last.withOpacity(0.6),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),

            8.h.verticalSpace,

            // 🔹 Milestones (Different Colors)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "₹0",
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                Row(
                  children: [
                    _milestoneChip("25%", progress >= 0.25, Colors.amber),
                    4.w.horizontalSpace,
                    _milestoneChip("50%", progress >= 0.50, Colors.orange),
                    4.w.horizontalSpace,
                    _milestoneChip("75%", progress >= 0.75, Colors.blue),
                    4.w.horizontalSpace,
                    _milestoneChip("100%", progress >= 1.0, Colors.green),
                  ],
                ),
                Text(
                  "₹${maxCost.toStringAsFixed(0)}",
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),

            // 🔹 Unlocked Banner
            if (isUnlocked) ...[
              10.h.verticalSpace,
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: Colors.greenAccent.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.savings_rounded,
                      color: Colors.greenAccent,
                      size: 16.sp,
                    ),
                    6.w.horizontalSpace,
                    Text(
                      "You're saving ₹${controller.specialDiscountAmount.value.toStringAsFixed(2)}!",
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _milestoneChip(String label, bool reached, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: reached ? color.withOpacity(0.3) : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.sp,
          color: reached ? Colors.white : Colors.white.withOpacity(0.5),
          fontWeight: reached ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
