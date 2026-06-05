import 'dart:async';
import 'dart:math';

import 'package:action_slider/action_slider.dart';
import 'package:cashback_farms/common/model/logger_model.dart';
import 'package:cashback_farms/common/widget/sessionhandler.dart';
import 'package:cashback_farms/features/menu/controller/dashboard_menu_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/api_constant.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/toster.dart';
import '../../payment/controller/razorpay_controller.dart';
import '../model/gioo_plot.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GiooPlotController extends GetxController {
  var isLoading = false.obs;
  var isLoadMore = false.obs;
  final RxBool showAllUnits = false.obs;
  var giooPlots = <GiooPlot>[].obs;
  var currentPage = 1.obs;
  var unitRanges = <String>[].obs;
  final TextEditingController searchController = TextEditingController();
  final RxString recentSearch = ''.obs;
  Timer? _debounce;
  final ScrollController gridScrollController = ScrollController();
  int firstAvailablePlotIndex = 0;
  bool hasFoundFirstAvailable = false;
  var totalPages = 1.obs;
  var hasMoreData = true.obs;
  var totalItems = 0.obs;
  var searchQuery = ''.obs;
  var selectedCity = Rxn<City>();
  var selectedState = Rxn<AppState>();
  var selectedPlotTypes = <String>[].obs;
  var minPrice = ''.obs;
  var maxPrice = ''.obs;
  var isLoadingDetail = false.obs;
  var giooPlotDetail = Rxn<GiooPlotDetail>();
  var errorMessage = ''.obs;
  var minAreaSqft = ''.obs;
  var maxAreaSqft = ''.obs;
  var isDescriptionExpanded = false.obs;
  var selectedStatsType = "Weekly".obs;
  var pricePerUnit = 0.0.obs;
  var isLoadingBuyingList = false.obs;
  var isLoadingBuyingDetail = false.obs;
  var isLoadingCancelRequest = false.obs;
  var states = <AppState>[].obs;
  var cities = <City>[].obs;

  // Properties for filtering
  var propertyTypes = <PropertyType>[].obs;
  var priceMin = 0.0.obs;
  var priceMax = 5000000.0.obs;
  var sqftMin = 0.0.obs;
  var sqftMax = 5000.0.obs;

  var buyingList = <GiooBuyingList>[].obs;
  var buyingListPage = 1.obs;
  var hasMoreBuyingData = true.obs;
  var totalBuyingPages = 1.obs;

  var buyingDetailList = <GiooBuyingDetail>[].obs;
  var buyingDetailPage = 1.obs;
  var hasMoreBuyingDetailData = true.obs;
  var totalBuyingDetailPages = 1.obs;

  var selectedTransactionId = Rxn<int>();

  // City loading state
  var isLoadingCities = false.obs;
  final Map<int, List<City>> _citiesCache = {};

  RxInt get selectedCount =>
      units.where((u) => u.status == 'Selected').length.obs;

  RxInt get bookedCount =>
      units.where((u) => u.status == 'Booked').length.obs;

  RxInt get availableCount =>
      units.where((u) => u.status == 'Available').length.obs;

  RxInt get adminBookedCount =>
      units.where((u) => u.status == 'AdminBooked').length.obs;

  RxInt get totalPlotsCount => units.length.obs;

  var units = <PlotUnit>[].obs;
  var selectedUnits = <int>[].obs;
  var approvedDate = "24 Dec 2024".obs;
  var totalSelectedAreaSqft = 0.0.obs;
  var totalPriceUnits = 0.0.obs;
  var totalFinalPrice = 0.0.obs;
  var pricePerSqft = 0.0.obs;
  var slotArea = 0.0.obs;
  var adminBlockUnits = ''.obs;
  var totalPlotSlots = 0.obs;
  var gioTermsChecked =  false.obs;
  // Dynamic graph data
  var weeklyProfit = 0.0.obs;
  var weeklyProfitPercent = 0.0.obs;
  final RxList<double> bookedValues = <double>[].obs;
  final RxList<double> availableValues = <double>[].obs;
  var overallProfit = 0.0.obs;
  var overallProfitPercent = 0.0.obs;
  List <GioPlotTermData>terms = [];
  @override
  void onInit() {
    super.onInit();
    fetchGiooPlots();
    fetchGiooBuyingList();
    fetchGioTerms();
    ever(totalAmount, (_) => calculateFinalAmount());
    ever(discountAmount, (_) => calculateFinalAmount());
    ever(useWallet, (_) => calculateFinalAmount());
    ever(isApplied, (_) => calculateFinalAmount());
  }


  void toggleDescription() =>
      isDescriptionExpanded.value = !isDescriptionExpanded.value;

  void findFirstAvailablePlot() {
    for (int i = 0; i < units.length; i++) {
      if (units[i].status == 'Available' || units[i].status == 'Open') {
        firstAvailablePlotIndex = i;
        hasFoundFirstAvailable = true;
        break;
      }
    }
  }

  // Check if any filters are applied
  bool hasFiltersApplied() {
    return searchQuery.value.isNotEmpty ||
        selectedPlotTypes.isNotEmpty ||
        minPrice.value.isNotEmpty ||
        maxPrice.value.isNotEmpty ||
        minAreaSqft.value.isNotEmpty ||
        selectedState.value != null ||
        selectedCity.value != null;
  }
  void resetAllFilters() {
    selectedPlotTypes.clear();
    minPrice.value = '';
    maxPrice.value = '';
    minAreaSqft.value = '';
    selectedState.value = null;
    selectedCity.value = null;
    cities.clear();
    searchQuery.value = '';
    searchController.clear();
  }
  // Get active filter count for UI
  int getActiveFilterCount() {
    int count = selectedPlotTypes.length;
    if (searchQuery.value.isNotEmpty) count++;
    if (minPrice.value.isNotEmpty || maxPrice.value.isNotEmpty) count++;
    if (minAreaSqft.value.isNotEmpty) count++;
    if (selectedState.value != null) count++;
    if (selectedCity.value != null) count++;
    return count;
  }

  // Clear all filters
  void clearFilters() {
    searchQuery.value = '';
    selectedPlotTypes.clear();
    minPrice.value = '';
    maxPrice.value = '';
    minAreaSqft.value = '';
    selectedState.value = null;
    selectedCity.value = null;
    cities.clear(); // Clear cities when filters are cleared
    fetchGiooPlots();
  }

  // ===============================
  // CITY FETCHING METHODS
  // ===============================

  Future<void> fetchCitiesForState(int stateId) async {
    try {
      if (_citiesCache.containsKey(stateId)) {
        // Use cached cities
        cities.value = _citiesCache[stateId]!;
        print('✅ Using cached cities for state $stateId: ${cities.length} cities');
        return;
      }

      isLoadingCities(true);

      final url = '${ApiUrl.cities}/$stateId';
      print('🌐 Fetching cities for state $stateId: $url');

      final response = await ApiService.getRequest(url);

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data;

        if (responseData['status'] == 200 || responseData['status'] == true) {
          final List<dynamic> citiesData = responseData['data'] ?? [];
          final List<City> cityList = citiesData
              .map((item) => City.fromJson(item))
              .toList();

          // Sort cities by name
          cityList.sort((a, b) => a.cityName.compareTo(b.cityName));

          // Cache the cities
          _citiesCache[stateId] = cityList;

          // Update observable list
          cities.value = cityList;

          print('✅ Fetched ${cities.length} cities for state $stateId');
        } else {
          print('⚠️ No cities found for state $stateId');
          cities.value = [];
        }
      } else {
        print('❌ Failed to fetch cities: ${response.statusCode}');
        cities.value = [];
      }
    } catch (e) {
      print('❌ Error fetching cities: $e');
      SnackBarHelper.showError("Failed to load cities");
      cities.value = [];
    } finally {
      isLoadingCities(false);
    }
  }

  // Method to handle state selection
  void onStateSelected(AppState? state) {
    selectedState.value = state;
    selectedCity.value = null; // Clear city when state changes

    if (state != null) {
      fetchCitiesForState(state.id);
    } else {
      cities.clear();
    }
  }

  Future<void> fetchGiooPlots({bool loadMore = false}) async {
    try {
      if (loadMore) {
        isLoadMore(true);
      } else {
        isLoading(true);
        currentPage.value = 1;
        hasMoreData.value = true;
      }

      final url = '${ApiUrl.giooPlotList}?page_no=${currentPage.value}${_buildQueryParams()}';
      print('🌐 Fetching Gioo Plots URL: $url');

      final response = await ApiService.getRequest(url);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          final data = responseData['data'];

          // Extract all filter data
          _extractFilterData(data);

          // Parse plots
          final giooData = data['geo'];
          if (giooData != null) {
            if (loadMore) {
              giooPlots.addAll(_parseGiooPlots(giooData));
            } else {
              giooPlots.assignAll(_parseGiooPlots(giooData));
            }
          }

          // Update pagination
          final paginationData = data['pagination'] ?? {};
          currentPage.value = paginationData['current_page'] ?? 1;
          totalPages.value = paginationData['last_page'] ?? 1;
          totalItems.value = paginationData['total'] ?? 0;
          hasMoreData.value = currentPage.value < totalPages.value;

          print('✅ Fetched ${giooPlots.length} Gioo plots');
        } else {
          SnackBarHelper.showError("Invalid response format from server");
        }
      } else if (response.statusCode == 404) {
        SnackBarHelper.showError("Gioo plots not found");
      } else {
        final errorMsg = response.data?['message'] ?? 'Failed to fetch Gioo plots';
        SnackBarHelper.showError("Error $errorMsg");
      }
    } catch (e) {
      SnackBarHelper.showError("Network error: $e");
      print('❌ Network error: $e');
    } finally {
      isLoading(false);
      isLoadMore(false);
    }
  }

  void _extractFilterData(Map<String, dynamic> data) {
    try {
      // Extract states
      if (data['state_list'] != null && data['state_list'] is List) {
        states.value = (data['state_list'] as List)
            .map((item) => AppState.fromJson(item))
            .toList();
        print('✅ Loaded ${states.length} states');
      }

      // Extract property types
      if (data['property_type'] != null && data['property_type'] is List) {
        propertyTypes.value = (data['property_type'] as List)
            .map((item) => PropertyType.fromJson(item))
            .toList();
        print('✅ Loaded ${propertyTypes.length} property types');
      }

      // Extract price ranges
      if (data['price_min'] != null) {
        final minPriceValue = (data['price_min'] as num).toDouble();
        priceMin.value = minPriceValue > 0 ? minPriceValue : 0.0;
      } else {
        priceMin.value = 0.0;
      }

      if (data['price_max'] != null) {
        final maxPriceValue = (data['price_max'] as num).toDouble();
        priceMax.value = maxPriceValue > priceMin.value ? maxPriceValue : priceMin.value + 1000000;
      } else {
        priceMax.value = priceMin.value + 1000000;
      }

      // Extract area ranges
      if (data['sqft_min'] != null) {
        final minAreaValue = (data['sqft_min'] as num).toDouble();
        sqftMin.value = minAreaValue > 0 ? minAreaValue : 0.0;
      } else {
        sqftMin.value = 0.0;
      }

      if (data['sqft_max'] != null) {
        final maxAreaValue = (data['sqft_max'] as num).toDouble();
        sqftMax.value = maxAreaValue > sqftMin.value ? maxAreaValue : sqftMin.value + 1000;
      } else {
        sqftMax.value = sqftMin.value + 1000;
      }

      // Don't extract cities from plots anymore - we fetch them separately
      // _extractCitiesFromPlots(data);

      print('💰 Price range: ₹${priceMin.value} - ₹${priceMax.value}');
      print('📏 Area range: ${sqftMin.value} - ${sqftMax.value} sqft');

    } catch (e) {
      print('❌ Error extracting filter data: $e');
      // Set safe defaults
      priceMin.value = 0.0;
      priceMax.value = 5000000.0;
      sqftMin.value = 0.0;
      sqftMax.value = 5000.0;
    }
  }

  String _buildQueryParams() {
    final params = <String>[];

    if (searchQuery.value.isNotEmpty) {
      params.add('search=${Uri.encodeComponent(searchQuery.value)}');
    }

    // State filter
    if (selectedState.value != null) {
      params.add('state=${selectedState.value!.id}');
    }

    // City filter
    if (selectedCity.value != null) {
      params.add('city=${selectedCity.value!.id}');
    }

    // Property type filter
    if (selectedPlotTypes.isNotEmpty) {
      final List<String> typeIds = [];
      for (var typeName in selectedPlotTypes) {
        final propertyType = propertyTypes.firstWhere(
              (type) => type.categoryName == typeName,
          orElse: () => PropertyType(
            id: 0,
            categoryName: '',
            status: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        if (propertyType.id > 0) {
          typeIds.add(propertyType.id.toString());
        }
      }
      if (typeIds.isNotEmpty) {
        params.add('plot_type=${typeIds.join(",")}');
      }
    }

    // Price filters
    if (minPrice.value.isNotEmpty) {
      params.add('min_price=${Uri.encodeComponent(minPrice.value)}');
    }

    if (maxPrice.value.isNotEmpty) {
      params.add('max_price=${Uri.encodeComponent(maxPrice.value)}');
    }

    // Area filters
    if (minAreaSqft.value.isNotEmpty) {
      params.add('min_sqft=${Uri.encodeComponent(minAreaSqft.value)}');
    }

    if (maxAreaSqft.value.isNotEmpty) {
      params.add('max_sqft=${Uri.encodeComponent(maxAreaSqft.value)}');
    }

    return params.isEmpty ? '' : '&${params.join('&')}';
  }

  void updateStats(String type) {
    selectedStatsType.value = type;

    if (giooPlotDetail.value == null) return;

    final detail = giooPlotDetail.value!;

    // Clear previous data
    bookedValues.clear();
    availableValues.clear();
    unitRanges.clear();

    if (type == "Weekly") {
      // Use weekly graph data
      if (detail.weeklyGraph.isNotEmpty) {
        final graphData = detail.weeklyGraph;

        // Prepare data for chart
        final List<double> bookedList = [];
        final List<double> availableList = [];
        final List<String> ranges = [];

        // Assuming weeklyGraph contains daily data
        for (var item in graphData) {
          ranges.add(item.day);
          bookedList.add(item.total.toDouble());
          // Calculate available units (total slots - booked)
          final totalSlots = totalPlotSlots.value;
          final available = totalSlots > item.total
              ? totalSlots - item.total
              : 0;
          availableList.add(available.toDouble());
        }

        bookedValues.value = bookedList;
        availableValues.value = availableList;

        // Update ranges
        unitRanges.value = ranges;
      }

      // Use weekly booked data
      if (detail.weeklyBooked != null) {
        weeklyProfit.value = double.tryParse(detail.weeklyBooked!.unitsBooked.toString()) ?? 0.0;
        weeklyProfitPercent.value = detail.weeklyBooked!.profitMargin;
      } else {
        weeklyProfit.value = 0.0;
        weeklyProfitPercent.value = 0.0;
      }
    } else {
      // Use monthly graph data
      if (detail.monthlyGraph.isNotEmpty) {
        final graphData = detail.monthlyGraph;

        final List<double> bookedList = [];
        final List<double> availableList = [];
        final List<String> ranges = [];

        for (var item in graphData) {
          ranges.add(item.month);
          bookedList.add(item.total.toDouble());
          final totalSlots = totalPlotSlots.value;
          final available = totalSlots > item.total
              ? totalSlots - item.total
              : 0;
          availableList.add(available.toDouble());
        }

        bookedValues.value = bookedList;
        availableValues.value = availableList;

        unitRanges.value = ranges;
      } else {
        weeklyProfit.value = 0.0;
        weeklyProfitPercent.value = 0.0;
      }
    }

    // Update overall data
    if (detail.overallBooked != null) {
      overallProfit.value = detail.overallBooked!.totalBookedUnits.toDouble();
      overallProfitPercent.value =
          detail.overallBooked!.growth;
    } else {
      overallProfit.value = 0.0;
      overallProfitPercent.value = 0.0;
    }

    print('📊 Graph data updated for $type');
    print('   Weekly Profit: ${weeklyProfit.value}');
    print('   Weekly Profit %: ${weeklyProfitPercent.value}');
    print('   Overall Profit: ${overallProfit.value}');
    print('   Overall Profit %: ${overallProfitPercent.value}');
    print('   Booked values: ${bookedValues.length} items');
    print('   Unit ranges: ${unitRanges.length} items');
  }

  Future<void> fetchGiooPlotDetail(int id) async {
    try {
      _clearDetailData();
      selectedUnits.clear();
      isLoadingDetail(true);
      errorMessage.value = '';

      final url = '${ApiUrl.giooDetails}/$id';
      print('🌐 Fetching Gioo Plot Detail URL: $url');

      final response = await ApiService.getRequest(url);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          giooPlotDetail.value = GiooPlotDetail.fromJson(responseData['data']);
          print('✅ Fetched Gioo plot detail: ${giooPlotDetail.value?.name}');

          _initializePlotData();
          _logPlotDetailInfo();
          generateAllPlotUnits();

          // Initialize graph data
          updateStats(selectedStatsType.value);
        } else {
          errorMessage.value = 'Invalid response format from server';
          SnackBarHelper.showError("Invalid response format");
          print('❌ Invalid response format: $responseData');
        }
      } else if (response.statusCode == 404) {
        errorMessage.value = 'Gioo plot details not found';
        SnackBarHelper.showError("Gioo plot details not found");
        print('❌ 404 Error: ${response.data}');
      } else {
        final errorMsg = response.data?['message'] ?? 'Failed to fetch Gioo plot details';
        errorMessage.value = errorMsg;
        SnackBarHelper.showError("Error: $errorMsg");
        print('❌ API Error ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      errorMessage.value = 'Network error: $e';
      SnackBarHelper.showError("Network error: $e");
      print('❌ Network error: $e');
    } finally {
      isLoadingDetail(false);
    }
  }

  void _initializePlotData() {
    final detail = giooPlotDetail.value;
    if (detail != null) {
      if (detail.price != null && detail.price!.isNotEmpty) {
        pricePerUnit.value = double.tryParse(detail.price!) ?? 0.0;
        print("💰 Price per Unit = ₹${pricePerUnit.value}");
      }

      if (detail.area != null && detail.area!.isNotEmpty) {
        totalPlotSlots.value = int.tryParse(detail.area!) ?? 0;
        print('📊 Total plot slots from area field: ${totalPlotSlots.value}');
      }

      if (detail.unitSpilt != null && detail.unitSpilt! > 0) {
        slotArea.value = double.tryParse(detail.area) ?? 0.0;
      }

      if (detail.adminblock?.units != null) {
        adminBlockUnits.value = detail.adminblock!.units;
      }
    }
  }

  List<int> getAdminBlockUnitIds() {
    final detail = giooPlotDetail.value;
    if (detail?.adminblock?.units == null) return [];
    try {
      final unitsString = detail!.adminblock!.units;
      final List<String> unitNumbers = unitsString.split(',');
      return unitNumbers
          .map((str) => int.tryParse(str.trim()) ?? 0)
          .where((id) => id > 0 && id <= totalPlotSlots.value)
          .toList();
    } catch (e) {
      print('❌ Error parsing adminblock units: $e');
      return [];
    }
  }

  List<int> getUserBookedUnitIds() {
    final detail = giooPlotDetail.value;
    if (detail?.bookings == null || detail!.bookings.isEmpty) {
      return [];
    }
    final List<int> bookedIds = [];
    for (var booking in detail.bookings) {
      if (booking.units.isNotEmpty) {
        final unitStrings = booking.units.split(',');
        for (var unitStr in unitStrings) {
          final unitId = int.tryParse(unitStr.trim());
          if (unitId != null && unitId <= totalPlotSlots.value) {
            bookedIds.add(unitId);
          }
        }
      }
    }
    return bookedIds;
  }

  void generateAllPlotUnits() {
    final detail = giooPlotDetail.value;
    if (detail == null || totalPlotSlots.value == 0) {
      generateDummyUnits();
      return;
    }
    try {
      final adminBlockIds = getAdminBlockUnitIds();
      final userBookedIds = getUserBookedUnitIds();
      double plotArea = 0.0;
      if (detail.totalPrice != null && detail.totalPrice!.isNotEmpty &&
          pricePerSqft.value > 0 && totalPlotSlots.value > 0) {
        final totalPrice = double.tryParse(detail.totalPrice!) ?? 0;
        final totalArea = totalPrice / pricePerSqft.value;
        plotArea = totalArea / totalPlotSlots.value;
      } else {
        plotArea = slotArea.value > 0 ? slotArea.value : 1800.0; // Default
      }
      final List<PlotUnit> allUnits = [];
      for (int unitId = 1; unitId <= totalPlotSlots.value; unitId++) {
        String status;
        if (adminBlockIds.contains(unitId)) {
          status = 'AdminBooked';
        } else if (userBookedIds.contains(unitId)) {
          status = 'Booked';
        } else {
          status = 'Available';
        }
        allUnits.add(PlotUnit(
          id: unitId,
          label: unitId.toString(),
          status: status,
          area: plotArea,
        ));
      }
      units.value = allUnits;
      print('📊 === PLOT STATISTICS ===');
      print('   Total Plots: ${units.length}');
      print('   Available: ${units
          .where((u) => u.status == 'Available')
          .length}');
      print('   Admin Booked: ${units
          .where((u) => u.status == 'AdminBooked')
          .length}');
      print('   User Booked: ${units
          .where((u) => u.status == 'Booked')
          .length}');
      print('   Available Count: ${availableCount.value}');
      print('========================');
    } catch (e) {
      print('❌ Error generating plot units: $e');
      generateDummyUnits();
    }
  }

  void generateDummyUnits() {
    final List<PlotUnit> dummyUnits = [];
    final int totalUnits = totalPlotSlots.value > 0
        ? totalPlotSlots.value
        : 1800;
    for (int i = 1; i <= totalUnits; i++) {
      final bool isBooked = i % 7 == 0;
      final status = isBooked ? 'Booked' : 'Available';
      dummyUnits.add(PlotUnit(
        id: i,
        label: i.toString(),
        status: status,
        area: slotArea.value > 0 ? slotArea.value : 1800.0,
      ));
    }
    units.value = dummyUnits;
    print('✅ Generated ${units.length} dummy units');
  }

  Future<void> proceedToPayment() async {
    if (selectedUnits.isEmpty) {
      SnackBarHelper.showError("Please select at least one plot unit");
      return;
    }
    if (giooPlotDetail.value == null) {
      SnackBarHelper.showError("Plot details not loaded");
      return;
    }
    if (totalFinalPrice.value <= 0) {
      SnackBarHelper.showError("Invalid amount");
      return;
    }
    try {
      final razorpayController = Get.put(RazorpayController());
      razorpayController.setupPlotPayment(
        type: 'gioo',
        propertyId: giooPlotDetail.value!.id,
        units: List.from(selectedUnits),
        amount: finalPayable.value,
        propertyName: giooPlotDetail.value!.name,
      );

      if (finalPayable.value == 0) {
        await razorpayController.handleZeroAmountPayment(
          couponCode: isApplied.value ? couponController.text.trim() : null,
          walletAmount: useWallet.value && actualWalletUsed.value > 0
              ? actualWalletUsed.value.toString()
              : null,
          specialDiscountAmount: specialDiscountAmount.value > 0
              ? specialDiscountAmount.value.toString()
              : null,
        );
        return;
      }

      razorpayController.initiatePayment(
        couponCode: isApplied.value ? couponController.text.trim() : null,
        walletAmount: useWallet.value && actualWalletUsed.value > 0
            ? actualWalletUsed.value.toString()
            : null,
        specialDiscountAmount: specialDiscountAmount.value > 0
            ? specialDiscountAmount.value.toString()
            : null,
      );
    } catch (e) {
      Loggers.error('❌ Error setting up payment: $e');
      SnackBarHelper.showError("Failed to setup payment: $e");
    }
  }


  Future<void> showPaymentDialog() async {
    if (selectedUnits.isEmpty) {
      SnackBarHelper.showError("Please select at least one plot unit");
      return;
    }

    final razorpayController = Get.find<RazorpayController>();
    razorpayController.setupPlotPayment(
      type: 'gioo',
      propertyId: giooPlotDetail.value!.id,
      units: List.from(selectedUnits),
      amount: finalPayable.value,
      propertyName: giooPlotDetail.value!.name,
    );

    Get.bottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 36.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Indicator
            Container(
              width: 48.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 28.h),

            // Header Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Review Booking",
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      "Finalize your plot selection",
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
                    ),
                  ],
                ),
                _buildSecureBadge(),
              ],
            ),

            SizedBox(height: 28.h),

            // Detailed Breakdown Card (Modern Elevation)
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(28.r),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
              ),
              child: Column(
                children: [
                  _buildModernDetailRow("Project", giooPlotDetail.value?.name ?? "N/A", Icons.business_rounded),
                  SizedBox(height: 16.h),
                  _buildModernDetailRow("Units Selected", selectedUnits.join(", "), Icons.layers_outlined),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Row(
                      children: List.generate(20, (index) => Expanded(
                        child: Container(
                          color: index % 2 == 0 ? Colors.transparent : Colors.grey[300],
                          height: 1,
                        ),
                      )),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total Amount", style: TextStyle(fontSize: 13.sp, color: const Color(0xFF64748B))),
                          Text("Inc. all taxes", style: TextStyle(fontSize: 11.sp, color: Colors.grey[400])),
                        ],
                      ),
                      Text(
                        "₹${finalPayable.value.toStringAsFixed(0)}",
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF4338CA),
                          letterSpacing: -1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // Terms & Conditions (Clean Layout)
            Obx(() => InkWell(
              onTap: () => razorpayController.toggleTerms(),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Row(
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: razorpayController.isTermsAccepted.value,
                        onChanged: (_) => razorpayController.toggleTerms(),
                        activeColor: const Color(0xFF4338CA),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 12.5.sp, color: const Color(0xFF64748B)),
                          children: const [
                            TextSpan(text: "I agree to the "),
                            TextSpan(text: "Booking Policy", style: TextStyle(color: Color(0xFF4338CA), fontWeight: FontWeight.w600)),
                            TextSpan(text: " & "),
                            TextSpan(text: "Terms and Conditions", style: TextStyle(color: Color(0xFF4338CA), fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),

            SizedBox(height: 24.h),

            // Action Slider
            Obx(() => AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: razorpayController.isTermsAccepted.value ? 1.0 : 0.6,
              child: ActionSlider.standard(
                height: 64.h,
                rolling: true,
                backgroundColor: const Color(0xFFF1F5F9),
                toggleColor: razorpayController.isTermsAccepted.value ? const Color(0xFF4338CA) : Colors.grey[400]!,
                icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 20),
                action: (controller) async {
                  if (!razorpayController.isTermsAccepted.value) {
                    SnackBarHelper.showError("Please accept terms to proceed");
                    return;
                  }
                  controller.loading();
                  await Future.delayed(const Duration(milliseconds: 800));
                  Get.back();
                  razorpayController.initiatePayment();
                },
                child: Text(
                  "Slide to Pay Securely",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            )),

            SizedBox(height: 20.h),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                "Cancel and Return",
                style: TextStyle(color: Colors.grey[500], fontSize: 14.sp, fontWeight: FontWeight.w500),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildModernDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.r)),
          child: Icon(icon, size: 18.sp, color: const Color(0xFF64748B)),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecureBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline_rounded, size: 14.sp, color: const Color(0xFF166534)),
          SizedBox(width: 6.w),
          Text(
            "SECURE",
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: const Color(0xFF166534)),
          ),
        ],
      ),
    );
  }

  Future<void> viewDocument(int id) async {
    try {
      final plotDetail = giooPlotDetail.value;
      if (plotDetail?.documents != null && plotDetail!.documents.isNotEmpty) {
        final doc = plotDetail.documents.firstWhere((d) => d.id == id);
        print("Viewing Gioo document: ${doc.doucType} - ${doc.file}");
        await _launchUrl(doc.file);
        return;
      }
    } catch (e) {
      print("Document not found: $id");
      SnackBarHelper.showError("Document not found");
    }
  }

  Future<void> downloadDocument(int id) async {
    try {
      final plotDetail = giooPlotDetail.value;
      if (plotDetail?.documents != null && plotDetail!.documents.isNotEmpty) {
        final doc = plotDetail.documents.firstWhere((d) => d.id == id);
        print("Downloading Gioo document: ${doc.doucType} - ${doc.file}");
        await _launchUrl(doc.file);
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
      if (!formattedUrl.startsWith('http://') &&
          !formattedUrl.startsWith('https://')) {
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
        SnackBarHelper.showError(
            "Cannot open the document. Please check your connection.");
      }
    } catch (e) {
      print('Error launching URL: $e');
      SnackBarHelper.showError("Failed to open document");
    }
  }

  void _clearDetailData() {
    giooPlotDetail.value = null;
    errorMessage.value = '';
    units.clear();
    selectedUnits.clear();
    totalSelectedAreaSqft.value = 0.0;
    totalPriceUnits.value = 0.0;
    totalFinalPrice.value = 0.0;
    pricePerSqft.value = 0.0;
    slotArea.value = 0.0;
    adminBlockUnits.value = '';
    totalPlotSlots.value = 0;

    // Clear graph data
    bookedValues.clear();
    availableValues.clear();
    unitRanges.clear();
    weeklyProfit.value = 0.0;
    weeklyProfitPercent.value = 0.0;
    overallProfit.value = 0.0;
    overallProfitPercent.value = 0.0;
  }

  void _logPlotDetailInfo() {
    final detail = giooPlotDetail.value;
    if (detail != null) {
      print('📊 Plot Name: ${detail.name}');
      print('📍 Address: ${detail.address}');
      print('🏙️ City: ${detail.city?.cityName}');
      print('🏛️ State: ${detail.state?.stateName}');
      print('💰 Price per sqft: ${detail.price}');
      print('📏 Total Plot Slots (area field): ${detail.area}');
      print('🔢 Unit Split: ${detail.unitSpilt}');
      print('🖼️ Images: ${detail.images.length}');
      print('📄 Documents: ${detail.documents.length}');
      print('🛠️ Work: ${detail.work}');
      print('👨‍💼 Agent ID: ${detail.agentId}');
      print('🔢 ULD No: ${detail.uldNo}');
      print('💰 Total Price: ${detail.totalPrice}');
      print('🧱 Admin Block: ${detail.adminBlock}');
      print('📋 Admin Block Units: ${detail.adminblock?.units
          ?.split(',')
          ?.length ?? 0} units');

      // Log graph data
      if (detail.weeklyGraph.isNotEmpty) {
        print('📅 Weekly Graph: ${detail.weeklyGraph.length} days');
      }
      if (detail.monthlyGraph.isNotEmpty) {
        print('📅 Monthly Graph: ${detail.monthlyGraph.length} months');
      }
      if (detail.weeklyBooked != null) {
        print('💰 Weekly Booked: ${detail.weeklyBooked!
            .weeklyProfit}, Profit Margin: ${detail.weeklyBooked!
            .profitMargin}%');
      }
      if (detail.overallBooked != null) {
        print('💰 Overall Booked: ${detail.overallBooked!
            .totalBookedUnits} units, Growth: ${detail.overallBooked!
            .growth}%');
      }
    }
  }

  String getFormattedAddress() {
    final detail = giooPlotDetail.value;
    if (detail == null) return '';
    final cityName = detail.city?.cityName ?? '';
    final stateName = detail.state?.stateName ?? '';
    if (cityName.isNotEmpty && stateName.isNotEmpty) {
      return '$cityName, $stateName';
    } else if (cityName.isNotEmpty) {
      return cityName;
    } else if (stateName.isNotEmpty) {
      return stateName;
    }
    return detail.address;
  }

  String getFormattedPrice() {
    if (pricePerSqft.value > 0) {
      return '₹${pricePerSqft.value.toStringAsFixed(2)}/sqft';
    }
    return 'Price not available';
  }

  String getPrimaryImage() {
    final detail = giooPlotDetail.value;
    if (detail?.images != null && detail!.images.isNotEmpty) {
      return detail.images.first;
    }
    return detail?.plotImage ?? '';
  }

  List<String> getAllImages() {
    final detail = giooPlotDetail.value;
    final List<String> allImages = [];
    if (detail?.plotImage != null && detail!.plotImage.isNotEmpty) {
      allImages.add(detail.plotImage);
    }
    if (detail?.images != null && detail!.images.isNotEmpty) {
      allImages.addAll(detail.images);
    }
    return allImages.toSet().toList();
  }

  Future<void> loadMore() async {
    if (!isLoadMore.value && hasMoreData.value) {
      currentPage.value++;
      await fetchGiooPlots(loadMore: true);
    }
  }

  Future<void> refreshData() async {
    await fetchGiooPlots();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    applySearch();
  }

  void applySearch() {
    if (searchQuery.value.trim().isEmpty) return;
    recentSearch.value = searchQuery.value.trim();
    fetchGiooPlots();
  }

  void clearRecentSearch() {
    recentSearch.value = '';
    searchQuery.value = '';
    searchController.clear();
    fetchGiooPlots();
  }

  List<GiooPlot> _parseGiooPlots(List<dynamic> data) {
    return data.map((item) => GiooPlot.fromJson(item)).toList();
  }

  GiooPlot? getPlotById(int id) {
    try {
      return giooPlots.firstWhere((plot) => plot.id == id);
    } catch (e) {
      return null;
    }
  }

  bool isPlotFavorite(int plotId) {
    return false;
  }

  void toggleFavorite(int plotId) {
    print('Toggled favorite for Gioo plot $plotId');
  }

  void toggleUnitSelection(int unitId) {
    final unitIndex = units.indexWhere((unit) => unit.id == unitId);
    if (unitIndex == -1) return;

    final unit = units[unitIndex];

    if (unit.status == 'Booked' || unit.status == 'AdminBooked') {
      SnackBarHelper.showError("This unit is already booked");
      return;
    }

    if (selectedUnits.contains(unitId)) {
      // Deselect
      selectedUnits.remove(unitId);
      units[unitIndex] = unit.copyWith(status: 'Available');
    } else {
      // Select
      selectedUnits.add(unitId);
      units[unitIndex] = unit.copyWith(status: 'Selected');
    }

    // Force UI update by reassigning the list
    units.value = List.from(units);

    calculateTotals();
  }

  void calculateTotals() {
    final selectedUnitList = units.where((unit) => selectedUnits.contains(unit.id)).toList();

    if (selectedUnitList.isEmpty) {
      totalSelectedAreaSqft.value = 0.0;
      totalPriceUnits.value = 0.0;
      totalFinalPrice.value = 0.0;
      return;
    }

    // 1️⃣ Number of selected plots
    int count = selectedUnitList.length;

    // 2️⃣ Final price = Count × Price per unit
    totalPriceUnits.value = count * pricePerUnit.value;

    totalFinalPrice.value = totalPriceUnits.value;

    print('📊 === CALCULATION ===');
    print('   Selected Units: $count');
    print('   Price per Unit: ₹${pricePerUnit.value}');
    print('   Total Price: ₹${totalFinalPrice.value}');
    print('====================');
  }

  String getSelectedUnitsText({int limit = 5}) {
    if (selectedUnits.isEmpty) return "No units selected";

    final units = selectedUnits.toList()..sort();

    if (showAllUnits.value || units.length <= limit) {
      return "Units: ${units.join(', ')}";
    }

    final visibleUnits = units.take(limit).join(', ');
    final remaining = units.length - limit;

    return "Units: $visibleUnits +$remaining more";
  }

  void toggleShowUnits() {
    showAllUnits.toggle();
    update();
  }

  String getSelectedUnitsString() {
    if (selectedUnits.isEmpty) return "";
    final sortedUnits = List.from(selectedUnits)
      ..sort();
    return sortedUnits.join(',');
  }

  String formatCurrency(double amount) {
    return "₹${amount.toStringAsFixed(2)}";
  }

  void setPlotDetail(GiooPlotDetail detail) {
    giooPlotDetail.value = detail;
    _initializePlotData();
    generateAllPlotUnits();
  }

  void updateAvailableCount() {
    refresh();
  }

  Future<void> fetchGiooBuyingList({bool loadMore = false}) async {
    try {
      // DEBUG: Check session status
      await SessionManager.debugSession();

      // Get token
      final String? token = await SessionManager.getToken();

      if (token == null || token.isEmpty) {
        print('the token....$token');
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

      final url = '${ApiUrl.giooBuyingList}?page=${buyingListPage.value}';
      print('🌐 Fetching Gioo Buying List URL: $url');

      // Add headers with token
      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      final response = await ApiService.getRequest(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null && responseData['status'] == true) {
          try {
            final giooBuyingResponse = GiooBuyingListResponse.fromJson(
                responseData);

            if (loadMore) {
              buyingList.addAll(giooBuyingResponse.data);
            } else {
              buyingList.assignAll(giooBuyingResponse.data);
            }

            totalBuyingPages.value = giooBuyingResponse.pagination.lastPage;
            hasMoreBuyingData.value =
                buyingListPage.value < totalBuyingPages.value;

            print('✅ Fetched ${buyingList.length} buying records');
            print(
                '📄 Current page: $buyingListPage, Total pages: $totalBuyingPages');
          } catch (e) {
            print('❌ Error parsing buying list: $e');
            SnackBarHelper.showError("Failed to parse buying list data");
          }
        } else {
          SnackBarHelper.showError(
              responseData?['message'] ?? "Failed to fetch buying list");
          print('❌ API Error: ${responseData?['message']}');
        }
      } else {
        // ... existing error handling ...
      }
    } catch (e) {
      SnackBarHelper.showError("Network error: $e");
      print('❌ Network error fetching buying list: $e');
    } finally {
      isLoadingBuyingList(false);
    }
  }

  Future<bool> fetchGiooBuyingListDetails({bool loadMore = false, int? transactionId}) async {
    try {
      if (transactionId != null) {
        selectedTransactionId.value = transactionId;
      }

      final txnId = transactionId ?? selectedTransactionId.value;
      if (txnId == null) {
        SnackBarHelper.showError("Transaction ID is required");
        return false;
      }

      // Check token first
      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        print('❌ No token found for details fetch');
        SnackBarHelper.showError('Please login');
        isLoadingBuyingDetail(false);
        return false;
      }

      if (loadMore) {
        if (!hasMoreBuyingDetailData.value)  return false;
        buyingDetailPage.value++;
      } else {
        isLoadingBuyingDetail(true);
        buyingDetailPage.value = 1;
        hasMoreBuyingDetailData.value = true;
        buyingDetailList.clear();
      }

      final url = '${ApiUrl
          .giooBuyingListDetails}?tran_id=$txnId&page=${buyingDetailPage
          .value}';
      print('🌐 Fetching Gioo Buying Details URL: $url');

      // Add headers with token
      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      final response = await ApiService.getRequest(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == true) {
          final detailResponse = GiooBuyingDetailResponse.fromJson(
              responseData);

          if (loadMore) {
            buyingDetailList.addAll(detailResponse.data);
          } else {
            buyingDetailList.assignAll(detailResponse.data);
          }

          totalBuyingDetailPages.value = detailResponse.pagination.lastPage;
          hasMoreBuyingDetailData.value =
              buyingDetailPage.value < totalBuyingDetailPages.value;

          print('✅ Fetched ${buyingDetailList.length} buying detail records');
        } else {
          SnackBarHelper.showError(
              responseData['message'] ?? "Failed to fetch buying details");
          print('❌ API Error: ${responseData['message']}');
        }
        return true;
      } else if (response.statusCode == 403) {
        SnackBarHelper.showError(
            "You don't have permission to view these details");
        return false;
      } else if (response.statusCode == 404) {
        SnackBarHelper.showError("Transaction details not found");
        return false;
      } else {
        SnackBarHelper.showError(
            "Failed to fetch buying details: ${response.statusCode}");
        print('❌ Error fetching buying details: ${response.data}');
        return false;
      }
    } catch (e) {
      SnackBarHelper.showError("Network error: $e");
      print('❌ Network error fetching buying details: $e');
      return false;
    } finally {
      isLoadingBuyingDetail(false);
    }
  }

  Future<void> cancelGiooBuyingRequest(int buyingId) async {
    try {
      isLoadingCancelRequest(true);

      // Get the token using SessionManager
      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        print('❌ No token found for cancellation');
        SnackBarHelper.showError('Please login');
        isLoadingCancelRequest(false);
        return;
      }

      final url = '${ApiUrl.giooBuyingCancelRequest}/$buyingId';
      print('🌐 Cancelling Gioo Buying Request URL: $url');

      // Add headers with token for GET request
      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      // Use GET method for cancel API
      final response = await ApiService.getRequest(url, headers: headers);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == true) {
          SnackBarHelper.showSuccess(responseData['message'] ??
              'Cancellation request submitted successfully');

          // Update the item in the list
          final index = buyingList.indexWhere((item) => item.id == buyingId);
          if (index != -1) {
            // Create a copy with updated status from response
            final updatedItem = buyingList[index];
            final data = responseData['data'] ?? {};

            buyingList[index] = GiooBuyingList(
              id: updatedItem.id,
              propertyId: updatedItem.propertyId,
              userId: updatedItem.userId,
              units: updatedItem.units,
              amount: updatedItem.amount,
              transactionId: updatedItem.transactionId,
              returnAmount: data['refund_amount'] != null
                  ? double.tryParse(data['refund_amount'].toString())
                  : updatedItem.returnAmount,
              returnDate: data['return_date'] != null
                  ? DateTime.parse(data['return_date'])
                  : DateTime.now(),
              createdAt: updatedItem.createdAt,
              updatedAt: DateTime.now(),
              transaction: Transaction(
                id: updatedItem.transaction.id,
                transactionId: updatedItem.transaction.transactionId,
                paymentMode: updatedItem.transaction.paymentMode,
                transactionDetails: updatedItem.transaction.transactionDetails,
                amount: updatedItem.transaction.amount,
                isCompleted: updatedItem.transaction.isCompleted,
                status: data['cancel_status'] == 1 ? 'cancelled' : updatedItem
                    .transaction.status,
                propertyId: updatedItem.transaction.propertyId,
                userId: updatedItem.transaction.userId,
                type: updatedItem.transaction.type,
                createdAt: updatedItem.transaction.createdAt,
                updatedAt: DateTime.now(),
                user: updatedItem.transaction.user,
              ),
              property: updatedItem.property,
            );

            // Refresh the list
            buyingList.refresh();
            print('✅ Updated item $buyingId with cancellation status');
          }
        } else {
          SnackBarHelper.showError(responseData['message'] ??
              'Failed to submit cancellation request');
        }
      } else if (response.statusCode == 403) {
        SnackBarHelper.showError(
            "You don't have permission to cancel this booking");
      } else if (response.statusCode == 404) {
        SnackBarHelper.showError("Booking not found");
      } else if (response.statusCode == 422) {
        SnackBarHelper.showError("Invalid request. Please check the details");
      } else {
        SnackBarHelper.showError(
            "Failed to cancel request: ${response.statusCode}");
        print('❌ Error cancelling request: ${response.data}');
      }
    } catch (e) {
      SnackBarHelper.showError("Network error: $e");
      print('❌ Network error cancelling request: $e');
    } finally {
      isLoadingCancelRequest(false);
    }
  }

  Future<void> fetchGioTerms()
  async {
    final gioresponse = await  ApiService.getRequest(ApiUrl.gioTerms);
    if (gioresponse.statusCode == 200) {
      var termlist = GioPlotTermsModel.fromJson(gioresponse.data);
      terms = termlist.data ?? [];
    }

  }


  Future<void> loadMoreBuyingList() async {
    if (!isLoadingBuyingList.value && hasMoreBuyingData.value) {
      await fetchGiooBuyingList(loadMore: true);
    }
  }

  Future<void> loadMoreBuyingDetails() async {
    if (!isLoadingBuyingDetail.value && hasMoreBuyingDetailData.value) {
      await fetchGiooBuyingListDetails(loadMore: true);
    }
  }

  // Helper methods
  List<String> getUnitsList(String unitsString) {
    return unitsString.split(',').map((unit) => unit.trim()).toList();
  }

  String formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd MMM yyyy hh:mm a').format(date.toLocal());
  }

  String getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirm':
        return 'Confirmed';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirm':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'refunded':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  void onClose() {
    _clearDetailData();
    _debounce?.cancel();
    gridScrollController.dispose();
    searchController.dispose();
    super.onClose();
  }

  RxDouble totalAmount = 0.0.obs;
  RxDouble discountAmount = 0.0.obs;
  RxDouble finalPayable = 0.0.obs;

  RxDouble discountPercentage = 0.0.obs;
  RxDouble discountMaxCost = 0.0.obs;
  RxDouble actualWalletUsed = 0.0.obs;
  RxDouble walletBalance = 0.0.obs;
  RxBool useWallet = false.obs;
  RxBool isApplied = false.obs;
  RxDouble walletUsedAmount = 0.0.obs;
  TextEditingController walletAmountController = TextEditingController();

  RxDouble specialDiscountAmount = 0.0.obs;
  RxDouble appliedDiscountAmount = 0.0.obs;

  TextEditingController couponController = TextEditingController();
  RxBool isCouponLoading = false.obs;

  Future<void> applyCoupon() async {
    if (selectedUnits.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please select at least one plot",
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }
    final code = couponController.text.trim();

    if (code.isEmpty) {
      Fluttertoast.showToast(msg: "Enter coupon code");
      return;
    }

    try {
      isCouponLoading.value = true;
      final String? token = await SessionManager.getToken();
      final response = await ApiService.postRequestWithToken(
          ApiUrl.applyCoupon,
          data: {
            "coupon_code": code,
          },
          token: token ?? ''
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['status'] == true) {
          final couponAmount = double.tryParse(data['data']['amount'].toString()) ?? 0.0;

          // Calculate current total and special discount first
          double total = totalAmount.value;
          double specialDiscount = 0.0;

          if (discountMaxCost.value > 0 && total >= discountMaxCost.value) {
            specialDiscount = (total * discountPercentage.value) / 100;
            if (specialDiscount > discountMaxCost.value) {
              specialDiscount = discountMaxCost.value;
            }
          }

          // Calculate amount after special discount
          double amountAfterSpecialDiscount = total - specialDiscount;

          // ✅ Check if coupon discount exceeds amount after special discount
          if (couponAmount > amountAfterSpecialDiscount) {
            Fluttertoast.showToast(
              msg: "Coupon amount ₹${couponAmount.toStringAsFixed(2)} More than payable ₹${amountAfterSpecialDiscount.toStringAsFixed(2)}",              gravity: ToastGravity.BOTTOM,
              toastLength: Toast.LENGTH_LONG,
            );
            discountAmount.value = 0.0;
            isApplied.value = false;
            calculateFinalAmount();
            return;
          }

          // ✅ Apply coupon if validation passes
          discountAmount.value = couponAmount;
          isApplied.value = true;
          calculateFinalAmount();
          Fluttertoast.showToast(msg: data['message']);
        } else {
          discountAmount.value = 0.0;
          isApplied.value = false;
          calculateFinalAmount();
          Fluttertoast.showToast(msg: data['message']);
        }
      } else {
        discountAmount.value = 0.0;
        isApplied.value = false;
        calculateFinalAmount();
        Fluttertoast.showToast(msg: "Something went wrong");
      }
    } catch (e) {
      discountAmount.value = 0.0;
      isApplied.value = false;
      calculateFinalAmount();
      Fluttertoast.showToast(msg: "Error applying coupon");
    } finally {
      isCouponLoading.value = false;
    }
  }
  void resetValues() {
    totalAmount.value = 0.0;
    discountAmount.value = 0.0;
    finalPayable.value = 0.0;
    appliedDiscountAmount.value = 0.0;
    specialDiscountAmount.value = 0.0;
    walletUsedAmount.value = 0.0;
    actualWalletUsed.value = 0.0;
    walletAmountController.clear();
    useWallet.value = false;
    isApplied.value = false;
    couponController.clear();
    giooServiceChargeAmount.value = 0.0;
    giooIgstAmount.value = 0.0;
    giooServiceChargePercent.value = 0.0;
    giooIgstPercent.value = 0.0;
  }



  void removeCoupon() {
    couponController.clear();
    discountAmount.value = 0.0;
    isApplied.value = false;

    calculateFinalAmount();

    Fluttertoast.showToast(msg: "Coupon removed");
  }

  void onWalletAmountChanged(String value) {
    double typed = double.tryParse(value) ?? 0.0;

    if (typed > walletBalance.value) {
      typed = walletBalance.value;
      walletAmountController.text = typed.toStringAsFixed(0);
      walletAmountController.selection = TextSelection.fromPosition(
        TextPosition(offset: walletAmountController.text.length),
      );
    }

    walletUsedAmount.value = typed;
    calculateFinalAmount();
  }


  final dashboardController = Get.put(DashboardController());



  RxDouble giooServiceChargeAmount = 0.0.obs;
  RxDouble giooIgstAmount = 0.0.obs;
  RxDouble giooServiceChargePercent = 0.0.obs;
  RxDouble giooIgstPercent = 0.0.obs;

  void calculateFinalAmount() {
    double baseAmount = totalAmount.value;

    final businessSettings = dashboardController.businessSettings.value;
    final double giooIgstPct = (businessSettings?.giooIgst ?? 0).toDouble();
    final double giooServicePct = (businessSettings?.giooServiceCharge ?? 0).toDouble();

    // 1️⃣ Special discount on base amount
    double specialDiscount = 0.0;
    if (discountMaxCost.value > 0 && baseAmount >= discountMaxCost.value) {
      specialDiscount = (baseAmount * discountPercentage.value) / 100;
      if (specialDiscount > discountMaxCost.value) specialDiscount = discountMaxCost.value;
    }
    specialDiscountAmount.value = specialDiscount;

    // 2️⃣ Coupon on (base - special discount)
    double couponDiscount = isApplied.value ? discountAmount.value : 0.0;
    double amountAfterSpecial = baseAmount - specialDiscount;
    if (isApplied.value && couponDiscount > amountAfterSpecial) {
      isApplied.value = false;
      discountAmount.value = 0.0;
      couponController.clear();
      couponDiscount = 0.0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Fluttertoast.showToast(msg: "Coupon removed - exceeds order value", gravity: ToastGravity.BOTTOM);
      });
    }

    double appliedDiscount = specialDiscount + couponDiscount;
    appliedDiscountAmount.value = appliedDiscount;

    double amountAfterDiscount = baseAmount - appliedDiscount;
    if (amountAfterDiscount < 0) amountAfterDiscount = 0;

    // 3️⃣ Wallet deduction
    double walletUsed = 0.0;
    if (useWallet.value) {
      double requestedWallet = walletUsedAmount.value > 0
          ? walletUsedAmount.value
          : walletBalance.value;
      walletUsed = requestedWallet >= amountAfterDiscount
          ? amountAfterDiscount
          : requestedWallet;
      amountAfterDiscount -= walletUsed;
    }
    actualWalletUsed.value = walletUsed;

    // 4️⃣ Apply IGST + service charge AFTER discounts & wallet
    final double serviceCharge = (amountAfterDiscount * giooServicePct) / 100;
    final double igstCharge = (amountAfterDiscount * giooIgstPct) / 100;

    // Expose for UI breakdown
    giooServiceChargeAmount.value = serviceCharge;
    giooIgstAmount.value = igstCharge;
    giooServiceChargePercent.value = giooServicePct;
    giooIgstPercent.value = giooIgstPct;

    finalPayable.value = amountAfterDiscount + serviceCharge + igstCharge;
    if (finalPayable.value < 0) finalPayable.value = 0;

    print('💰 Base=$baseAmount, SpecialDisc=$specialDiscount, Coupon=$couponDiscount, Wallet=$walletUsed, Service=$serviceCharge, IGST=$igstCharge, Final=${finalPayable.value}');
  }
