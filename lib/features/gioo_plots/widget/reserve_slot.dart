import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../common/colours.dart';
import '../controller/gioo_controller.dart';
import '../model/gioo_plot.dart';
import 'package:lottie/lottie.dart';

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
  bool _isDragging = false;
  int? _dragStartUnit;
  int _currentPage = 0;
  int _itemsPerPage = 100;
  final PageController _pageController = PageController();

  // Add this getter for paginated units
  List<PlotUnit> get paginatedUnits {
    final start = _currentPage * _itemsPerPage;
    final end = start + _itemsPerPage;

    if (controller.units.isEmpty) return [];

    if (start >= controller.units.length) {
      _currentPage = 0;
      return controller.units.take(_itemsPerPage).toList();
    }

    return controller.units.sublist(
        start,
        end > controller.units.length ? controller.units.length : end
    );
  }

  int get totalPages => (controller.units.length / _itemsPerPage).ceil();

  @override
  void initState() {
    super.initState();
    // Listen for unit changes
    ever(controller.units, (_) {
      if (controller.units.isNotEmpty && _currentPage * _itemsPerPage >= controller.units.length) {
        _currentPage = 0;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
            )
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
                  // Legend with animation
                  Animate(
                    effects: [
                      FadeEffect(duration: 350.ms),
                      SlideEffect(begin: Offset(0, 0.15), duration: 350.ms),
                    ],
                    child: _buildLegend(controller),
                  ),
                  15.h.verticalSpace,

                  // Conditional widgets
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

            Divider(height: 1, color: Colors.black.withOpacity(0.1)),

            // Sidebar with animation
            Animate(
              effects: [
                FadeEffect(duration: 450.ms),
                SlideEffect(begin: Offset(0, 0.1), duration: 450.ms),
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
        Text(
          "How many plots would you like to book?",
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColor.textMain,
          ),
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
                        color: selectedPlotCount > 0 ? AppColor.orange.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: selectedPlotCount > 0 ? AppColor.orange : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.remove,
                          color: selectedPlotCount > 0 ? AppColor.orange : Colors.grey,
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
                            content: Text('Maximum ${maxAvailable} plots available'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    },
                    child: Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        color: selectedPlotCount < controller.availableCount.value
                            ? AppColor.orange.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: selectedPlotCount < controller.availableCount.value
                              ? AppColor.orange
                              : Colors.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add,
                          color: selectedPlotCount < controller.availableCount.value
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
                        content: Text('Only ${controller.availableCount.value} plots available'),
                        duration: Duration(seconds: 2),
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
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14.w,
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
                  _isDragging = false;
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
                  Icon(
                    Icons.touch_app,
                    size: 14.w,
                    color: AppColor.orange,
                  ),
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
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColor.textMain,
                    ),
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
      final unitIndex = controller.units.indexWhere((unit) => unit.id == unitId);
      if (unitIndex != -1) {
        controller.units[unitIndex] = controller.units[unitIndex].copyWith(status: 'Selected');
      }
    }

    // Update controller's selected units
    controller.selectedUnits.value = List.from(_tempSelectedUnits);

    setState(() {
      _isSelectionMode = false;
      _tempSelectedUnits.clear();
    });

    controller.calculateTotals();
  }

  // LEGEND ----------------------------------------------------------------
  Widget _buildLegend(GiooPlotController controller) {
    return Obx(() => Column(
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
            _legendItem(AppColor.orange,
                _isSelectionMode
                    ? "Selecting (${_tempSelectedUnits.length})"
                    : "Selected (${controller.selectedCount.value})"),
            _legendItem(AppColor.primary, "Booked (${controller.bookedCount.value})"),
            // _legendItem(Colors.green, "Admin Booked (${controller.adminBookedCount.value})"),
            _legendItem(Colors.grey.withOpacity(0.5), "Available (${controller.availableCount.value})"),
            _legendItem(Colors.blue.withOpacity(0.5), "Total (${controller.totalPlotsCount.value})"),
          ],
        ),
      ],
    ));
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
        Text(text, style: TextStyle(fontSize: 12.sp, color: AppColor.textMain)),
      ],
    );
  }

  // PLOT GRID WITH DRAG SELECTION -----------------------------------------
  Widget _buildPlotGrid(GiooPlotController controller) {
    return Obx(() {
      if (controller.units.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      return Column(
        children: [
          // Page navigation
          if (controller.units.length > 100) ...[
            _buildPageNavigation(controller),
            15.h.verticalSpace,
          ],

          // Plot grid
          _buildGridForCurrentPage(controller),

          // Page info
          if (controller.units.length > 100) ...[
            10.h.verticalSpace,
            _buildPageInfo(controller),
          ],
        ],
      );
    });
  }
  Widget _buildPageNavigation(GiooPlotController controller) {
    final totalPages = (controller.units.length / 100).ceil();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _currentPage > 0 ? () {
            setState(() {
              _currentPage--;
            });
          } : null,
          icon: Icon(Icons.chevron_left),
          color: _currentPage > 0 ? AppColor.orange : Colors.grey,
        ),
        20.w.horizontalSpace,
        Text(
          'Plots ${_currentPage * 100 + 1}-${min((_currentPage + 1) * 100, controller.units.length)}',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        20.w.horizontalSpace,
        IconButton(
          onPressed: _currentPage < totalPages - 1 ? () {
            setState(() {
              _currentPage++;
            });
          } : null,
          icon: Icon(Icons.chevron_right),
          color: _currentPage < totalPages - 1 ? AppColor.orange : Colors.grey,
        ),
      ],
    );
  }

  Widget _buildGridForCurrentPage(GiooPlotController controller) {
    final start = _currentPage * 100;
    final end = min(start + 100, controller.units.length);
    final pageUnits = controller.units.sublist(start, end);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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

        return _buildPlotUnitItem(controller, actualUnit);
      },
    );
  }

  Widget _buildPlotUnitItem(GiooPlotController controller, PlotUnit unit) {
    final isTempSelected = _tempSelectedUnits.contains(unit.id);
    final isPermanentlySelected = controller.selectedUnits.contains(unit.id);

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
      color = AppColor.orange.withOpacity(0.7);
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
              duration: Duration(seconds: 1),
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
          border: isPermanentlySelected || isTempSelected
              ? Border.all(color: AppColor.orangeAccent, width: 2.w)
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
                  if (icon != null)
                    Icon(icon, size: 12.w, color: Colors.white),
                ],
              ),
            ),
            if (isTempSelected)
              Positioned(
                top: 2.w,
                right: 2.w,
                child: Icon(Icons.check, size: 10.w, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageInfo(GiooPlotController controller) {
    final totalPages = (controller.units.length / 100).ceil();

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
                    color: i == _currentPage ? AppColor.orange : Colors.grey.withOpacity(0.3),
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
                  color: 0 == _currentPage ? AppColor.orange : Colors.grey.withOpacity(0.3),
                ),
              ),

              // Show dots based on current page position
              if (_currentPage > 3) ...[
                SizedBox(width: 2.w),
                Text('...', style: TextStyle(fontSize: 10.sp)),
                SizedBox(width: 2.w),
              ],

              // Show 5 pages around current page
              for (int i = max(1, _currentPage - 2); i <= min(totalPages - 2, _currentPage + 2); i++)
                Container(
                  width: 6.w,
                  height: 6.w,
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i == _currentPage ? AppColor.orange : Colors.grey.withOpacity(0.3),
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
                  color: (totalPages - 1) == _currentPage ? AppColor.orange : Colors.grey.withOpacity(0.3),
                ),
              ),
            ],
          ),

        // Page number text
        5.h.verticalSpace,
        Text(
          'Page ${_currentPage + 1} of $totalPages',
          style: TextStyle(fontSize: 12.sp, color: AppColor.textMain.withOpacity(0.7)),
        ),
      ],
    );
  }  // Widget _buildPageIndicator() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       for (int i = 0; i < totalPages; i++)
  //         Container(
  //           width: 8.w,
  //           height: 8.w,
  //           margin: EdgeInsets.symmetric(horizontal: 4.w),
  //           decoration: BoxDecoration(
  //             shape: BoxShape.circle,
  //             color: i == _currentPage ? AppColor.orange : Colors.grey.withOpacity(0.3),
  //           ),
  //         ),
  //     ],
  //   );
  // }
  //
  // Widget _buildPageNavigation() {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     children: [
  //       IconButton(
  //         onPressed: _currentPage > 0
  //             ? () {
  //           _pageController.previousPage(
  //             duration: Duration(milliseconds: 300),
  //             curve: Curves.easeInOut,
  //           );
  //         }
  //             : null,
  //         icon: Icon(Icons.chevron_left),
  //         color: _currentPage > 0 ? AppColor.orange : Colors.grey,
  //       ),
  //       20.w.horizontalSpace,
  //       Text(
  //         'Page ${_currentPage + 1} of $totalPages',
  //         style: TextStyle(fontSize: 12.sp),
  //       ),
  //       20.w.horizontalSpace,
  //       IconButton(
  //         onPressed: _currentPage < totalPages - 1
  //             ? () {
  //           _pageController.nextPage(
  //             duration: Duration(milliseconds: 300),
  //             curve: Curves.easeInOut,
  //           );
  //         }
  //             : null,
  //         icon: Icon(Icons.chevron_right),
  //         color: _currentPage < totalPages - 1 ? AppColor.orange : Colors.grey,
  //       ),
  //     ],
  //   );
  // }
  //
  // List<PlotUnit> _getUnitsForPage(int pageIndex) {
  //   final start = pageIndex * _itemsPerPage;
  //   final end = start + _itemsPerPage;
  //
  //   if (controller.units.isEmpty) return [];
  //
  //   if (start >= controller.units.length) return [];
  //
  //   return controller.units.sublist(
  //       start,
  //       end > controller.units.length ? controller.units.length : end
  //   );
  // }
  //
  // Widget _buildGridForUnits(List<PlotUnit> units) {
  //   return GridView.builder(
  //     physics: const NeverScrollableScrollPhysics(),
  //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: 10,
  //       crossAxisSpacing: 6.w,
  //       mainAxisSpacing: 6.h,
  //       childAspectRatio: 1.0,
  //     ),
  //     itemCount: units.length,
  //     itemBuilder: (context, index) {
  //       final unit = units[index];
  //       final globalIndex = _currentPage * _itemsPerPage + index;
  //       final actualUnit = controller.units[globalIndex];
  //
  //       return _buildPlotUnitItem(actualUnit);
  //     },
  //   );
  // }
  //
  // Widget _buildPlotUnitItem(PlotUnit unit) {
  //   final isTempSelected = _tempSelectedUnits.contains(unit.id);
  //   final isPermanentlySelected = controller.selectedUnits.contains(unit.id);
  //
  //   Color color;
  //   String statusText = '';
  //
  //   if (isPermanentlySelected) {
  //     color = AppColor.orange;
  //     statusText = 'Selected';
  //   } else if (unit.status == 'Booked') {
  //     color = AppColor.primary;
  //     statusText = 'Booked';
  //   } else if (isTempSelected && _isSelectionMode) {
  //     color = AppColor.orange.withOpacity(0.7);
  //     statusText = 'Selecting';
  //   } else {
  //     color = Colors.grey.withOpacity(0.5);
  //     statusText = 'Available';
  //   }
  //
  //   return GestureDetector(
  //     behavior: HitTestBehavior.translucent,
  //     onTap: () {
  //       if (unit.status == 'Booked') {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('This plot is already booked'),
  //             duration: Duration(seconds: 1),
  //           ),
  //         );
  //         return;
  //       }
  //
  //       if (_isSelectionMode) {
  //         _handleTapSelection(unit.id);
  //       } else {
  //         controller.toggleUnitSelection(unit.id);
  //       }
  //     },
  //     onPanDown: (details) {
  //       if (_isSelectionMode && unit.status != 'Booked') {
  //         setState(() {
  //           _isDragging = true;
  //           _dragStartUnit = unit.id;
  //           _handleDragSelection(unit.id);
  //         });
  //       }
  //     },
  //     onPanEnd: (details) {
  //       if (_isDragging) {
  //         setState(() {
  //           _isDragging = false;
  //           _dragStartUnit = null;
  //         });
  //       }
  //     },
  //     onPanCancel: () {
  //       if (_isDragging) {
  //         setState(() {
  //           _isDragging = false;
  //           _dragStartUnit = null;
  //         });
  //       }
  //     },
  //     child: MouseRegion(
  //       onEnter: (_) {
  //         if (_isDragging && _dragStartUnit != null && unit.status != 'Booked') {
  //           _handleDragSelection(unit.id);
  //         }
  //       },
  //       child: Stack(
  //         children: [
  //           AnimatedContainer(
  //             duration: const Duration(milliseconds: 200),
  //             decoration: BoxDecoration(
  //               color: color,
  //               borderRadius: BorderRadius.circular(8.r),
  //               border: isPermanentlySelected || isTempSelected
  //                   ? Border.all(color: AppColor.orangeAccent, width: 2.w)
  //                   : null,
  //               boxShadow: isTempSelected ? [
  //                 BoxShadow(
  //                   color: AppColor.orange.withOpacity(0.3),
  //                   blurRadius: 6,
  //                   spreadRadius: 1,
  //                 )
  //               ] : null,
  //             ),
  //             child: Center(
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Text(
  //                     unit.label,
  //                     style: TextStyle(
  //                       fontSize: 10.sp,
  //                       color: unit.status == 'Available' && !isTempSelected
  //                           ? AppColor.textMain
  //                           : Colors.white,
  //                       fontWeight: FontWeight.w600,
  //                     ),
  //                   ),
  //
  //                 ],
  //               ),
  //             ),
  //           ),
  //
  //           if (isTempSelected)
  //             Positioned(
  //               top: 2.w,
  //               right: 2.w,
  //               child: Container(
  //                 padding: EdgeInsets.all(2.w),
  //                 decoration: BoxDecoration(
  //                   color: AppColor.orange,
  //                   shape: BoxShape.circle,
  //                 ),
  //                 child: Icon(
  //                   Icons.check,
  //                   size: 8.w,
  //                   color: Colors.white,
  //                 ),
  //               ),
  //             ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Enhanced drag selection

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
          content: Text('Not enough available plots. Only ${availableUnits.length} available.'),
          duration: Duration(seconds: 2),
        ),
      );
      // Select all available
      _tempSelectedUnits = availableUnits;
    }
  }
