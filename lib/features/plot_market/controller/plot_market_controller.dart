import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/api_constant.dart';
import '../../../common/colours.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';
import '../../payment/controller/razorpay_controller.dart';
import '../model/plot_market.dart';
import '../screens/add_plot.dart';

class PlotMarketController extends GetxController {
  var isLoading = false.obs;
  var isLoadMore = false.obs;
  var isLoadingDetail = false.obs;
  var marketPlots = <MarketPlot>[].obs;
  var marketDetail = Rxn<MarketPlotDetail>();

  // Pagination
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var hasMoreData = true.obs;
  var totalItems = 0.obs;

  // Filters
  var searchQuery = ''.obs;
  var selectedCity = Rxn<City>();
  var selectedState = Rxn<AppState>();
  var selectedPlotTypes = <PropertyType>[].obs;
  var minPrice = ''.obs;
  var maxPrice = ''.obs;
  var minAreaSqft = ''.obs;
  var maxAreaSqft = ''.obs;

  // Filter data from API
  var states = <AppState>[].obs;
  var cities = <City>[].obs;
  var plotTypes = <PropertyType>[].obs;

  // Dynamic price ranges - These will be updated from API response
  var priceMin = 0.0.obs;
  var priceMax = 10000000.0.obs;
  var areaMin = 0.0.obs;
  var areaMax = 10000.0.obs;

  // Other
  var errorMessage = ''.obs;
  var isExpanded = true.obs;
  var verificationAmount = 499.0.obs; // Default value

