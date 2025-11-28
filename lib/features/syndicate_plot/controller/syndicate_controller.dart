import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/api_constant.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/toster.dart';
import '../model/syndicate_model.dart';

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
  var searchQuery = ''.obs;
  var selectedCity = ''.obs;
  var selectedState = ''.obs;
  var minPrice = ''.obs;
  var maxPrice = ''.obs;
  var errorMessage = ''.obs;
  var isExpanded = false.obs;
  var isExpandedrefral = false.obs;

  // Dynamic plots based on API data
  RxList<Map<String, dynamic>> plots = <Map<String, dynamic>>[].obs;
  RxList<int> selectedPlots = <int>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  void refralExpansion() => isExpandedrefral.value = !isExpandedrefral.value;
  void toggleExpansion() => isExpanded.value = !isExpanded.value;

  // Generate plots dynamically based on API data
  void generatePlotsFromApiData() {
    final detail = syndicateDetail.value;
    if (detail == null) return;

    final totalPlots = detail.unitSpilt;
    final bookings = detail.bookings;

    // Get all booked plot IDs from bookings
    final Set<int> bookedPlotIds = <int>{};
    for (final booking in bookings) {
      final unitIds = _parseUnitIds(booking.units);
      bookedPlotIds.addAll(unitIds);
    }

    // Generate plots list
    final List<Map<String, dynamic>> generatedPlots = [];
    for (int i = 1; i <= totalPlots; i++) {
      final status = bookedPlotIds.contains(i) ? "booked" : "available";
      generatedPlots.add({
        "id": i,
        "status": status,
      });
    }

    plots.value = generatedPlots;
    selectedPlots.clear(); // Clear previous selections
    update();
  }

  // Parse unit IDs from comma-separated string like "1,5,3"
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

  int countStatus(String type) {
    return plots.where((e) => e["status"] == type).length;
  }

  void toggleSelect(int id, String type) {
    if (type == "booked") return;

    if (selectedPlots.contains(id)) {
      selectedPlots.remove(id);
      // Update plot status from selected to available
      final index = plots.indexWhere((plot) => plot["id"] == id);
      if (index != -1) {
        plots[index]["status"] = "available";
      }
    } else {
      selectedPlots.add(id);
      // Update plot status from available to selected
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

  // Document methods
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

  // Main data fetching methods
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
          print('📄 Current page: $currentPage, Total pages: $totalPages, Total items: $totalItems');

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

  // **CRITICAL FIX**: Proper syndicate detail fetching with pre-clear
  Future<void> fetchSyndicateDetail(int id) async {
    try {
      // Clear previous data immediately when starting new request
      _clearDetailData();

      isLoadingDetail(true);
      errorMessage('');

      final url = '${ApiUrl.syndicateDetails}/$id';
      print('🌐 Fetching Syndicate Detail URL: $url');

      final response = await ApiService.getRequest(url);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          syndicateDetail.value = SyndicateDetail.fromJson(responseData['data']);
          print('✅ Fetched syndicate detail: ${syndicateDetail.value?.name}');

          // Generate plots dynamically after fetching detail
          generatePlotsFromApiData();

          // Log booking information
          _logBookingInfo();
        } else {
          errorMessage('Invalid response format from server');
          SnackBarHelper.showError("Invalid response format");
          print('❌ Invalid response format: $responseData');
        }
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
    } finally {
      isLoadingDetail(false);
    }
  }

  // Log booking information for debugging
  void _logBookingInfo() {
    final detail = syndicateDetail.value;
    if (detail != null) {
      print('📊 Total Plots: ${detail.unitSpilt}');
      print('📋 Bookings Count: ${detail.bookings.length}');

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

  // Clear detail data method
  void _clearDetailData() {
    syndicateDetail.value = null;
    errorMessage('');
    plots.clear();
    selectedPlots.clear();
  }

  // Navigation method that clears data before navigating
  void navigateToDetail(int id) {
    // Clear data immediately when navigating
    _clearDetailData();

    // Navigate to detail page
    Get.toNamed('/syndicate-detail', arguments: id);

    // Fetch new data
    fetchSyndicateDetail(id);
  }

  // Reserve selected plots
  void reserveSelectedPlots() {
    if (selectedPlots.isEmpty) {
      SnackBarHelper.showError("Please select at least one plot");
      return;
    }

    print("Reserving plots: $selectedPlots");
    // TODO: Implement actual reservation API call
    SnackBarHelper.showSuccess("Plot reservation request sent!");

    // After reservation, you might want to mark these as booked
    // and clear selection
    for (final plotId in selectedPlots) {
      final index = plots.indexWhere((plot) => plot["id"] == plotId);
      if (index != -1) {
        plots[index]["status"] = "booked";
      }
    }
    selectedPlots.clear();
    update();
  }

  // Other existing methods
  Future<void> loadMore() async {
    if (!isLoadMore.value && hasMoreData.value) {
      currentPage.value++;
      await fetchSyndicatePlots(loadMore: true);
    }
  }

  Future<void> refreshData() async {
    await fetchSyndicatePlots();
  }

  Future<void> searchPlots(String query) async {
    searchQuery.value = query;
    await fetchSyndicatePlots();
  }

  Future<void> filterByCity(String city) async {
    selectedCity.value = city;
    await fetchSyndicatePlots();
  }

  Future<void> filterByState(String state) async {
    selectedState.value = state;
    await fetchSyndicatePlots();
  }

  Future<void> filterByPrice(String min, String max) async {
    minPrice.value = min;
    maxPrice.value = max;
    await fetchSyndicatePlots();
  }

  Future<void> clearFilters() async {
    searchQuery.value = '';
    selectedCity.value = '';
    selectedState.value = '';
    minPrice.value = '';
    maxPrice.value = '';
    await fetchSyndicatePlots();
  }

  List<String> getAvailableCities() {
    return syndicatePlots
        .map((plot) => plot.city?.cityName ?? '')
        .where((city) => city.isNotEmpty)
        .toSet()
        .toList();
  }

  List<String> getAvailableStates() {
    return syndicatePlots
        .map((plot) => plot.state?.stateName ?? '')
        .where((state) => state.isNotEmpty)
        .toSet()
        .toList();
  }

  String _buildQueryParams() {
    final params = <String>[];
    if (searchQuery.value.isNotEmpty) {
      params.add('search=${Uri.encodeComponent(searchQuery.value)}');
    }
    if (selectedCity.value.isNotEmpty) {
      params.add('city=${Uri.encodeComponent(selectedCity.value)}');
    }
    if (selectedState.value.isNotEmpty) {
      params.add('state=${Uri.encodeComponent(selectedState.value)}');
    }
    if (minPrice.value.isNotEmpty) {
      params.add('min_price=${Uri.encodeComponent(minPrice.value)}');
    }
    if (maxPrice.value.isNotEmpty) {
      params.add('max_price=${Uri.encodeComponent(maxPrice.value)}');
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

  @override
  void onClose() {
    _clearDetailData();
    super.onClose();
  }
}