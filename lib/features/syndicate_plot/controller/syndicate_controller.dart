import 'dart:ui';
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
  RxList<Map<String, dynamic>> plots = <Map<String, dynamic>>[].obs;
  RxList<int> selectedPlots = <int>[].obs;

  @override
  void onInit() {
    super.onInit();
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


  List<double> _parseUnitAreas(String unitString) {
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

  Future<void> fetchSyndicateDetail(int id) async {
    try {
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

          generatePlotsFromApiData();
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
    return syndicatePlots.map((plot) => plot.city?.cityName ?? '').where((city) => city.isNotEmpty).toSet().toList();}
  List<String> getAvailableStates() {
    return syndicatePlots.map((plot) => plot.state?.stateName ?? '').where((state) => state.isNotEmpty).toSet().toList();}
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

  /////////////////////////////////----------Payment-----////////////////////////////////

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

  // Calculate total amount for selected plots (price per plot × number of selected plots)
  double calculateSelectedPlotsAmount() {
    final detail = syndicateDetail.value;
    if (detail == null || selectedPlots.isEmpty) return 0.0;

    // Get price per plot from API
    final pricePerPlot = double.tryParse(detail.price.replaceAll(',', '')) ?? 0.0;

    // Calculate total amount for selected plots
    return pricePerPlot * selectedPlots.length;
  }

  // Get price per plot
  double getPricePerPlot() {
    final detail = syndicateDetail.value;
    if (detail == null) return 0.0;

    return double.tryParse(detail.price.replaceAll(',', '')) ?? 0.0;
  }

  // Get unit details for selected plots with area
  List<Map<String, dynamic>> getSelectedUnitDetails() {
    final detail = syndicateDetail.value;
    if (detail == null || selectedPlots.isEmpty) return [];

    final pricePerPlot = getPricePerPlot();
    final List<Map<String, dynamic>> details = [];

    for (final plotId in selectedPlots) {
      final area = getPlotArea(plotId);
      details.add({
        "id": plotId,
        "area": area,
        "formattedArea": formatArea(area),
        "pricePerPlot": pricePerPlot,
        "formattedPrice": "₹${pricePerPlot.toStringAsFixed(2)}",
      });
    }

    return details;
  }

  // Generate plots from API data with area
  void generatePlotsFromApiData() {
    final detail = syndicateDetail.value;
    if (detail == null) return;

    final totalPlots = detail.unitSpilt;
    final bookings = detail.bookings;
    final plotAreas = getPlotAreas();
    final pricePerPlot = getPricePerPlot();

    // Get all booked plot IDs from bookings
    final Set<int> bookedPlotIds = <int>{};
    for (final booking in bookings) {
      final unitIds = _parseUnitIds(booking.units);
      bookedPlotIds.addAll(unitIds);
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

    // Calculate amount
    final amount = calculateSelectedPlotsAmount();
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
      amount: amount, type: 'syndicate',
    );

    // Show payment summary dialog
    showPlotPaymentSummaryDialog(amount, unitDetails);
  }

  void initiateDocumentPayment(int documentId, String documentType) {
    final detail = syndicateDetail.value;
    if (detail == null) {
      SnackBarHelper.showError("Property details not available");
      return;
    }

    // Get document price
    final amount = getDocumentPrice();
    if (amount <= 0) {
      SnackBarHelper.showError("Document price not available");
      return;
    }

    final paymentController = Get.put(RazorpayController());
    paymentController.setupDocumentPayment(
      propertyId: detail.id,
      documentId: documentId,
      documentType: documentType,
      amount: amount,
    );

    showDocumentPaymentSummaryDialog(amount, documentType);
  }

  void showPlotPaymentSummaryDialog(double amount, List<Map<String, dynamic>> unitDetails) {
    final gstAmount = amount * 0.18;
    final totalAmount = amount + gstAmount;
    final pricePerPlot = getPricePerPlot();

    Get.defaultDialog(
      title: "Plot Payment Summary",
      titleStyle: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
      content: Container(
        width: 320.w,
        padding: EdgeInsets.all(15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Info
            _buildSummaryRowWidget("Property", syndicateDetail.value?.name ?? "N/A"),
            _buildSummaryRowWidget("Price per Plot", "₹${pricePerPlot.toStringAsFixed(2)}"),
            _buildSummaryRowWidget("Selected Plots", selectedPlots.length.toString()),

            // Plot details with area
            if (unitDetails.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Text(
                "Plot Details:",
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 8.h),
              ...unitDetails.map((unit) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Plot ${unit['id']}",
                        style: TextStyle(fontSize: 12.sp),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            unit['formattedArea'],
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            unit['formattedPrice'],
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],

            Divider(thickness: 1, height: 20.h),

            // Simple Calculation
            Text(
              "Calculation:",
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "${selectedPlots.length} plots × ₹${pricePerPlot.toStringAsFixed(2)} = ₹${amount.toStringAsFixed(2)}",
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.green,
              ),
            ),

            Divider(thickness: 1, height: 20.h),

            // Price Calculation
            _buildPriceRowWidget("Base Amount", "₹${amount.toStringAsFixed(2)}"),
            _buildPriceRowWidget("GST (18%)", "₹${gstAmount.toStringAsFixed(2)}", isBold: false),

            Divider(thickness: 2, height: 20.h),

            // Total Amount
            _buildPriceRowWidget(
              "Total Amount",
              "₹${totalAmount.toStringAsFixed(2)}",
              isBold: true,
              isTotal: true,
            ),

            // Terms and Conditions
            SizedBox(height: 15.h),
            _buildTermsCheckboxWidget(),

            SizedBox(height: 20.h),

            // Payment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  _proceedToPlotPayment(totalAmount);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  "Proceed to Payment",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: 10.h),

            TextButton(
              onPressed: Get.back,
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showDocumentPaymentSummaryDialog(double amount, String documentType) {
    final gstAmount = amount * 0.18;
    final totalAmount = amount + gstAmount;

    Get.defaultDialog(
      title: "Document Payment Summary",
      titleStyle: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
      content: Container(
        width: 320.w,
        padding: EdgeInsets.all(15.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Document Info
            _buildSummaryRowWidget("Document Type", documentType),
            _buildSummaryRowWidget("Property", syndicateDetail.value?.name ?? "N/A"),

            Divider(thickness: 1, height: 20.h),

            // Price Calculation
            _buildPriceRowWidget("Document Fee", "₹${amount.toStringAsFixed(2)}"),
            _buildPriceRowWidget("GST (18%)", "₹${gstAmount.toStringAsFixed(2)}", isBold: false),

            Divider(thickness: 2, height: 20.h),

            // Total Amount
            _buildPriceRowWidget(
              "Total Amount",
              "₹${totalAmount.toStringAsFixed(2)}",
              isBold: true,
              isTotal: true,
            ),

            // Terms and Conditions
            SizedBox(height: 15.h),
            _buildTermsCheckboxWidget(),

            SizedBox(height: 20.h),

            // Payment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  _proceedToDocumentPayment(totalAmount, documentType);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                child: Text(
                  "Proceed to Payment",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: 10.h),

            TextButton(
              onPressed: Get.back,
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRowWidget(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRowWidget(String label, String value, {bool isBold = false, bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 14.sp : 12.sp,
              color: isTotal ? Colors.green : Colors.grey[700],
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 16.sp : 12.sp,
              color: isTotal ? Colors.green : Colors.black,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
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

      // Check terms
      if (!paymentController.isTermsAccepted.value) {
        SnackBarHelper.showError("Please accept terms and conditions");
        return;
      }

      // Get user details
      final userDetails = await _getUserDetails();

      // Validate user details
      if (userDetails['name']!.isEmpty || userDetails['email']!.isEmpty || userDetails['phone']!.isEmpty) {
        SnackBarHelper.showError("Please complete your profile before making payments");
        return;
      }

      paymentController.openCheckout(
        customerName: userDetails['name']!,
        customerEmail: userDetails['email']!,
        customerPhone: userDetails['phone']!,
        amount: (totalAmount * 100).toInt(), // Convert to paise
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

      // Check terms
      if (!paymentController.isTermsAccepted.value) {
        SnackBarHelper.showError("Please accept terms and conditions");
        return;
      }

      // Get user details
      final userDetails = await _getUserDetails();

      // Validate user details
      if (userDetails['name']!.isEmpty || userDetails['email']!.isEmpty || userDetails['phone']!.isEmpty) {
        SnackBarHelper.showError("Please complete your profile before making payments");
        return;
      }

      paymentController.openCheckout(
        customerName: userDetails['name']!,
        customerEmail: userDetails['email']!,
        customerPhone: userDetails['phone']!,
        amount: (totalAmount * 100).toInt(), // Convert to paise
        description: "Document Payment: $documentType",
      );
    } catch (e) {
      print('❌ Error proceeding to document payment: $e');
      SnackBarHelper.showError("Failed to proceed with payment. Please try again.");
    }
  }
  Future<Map<String, String>> _getUserDetails() async {
    try {
      // Check if user is logged in
      final isLoggedIn = await SessionManager.isLoggedIn();
      if (!isLoggedIn) {
        SnackBarHelper.showError("Please login to make payments");
        Get.offAllNamed('/login');
        throw Exception('User not logged in');
      }

      // Get user data from SessionManager
      final userData = await SessionManager.getUserData();
      if (userData == null) {
        SnackBarHelper.showError("Session expired. Please login again.");
        await SessionManager.clearSession();
        Get.offAllNamed('/login');
        throw Exception('User data not found');
      }

      // Get token for verification
      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        SnackBarHelper.showError("Session invalid. Please login again.");
        await SessionManager.clearSession();
        Get.offAllNamed('/login');
        throw Exception('Token not found');
      }

      // Construct name from first and last name
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

      // If there's an error, try to get minimal user info from prefs
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
        // Return default values as last resort
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

  @override
  void onClose() {
    _clearDetailData();
    super.onClose();
  }
}