// Update the drag handling logic
  void _handleDragSelection(int unitId) {
    // Don't allow selection if unit is booked/admin-block
    final unit = controller.units.firstWhere((u) => u.id == unitId,
        orElse: () => PlotUnit(id: -1, label: '', status: 'Booked', area: 0));

    if (unit.status == 'Booked') {
      return; // Skip booked units
    }

    if (_tempSelectedUnits.length >= selectedPlotCount &&
        !_tempSelectedUnits.contains(unitId)) {
      return; // Max limit reached
    }

    if (!_tempSelectedUnits.contains(unitId)) {
      setState(() {
        _tempSelectedUnits.add(unitId);
        _tempSelectedUnits.sort();
      });
    }
  }

// Update the tap selection to handle edge cases
  void _handleTapSelection(int unitId) {
    final unit = controller.units.firstWhere((u) => u.id == unitId,
        orElse: () => PlotUnit(id: -1, label: '', status: 'Booked', area: 0));

    if (unit.status == 'Booked') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This plot is already booked'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    if (_tempSelectedUnits.contains(unitId)) {
      setState(() {
        _tempSelectedUnits.remove(unitId);
      });
    } else if (_tempSelectedUnits.length < selectedPlotCount) {
      setState(() {
        _tempSelectedUnits.add(unitId);
        _tempSelectedUnits.sort();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You can only select $selectedPlotCount plots'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  // SIDEBAR ---------------------------------------------------------------
  Widget _buildSidebarCard(GiooPlotController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(25.w),
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
            _buildPayNowButton(controller),
          ],
        );
      }),
    );
  }

  Widget _buildLocationDetail(GiooPlotController controller, GiooPlotDetail detail) {
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
          style: TextStyle(fontSize: 12.sp, color: AppColor.black,),
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

  Widget _buildStatusAndUnitInfo(GiooPlotController controller, GiooPlotDetail detail) {
    final dateFormatter = DateFormat('dd MMM yyyy');
    final timeFormatter = DateFormat('hh:mm a');

    final createdDate = dateFormatter.format(detail.createdAt);
    final createdTime = timeFormatter.format(detail.createdAt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                detail.name,
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColor.black),
              ),
            ),
            Row(
              children: [
                Icon(Icons.check_circle, size: 16.w, color: AppColor.black),
                5.w.horizontalSpace,
                Text(
                  "Approved Plot",
                  style: TextStyle(fontSize: 12.sp, color: AppColor.black),
                ),
              ],
            ),
          ],
        ),
        15.h.verticalSpace,
        Row(
          children: [
            Expanded(child: _infoItem(Icons.calendar_today_outlined, createdDate, AppColor.black)),
            20.w.horizontalSpace,
            Expanded(child: _infoItem(Icons.access_time, createdTime, AppColor.black)),
          ],
        ),
        10.h.verticalSpace,
        _infoItem(
            Icons.location_city_outlined,
            _isSelectionMode
                ? (_tempSelectedUnits.isNotEmpty
                ? "Selecting: ${_tempSelectedUnits.join(', ')}"
                : "Select plots")
                : controller.getSelectedUnitRange(),
            AppColor.black
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

    // Count of selected units
    final selectedCount = _isSelectionMode
        ? _tempSelectedUnits.length
        : controller.selectedUnits.length;

    // Price per UNIT — coming from controller
    final pricePerUnit = controller.pricePerUnit.value;

    // NEW LOGIC ⭐ price = count × price per unit
    final totalPrice = selectedCount * pricePerUnit;

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

        _priceRow("Number of Plots:", "$selectedCount"),
        Divider(height: 20, color: Colors.black.withOpacity(0.1)),

        _priceRow("Total Payable:", "₹${totalPrice.toStringAsFixed(2)}", isBold: true),
      ],
    );
  }

  Widget _priceRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13.sp, color: AppColor.primary,fontWeight: FontWeight.bold)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: isBold ? FontWeight.bold : FontWeight.bold,
            color: AppColor.black,
          ),
        ),
      ],
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
          onTap: enabled ? () {
            if (_isSelectionMode) {
              // Save temporary selection
              _confirmSelection();
            } else {
              controller.proceedToPayment();
            }
          } : null,
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
                SizedBox(width: 30.w,)
              ],
            ),
          ),
        ),
      ],
    );
  }
}