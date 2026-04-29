import 'dart:async';
import 'dart:ui';
import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/api_constant.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';
import '../../payment/controller/razorpay_controller.dart';
import '../model/syndicate_model.dart';
import '../widget/dotline.dart';
import 'package:dio/dio.dart';

class SyndicatePlotController extends GetxController {
  var isLoading = false.obs;
  var isLoadMore = false.obs;
  var isLoadingDetail = false.obs;
  var syndicatePlots = <SyndicatePlot>[].obs;
  var syndicateDetail = Rxn<SyndicateDetail>();
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var hasMoreData = true.obs;
  var totalItems = 0.obs;
  var selectedCityId = 0.obs;
  var selectedStateId = 0.obs;
  var selectedCityName = ''.obs;
  var selectedStateName = ''.obs;
  var isLoadingBuyingList = false.obs;
  var isLoadingBuyingDetail = false.obs;
  var isLoadingCancelRequest = false.obs;
  var buyingList = <SyndicateBuyingList>[].obs;
  var buyingDetailList = <SyndicateBuyingDetail>[].obs;
  var buyingListPage = 1.obs;
  var buyingDetailPage = 1.obs;
  var totalBuyingPages = 1.obs;
  var totalBuyingDetailPages = 1.obs;
  var hasMoreBuyingData = true.obs;
  var hasMoreBuyingDetailData = true.obs;
  var selectedTransactionId = Rxn<int>();
  final TextEditingController searchController = TextEditingController();
  final RxString recentSearch = ''.obs;
  RxBool isTermsAccepted = false.obs;

  var searchQuery = ''.obs;
  var selectedCity = ''.obs;
  var selectedState = ''.obs;
  var minPrice = ''.obs;
  var maxPrice = ''.obs;
  var minAreaSqft = ''.obs;
  var maxAreaSqft = ''.obs;

  // Property type filter
  var selectedPropertyTypeId = 0.obs;
  var selectedPropertyTypeName = ''.obs;
  var propertyTypes = <PropertyType>[].obs;

  // For dynamic filtering UI
  var priceMin = 0.0.obs;
  var priceMax = 10000000.0.obs;
  var sqftMin = 0.0.obs;
  var sqftMax = 10000.0.obs;

  Timer? _debounce;

