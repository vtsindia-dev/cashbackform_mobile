import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/api_constant.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';
import '../model/plot_market.dart';
import '../screens/add_plot.dart';
class PlotMarketController extends GetxController {
  var isLoading = false.obs;
  var isLoadMore = false.obs;
  var isLoadingDetail = false.obs;
  var marketPlots = <MarketPlot>[].obs;
  var marketDetail = Rxn<MarketPlotDetail>();
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
  var isExpanded = true.obs;
  void toggleExpansion() => isExpanded.value = !isExpanded.value;

  @override
  void onInit() {
    super.onInit();
    fetchMarketPlots();
  }
  Future<void> fetchMarketPlotDetail(int id) async {
    try {
      _clearDetailData();
      isLoadingDetail(true);
      errorMessage('');
      final url = '${ApiUrl.marketDetails}/$id';
      print('🌐 Fetching Market Plot Detail URL: $url');
      final response = await ApiService.getRequest(url);
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          marketDetail.value = MarketPlotDetail.fromJson(responseData['data']);
          print('✅ Fetched market plot detail: ${marketDetail.value?.name}');
          _logDetailInfo();
        } else {
          errorMessage('Invalid response format from server');
          SnackBarHelper.showError("Invalid response format");
          print('❌ Invalid response format: $responseData');
        }
      } else if (response.statusCode == 404) {
        errorMessage('Market plot details not found');
        SnackBarHelper.showError("Market plot details not found");
        print('❌ 404 Error: ${response.data}');
      } else {
        final errorMsg = response.data?['message'] ?? 'Failed to fetch market plot details';
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
  void _clearDetailData() {
    marketDetail.value = null;
    errorMessage('');
  }
  void _logDetailInfo() {
    final detail = marketDetail.value;
    if (detail != null) {
      print('📊 Market Plot Details:');
      print('   Name: ${detail.name}');
      print('   Price: ${detail.formattedPrice}');
      print('   Location: ${detail.fullAddress}');
      print('   Verified: ${detail.isVerified}');
      print('   Amenities: ${detail.amenities.length}');
      print('   Documents: ${detail.documents.length}');
      print('   Units: ${detail.unitSpilt}');
    }
  }

  Future<void> viewDocument(int id) async {
    try {
      final apiDoc = marketDetail.value?.documents.firstWhere((d) => d.id == id);
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
      final apiDoc = marketDetail.value?.documents.firstWhere((d) => d.id == id);
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
  Future<void> fetchMarketPlots({bool loadMore = false}) async {
    try {
      if (loadMore) {
        isLoadMore(true);
      } else {
        isLoading(true);
        currentPage.value = 1;
        hasMoreData.value = true;
      }

      final url = '${ApiUrl.marketPlotList}?page_no=${currentPage.value}${_buildQueryParams()}';
      print('Fetching URL: $url');

      final response = await ApiService.getRequest(url);
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null &&
            responseData['data'] != null &&
            responseData['data']['market'] != null) {

          final marketData = responseData['data']['market'];
          final paginationData = responseData['data']['pagination'];

          if (loadMore) {
            marketPlots.addAll(_parseMarketPlots(marketData));
          } else {
            marketPlots.assignAll(_parseMarketPlots(marketData));
          }
          currentPage.value = paginationData['current_page'] ?? 1;
          totalPages.value = paginationData['last_page'] ?? 1;
          totalItems.value = paginationData['total'] ?? 0;
          hasMoreData.value = currentPage.value < totalPages.value;

          print('✅ Fetched ${marketPlots.length} market plots');
          print('📄 Current page: $currentPage, Total pages: $totalPages, Total items: $totalItems');

        } else {
          SnackBarHelper.showError("Invalid response format from server");
          print('❌ Invalid response format: $responseData');
        }
      } else if (response.statusCode == 404) {
        SnackBarHelper.showError("Market plots not found");
        print('❌ 404 Error: ${response.data}');
      } else {
        final errorMessage = response.data?['message'] ?? 'Failed to fetch market plots';
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
      await fetchMarketPlots(loadMore: true);
    }
  }

  Future<void> refreshData() async {
    await fetchMarketPlots();
  }

  Future<void> searchPlots(String query) async {
    searchQuery.value = query;
    await fetchMarketPlots();
  }

  Future<void> filterByCity(String city) async {
    selectedCity.value = city;
    await fetchMarketPlots();
  }

  Future<void> filterByState(String state) async {
    selectedState.value = state;
    await fetchMarketPlots();
  }

  Future<void> filterByPrice(String min, String max) async {
    minPrice.value = min;
    maxPrice.value = max;
    await fetchMarketPlots();
  }

  Future<void> clearFilters() async {
    searchQuery.value = '';
    selectedCity.value = '';
    selectedState.value = '';
    minPrice.value = '';
    maxPrice.value = '';
    await fetchMarketPlots();
  }

  List<String> getAvailableCities() {
    return marketPlots
        .map((plot) => plot.city?.cityName ?? '')
        .where((city) => city.isNotEmpty)
        .toSet()
        .toList();
  }

  List<String> getAvailableStates() {
    return marketPlots
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

  List<MarketPlot> _parseMarketPlots(List<dynamic> data) {
    return data.map((item) => MarketPlot.fromJson(item)).toList();
  }

  MarketPlot? getPlotById(int id) {
    try {
      return marketPlots.firstWhere((plot) => plot.id == id);
    } catch (e) {
      return null;
    }
  }

  bool isPlotFavorite(int plotId) {
    return false;
  }

  void toggleFavorite(int plotId) {
    print('Toggled favorite for market plot $plotId');
  }

  Future<Map<String, dynamic>> submitMarketPlot({
    required Map<String, dynamic> formData,
    List<File> images = const [],
    File? plotImage,
    File? bluePrint,
    bool isUpdate = false,
  }) async {
    try {
      isLoading(true);
      final formDataToSend = dio.FormData();
      formData.forEach((key, value) {
        if (value != null) {
          if (value is List) {
            formDataToSend.fields.add(MapEntry(key, value.join(',')));
          } else {
            formDataToSend.fields.add(MapEntry(key, value.toString()));
          }
        }
      });
      for (int i = 0; i < images.length; i++) {
        formDataToSend.files.add(
          MapEntry(
            'image[]',
            await dio.MultipartFile.fromFile(
              images[i].path,
              filename: 'image_$i.jpg',
            ),
          ),
        );
      }
      if (plotImage != null) {
        formDataToSend.files.add(
          MapEntry(
            'plot_image',
            await dio.MultipartFile.fromFile(
              plotImage.path,
              filename: 'plot_image.jpg',
            ),
          ),
        );
      }
      if (bluePrint != null) {
        formDataToSend.files.add(
          MapEntry(
            'blue_print',
            await dio.MultipartFile.fromFile(
              bluePrint.path,
              filename: 'blueprint.jpg',
            ),
          ),
        );
      }
      final token = await SessionManager.getToken();
      print('🔑 Using token: $token');
      final url = isUpdate ? ApiUrl.marketPlotEdit : ApiUrl.marketPlotAdd;
      print('🌐 ${isUpdate ? 'Updating' : 'Adding'} market plot: $url');
      final response = await dio.Dio().post(
        url,
        data: formDataToSend,
        options: dio.Options(
          headers: {
            "Accept": "application/json",
            "Content-Type": "multipart/form-data",
            if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
          },
        ),
      );
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response data: ${response.data}');
      if (response.statusCode == 200) {
        final responseData = response.data;
        print('✅ ${isUpdate ? 'Updated' : 'Added'} market plot successfully');
        await fetchMarketPlots();
        return {
          'status': 200,
          'message': responseData['message'] ?? 'Success',
          'data': responseData['data'],
        };
      } else {
        final errorMsg = response.data?['message'] ?? 'Failed to ${isUpdate ? 'update' : 'add'} market plot';
        print('❌ Error: $errorMsg');
        return {
          'status': response.statusCode ?? 500,
          'message': errorMsg,
        };
      }
    } catch (e, stackTrace) {
      print('❌ Exception: $e');
      print('❌ Stack trace: $stackTrace');
      return {
        'status': 500,
        'message': 'Network error: $e',
      };
    } finally {
      isLoading(false);
    }
  }
  Future<bool> deleteMarketPlot(int id) async {
    try {
      isLoading(true);
      final url = '${ApiUrl.marketPlotDelete}/$id';
      print('🌐 Deleting market plot: $url');
      final response = await dio.Dio().delete(url);
      if (response.statusCode == 200) {
        print('✅ Deleted market plot successfully');
        marketPlots.removeWhere((plot) => plot.id == id);
        refresh();
        return true;
      } else {
        final errorMsg = response.data?['message'] ?? 'Failed to delete market plot';
        print('❌ Error: $errorMsg');
        SnackBarHelper.showError(errorMsg);
        return false;
      }
    } catch (e) {
      print('❌ Exception: $e');
      SnackBarHelper.showError('Network error: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }
  void openEditForm(MarketPlot plot) {
    Get.to(() => MarketPlotForm(plot: plot));
  }

  void openAddForm() {
    Get.to(() => MarketPlotForm());
  }
  @override
  void onClose() {
    _clearDetailData();
    super.onClose();
  }
}