import 'package:get/get.dart';
import '../../../common/api_constant.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/toster.dart';
import '../model/syndicate_model.dart';

class SyndicatePlotController extends GetxController {
  var isLoading = false.obs;
  var isLoadMore = false.obs;
  var syndicatePlots = <SyndicatePlot>[].obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var hasMoreData = true.obs;
  var totalItems = 0.obs;
  var searchQuery = ''.obs;
  var selectedCity = ''.obs;
  var selectedState = ''.obs;
  var minPrice = ''.obs;
  var maxPrice = ''.obs;
  var syndicateDetail = Rxn<SyndicateDetail>();
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSyndicatePlots();
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
      refresh();
    }
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


  Future<void> fetchSyndicateDetail(int id) async {
    try {
      isLoading(true); // Use isLoadingDetail instead of isLoading
      errorMessage('');

      final url = '${ApiUrl.syndicateDetails}/$id';
      print('🌐 Fetching Syndicate Detail URL: $url');

      final response = await ApiService.getRequest(url);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          syndicateDetail.value = SyndicateDetail.fromJson(responseData['data']);
          print('✅ Fetched syndicate detail: ${syndicateDetail.value?.name}');
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
      isLoading(false); // Use isLoadingDetail instead of isLoading
      refresh(); // Add this to refresh the GetBuilder
    }
  }

 void clearData() {
    syndicateDetail.value = null;
    errorMessage('');
  }
  @override
  void onClose() {
    clearData();
    super.onClose();
  }
}