  var errorMessage = ''.obs;
  var isExpanded = false.obs;
  var isExpandedrefral = false.obs;
  RxList<Map<String, dynamic>> plots = <Map<String, dynamic>>[].obs;
  RxList<int> selectedPlots = <int>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchSyndicatePlots();
    loadPropertyTypes();
  }

  void refralExpansion() => isExpandedrefral.value = !isExpandedrefral.value;
  void toggleExpansion() => isExpanded.value = !isExpanded.value;

  Set<int> _parseUnitIds(String unitsString) {
    final Set<int> unitIds = <int>{};
    try {
      final parts = unitsString.split(',');
      for (final part in parts) {
        final id = int.tryParse(part.trim());
        if (id != null) {
          unitIds.add(id);
        }
      }
    } catch (e) {
      print('Error parsing unit IDs: $e');
    }
    return unitIds;
  }

  List<double>   _parseUnitAreas(String unitString) {
    try {
      if (unitString.isEmpty) return [];
      return unitString.split(',').map((e) => double.tryParse(e.trim()) ?? 0.0).toList();
    } catch (e) {
      print('Error parsing unit areas: $e');
      return [];
    }
  }

  int countStatus(String type) {
    return plots.where((e) => e["status"] == type).length;
  }

  void toggleSelect(int id, String type) {
    if (type == "booked") return;

    if (selectedPlots.contains(id)) {
      selectedPlots.remove(id);
      final index = plots.indexWhere((plot) => plot["id"] == id);
      if (index != -1) {
        plots[index]["status"] = "available";
      }
    } else {
      selectedPlots.add(id);
      final index = plots.indexWhere((plot) => plot["id"] == id);
      if (index != -1) {
        plots[index]["status"] = "selected";
      }
    }

    update();
  }

  Color getColor(String type, bool isSelected) {
    if (isSelected) return Colors.orange;

    switch (type) {
      case "selected":
        return Colors.orange;
      case "booked":
        return const Color(0xFF3B711A);
      default:
        return const Color(0xFFB8D79A);
    }
  }

  Future<void> viewDocument(int id) async {
    try {
      final apiDoc = syndicateDetail.value?.documents.firstWhere((d) => d.id == id);
      if (apiDoc != null) {
        print("Viewing API document: ${apiDoc.doucType} - ${apiDoc.file}");
        await _launchUrl(apiDoc.file);
        return;
      }
    } catch (e) {
      print("Document not found: $id");
      SnackBarHelper.showError("Document not found");
    }
  }

  Future<void> downloadDocument(int id) async {
    try {
      final apiDoc = syndicateDetail.value?.documents.firstWhere((d) => d.id == id);
      if (apiDoc != null) {
        print("Downloading API document: ${apiDoc.doucType} - ${apiDoc.file}");
        await _launchUrl(apiDoc.file);
        return;
      }
    } catch (e) {
      print("Document not found: $id");
      SnackBarHelper.showError("Document not found");
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      String formattedUrl = url;

      if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
        formattedUrl = 'http://$formattedUrl';
      }

      final Uri uri = Uri.parse(formattedUrl);

      print('Launching URL: $uri');

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        print('Cannot launch URL: $uri');
        SnackBarHelper.showError("Cannot open the document. Please check your connection.");
      }
    } catch (e) {
      print('Error launching URL: $e');
      SnackBarHelper.showError("Failed to open document");
    }
  }

  Future<void> loadPropertyTypes() async {
    try {
      final url = '${ApiUrl.syndicatePlotList}?page_no=1&limit=100';
      final response = await ApiService.getRequest(url);

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData != null &&
            responseData['data'] != null &&
            responseData['data']['syndicate'] is List) {

          final List syndicateData = responseData['data']['syndicate'];
          final Map<int, PropertyType> uniquePropertyTypes = {};

          for (var plotData in syndicateData) {
            final pt = plotData['property_type'];

            if (pt != null && pt is Map && pt['id'] != null) {
              final int id = pt['id'];
              uniquePropertyTypes[id] = PropertyType(
                id: id,
                categoryName: pt['category_name'] ?? '',
                status: pt['status'] ?? 0,
              );
            }
          }

          propertyTypes.value = uniquePropertyTypes.values.toList();
          print('✅ Loaded ${propertyTypes.length} unique property types');
        }
      }
    } catch (e) {
      print('❌ Error loading property types: $e');
    }
  }

  Future<void> fetchSyndicatePlots({bool loadMore = false}) async {
    try {
      if (loadMore) {
        isLoadMore(true);
      } else {
        isLoading(true);
        currentPage.value = 1;
        hasMoreData.value = true;
      }

      final url = '${ApiUrl.syndicatePlotList}?page_no=${currentPage.value}${_buildQueryParams()}';
      print('Fetching URL: $url');
      final response = await ApiService.getRequest(url);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null &&
            responseData['data'] != null &&
            responseData['data']['syndicate'] != null) {

          final syndicateData = responseData['data']['syndicate'];
          final paginationData = responseData['data']['pagination'];

          _extractPriceRanges(responseData);
          _extractAreaRanges(responseData);

          if (loadMore) {
            syndicatePlots.addAll(_parseSyndicatePlots(syndicateData));
          } else {
            syndicatePlots.assignAll(_parseSyndicatePlots(syndicateData));
          }

          currentPage.value = paginationData['current_page'] ?? 1;
          totalPages.value = paginationData['last_page'] ?? 1;
          totalItems.value = paginationData['total'] ?? 0;
          hasMoreData.value = currentPage.value < totalPages.value;

          print('✅ Fetched ${syndicatePlots.length} syndicate plots');
        } else {
          SnackBarHelper.showError("Invalid response format from server");
          print('❌ Invalid response format: $responseData');
        }
      } else if (response.statusCode == 404) {
        SnackBarHelper.showError("Syndicate plots not found");
        print('❌ 404 Error: ${response.data}');
      } else {
        final errorMessage = response.data?['message'] ?? 'Failed to fetch syndicate plots';
        SnackBarHelper.showError("Error $errorMessage");
        print('❌ API Error ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      SnackBarHelper.showError("Network error: $e");
      print('❌ Network error: $e');
    } finally {
      isLoading(false);
      isLoadMore(false);
    }
  }

  void _extractPriceRanges(dynamic responseData) {
    try {
      if (responseData != null && responseData['data'] != null) {
        final priceMin = responseData['data']['price_min'];
        final priceMax = responseData['data']['price_max'];

        if (priceMin != null && priceMax != null) {
          double min = priceMin is int ? priceMin.toDouble() : double.tryParse(priceMin.toString()) ?? 0.0;
          double max = priceMax is int ? priceMax.toDouble() : double.tryParse(priceMax.toString()) ?? 10000000.0;

          if (min > max) {
            final temp = min;
            min = max;
            max = temp;
          }

          if (min == max) {
            max = min + 1000;
          }

          this.priceMin.value = min;
          this.priceMax.value = max;

          return;
        }
      }
      _extractPriceRangesFromPlots();
    } catch (e) {
      print('❌ Error extracting price ranges from API: $e');
      _extractPriceRangesFromPlots();
    }
  }

  void _extractPriceRangesFromPlots() {
    try {
      double minPriceValue = double.infinity;
      double maxPriceValue = 0;

      for (var plot in syndicatePlots) {
        try {
          String priceStr = plot.price?.replaceAll(',', '') ?? '';
          if (priceStr.isNotEmpty) {
            double price = double.tryParse(priceStr) ?? 0;
            if (price > 0) {
              if (price < minPriceValue) minPriceValue = price;
              if (price > maxPriceValue) maxPriceValue = price;
            }
          }
        } catch (e) {
          print('Error parsing price for plot: $e');
        }
      }

      if (minPriceValue == double.infinity) minPriceValue = 0;
      if (maxPriceValue <= minPriceValue) maxPriceValue = minPriceValue + 1000000;

      priceMin.value = minPriceValue;
      priceMax.value = maxPriceValue;
    } catch (e) {
      print('❌ Error in fallback price extraction: $e');
      priceMin.value = 0.0;
      priceMax.value = 10000000.0;
    }
  }

  void _extractAreaRanges(dynamic responseData) {
    try {
      if (responseData != null && responseData['data'] != null) {
        final sqftMin = responseData['data']['sqft_min'];
        final sqftMax = responseData['data']['sqft_max'];

        if (sqftMin != null && sqftMax != null) {
          double min = sqftMin is int ? sqftMin.toDouble() : double.tryParse(sqftMin.toString()) ?? 0.0;
          double max = sqftMax is int ? sqftMax.toDouble() : double.tryParse(sqftMax.toString()) ?? 10000.0;

          if (min > max) {
            final temp = min;
            min = max;
            max = temp;
          }

          if (min == max) {
            max = min + 1000;
          }

          this.sqftMin.value = min;
          this.sqftMax.value = max;
          return;
        }
      }
      _extractAreaRangesFromPlots();
    } catch (e) {
      print('❌ Error extracting area ranges from API: $e');
      _extractAreaRangesFromPlots();
    }
  }

  void _extractAreaRangesFromPlots() {
    try {
      double minAreaValue = double.infinity;
      double maxAreaValue = 0;

      for (var plot in syndicatePlots) {
        try {
          String areaStr = plot.area?.toString() ?? '';
          if (areaStr.isNotEmpty) {
            areaStr = areaStr.replaceAll(RegExp(r'[^0-9.]'), '');
            double area = double.tryParse(areaStr) ?? 0;

            if (area > 0) {
              if (area < minAreaValue) minAreaValue = area;
              if (area > maxAreaValue) maxAreaValue = area;
            }
          }
        } catch (e) {
          print('Error parsing area for plot: $e');
        }
      }

      if (minAreaValue == double.infinity) minAreaValue = 0;
      if (maxAreaValue <= minAreaValue) maxAreaValue = minAreaValue + 1000;

      sqftMin.value = minAreaValue;
      sqftMax.value = maxAreaValue;
    } catch (e) {
      print('❌ Error in fallback area extraction: $e');
      sqftMin.value = 0.0;
      sqftMax.value = 10000.0;
    }
  }

  Future<void> fetchSyndicateDetail(int id) async {
    try {
      _clearDetailData();

      isLoadingDetail(true);
      errorMessage('');
      final token = await SessionManager.getToken();

      final url = '${ApiUrl.syndicateDetails}/$id';
      print('🌐 Fetching Syndicate Detail URL: $url');
      final Map<String, String> headers = {};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        print('🔐 Using token: ${token.substring(0, 20)}...');
      } else {
        print('⚠️ No token found, making unauthenticated request');
      }
      final response = await ApiService.getRequest(url, headers: headers);
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          syndicateDetail.value = SyndicateDetail.fromJson(responseData['data']);
          print('✅ Fetched syndicate detail: ${syndicateDetail.value?.name}');
          generatePlotsFromApiData();
          _logBookingInfo();
        } else {
          errorMessage('Invalid response format from server');
          SnackBarHelper.showError("Invalid response format");
          print('❌ Invalid response format: $responseData');
        }
      } else if (response.statusCode == 401) {
        errorMessage('Session expired. Please login again.');
        SnackBarHelper.showError("Session expired. Please login again.");
        print('❌ 401 Unauthorized: Token invalid or expired');
        await SessionManager.clearSession();
        Get.offAllNamed('/login');
      } else if (response.statusCode == 403) {
        errorMessage('Authentication required');
        SnackBarHelper.showError("Please login to view details");
        print('❌ 403 Forbidden: Authentication required');
      } else if (response.statusCode == 404) {
        errorMessage('Syndicate details not found');
        SnackBarHelper.showError("Syndicate details not found");
        print('❌ 404 Error: ${response.data}');
      } else {
        final errorMsg = response.data?['message'] ?? 'Failed to fetch syndicate details';
        errorMessage(errorMsg);
        SnackBarHelper.showError("Error: $errorMsg");
        print('❌ API Error ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      errorMessage('Network error: $e');
      SnackBarHelper.showError("Network error: $e");
      print('❌ Network error: $e');

      if (e.toString().contains('401') || e.toString().contains('unauthorized')) {
        await SessionManager.clearSession();
        Get.offAllNamed('/login');
      }
    } finally {
      isLoadingDetail(false);
    }
  }

  void _logBookingInfo() {
    final detail = syndicateDetail.value;
    if (detail != null) {
      print('📊 Total Plots: ${detail.unitSpilt}');
      print('📋 Bookings Count: ${detail.bookings.length}');
      print('💰 Admin Block Amount: ${detail.adminBlockAmount}');
      print('💵 Price per Plot (calculated): ${getPricePerPlot()}');
      print('🏷️ Price per Plot (admin block): ${getPricePerPlotFromAdminBlock()}');

      for (final booking in detail.bookings) {
        print('   Booking ID: ${booking.id}, Units: ${booking.units}');
        final unitIds = _parseUnitIds(booking.units);
        print('   Parsed Plot IDs: $unitIds');
      }

      print('🎯 Generated ${plots.length} plots');
      print('   Available: ${countStatus("available")}');
      print('   Booked: ${countStatus("booked")}');
      print('   Selected: ${selectedPlots.length}');
    }
  }

  void _clearDetailData() {
    syndicateDetail.value = null;
    errorMessage('');
    plots.clear();
    selectedPlots.clear();
  }

  void navigateToDetail(int id) {
    _clearDetailData();
    Get.toNamed('/syndicate-detail', arguments: id);
    fetchSyndicateDetail(id);
  }

  void reserveSelectedPlots() {
    if (selectedPlots.isEmpty) {
      SnackBarHelper.showError("Please select at least one plot");
      return;
    }

    print("Reserving plots: $selectedPlots");
    SnackBarHelper.showSuccess("Plot reservation request sent!");
    for (final plotId in selectedPlots) {
      final index = plots.indexWhere((plot) => plot["id"] == plotId);
      if (index != -1) {
        plots[index]["status"] = "booked";
      }
    }

    selectedPlots.clear();
    update();
  }

  Future<void> loadMore() async {
    if (!isLoadMore.value && hasMoreData.value) {
      currentPage.value++;
      await fetchSyndicatePlots(loadMore: true);
    }
  }

  Future<void> refreshData() async {
    await fetchSyndicatePlots();
  }

  // ✅ FIXED: fires on every character with 300ms debounce
  void onSearchChanged(String value) {
    searchQuery.value = value;
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      recentSearch.value = value.trim();
      fetchSyndicatePlots();
    });
  }

  // ✅ FIXED: works with any input, clears when empty
  void applySearch() {
    recentSearch.value = searchQuery.value.trim();
    fetchSyndicatePlots();
  }

  void clearRecentSearch() {
    recentSearch.value = '';
    searchQuery.value = '';
    searchController.clear();
    fetchSyndicatePlots();
  }

  Future<void> searchPlots(String query) async {
    searchQuery.value = query;
    await fetchSyndicatePlots();
  }

  Future<void> filterByCity(int cityId, String cityName) async {
    selectedCityId.value = cityId;
    selectedCityName.value = cityName;
    await fetchSyndicatePlots();
  }

  Future<void> filterByState(int stateId, String stateName) async {
    selectedStateId.value = stateId;
    selectedStateName.value = stateName;
    selectedCityId.value = 0;
    selectedCityName.value = '';
    await fetchSyndicatePlots();
  }

  Future<void> filterByPrice(String min, String max) async {
    minPrice.value = min;
    maxPrice.value = max;
    await fetchSyndicatePlots();
  }

  Future<void> filterByArea(String min, String max) async {
    minAreaSqft.value = min;
    maxAreaSqft.value = max;
    await fetchSyndicatePlots();
  }

  Future<void> filterByPropertyType(int typeId, String typeName) async {
    selectedPropertyTypeId.value = typeId;
    selectedPropertyTypeName.value = typeName;
    await fetchSyndicatePlots();
  }

  Future<void> clearPropertyTypeFilter() async {
    selectedPropertyTypeId.value = 0;
    selectedPropertyTypeName.value = '';
    await fetchSyndicatePlots();
  }

  bool hasFiltersApplied() {
    return searchQuery.value.isNotEmpty ||
        selectedCityId.value > 0 ||
        selectedStateId.value > 0 ||
        minPrice.value.isNotEmpty ||
        maxPrice.value.isNotEmpty ||
        minAreaSqft.value.isNotEmpty ||
        maxAreaSqft.value.isNotEmpty ||
        selectedPropertyTypeId.value > 0;
  }

  Future<void> clearFilters() async {
    searchQuery.value = '';
    selectedCityId.value = 0;
    selectedCityName.value = '';
    selectedStateId.value = 0;
    selectedStateName.value = '';
    minPrice.value = '';
    maxPrice.value = '';
    minAreaSqft.value = '';
    maxAreaSqft.value = '';
    selectedPropertyTypeId.value = 0;
    selectedPropertyTypeName.value = '';
    searchController.clear();
    await fetchSyndicatePlots();
  }

  List<Map<String, dynamic>> getAvailableCities() {
    final cityMap = <int, Map<String, dynamic>>{};

    for (var plot in syndicatePlots) {
      if (plot.city != null) {
        cityMap[plot.city!.id] = {
          'id': plot.city!.id,
          'name': plot.city!.cityName,
          'stateId': plot.city!.stateId,
        };
      }
    }

    return cityMap.values.toList();
  }

  List<Map<String, dynamic>> getAvailableStates() {
    final stateMap = <int, Map<String, dynamic>>{};

    for (var plot in syndicatePlots) {
      if (plot.state != null) {
        stateMap[plot.state!.id] = {
          'id': plot.state!.id,
          'name': plot.state!.stateName,
        };
      }
    }

    return stateMap.values.toList();
  }

  List<Map<String, dynamic>> getCitiesByStateId(int stateId) {
    final cityMap = <int, Map<String, dynamic>>{};

    for (var plot in syndicatePlots) {
      if (plot.city != null && plot.state != null && plot.state!.id == stateId) {
        cityMap[plot.city!.id] = {
          'id': plot.city!.id,
          'name': plot.city!.cityName,
          'stateId': plot.city!.stateId,
        };
      }
    }

    return cityMap.values.toList();
  }

  List<PropertyType> getAvailablePropertyTypes() {
    return propertyTypes;
  }

  String _buildQueryParams() {
    final params = <String>[];

    if (searchQuery.value.isNotEmpty) {
      params.add('search=${Uri.encodeComponent(searchQuery.value)}');
    }

    if (selectedCityId.value > 0) {
      params.add('city=${Uri.encodeComponent(selectedCityId.value.toString())}');
    }

    if (selectedStateId.value > 0) {
      params.add('state=${Uri.encodeComponent(selectedStateId.value.toString())}');
    }

    if (minPrice.value.isNotEmpty) {
      params.add('min_price=${Uri.encodeComponent(minPrice.value)}');
    }

    if (maxPrice.value.isNotEmpty) {
      params.add('max_price=${Uri.encodeComponent(maxPrice.value)}');
    }

    if (minAreaSqft.value.isNotEmpty) {
      params.add('min_sqft=${Uri.encodeComponent(minAreaSqft.value)}');
    }

    if (maxAreaSqft.value.isNotEmpty) {
      params.add('max_sqft=${Uri.encodeComponent(maxAreaSqft.value)}');
    }

    if (selectedPropertyTypeId.value > 0) {
      params.add('plot_type=${Uri.encodeComponent(selectedPropertyTypeId.value.toString())}');
    }

    return params.isEmpty ? '' : '&${params.join('&')}';
  }

  List<SyndicatePlot> _parseSyndicatePlots(List<dynamic> data) {
    return data.map((item) => SyndicatePlot.fromJson(item)).toList();
  }

  SyndicatePlot? getPlotById(int id) {
    try {
      return syndicatePlots.firstWhere((plot) => plot.id == id);
    } catch (e) {
      return null;
    }
  }

  bool isPlotFavorite(int plotId) {
    return false;
  }

  void toggleFavorite(int plotId) {
    print('Toggled favorite for plot $plotId');
  }

  /////////////////////////////////----------Payment Methods-----////////////////////////////////

  // Get plot areas from API unit field
  List<double> getPlotAreas() {
    final detail = syndicateDetail.value;
    if (detail == null) return [];
    return _parseUnitAreas(detail.unit);
  }

  // Get area for a specific plot
  double getPlotArea(int plotId) {
    final areas = getPlotAreas();
    if (plotId > 0 && plotId <= areas.length) {
      return areas[plotId - 1];
    }
    return 0.0;
  }

  // Format area as string
  String formatArea(double area) {
    return "${area.toStringAsFixed(0)} sq.ft";
  }
  double getFixedBookingAmount() {
    final detail = syndicateDetail.value;
    if (detail == null) return 0.0;

    // Use adminBlockAmount as the fixed total amount, not per plot
    final adminBlockAmount = detail.adminBlockAmount;
    print('💰 Fixed Booking Amount raw: $adminBlockAmount');

    if (adminBlockAmount != null && adminBlockAmount.isNotEmpty && adminBlockAmount != '0') {
      final cleanedAmount = adminBlockAmount.replaceAll(',', '');
      final amount = double.tryParse(cleanedAmount) ?? 0.0;
      print('💰 Fixed Booking Amount: $amount');
      return amount;
    }

    // Fallback
    return 5000.0; // Default fixed amount
  }

  double getPricePerPlotFromAdminBlock() {
    final detail = syndicateDetail.value;
    if (detail == null) return 0.0;

    final adminBlockAmount = detail.adminBlockAmount;
    print('💰 Admin Block Amount raw: $adminBlockAmount');

    if (adminBlockAmount != null && adminBlockAmount.isNotEmpty && adminBlockAmount != '0') {
      final cleanedAmount = adminBlockAmount.replaceAll(',', '');
      final price = double.tryParse(cleanedAmount) ?? 0.0;
      print('💰 This is the FIXED total amount, not per plot: $price');
      return price;
    }

    final fallbackPrice = getPricePerPlot();
    print('⚠️ Using fallback price: $fallbackPrice');
    return fallbackPrice;
  }  double getPricePerPlot() {
    final detail = syndicateDetail.value;
    if (detail == null) return 0.0;

    return double.tryParse(detail.price.replaceAll(',', '')) ?? 0.0;
  }
  double calculateSelectedPlotsAmount() {
    final detail = syndicateDetail.value;
    if (detail == null || selectedPlots.isEmpty) return 0.0;

    // Return FIXED amount regardless of how many plots are selected
    final fixedAmount = getFixedBookingAmount();

    print('💵 Fixed amount (NOT per plot): $fixedAmount for ${selectedPlots.length} plots');
    print('💰 Admin Block Amount from detail: ${detail.adminBlockAmount}');

    return fixedAmount;
  }  List<Map<String, dynamic>> getSelectedUnitDetails() {
    final detail = syndicateDetail.value;
    if (detail == null || selectedPlots.isEmpty) return [];

    final pricePerPlot = getPricePerPlotFromAdminBlock();
    final List<Map<String, dynamic>> details = [];

    for (final plotId in selectedPlots) {
      final area = getPlotArea(plotId);
      details.add({
        "id": plotId,
        "area": area,
        "formattedArea": formatArea(area),
        "pricePerPlot": pricePerPlot,
        "formattedPrice": "₹${pricePerPlot.toStringAsFixed(2)}",
        "priceSource": detail.adminBlockAmount != null &&
            detail.adminBlockAmount!.isNotEmpty &&
            detail.adminBlockAmount != '0'
            ? "admin_block_amount"
            : "calculated_price",
      });
    }

    return details;
  }
  void generatePlotsFromApiData() {
    final detail = syndicateDetail.value;
    if (detail == null) return;

    final totalPlots = detail.unitSpilt;
    final bookings = detail.bookings;
    final plotAreas = getPlotAreas();
    final pricePerPlot = getPricePerPlotFromAdminBlock();

    print('🎯 Generating $totalPlots plots with price per plot: $pricePerPlot');
    print('💰 Admin Block Amount from API: ${detail.adminBlockAmount}');

    // Get all booked plot IDs from bookings
    final Set<int> bookedPlotIds = <int>{};
    for (final booking in bookings) {
      final unitIds = _parseUnitIds(booking.units);
      bookedPlotIds.addAll(unitIds);
      print('📋 Booking units: ${booking.units} -> Parsed: $unitIds');
    }

    // Generate plots list with area
    final List<Map<String, dynamic>> generatedPlots = [];
    for (int i = 1; i <= totalPlots; i++) {
      final status = bookedPlotIds.contains(i) ? "booked" : "available";
      final area = i <= plotAreas.length ? plotAreas[i - 1] : 0.0;

      generatedPlots.add({
        "id": i,
        "status": status,
        "area": area,
        "formattedArea": formatArea(area),
        "pricePerPlot": pricePerPlot,
        "formattedPrice": "₹${pricePerPlot.toStringAsFixed(2)}",
      });
    }

    plots.value = generatedPlots;
    selectedPlots.clear(); // Clear previous selections

    print('✅ Generated ${plots.length} plots');
    print('   Available: ${countStatus("available")}');
    print('   Booked: ${countStatus("booked")}');

    update();
  }
  double getDocumentPrice() {
    final detail = syndicateDetail.value;
    if (detail == null) return 0.0;

    return detail.documentPriceValue;
  }
  void initiatePlotPayment() {
    if (selectedPlots.isEmpty) {
      SnackBarHelper.showError("Please select at least one plot");
      return;
    }

    final detail = syndicateDetail.value;
    if (detail == null) {
      SnackBarHelper.showError("Property details not available");
      return;
    }

    // Calculate amount using admin_block_amount
    final amount = calculateSelectedPlotsAmount();
    print('💰 Payment amount calculated: $amount for ${selectedPlots.length} plots');
    print('💰 Price per plot: ${getPricePerPlotFromAdminBlock()}');

    if (amount <= 0) {
      SnackBarHelper.showError("Invalid amount calculation");
      return;
    }

    // Get unit details
    final unitDetails = getSelectedUnitDetails();

    // Setup payment controller
    final paymentController = Get.find<RazorpayController>();
    paymentController.setupPlotPayment(
      propertyId: detail.id,
      units: selectedPlots.toList(),
      unitDetails: unitDetails,
      amount: amount, // Make sure this is the correct total amount
      type: 'syndicate',
    );

    // Show payment summary dialog
    showPlotPaymentSummaryBottomSheet(amount, unitDetails);
  }
  void initiateDocumentPayment(int documentId, String documentType) {
    // Check if user has booked plots
    final hasBookedPlots = countStatus("booked") > 0;

    if (!hasBookedPlots) {
      SnackBarHelper.showError(
          "Please book a plot first to access documents"
      );
      return;
    }

    // If you still want to allow document viewing/downloading without payment
    // just call viewDocument or downloadDocument directly
    if (documentId == 0) {
      // For "ALL" documents case
      SnackBarHelper.showSuccess("Documents are now unlocked!");
    } else {
      viewDocument(documentId);
    }
  }
  // void initiateDocumentPayment(int documentId, String documentType) {
  //   final detail = syndicateDetail.value;
  //   if (detail == null) {
  //     SnackBarHelper.showError("Property details not available");
  //     return;
  //   }
  //
  //   // Get document price
  //   final amount = getDocumentPrice();
  //   if (amount <= 0) {
  //     SnackBarHelper.showError("Document price not available");
  //     return;
  //   }
  //
  //   final paymentController = Get.put(RazorpayController());
  //   paymentController.setupDocumentPayment(
  //     propertyId: detail.id,
  //     documentId: documentId,
  //     documentType: documentType,
  //     amount: amount,
  //   );
  //
  //   showDocumentPaymentSummaryDialog(amount, documentType);
  // }
  void showPlotPaymentSummaryBottomSheet(double amount, List<Map<String, dynamic>> unitDetails) {
    final totalAmount = amount;
    final razorpayController = Get.find<RazorpayController>();
    final detail = syndicateDetail.value;
    final selectedCount = selectedPlots.length;

    final fixedAmount = getFixedBookingAmount();
    final perPlotDisplay = selectedCount > 0 ? (fixedAmount / selectedCount) : fixedAmount;

    Get.bottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5)),
          ],
        ),
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 30.h),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              SizedBox(height: 24.h),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Payment Summary",
                          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                      Text("Review your plot investment", style: TextStyle(fontSize: 13.sp, color: Colors.grey[500])),
                      SizedBox(height: 4.h),
                      Text(
                        "Fixed Booking Amount (Not per plot)",
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  _buildModernSecureBadge(),
                ],
              ),

              SizedBox(height: 24.h),

              // Main Summary Card
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildModernRow("Property", detail?.name ?? "N/A", Icons.location_city_rounded),
                    SizedBox(height: 12.h),
                    _buildModernRow("Selected Plots", "${selectedCount} Unit${selectedCount > 1 ? 's' : ''}", Icons.grid_view_rounded),
                    SizedBox(height: 12.h),
                    _buildModernRow("Price Breakdown", "${selectedCount} plot${selectedCount > 1 ? 's' : ''} × ₹${(fixedAmount / selectedCount).toStringAsFixed(2)}", Icons.calculate_rounded),

                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Divider(color: Colors.grey[200], thickness: 1),
                    ),

                    // Show calculation
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Fixed Booking Amount",
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[800],
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "Total: ₹${fixedAmount.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                          if (selectedCount > 1)
                            Text(
                              "(Same price regardless of plot count)",
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.blue[600],
                              ),
                            ),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Payable", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.blueGrey[800])),
                        Text("₹${totalAmount.toStringAsFixed(2)}",
                            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w900, color: const Color(0xFF4338CA), letterSpacing: -0.5)),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Terms and Conditions Section
              Obx(() => InkWell(
                onTap: () => razorpayController.toggleTerms(),
                child: Row(
                  children: [
                    Checkbox(
                      value: razorpayController.isTermsAccepted.value,
                      onChanged: (v) => razorpayController.toggleTerms(),
                      activeColor: const Color(0xFF4338CA),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    Expanded(
                      child: Text("I agree to the payment terms and booking policy",
                          style: TextStyle(fontSize: 12.sp, color: Colors.blueGrey[600])),
                    ),
                  ],
                ),
              )),

              SizedBox(height: 20.h),

              // Action Slider
              Obx(() {
                final isTermsAccepted = razorpayController.isTermsAccepted.value;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth <= 0) {
                      return const SizedBox(height: 60);
                    }

                    return SizedBox(
                      width: constraints.maxWidth,
                      height: 60.h,
                      child: ActionSlider.standard(
                        height: 60.h,
                        backgroundColor: const Color(0xFFF1F5F9),
                        toggleColor: isTermsAccepted
                            ? const Color(0xFF4338CA)
                            : Colors.grey[400]!,
                        icon: const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        child: Text(
                          "Slide to Confirm Payment",
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        action: (controller) async {
                          if (!isTermsAccepted) {
                            SnackBarHelper.showError("Please accept terms to proceed");
                            controller.reset();
                            return;
                          }

                          controller.loading();

                          await Future.delayed(const Duration(milliseconds: 300));
                          Get.back();
                          razorpayController.initiatePayment();

                          controller.success();
                        },
                      ),
                    );
                  },
                );
              }),

              SizedBox(height: 16.h),

              // Cancel button
              GestureDetector(
                onTap: () => Get.back(),
                child: Text(
                    "Cancel and Return",
                    style: TextStyle(color: Colors.grey[500], fontSize: 14.sp, decoration: TextDecoration.underline)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }  Widget _buildModernRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: const Color(0xFF64748B)),
        SizedBox(width: 10.w),
        Text(label, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B))),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildPriceDetail(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13.sp, color: Colors.blueGrey[400])),
        Text(value, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.blueGrey[700])),
      ],
    );
  }

  Widget _buildModernSecureBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, size: 14.sp, color: const Color(0xFF4338CA)),
          SizedBox(width: 4.w),
          Text("SECURE", style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: const Color(0xFF4338CA))),
        ],
      ),
    );
  }

  void showDocumentPaymentSummaryDialog(double amount, String documentType) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 24.h),

            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.description_outlined, color: const Color(0xFF6366F1), size: 24.w),
                ),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Confirm Payment",
                        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                    Text("Review your document details",
                        style: TextStyle(fontSize: 13.sp, color: Colors.grey[500])),
                  ],
                ),
              ],
            ),

            SizedBox(height: 24.h),

            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                children: [
                  _buildSummaryRow("Document Type", documentType),
                  SizedBox(height: 12.h),
                  _buildSummaryRow("Property", syndicateDetail.value?.name ?? "N/A"),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: DottedLine(dashColor: Colors.grey[300]!),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Amount to Pay",
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
                      Text("₹${amount.toStringAsFixed(2)}",
                          style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: Color(0xFF1E293B))),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),
            _buildTermsCheckboxWidget(),
            SizedBox(height: 24.h),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    child: Text("Cancel", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _proceedToDocumentPayment(amount, documentType);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E293B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    ),
                    child: Text("Confirm & Pay", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13.sp, color: Color(0xFF64748B))),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
        ),
      ],
    );
  }

  Widget _buildTermsCheckboxWidget() {
    final paymentController = Get.find<RazorpayController>();

    return Row(
      children: [
        Obx(() => Checkbox(
          value: paymentController.isTermsAccepted.value,
          onChanged: (value) => paymentController.toggleTerms(),
        )),
        Expanded(
          child: GestureDetector(
            onTap: () => _showTermsAndConditions(),
            child: Text(
              "I agree to the Terms and Conditions",
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showTermsAndConditions() {
    Get.defaultDialog(
      title: "Terms and Conditions",
      titleStyle: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      ),
      content: Container(
        width: 300.w,
        height: 300.h,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "1. All payments are non-refundable.",
                style: TextStyle(fontSize: 12.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                "2. Plot booking is confirmed only after successful payment.",
                style: TextStyle(fontSize: 12.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                "3. Document access is granted after payment verification.",
                style: TextStyle(fontSize: 12.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                "4. GST is applicable as per government regulations.",
                style: TextStyle(fontSize: 12.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                "5. For any disputes, contact our customer support.",
                style: TextStyle(fontSize: 12.sp),
              ),
            ],
          ),
        ),
      ),
      confirm: ElevatedButton(
        onPressed: Get.back,
        child: Text("OK"),
      ),
    );
  }

  Future<void> _proceedToPlotPayment(double totalAmount) async {
    try {
      final paymentController = Get.find<RazorpayController>();

      if (!paymentController.isTermsAccepted.value) {
        SnackBarHelper.showError("Please accept terms and conditions");
        return;
      }

      final userDetails = await _getUserDetails();

      if (userDetails['name']!.isEmpty || userDetails['email']!.isEmpty || userDetails['phone']!.isEmpty) {
        SnackBarHelper.showError("Please complete your profile before making payments");
        return;
      }

      paymentController.openCheckout(
        customerName: userDetails['name']!,
        customerEmail: userDetails['email']!,
        customerPhone: userDetails['phone']!,
        amount: (totalAmount * 100).toInt(),
        description: "Plot Booking for ${selectedPlots.length} plots",
      );
    } catch (e) {
      print('❌ Error proceeding to plot payment: $e');
      SnackBarHelper.showError("Failed to proceed with payment. Please try again.");
    }
  }

  Future<void> _proceedToDocumentPayment(double totalAmount, String documentType) async {
    try {
      final paymentController = Get.find<RazorpayController>();

      if (!paymentController.isTermsAccepted.value) {
        SnackBarHelper.showError("Please accept terms and conditions");
        return;
      }

      final userDetails = await _getUserDetails();

      if (userDetails['name']!.isEmpty || userDetails['email']!.isEmpty || userDetails['phone']!.isEmpty) {
        SnackBarHelper.showError("Please complete your profile before making payments");
        return;
      }

      paymentController.openCheckout(
        customerName: userDetails['name']!,
        customerEmail: userDetails['email']!,
        customerPhone: userDetails['phone']!,
        amount: (totalAmount * 100).toInt(),
        description: "Document Payment: $documentType",
      );
    } catch (e) {
      print('❌ Error proceeding to document payment: $e');
      SnackBarHelper.showError("Failed to proceed with payment. Please try again.");
    }
  }

  Future<Map<String, String>> _getUserDetails() async {
    try {
      final isLoggedIn = await SessionManager.isLoggedIn();
      if (!isLoggedIn) {
        SnackBarHelper.showError("Please login to make payments");
        Get.offAllNamed('/login');
        throw Exception('User not logged in');
      }

      final userData = await SessionManager.getUserData();
      if (userData == null) {
        SnackBarHelper.showError("Session expired. Please login again.");
        await SessionManager.clearSession();
        Get.offAllNamed('/login');
        throw Exception('User data not found');
      }

      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        SnackBarHelper.showError("Session invalid. Please login again.");
        await SessionManager.clearSession();
        Get.offAllNamed('/login');
        throw Exception('Token not found');
      }

      final firstName = userData['first_name']?.toString() ?? '';
      final lastName = userData['last_name']?.toString() ?? '';
      final fullName = firstName.isNotEmpty && lastName.isNotEmpty
          ? '$firstName $lastName'
          : firstName.isNotEmpty
          ? firstName
          : lastName.isNotEmpty
          ? lastName
          : 'User';

      return {
        'name': fullName,
        'email': userData['email']?.toString() ?? '',
        'phone': userData['phone']?.toString() ?? '',
        'user_id': userData['id']?.toString() ?? '',
        'gender': userData['gender']?.toString() ?? '1',
        'role': userData['role']?.toString() ?? '2',
      };
    } catch (e) {
      print('❌ Error getting user details: $e');

      try {
        final prefs = await SharedPreferences.getInstance();
        final firstName = prefs.getString('first_name') ?? '';
        final lastName = prefs.getString('last_name') ?? '';
        final fullName = firstName.isNotEmpty && lastName.isNotEmpty
            ? '$firstName $lastName'
            : firstName.isNotEmpty
            ? firstName
            : lastName.isNotEmpty
            ? lastName
            : 'User';

        return {
          'name': fullName,
          'email': prefs.getString('email') ?? 'user@example.com',
          'phone': prefs.getString('phone') ?? '9876543210',
          'user_id': prefs.getString('user_id') ?? '',
          'gender': prefs.getInt('gender')?.toString() ?? '1',
          'role': prefs.getInt('role')?.toString() ?? '2',
        };
      } catch (e2) {
        print('❌ Fallback error: $e2');
        return {
          'name': 'User',
          'email': 'user@example.com',
          'phone': '9876543210',
          'user_id': '',
          'gender': '1',
          'role': '2',
        };
      }
    }
  }

  // Syndicate Buying List Methods
  Future<void> fetchSyndicateBuyingList({bool loadMore = false}) async {
    try {
      await SessionManager.debugSession();
      final String? token = await SessionManager.getToken();

      if (token == null || token.isEmpty) {
        print('❌ No token found for syndicate buying list');
        SnackBarHelper.showError('Authentication failed. Please login again.');
        isLoadingBuyingList(false);
        return;
      }

      if (loadMore) {
        if (!hasMoreBuyingData.value) return;
        buyingListPage.value++;
      } else {
        isLoadingBuyingList(true);
        buyingListPage.value = 1;
        hasMoreBuyingData.value = true;
        buyingList.clear();
      }

      final url = '${ApiUrl.syndicateBuyingList}?page=${buyingListPage.value}';
      print('🌐 Fetching Syndicate Buying List URL: $url');

      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      final response = await ApiService.getRequest(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null && responseData['status'] == true) {
          try {
            final syndicateBuyingResponse = SyndicateBuyingListResponse.fromJson(responseData);

            if (loadMore) {
              buyingList.addAll(syndicateBuyingResponse.data);
            } else {
              buyingList.assignAll(syndicateBuyingResponse.data);
            }

            totalBuyingPages.value = syndicateBuyingResponse.pagination.lastPage;
            hasMoreBuyingData.value = buyingListPage.value < totalBuyingPages.value;

            print('✅ Fetched ${buyingList.length} syndicate buying records');
          } catch (e) {
            print('❌ Error parsing syndicate buying list: $e');
            SnackBarHelper.showError("Failed to parse buying list data");
          }
        } else {
          SnackBarHelper.showError(
              responseData?['message'] ?? "Failed to fetch syndicate buying list");
          print('❌ API Error: ${responseData?['message']}');
        }
      } else if (response.statusCode == 401) {
        print('🔐 Session expired (401) for buying list');
        SnackBarHelper.showError("Session expired. Please login again.");
      } else if (response.statusCode == 403) {
        SnackBarHelper.showError("You don't have permission to view buying list");
      } else {
        SnackBarHelper.showError("Failed to fetch buying list: ${response.statusCode}");
        print('❌ Error fetching buying list: ${response.data}');
      }
    } catch (e) {
      SnackBarHelper.showError("Network error: $e");
      print('❌ Network error fetching syndicate buying list: $e');
    } finally {
      isLoadingBuyingList(false);
    }
  }

  Future<void> fetchSyndicateBuyingListDetails({
    bool loadMore = false,
    int? transactionId
  }) async {
    try {
      if (transactionId != null) {
        selectedTransactionId.value = transactionId;
      }

      final txnId = transactionId ?? selectedTransactionId.value;
      if (txnId == null) {
        SnackBarHelper.showError("Transaction ID is required");
        return;
      }

      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        print('❌ No token found for syndicate details fetch');
        SnackBarHelper.showError('Please login');
        isLoadingBuyingDetail(false);
        return;
      }

      if (loadMore) {
        if (!hasMoreBuyingDetailData.value) return;
        buyingDetailPage.value++;
      } else {
        isLoadingBuyingDetail(true);
        buyingDetailPage.value = 1;
        hasMoreBuyingDetailData.value = true;
        buyingDetailList.clear();
      }

      final url = '${ApiUrl.syndicateBuyingDetails}?tran_id=$txnId&page=${buyingDetailPage.value}';
      print('🌐 Fetching Syndicate Buying Details URL: $url');

      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      final response = await ApiService.getRequest(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == true) {
          final detailResponse = SyndicateBuyingDetailResponse.fromJson(responseData);

          if (loadMore) {
            buyingDetailList.addAll(detailResponse.data);
          } else {
            buyingDetailList.assignAll(detailResponse.data);
          }

          totalBuyingDetailPages.value = detailResponse.pagination.lastPage;
          hasMoreBuyingDetailData.value = buyingDetailPage.value < totalBuyingDetailPages.value;

          print('✅ Fetched ${buyingDetailList.length} syndicate buying detail records');
        } else {
          SnackBarHelper.showError(
              responseData['message'] ?? "Failed to fetch syndicate buying details");
          print('❌ API Error: ${responseData['message']}');
        }
      } else if (response.statusCode == 401) {
        print('🔐 Session expired (401) for details');
        SnackBarHelper.showError("Session expired. Please login again.");
      } else if (response.statusCode == 403) {
        SnackBarHelper.showError("You don't have permission to view these details");
      } else if (response.statusCode == 404) {
        SnackBarHelper.showError("Syndicate transaction details not found");
      } else {
        SnackBarHelper.showError(
            "Failed to fetch syndicate buying details: ${response.statusCode}");
        print('❌ Error fetching syndicate buying details: ${response.data}');
      }
    } catch (e) {
      SnackBarHelper.showError("Network error: $e");
      print('❌ Network error fetching syndicate buying details: $e');
    } finally {
      isLoadingBuyingDetail(false);
    }
  }

  Future<void> cancelSyndicateBuyingRequest(int buyingId) async {
    try {
      isLoadingCancelRequest(true);

      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        print('❌ No token found for syndicate cancellation');
        SnackBarHelper.showError('Please login');
        isLoadingCancelRequest(false);
        return;
      }

      final url = '${ApiUrl.syndicateBuyingCancelRequest}/$buyingId';
      print('🌐 Cancelling Syndicate Buying Request URL: $url');

      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      final response = await ApiService.getRequest(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == true) {
          SnackBarHelper.showSuccess(responseData['message'] ??
              'Syndicate cancellation request submitted successfully');

          final index = buyingDetailList.indexWhere((item) => item.id == buyingId);
          if (index != -1) {
            final updatedDetail = buyingDetailList[index];
            final data = responseData['data'] ?? {};

            final updatedTransaction = Transaction(
              id: updatedDetail.transaction.id,
              transactionId: updatedDetail.transaction.transactionId,
              paymentMode: updatedDetail.transaction.paymentMode,
              transactionDetails: updatedDetail.transaction.transactionDetails,
              amount: updatedDetail.transaction.amount,
              isCompleted: updatedDetail.transaction.isCompleted,
              status: data['cancel_status'] == 1 ? 'cancelled' : updatedDetail.transaction.status,
              propertyId: updatedDetail.transaction.propertyId,
              userId: updatedDetail.transaction.userId,
              type: updatedDetail.transaction.type,
              createdAt: updatedDetail.transaction.createdAt,
              updatedAt: DateTime.now(),
              user: updatedDetail.transaction.user,
            );

            buyingDetailList[index] = SyndicateBuyingDetail(
              id: updatedDetail.id,
              transactionId: updatedDetail.transactionId,
              propertyId: updatedDetail.propertyId,
              unit: updatedDetail.unit,
              cancelStatus: data['cancel_status'] ?? updatedDetail.cancelStatus,
              refundDate: data['refund_date'] != null
                  ? DateTime.tryParse(data['refund_date'].toString())
                  : updatedDetail.refundDate,
              refundStatus: data['refund_status'] ?? updatedDetail.refundStatus,
              amount: updatedDetail.amount,
              refundAmount: data['refund_amount'] ?? updatedDetail.refundAmount,
              createdAt: updatedDetail.createdAt,
              updatedAt: DateTime.now(),
              transaction: updatedTransaction,
              property: updatedDetail.property,
            );

            buyingDetailList.refresh();
            print('✅ Updated syndicate detail $buyingId with cancellation status');
          }
        } else {
          SnackBarHelper.showError(responseData['message'] ??
              'Failed to submit syndicate cancellation request');
        }
      } else if (response.statusCode == 401) {
        print('🔐 Session expired (401) during syndicate cancellation');
        SnackBarHelper.showError("Session expired. Please login again.");
      } else if (response.statusCode == 403) {
        SnackBarHelper.showError(
            "You don't have permission to cancel this syndicate plot");
      } else if (response.statusCode == 404) {
        SnackBarHelper.showError("Syndicate plot not found");
      } else if (response.statusCode == 422) {
        SnackBarHelper.showError("Invalid request. Please check the details");
      } else {
        SnackBarHelper.showError(
            "Failed to cancel syndicate plot: ${response.statusCode}");
        print('❌ Error cancelling syndicate plot: ${response.data}');
      }
    } catch (e) {
      SnackBarHelper.showError("Network error: $e");
      print('❌ Network error cancelling syndicate plot: $e');
    } finally {
      isLoadingCancelRequest(false);
    }
  }

  Future<void> loadMoreBuyingList() async {
    if (!isLoadingBuyingList.value && hasMoreBuyingData.value) {
      await fetchSyndicateBuyingList(loadMore: true);
    }
  }

  Future<void> loadMoreBuyingDetail() async {
    if (!isLoadingBuyingDetail.value && hasMoreBuyingDetailData.value) {
      await fetchSyndicateBuyingListDetails(loadMore: true);
    }
  }

  Future<void> refreshBuyingList() async {
    await fetchSyndicateBuyingList();
  }

  void navigateToSyndicateBuyingDetails(int transactionId) {
    selectedTransactionId.value = transactionId;
    Get.toNamed('/syndicate-buying-details', arguments: transactionId);
    fetchSyndicateBuyingListDetails(transactionId: transactionId);
  }

  void showCancelConfirmationDialog(int buyingId, String propertyName) {
    Get.defaultDialog(
      title: "Cancel Syndicate Booking",
      titleStyle: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
      content: Column(
        children: [
          Text(
            "Are you sure you want to cancel your booking for:",
            style: TextStyle(fontSize: 14.sp),
          ),
          SizedBox(height: 10.h),
          Text(
            propertyName,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15.h),
          Text(
            "Note: Cancellation charges may apply as per terms.",
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.orange,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () {
          Get.back();
          cancelSyndicateBuyingRequest(buyingId);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        child: Text("Confirm Cancel"),
      ),
      cancel: TextButton(
        onPressed: Get.back,
        child: Text("Go Back"),
      ),
    );
  }

  String formatTransactionDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  bool canCancelBooking(SyndicateBuyingList booking) {
    return booking.transaction.status.toLowerCase() != 'cancelled';
  }

  double calculateRefundAmount(SyndicateBuyingList booking, double cancellationChargePercent) {
    final totalAmount = double.tryParse(booking.amount) ?? 0.0;
    final refundAmount = totalAmount * ((100 - cancellationChargePercent) / 100);
    return refundAmount;
  }

  @override
  void onClose() {
    _clearDetailData();
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }

  Future<Map<String, dynamic>> fetchStoreReferral(String email, int propertyId) async {
    try {
      final token = await SessionManager.getToken();

      if (token == null || token.isEmpty) {
        print('❌ No authentication token found');
        SnackBarHelper.showError('Please login to use referral feature');
        return {'success': false, 'message': 'Authentication required'};
      }

      final dio = Dio();
      dio.options.headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

      final Map<String, dynamic> requestData = {
        'email': email,
        'property_id': propertyId.toString(),
      };

      print('🌐 Store Referral API Request:');
      print('   URL: ${ApiUrl.baseUrl}/api/v2/store-referral');
      print('   Email: $email');
      print('   Property ID: $propertyId');
      print('   Token: ${token.substring(0, 20)}...');

      final response = await dio.post(
        '${ApiUrl.baseUrl}/api/v2/store-referral',
        data: requestData,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('✅ Store Referral API Response: $responseData');

        if (responseData['status'] == true) {
          SnackBarHelper.showSuccess(responseData['message'] ?? 'Referral stored successfully');
          return {
            'success': true,
            'message': responseData['message'],
            'data': responseData['data'] ?? {},
          };
        } else {
          SnackBarHelper.showError(responseData['message'] ?? 'Failed to store referral');
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to store referral',
          };
        }
      } else if (response.statusCode == 401) {
        print('🔐 Unauthorized - Token may be expired');
        SnackBarHelper.showError('Session expired. Please login again.');
        await SessionManager.clearSession();
        Get.offAllNamed('/login');

        return {
          'success': false,
          'message': 'Session expired',
        };
      } else if (response.statusCode == 422) {
        final responseData = response.data;
        final errors = responseData['errors'] ?? {};
        final errorMessage = errors.isNotEmpty
            ? errors.values.first.first?.toString()
            : responseData['message'] ?? 'Validation failed';

        SnackBarHelper.showError(errorMessage);
        return {
          'success': false,
          'message': errorMessage,
          'errors': errors,
        };
      } else {
        final responseData = response.data;
        final errorMsg = responseData?['message'] ?? 'Failed to store referral. Status: ${response.statusCode}';
        SnackBarHelper.showError(errorMsg);
        print('❌ Store Referral API Error: ${response.statusCode} - ${response.data}');

        return {
          'success': false,
          'message': errorMsg,
        };
      }
    } on DioException catch (e) {
      print('❌ Dio Error: ${e.type} - ${e.message}');

      if (e.response != null) {
        print('Response status: ${e.response!.statusCode}');
        print('Response data: ${e.response!.data}');

        return {
          'success': false,
          'message': 'Server error: ${e.response!.statusCode}',
        };
      }

      SnackBarHelper.showError('Network error: ${e.message}');
      return {
        'success': false,
        'message': 'Network error: ${e.message}',
      };
    } catch (e) {
      print('❌ Store Referral Network Error: $e');
      SnackBarHelper.showError('Error: $e');

      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}