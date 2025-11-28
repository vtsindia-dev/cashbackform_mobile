import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/api_constant.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/toster.dart';
import '../model/gioo_plot.dart';
class GiooPlotController extends GetxController {
  var isLoading = false.obs;
  var isLoadMore = false.obs;
  var giooPlots = <GiooPlot>[].obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var hasMoreData = true.obs;
  var totalItems = 0.obs;
  var searchQuery = ''.obs;
  var selectedCity = ''.obs;
  var selectedState = ''.obs;
  var minPrice = ''.obs;
  var maxPrice = ''.obs;
  var isLoadingDetail = false.obs;
  var giooPlotDetail = Rxn<GiooPlotDetail>();
  var errorMessage = ''.obs;
  var isExpanded = false.obs;
  var isDescriptionExpanded = false.obs;
  var selectedStatsType = "Weekly".obs;
  RxInt get selectedCount => units.where((u) => u.status == 'Selected').length.obs;
  RxInt get bookedCount => units.where((u) => u.status == 'Booked').length.obs;
  RxInt get availableCount => units.where((u) => u.status == 'Available').length.obs;
  void toggleExpansion() => isExpanded.value = !isExpanded.value;
  void toggleDescription() => isDescriptionExpanded.value = !isDescriptionExpanded.value;
  final List<String> unitRanges = [
    "1-50", "50-100", "150-200", "250-300",
    "350-400","450-500","550-600","650-700",

  ];

  var weeklyProfit = 5000.obs;
  var weeklyProfitPercent = 30.obs; // 30%
  final RxList<double> bookedValues = <double>[].obs;
  final RxList<double> availableValues = <double>[].obs;
  var overallProfit = 5000.obs;
  var overallProfitPercent = 50.obs; // 50%
  final List<double> _weeklyBooked = [60, 80, 65, 78, 40, 75, 58, 79, 38, 38, 62, 72];
  final List<double> _weeklyAvailable = [15, 18, 15, 15, 20, 14, 12, 18, 18, 12, 20, 18];

  // Monthly Data (Different values to show filtering works)
  final List<double> _monthlyBooked = [40, 50, 45, 60, 30, 50, 40, 60, 30, 20, 50, 60];
  final List<double> _monthlyAvailable = [30, 20, 30, 20, 40, 20, 30, 15, 40, 50, 20, 15];