/*  void calculateFinalAmount() {
    double total = totalAmount.value;
    double specialDiscount = 0.0;


    final businessSettings = dashboardController.businessSettings.value;
    final double giooIgst = (businessSettings?.giooIgst ?? 0).toDouble();
    final double giooServiceCharge = (businessSettings?.giooServiceCharge ?? 0).toDouble();



    if (discountMaxCost.value > 0 && total >= discountMaxCost.value) {
      specialDiscount = (total * discountPercentage.value) / 100;
      if (specialDiscount > discountMaxCost.value) {
        specialDiscount = discountMaxCost.value;
      }
    }
    specialDiscountAmount.value = specialDiscount;

    double couponDiscount = isApplied.value ? discountAmount.value : 0.0;

    // ✅ Auto-remove coupon if it exceeds amount after special discount
    double amountAfterSpecialDiscount = total - specialDiscount;
    if (isApplied.value && couponDiscount > amountAfterSpecialDiscount) {
      isApplied.value = false;
      discountAmount.value = 0.0;
      couponController.clear();
      couponDiscount = 0.0;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Fluttertoast.showToast(
          msg: "Coupon removed - exceeds order value",
          gravity: ToastGravity.BOTTOM,
        );
      });
    }

    double appliedDiscount = specialDiscount + couponDiscount;
    appliedDiscountAmount.value = appliedDiscount;

    double amountAfterDiscount = total - appliedDiscount;
    if (amountAfterDiscount < 0) amountAfterDiscount = 0;

    double walletUsed = 0.0;
    if (useWallet.value) {
      double requestedWallet = walletUsedAmount.value > 0
          ? walletUsedAmount.value
          : walletBalance.value;

      walletUsed = requestedWallet >= amountAfterDiscount
          ? amountAfterDiscount
          : requestedWallet;

      amountAfterDiscount -= walletUsed;
    }

    actualWalletUsed.value = walletUsed;

    finalPayable.value = amountAfterDiscount < 0 ? 0 : amountAfterDiscount;

    print(
      '💰 Total=$total, Special=$specialDiscount, Coupon=$couponDiscount, Applied=$appliedDiscount, Wallet=$walletUsed, Final=${finalPayable.value}',
    );
  }*/


}

class PlotUnit {
  final int id;
  final String label;
  final String status; // 'Available', 'Selected', 'Booked', 'AdminBooked'
  final double area; // Area per plot in sqft

  PlotUnit({
    required this.id,
    required this.label,
    required this.status,
    required this.area,
  });

  PlotUnit copyWith({
    int? id,
    String? label,
    String? status,
    double? area,
  }) {
    return PlotUnit(
      id: id ?? this.id,
      label: label ?? this.label,
      status: status ?? this.status,
      area: area ?? this.area,
    );
  }
}