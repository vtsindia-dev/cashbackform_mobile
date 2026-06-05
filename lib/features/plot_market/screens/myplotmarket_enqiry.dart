import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../common/colours.dart';
import '../../../common/widget/appbar.dart';
import '../controller/plot_market_controller.dart';
import '../model/plot_market.dart';

class MarketPlotEnquiryScreen extends StatefulWidget {
  const MarketPlotEnquiryScreen({Key? key}) : super(key: key);

  @override
  State<MarketPlotEnquiryScreen> createState() => _MarketPlotEnquiryScreenState();
}

class _MarketPlotEnquiryScreenState extends State<MarketPlotEnquiryScreen> {
  final controller = Get.put(PlotMarketController());

  // Search related variables
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<MarketPlotEnquiry> _filteredEnquiries = [];
  List<String> _searchSuggestions = [];
  bool _isSearching = false;
  String _currentSearchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMarketPlotEnquiries();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    _currentSearchQuery = query;

    if (query.isEmpty) {
      setState(() {
        _filteredEnquiries = [];
        _searchSuggestions = [];
        _isSearching = false;
      });
    } else {
      setState(() {
        _isSearching = true;
        _filterSuggestions(query);
      });
    }
  }

  void _filterSuggestions(String query) {
    final allEnquiries = controller.marketPlotEnquiries;

    // Filter enquiries based on search query
    final filtered = allEnquiries.where((enquiry) {
      final propertyName = enquiry.property?.name?.toLowerCase() ?? '';
      final enquiryId = enquiry.id.toString();
      final propertyAddress = enquiry.property?.address?.toLowerCase() ?? '';

      return propertyName.contains(query) ||
          enquiryId.contains(query) ||
          propertyAddress.contains(query);
    }).toList();

    setState(() {
      _filteredEnquiries = filtered;

      // Generate suggestions from property names
      final suggestions = <String>[];
      for (var enquiry in allEnquiries) {
        if (enquiry.property?.name != null &&
            enquiry.property!.name.toLowerCase().contains(query) &&
            !suggestions.contains(enquiry.property!.name)) {
          suggestions.add(enquiry.property!.name);
        }
        if (suggestions.length >= 5) break;
      }
      _searchSuggestions = suggestions;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredEnquiries = [];
      _searchSuggestions = [];
      _isSearching = false;
      _currentSearchQuery = '';
    });
    FocusScope.of(context).unfocus();
  }

  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    _onSearchChanged();
    FocusScope.of(context).unfocus();
  }

  List<MarketPlotEnquiry> get _displayedEnquiries {
    if (_isSearching && _currentSearchQuery.isNotEmpty) {
      return _filteredEnquiries;
    }
    return controller.marketPlotEnquiries;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: DynamicAppBar(
          title: "My Land Enquiries",
          showBackButton: true,
          actions: [
            IconButton(
              onPressed: controller.refreshMarketEnquiries,
              icon: Icon(Iconsax.refresh, size: 20.sp),
              tooltip: "Refresh",
            ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingMarketEnquiries.value &&
            controller.marketPlotEnquiries.isEmpty) {
          return _buildLoadingState();
        }

        if (controller.marketPlotEnquiries.isEmpty) {
          return _buildEmptyEnquiryState();
        }

        return Column(
          children: [
            // Search Bar
            _buildSearchBar(),

            // Search Suggestions
            if (_isSearching && _searchSuggestions.isNotEmpty && _currentSearchQuery.isNotEmpty)
              _buildSearchSuggestions(),

            // Results count
            if (_isSearching && _currentSearchQuery.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Found ${_filteredEnquiries.length} result${_filteredEnquiries.length != 1 ? 's' : ''}",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColor.textSecondary,
                      ),
                    ),
                    if (_filteredEnquiries.isNotEmpty)
                      TextButton(
                        onPressed: _clearSearch,
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                        ),
                        child: Text(
                          "Clear Search",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColor.primary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            Expanded(
              child: RefreshIndicator(
                color: AppColor.primary,
                backgroundColor: AppColor.white,
                onRefresh: () async {
                  _clearSearch();
                  await controller.refreshMarketEnquiries();
                },
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 15.h),
                  itemCount: _displayedEnquiries.length + 1,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    // Load more indicator
                    if (index == _displayedEnquiries.length) {
                      if (controller.hasMoreMarketEnquiries.value && !_isSearching) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: Center(
                            child: controller.isLoadingMarketEnquiries.value
                                ? CircularProgressIndicator(color: AppColor.primary)
                                : ElevatedButton(
                              onPressed: controller.loadMoreMarketEnquiries,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primary,
                                foregroundColor: AppColor.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                              child: Text("Load More Enquiries"),
                            ),
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    }

                    final enquiry = _displayedEnquiries[index];
                    return _buildEnquiryCard(enquiry);
                  },
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: "Search by property name, ID or address...",
          hintStyle: TextStyle(fontSize: 13.sp, color: AppColor.textSecondary),
          prefixIcon: Icon(Iconsax.search_normal, size: 18.sp, color: AppColor.primary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: Icon(Iconsax.close_circle, size: 18.sp, color: AppColor.grey),
            onPressed: _clearSearch,
          )
              : null,
          filled: true,
          fillColor: AppColor.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide(color: AppColor.primary, width: 1.5.w),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              children: [
                Icon(Iconsax.search_normal, size: 14.sp, color: AppColor.primary),
                SizedBox(width: 8.w),
                Text(
                  "Suggestions",
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ..._searchSuggestions.map((suggestion) => ListTile(
            leading: Icon(Iconsax.house, size: 16.sp, color: AppColor.primary),
            title: Text(
              suggestion,
              style: TextStyle(fontSize: 13.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Icon(Iconsax.arrow_right, size: 16.sp, color: AppColor.grey),
            onTap: () => _selectSuggestion(suggestion),
            dense: true,
          )),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColor.primary,
            strokeWidth: 2.0,
          ),
          SizedBox(height: 16.h),
          Text(
            "Loading your enquiries...",
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColor.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnquirySummary() {
    final withProperty = controller.getEnquiriesWithProperty().length;
    final withoutProperty = controller.getEnquiriesWithoutProperty().length;
    final total = controller.totalMarketEnquiries.value;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColor.primary.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem(
            icon: Iconsax.receipt_item,
            label: "Total",
            value: "$total",
            color: AppColor.primary,
          ),
          _buildStatItem(
            icon: Iconsax.home,
            label: "With Plot",
            value: "$withProperty",
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Iconsax.info_circle,
            label: "Without Plot",
            value: "$withoutProperty",
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18.sp, color: color),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: AppColor.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEnquiryCard(MarketPlotEnquiry enquiry) {
    final hasProperty = enquiry.property != null;

    return Container(
      margin: EdgeInsets.only(bottom: 18.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header: Enquiry Info with Remove Icon
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: enquiry.statusColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        hasProperty ? Iconsax.receipt_item : Iconsax.info_circle,
                        size: 14.sp,
                        color: enquiry.statusColor,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Enquiry #${enquiry.id}",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColor.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          enquiry.formattedDate,
                          style: TextStyle(fontSize: 10.sp, color: AppColor.grey),
                        ),
                        Text(
                          enquiry.formattedTime,
                          style: TextStyle(fontSize: 9.sp, color: AppColor.grey),
                        ),
                      ],
                    ),

                    // SizedBox(width: 12.w),
                    // // Remove Icon Button
                    // GestureDetector(
                    //   onTap: () => _confirmDeleteEnquiry(enquiry),
                    //   child: Container(
                    //     padding: EdgeInsets.all(6.w),
                    //     decoration: BoxDecoration(
                    //       color: Colors.red.withOpacity(0.1),
                    //       shape: BoxShape.circle,
                    //     ),
                    //     child: Icon(
                    //       Iconsax.trash,
                    //       size: 14.sp,
                    //       color: Colors.red,
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ],
            ),
          ),

          // Property Details or Message
          if (hasProperty)
            _buildPropertyDetails(enquiry.property!)
          else
            _buildNoPropertyMessage(),

          // Footer: Actions
          Container(
            decoration: BoxDecoration(
              color: AppColor.primarylite.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Row(
              children: [
                Spacer(),
                // Action Buttons
                if (hasProperty)
                  InkWell(
                    onTap: () {
                      _viewPlotDetails(enquiry.property!);
                    },
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColor.primary,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Iconsax.eye, size: 12.sp, color: AppColor.white),
                          SizedBox(width: 6.w),
                          Text(
                            "View Plot",
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColor.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Text(
                    "Plot details not available",
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColor.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteEnquiry(MarketPlotEnquiry enquiry) {
    Get.defaultDialog(
      title: "Delete Enquiry",
      titleStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Are you sure you want to delete this enquiry?",
            style: TextStyle(fontSize: 13.sp),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColor.lightGrey,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Enquiry #${enquiry.id}",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
                if (enquiry.property?.name != null)
                  Text(
                    enquiry.property!.name,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColor.textSecondary,
                    ),
                  ),
                SizedBox(height: 4.h),
                Text(
                  enquiry.formattedDate,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColor.grey,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
        ],
      ),
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: AppColor.textSecondary,
    );
  }

  Widget _buildPropertyDetails(MarketPlotEnquiryProperty property) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Property Image
        Padding(
          padding: EdgeInsets.only(left: 12.w, bottom: 12.h),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.r),
            child: Image.network(
              property.thumbnail,
              width: 100.w,
              height: 100.h,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 100.w,
                  height: 100.h,
                  color: AppColor.lightGrey,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (c, e, s) => Container(
                width: 100.w,
                height: 100.h,
                color: AppColor.lightGrey,
                child: Icon(Iconsax.image, color: AppColor.grey),
              ),
            ),
          ),
        ),

        // Property Info
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColor.textMain,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),

                // Location
                Row(
                  children: [
                    Icon(Iconsax.location, size: 12.sp, color: AppColor.grey),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        property.address,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColor.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),

                // Price and Area
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Iconsax.dollar_circle, size: 12.sp, color: AppColor.primary),
                          SizedBox(width: 4.w),
                          Text(
                            property.formattedPrice,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColor.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColor.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Iconsax.ruler, size: 12.sp, color: AppColor.accent),
                          SizedBox(width: 4.w),
                          Text(
                            property.formattedArea,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColor.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoPropertyMessage() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        children: [
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: AppColor.lightGrey,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.info_circle,
              size: 30.sp,
              color: AppColor.grey,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "Plot Details Unavailable",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "The property associated with this enquiry may have been removed or is no longer available.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColor.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _viewPlotDetails(MarketPlotEnquiryProperty property) {
    Get.toNamed(
      '/plotMarketDetails',
      arguments: {
        'id': property.id,
        'title': property.name,
      },
    );
  }

  Widget _buildEmptyEnquiryState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              color: AppColor.lightGrey,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.receipt_search,
              size: 50.sp,
              color: AppColor.grey.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            "No Market Plot Enquiries",
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.textMain,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              "Your market plot enquiries will appear here once you make them",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColor.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: controller.refreshMarketEnquiries,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: AppColor.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.refresh, size: 16.sp),
                SizedBox(width: 8.w),
                Text("Refresh", style: TextStyle(fontSize: 13.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}