  var units = <PlotUnit>[].obs;
  var selectedUnits = <int>[].obs;
  var approvedDate = "24 Dec 2024".obs;
  var totalSelectedAreaSqft = 0.0.obs;
  var totalPriceUnits = 0.0.obs;
  var totalFinalPrice = 0.0.obs;
  var pricePerSqft = 1000.0.obs; // Default price per sqft
  @override
  void onInit() {
    super.onInit();
    fetchGiooPlots();
    updateStats("Weekly");
    generateDummyUnits();

  }
  void updateStats(String type) {
    selectedStatsType.value = type;

    if (type == "Weekly") {
      bookedValues.value = _weeklyBooked;
      availableValues.value = _weeklyAvailable;
      weeklyProfit.value = 5000;
      weeklyProfitPercent.value = 30;
      overallProfit.value = 5000;
      overallProfitPercent.value = 50;
    } else {
      // Monthly Data Simulation
      bookedValues.value = _monthlyBooked;
      availableValues.value = _monthlyAvailable;
      weeklyProfit.value = 12500; // Different value
      weeklyProfitPercent.value = 45;
      overallProfit.value = 18000;
      overallProfitPercent.value = 62;
    }
  }
  // Fetch Gioo Plots List
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
        if (responseData != null &&
            responseData['data'] != null &&
            responseData['data']['geo'] != null) {

          final giooData = responseData['data']['geo'];
          final paginationData = responseData['data']['pagination'];

          if (loadMore) {
            giooPlots.addAll(_parseGiooPlots(giooData));
          } else {
            giooPlots.assignAll(_parseGiooPlots(giooData));
          }
          currentPage.value = paginationData['current_page'] ?? 1;
          totalPages.value = paginationData['last_page'] ?? 1;
          totalItems.value = paginationData['total'] ?? 0;
          hasMoreData.value = currentPage.value < totalPages.value;

          print('✅ Fetched ${giooPlots.length} Gioo plots');
          print('📄 Current page: $currentPage, Total pages: $totalPages, Total items: $totalItems');

        } else {
          SnackBarHelper.showError("Invalid response format from server");
          print('❌ Invalid response format: $responseData');
        }
      } else if (response.statusCode == 404) {
        SnackBarHelper.showError("Gioo plots not found");
        print('❌ 404 Error: ${response.data}');
      } else {
        final errorMessage = response.data?['message'] ?? 'Failed to fetch Gioo plots';
        SnackBarHelper.showError("Error $errorMessage");
        print('❌ API Error ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      SnackBarHelper.showError("Network error: $e");
      print('❌ Network error: $e');
    } finally {
      isLoading(false);
      isLoadMore(false);
      refresh();
    }
  }

  // Fetch Gioo Plot Detail
  Future<void> fetchGiooPlotDetail(int id) async {
    try {
      _clearDetailData();

      isLoadingDetail(true);
      errorMessage('');

      final url = '${ApiUrl.giooDetails}/$id';
      print('🌐 Fetching Gioo Plot Detail URL: $url');
      final response = await ApiService.getRequest(url);
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          giooPlotDetail.value = GiooPlotDetail.fromJson(responseData['data']);
          print('✅ Fetched Gioo plot detail: ${giooPlotDetail.value?.name}');
          _logPlotDetailInfo();
        } else {
          errorMessage('Invalid response format from server');
          SnackBarHelper.showError("Invalid response format");
          print('❌ Invalid response format: $responseData');
        }
      } else if (response.statusCode == 404) {
        errorMessage('Gioo plot details not found');
        SnackBarHelper.showError("Gioo plot details not found");
        print('❌ 404 Error: ${response.data}');
      } else {
        final errorMsg = response.data?['message'] ?? 'Failed to fetch Gioo plot details';
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
  void _clearDetailData() {
    giooPlotDetail.value = null;
    errorMessage('');
  }
  void _logPlotDetailInfo() {
    final detail = giooPlotDetail.value;
    if (detail != null) {
      print('📊 Plot Name: ${detail.name}');
      print('📍 Address: ${detail.address}');
      print('🏙️ City: ${detail.city?.cityName}');
      print('🏛️ State: ${detail.state?.stateName}');
      print('💰 Price: ${detail.price}');
      print('📏 Area: ${detail.area}');
      print('🔢 Unit Split: ${detail.unitSpilt}');
      print('🖼️ Images: ${detail.image.length}');
      print('📄 Documents: ${detail.documents.length}');
      print('🛠️ Work: ${detail.work}');
      print('👨‍💼 Agent ID: ${detail.agentId}');
      print('🔢 ULD No: ${detail.uldNo}');
    }
  }

  // Get formatted address
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

  // Get formatted price
  String getFormattedPrice() {
    final detail = giooPlotDetail.value;
    if (detail?.price == null) return 'Price not available';

    try {
      final price = double.tryParse(detail!.price);
      if (price != null) {
        return '₹${price.toStringAsFixed(2)}';
      }
    } catch (e) {
      print('Error formatting price: $e');
    }

    return '₹${detail?.price??''}';
  }

  // Get first image or placeholder
  String getPrimaryImage() {
    final detail = giooPlotDetail.value;
    if (detail?.image != null && detail!.image.isNotEmpty) {
      return detail.image.first;
    }
    return detail?.plotImage ?? '';
  }

  // Get all images including plot image
  List<String> getAllImages() {
    final detail = giooPlotDetail.value;
    final List<String> allImages = [];

    if (detail?.plotImage != null && detail!.plotImage.isNotEmpty) {
      allImages.add(detail.plotImage);
    }

    if (detail?.image != null && detail!.image.isNotEmpty) {
      allImages.addAll(detail.image);
    }

    return allImages.toSet().toList(); // Remove duplicates
  }

  // Existing methods for list functionality
  Future<void> loadMore() async {
    if (!isLoadMore.value && hasMoreData.value) {
      currentPage.value++;
      await fetchGiooPlots(loadMore: true);
    }
  }

  Future<void> refreshData() async {
    await fetchGiooPlots();
  }

  Future<void> searchPlots(String query) async {
    searchQuery.value = query;
    await fetchGiooPlots();
  }

  Future<void> filterByCity(String city) async {
    selectedCity.value = city;
    await fetchGiooPlots();
  }

  Future<void> filterByState(String state) async {
    selectedState.value = state;
    await fetchGiooPlots();
  }

  Future<void> filterByPrice(String min, String max) async {
    minPrice.value = min;
    maxPrice.value = max;
    await fetchGiooPlots();
  }

  Future<void> clearFilters() async {
    searchQuery.value = '';
    selectedCity.value = '';
    selectedState.value = '';
    minPrice.value = '';
    maxPrice.value = '';
    await fetchGiooPlots();
  }

  List<String> getAvailableCities() {
    return giooPlots
        .map((plot) => plot.city?.cityName ?? '')
        .where((city) => city.isNotEmpty)
        .toSet()
        .toList();
  }

  List<String> getAvailableStates() {
    return giooPlots
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
  void generateDummyUnits() {
    final List<PlotUnit> dummyUnits = [];

    // Generate 196 units (14x14 grid)
    for (int i = 1; i <= 196; i++) {
      // Create some booked units randomly (about 30% booked)
      final bool isBooked = i % 3 == 0 || i % 7 == 0;
      final status = isBooked ? 'Booked' : 'Available';

      dummyUnits.add(PlotUnit(
        id: i,
        label: i.toString(),
        status: status,
        area: 100.0, // Each unit is 100 sqft
      ));
    }

    units.value = dummyUnits;
  }

  void toggleUnitSelection(int unitId) {
    final unitIndex = units.indexWhere((unit) => unit.id == unitId);
    if (unitIndex == -1) return;

    final unit = units[unitIndex];

    if (unit.status == 'Booked') return;

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

    totalSelectedAreaSqft.value = selectedUnitList.fold(0.0, (sum, unit) => sum + unit.area);
    totalPriceUnits.value = totalSelectedAreaSqft.value * pricePerSqft.value;
    totalFinalPrice.value = totalPriceUnits.value; // You can add taxes/discounts here
  }

  String getSelectedUnitRange() {
    if (selectedUnits.isEmpty) return "No units selected";

    final sortedUnits = List.from(selectedUnits)..sort();
    if (sortedUnits.length == 1) {
      return "Unit ${sortedUnits.first}";
    } else {
      return "Units ${sortedUnits.first}-${sortedUnits.last}";
    }
  }

  String formatCurrency(double amount) {
    return "₹ ${amount.toStringAsFixed(2)}";
  }

  void setPlotDetail(GiooPlotDetail detail) {
    giooPlotDetail.value = detail;
    // Update price per sqft from actual plot data if available
    if (detail.price != null && detail.price!.isNotEmpty) {
      pricePerSqft.value = double.tryParse(detail.price!) ?? 1000.0;
    }
  }

  void proceedToPayment() {
    if (selectedUnits.isEmpty) {
      Get.snackbar(
        "No Units Selected",
        "Please select at least one plot unit",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // TODO: Implement actual payment integration
    print("Proceeding to payment for units: $selectedUnits");
    print("Total amount: ${formatCurrency(totalFinalPrice.value)}");

    Get.snackbar(
      "Payment Initiated",
      "Redirecting to payment gateway...",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  @override
  void onClose() {
    _clearDetailData();
    super.onClose();
  }
}


class PlotUnit {
  final int id;
  final String label;
  final String status;
  final double area;

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