  // UI State
  var isEnquiryLoading = false.obs;
  var enquiryCount = 0.obs;
  var message = ''.obs;
  final TextEditingController searchController = TextEditingController();
  var recentSearch = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMarketPlots();
    // Note: We don't need fetchFilterData() initially since plot types come with market plots
  }

  // Fetch filter data (states only, plot types come from market plot response)
  Future<void> fetchFilterData() async {
    try {
      // Fetch states
      final statesResponse = await ApiService.getRequest(ApiUrl.states);
      if (statesResponse.statusCode == 200) {
        final statesData = statesResponse.data;
        if (statesData['data'] != null && statesData['data'] is List) {
          states.value = (statesData['data'] as List)
              .map((item) => AppState.fromJson(item))
              .toList();
          print('✅ Loaded ${states.length} states');
        }
      }

      // Note: Plot types will be loaded from market plot response in fetchMarketPlots()
    } catch (e) {
      print('❌ Error fetching filter data: $e');
    }
  }

  // Fetch cities for selected state
  Future<void> fetchCitiesForState(int stateId) async {
    try {
      final url = '${ApiUrl.cities}/$stateId';
      final response = await ApiService.getRequest(url);
      if (response.statusCode == 200) {
        final citiesData = response.data;
        if (citiesData['data'] != null && citiesData['data'] is List) {
          cities.value = (citiesData['data'] as List)
              .map((item) => City.fromJson(item))
              .toList();
          print('✅ Loaded ${cities.length} cities for state $stateId');
        }
      }
    } catch (e) {
      print('❌ Error fetching cities: $e');
    }
  }

  // When state changes, fetch its cities
  void onStateChanged(AppState? state) {
    selectedState.value = state;
    selectedCity.value = null; // Reset city when state changes
    cities.clear(); // Clear previous cities

    if (state != null) {
      fetchCitiesForState(state.id);
    }
  }

  void toggleExpansion() => isExpanded.value = !isExpanded.value;

  Future<void> sendEnquiry() async {
    isEnquiryLoading.value = true;
    final token = await SessionManager.getToken();
    try {
      final response = await dio.Dio().post(
        ApiUrl.sendMarketEnquiry,
        options: dio.Options(
          headers: {
            "Accept": "application/json",
            if (token != null && token.isNotEmpty)
              "Authorization": "Bearer $token",
          },
        ),
      );

      final data = response.data;

      if (response.statusCode == 200 && data['status'] == true) {
        enquiryCount.value = data['counts'];
        message.value = data['message'];

        Get.snackbar(
          'Success',
          "Enquiry Submitted successfully",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Error',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          data['message'] ?? 'Something went wrong',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } on dio.DioException catch (e) {
      Get.snackbar(
        'Network Error',
        e.response?.data['message'] ?? e.message ?? 'Request failed',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isEnquiryLoading.value = false;
    }
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
      print('🌐 Fetching URL: $url');

      final response = await ApiService.getRequest(url);
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null &&
            responseData['data'] != null &&
            responseData['data']['market'] != null) {

          final marketData = responseData['data']['market'];
          final paginationData = responseData['data']['pagination'];

          // Parse market plots
          if (loadMore) {
            marketPlots.addAll(_parseMarketPlots(marketData));
          } else {
            marketPlots.assignAll(_parseMarketPlots(marketData));
          }

          // IMPORTANT: Extract plot types from the response
          if (!loadMore && responseData['data']['property_type'] != null) {
            final propertyTypesData = responseData['data']['property_type'];
            if (propertyTypesData is List) {
              plotTypes.value = (propertyTypesData as List)
                  .map((item) => PropertyType.fromJson(item))
                  .toList();
              print('✅ Loaded ${plotTypes.length} plot types from market response');
            }
          }

          // Extract dynamic ranges from response if available
          _extractDynamicRanges(responseData['data']);

          currentPage.value = paginationData['current_page'] ?? 1;
          totalPages.value = paginationData['last_page'] ?? 1;
          totalItems.value = paginationData['total'] ?? 0;
          hasMoreData.value = currentPage.value < totalPages.value;

          print('✅ Fetched ${marketPlots.length} market plots');
          print('📄 Current page: $currentPage, Total pages: $totalPages, Total items: $totalItems');
          print('💰 Price range: ₹$priceMin - ₹$priceMax');
          print('📏 Area range: ${areaMin.value} - ${areaMax.value} sqft');
          print('🏠 Plot types available: ${plotTypes.length}');

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

  void _extractDynamicRanges(Map<String, dynamic>? data) {
    try {
      if (data != null) {
        // Extract price ranges
        if (data['price_min'] != null) {
          priceMin.value = double.tryParse(data['price_min'].toString()) ?? 0.0;
          print('💰 Extracted price_min from API: ${priceMin.value}');
        }
        if (data['price_max'] != null) {
          priceMax.value = double.tryParse(data['price_max'].toString()) ?? 10000000.0;
          print('💰 Extracted price_max from API: ${priceMax.value}');
        }

        // Extract area ranges - Note: your JSON shows "sqft_min" and "sqft_max"
        if (data['sqft_min'] != null) {
          areaMin.value = double.tryParse(data['sqft_min'].toString()) ?? 0.0;
          print('📏 Extracted sqft_min from API: ${areaMin.value}');
        }
        if (data['sqft_max'] != null) {
          areaMax.value = double.tryParse(data['sqft_max'].toString()) ?? 10000.0;
          print('📏 Extracted sqft_max from API: ${areaMax.value}');
        }

        // Also check for area_min and area_max as fallback
        if (data['area_min'] != null && areaMin.value == 0.0) {
          areaMin.value = double.tryParse(data['area_min'].toString()) ?? 0.0;
          print('📏 Extracted area_min from API: ${areaMin.value}');
        }
        if (data['area_max'] != null && areaMax.value == 10000.0) {
          areaMax.value = double.tryParse(data['area_max'].toString()) ?? 10000.0;
          print('📏 Extracted area_max from API: ${areaMax.value}');
        }
      }
    } catch (e) {
      print('❌ Error extracting dynamic ranges: $e');
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

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  void applySearch() {
    if (searchQuery.value.trim().isEmpty) return;
    recentSearch.value = searchQuery.value.trim();
    fetchMarketPlots();
  }

  void clearRecentSearch() {
    recentSearch.value = '';
    searchQuery.value = '';
    searchController.clear();
    fetchMarketPlots();
  }

  void togglePlotTypeSelection(PropertyType plotType) {
    if (selectedPlotTypes.contains(plotType)) {
      selectedPlotTypes.remove(plotType);
    } else {
      selectedPlotTypes.add(plotType);
    }
  }

  // Check if any filters are applied
  bool hasFiltersApplied() {
    return searchQuery.value.isNotEmpty ||
        selectedState.value != null ||
        selectedCity.value != null ||
        selectedPlotTypes.isNotEmpty ||
        minPrice.value.isNotEmpty ||
        maxPrice.value.isNotEmpty ||
        minAreaSqft.value.isNotEmpty ||
        maxAreaSqft.value.isNotEmpty;
  }

  // Get active filter count for UI
  int getActiveFilterCount() {
    int count = selectedPlotTypes.length;
    if (searchQuery.value.isNotEmpty) count++;
    if (selectedState.value != null) count++;
    if (selectedCity.value != null) count++;
    if (minPrice.value.isNotEmpty || maxPrice.value.isNotEmpty) count++;
    if (minAreaSqft.value.isNotEmpty || maxAreaSqft.value.isNotEmpty) count++;
    return count;
  }

  // Clear all filters
  Future<void> clearFilters() async {
    searchQuery.value = '';
    selectedState.value = null;
    selectedCity.value = null;
    selectedPlotTypes.clear();
    minPrice.value = '';
    maxPrice.value = '';
    minAreaSqft.value = '';
    maxAreaSqft.value = '';
    searchController.clear();
    cities.clear();
    await fetchMarketPlots();
  }

  String _buildQueryParams() {
    final params = <String>[];

    // Search
    if (searchQuery.value.isNotEmpty) {
      params.add('search=${Uri.encodeComponent(searchQuery.value)}');
    }

    // State
    if (selectedState.value != null) {
      params.add('state=${selectedState.value!.id}');
    }

    // City
    if (selectedCity.value != null) {
      params.add('city=${selectedCity.value!.id}');
    }

    // Plot Types
    if (selectedPlotTypes.isNotEmpty) {
      final typeIds = selectedPlotTypes.map((type) => type.id).toList();
      params.add('plot_type=${typeIds.join(',')}');
    }

    // Price Range
    if (minPrice.value.isNotEmpty) {
      params.add('min_price=${Uri.encodeComponent(minPrice.value)}');
    }
    if (maxPrice.value.isNotEmpty) {
      params.add('max_price=${Uri.encodeComponent(maxPrice.value)}');
    }

    // Area Range
    if (minAreaSqft.value.isNotEmpty) {
      params.add('area_sqft_min=${Uri.encodeComponent(minAreaSqft.value)}');
    }
    if (maxAreaSqft.value.isNotEmpty) {
      params.add('area_sqft_max=${Uri.encodeComponent(maxAreaSqft.value)}');
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
      print('🌐 Response status code: ${response.headers}');
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
        print('Form Data : $formDataToSend');
        print('🌐 Response status code: ${response.headers}');
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

  // Fetch verification amount from API (NOTE: your model has "verfication" not "verification")
  Future<double> _fetchVerificationAmount() async {
    try {
      print('🌐 Fetching verification amount...');

      // Since your MarketPlot model has "verfication" field, we'll use that
      // Check if any plot has a verification fee set
      for (var plot in marketPlots) {
        if (plot.verfication != null && plot.verfication! > 0) {
          verificationAmount.value = plot.verfication!.toDouble();
          print('✅ Found verification amount in plot data: ₹${verificationAmount.value}');
          return verificationAmount.value;
        }
      }

      // If not found in plot data, try to fetch from API
      final url = '${ApiUrl.baseUrl}verification-fee'; // Make sure this endpoint exists
      print('🌐 Trying to fetch verification amount from: $url');

      try {
        final response = await ApiService.getRequest(url);

        if (response.statusCode == 200) {
          final responseData = response.data;

          if (responseData['status'] == true) {
            double amount = 499.0; // Default fallback

            if (responseData['data'] != null) {
              final data = responseData['data'];

              // Check for different possible field names
              if (data['verification_fee'] != null) {
                amount = double.tryParse(data['verification_fee'].toString()) ?? 499.0;
                print('✅ Got verification amount from API: ₹$amount');
              }
              else if (data['verfication_fee'] != null) { // Note the spelling
                amount = double.tryParse(data['verfication_fee'].toString()) ?? 499.0;
                print('✅ Got verification amount from API (verfication_fee): ₹$amount');
              }
              else if (data['amount'] != null) {
                amount = double.tryParse(data['amount'].toString()) ?? 499.0;
                print('✅ Got verification amount from API (amount): ₹$amount');
              }
              else if (data['fee'] != null) {
                amount = double.tryParse(data['fee'].toString()) ?? 499.0;
                print('✅ Got verification amount from API (fee): ₹$amount');
              }
              else if (data['verification_amount'] != null) {
                amount = double.tryParse(data['verification_amount'].toString()) ?? 499.0;
                print('✅ Got verification amount from API (verification_amount): ₹$amount');
              }
              else {
                print('⚠️ No verification amount found in API response');
              }
            }
            else if (responseData['verification_fee'] != null) {
              amount = double.tryParse(responseData['verification_fee'].toString()) ?? 499.0;
              print('✅ Got verification amount from root level: ₹$amount');
            }
            else {
              print('⚠️ API response data is null');
            }

            verificationAmount.value = amount;
            return amount;
          } else {
            print('❌ API returned false status: ${responseData['message']}');
            return verificationAmount.value;
          }
        } else {
          print('❌ Failed to fetch verification amount. Status: ${response.statusCode}');
          return verificationAmount.value;
        }
      } catch (apiError) {
        print('❌ Error calling verification API: $apiError');
        return verificationAmount.value;
      }
    } catch (e) {
      print('❌ Error in _fetchVerificationAmount: $e');
      return verificationAmount.value;
    }
  }

  Future<void> initiateVerificationPayment(MarketPlot plot) async {
    try {
      final razorpayController = Get.put(RazorpayController());

      // Check verification status
      if (plot.verifyStatus == 1) {
        Get.snackbar(
          "Already Verified",
          "This plot is already verified!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return;
      }

      // Get verification amount (try multiple sources)
      double amountToCharge = 499.0; // Default

      // 1. Try from plot's verfication field (note the spelling)
      if (plot.verfication != null && plot.verfication! > 0) {
        amountToCharge = plot.verfication!.toDouble();
        print('💰 Using plot-specific verification fee (verfication field): ₹$amountToCharge');
      }
      // 2. Try from fetched API amount
      else if (verificationAmount.value > 0) {
        amountToCharge = verificationAmount.value;
        print('💰 Using pre-fetched verification amount: ₹$amountToCharge');
      }
      // 3. Try to fetch fresh from API
      else {
        amountToCharge = await _fetchVerificationAmount();
        print('💰 Using freshly fetched verification amount: ₹$amountToCharge');
      }

      // Setup verification payment
      razorpayController.setupMarketVerificationPayment(
        marketPlotId: plot.id,
        amount: amountToCharge,
        propertyName: plot.name,
      );

      // Show verification payment dialog with dynamic amount
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(Icons.verified, color: Colors.blue, size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                "Verify Your Plot",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Verify your plot to enhance visibility and trust:",
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
              ),

              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plot.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      plot.location,
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBenefitItem("✓ Enhanced visibility in search"),
                  _buildBenefitItem("✓ Trust badge on listing"),
                  _buildBenefitItem("✓ Priority customer support"),
                  _buildBenefitItem("✓ Increased buyer confidence"),
                ],
              ),

              SizedBox(height: 16.h),

              // Price - Dynamic amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Verification Fee:",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "₹${amountToCharge.toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Terms checkbox
              Obx(() => Row(
                children: [
                  Checkbox(
                    value: razorpayController.isTermsAccepted.value,
                    onChanged: (value) {
                      razorpayController.toggleTerms();
                    },
                    activeColor: Colors.blue,
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showTermsDialog(),
                      child: Text.rich(
                        TextSpan(
                          text: "I agree to the ",
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                          children: [
                            TextSpan(
                              text: "terms and conditions",
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (!razorpayController.isTermsAccepted.value) {
                  Get.snackbar(
                    "Terms Required",
                    "Please accept terms and conditions",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                Get.back();
                razorpayController.initiatePayment();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text("Proceed to Pay"),
            ),
          ],
        ),
      );
    } catch (e) {
      print("❌ Error initiating verification payment: $e");
      Get.snackbar(
        "Error",
        "Failed to initiate verification: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle, size: 16.sp, color: Colors.green),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 12.sp),
              ),
            ),
          ],
        )
    );
  }





  void _showTermsDialog() {
    Get.dialog(
      AlertDialog(
        title: Text("Terms and Conditions"),
        content: SingleChildScrollView(
          child: Text(
                "1. Verification fee is non-refundable.\n"
                "2. Verification process takes 2-3 business days.\n"
                "3. We verify plot details, documents, and ownership.\n"
                "4. Verified status can be revoked if false information is provided.\n"
                "5. All documents must be authentic and valid.",
            style: TextStyle(fontSize: 12.sp),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text("Close"),
          ),
        ],
      ),
    );
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