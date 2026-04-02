import 'dart:convert';
import 'dart:io';
import 'package:cashback_farms/features/plot_market/model/common_facility_model.dart';
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
import '../../menu/controller/dashboard_menu_controller.dart';
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
  var isCityLoading = false.obs;

  // Filters
  var searchQuery = ''.obs;
  var selectedCity = Rxn<City>();
  var selectedState = Rxn<AppState>();
  var selectedPlotTypes = <PropertyType>[].obs;
  var minPrice = ''.obs;
  var maxPrice = ''.obs;
  var minAreaSqft = ''.obs;
  var maxAreaSqft = ''.obs;
  var myMarketPlots = <MarketPlot>[].obs;
  var selectedTabIndex = 0.obs; // 0 = All Plots, 1 = My Plots
  var isLoadingMyPlots = false.obs;
  var myCurrentPage = 1.obs;
  var myTotalPages = 1.obs;
  var hasMoreMyPlots = true.obs;
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
  var amenities = <dynamic>[].obs;
  var nearbyPlaces = <dynamic>[].obs;
  // UI State
  var isEnquiryLoading = false.obs;
  var enquiryCount = 0.obs;
  var message = ''.obs;
  final TextEditingController searchController = TextEditingController();
  var recentSearch = ''.obs;
  var isLoadMoreMyPlots = false.obs;
  var myHasMoreData = true.obs;
  var myTotalItems = 0.obs;

  // Add these Rx variables to your controller class
  RxList<MarketPlotEnquiry> marketPlotEnquiries = <MarketPlotEnquiry>[].obs;
  RxBool isLoadingMarketEnquiries = false.obs;
  RxInt marketEnquiryCurrentPage = 1.obs;
  RxInt marketEnquiryTotalPages = 1.obs;
  RxBool hasMoreMarketEnquiries = true.obs;
  RxInt totalMarketEnquiries = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMarketPlots();
    fetchStates();
    getCommonFacility();
  }

  void toggleExpansion() => isExpanded.value = !isExpanded.value;


  var getCommonFacilityModel = <CommonFacilityModel>[].obs;

  List<int> selectedFacilityIds = [];

  void toggleFacility(int id) {
    if (selectedFacilityIds.contains(id)) {
      selectedFacilityIds.remove(id);
    } else {
      selectedFacilityIds.add(id);
    }
    update();
  }

  Future<void> getCommonFacility() async {
    final token = await SessionManager.getToken();
    try {
      final response = await dio.Dio().get(
        ApiUrl.commonFacilities,
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
        final facility = data['data'] as List;
        getCommonFacilityModel.assignAll(
          facility.map((e) => CommonFacilityModel.fromJson(e)).toList(),
        );
      } else {
        debugPrint('Something went wrong');
      }
    } catch (e) {
      debugPrint('Error :: $e');
    }
  }



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

        // Updated snackbar
        SnackBarHelper.showSuccess("Enquiry Submitted successfully");
      } else {
        // Updated snackbar
        SnackBarHelper.showError(data['message'] ?? 'Something went wrong');
      }
    } on dio.DioException catch (e) {
      // Updated snackbar
      SnackBarHelper.showError(e.response?.data['message'] ?? e.message ?? 'Request failed');
    } catch (e) {
      // Updated snackbar
      SnackBarHelper.showError(e.toString());
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
        print('📦 Full Response: ${responseData.toString()}'); // Debug print

        if (responseData != null && responseData['data'] != null) {
          try {
            marketDetail.value = MarketPlotDetail.fromJson(responseData['data']);
            print('✅ Fetched market plot detail: ${marketDetail.value?.name}');
            _logDetailInfo();
          } catch (e, stackTrace) {
            print('❌ Error parsing market plot detail: $e');
            print('❌ Stack trace: $stackTrace');
            errorMessage('Error parsing data: $e');
            SnackBarHelper.showError("Error parsing plot details");
          }
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
    } catch (e, stackTrace) {
      print('❌ Network error: $e');
      print('❌ Stack trace: $stackTrace');
      errorMessage('Network error: $e');
      SnackBarHelper.showError("Network error: $e");
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
      print('   Amenities: ${detail.amenities?.length}');
      print('   Documents: ${detail.documents.length}');
      print('   Units: ${detail.unitSplit}');
    }
  }

  Future<void> viewDocument(int documentId) async {
    try {
      final token = await SessionManager.getToken();

      // Find the document in the current detail
      final document = marketDetail.value?.documents?.firstWhere(
            (doc) => doc.id == documentId,
        orElse: () => Document(
          id: 0,
          propertyId: 0,
          file: '',
          type: '',
          docType: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          downloadUrl: '',
        ),
      );

      if (document!.downloadUrl.isEmpty) {
        SnackBarHelper.showError("Document URL not available");
        return;
      }

      // Just launch the URL in browser
      await _launchUrl(document.downloadUrl, token ?? '');

    } catch (e) {
      SnackBarHelper.showError("Failed to open document: $e");
    }
  }
  Future<void> downloadDocument(int documentId) async {
    try {
      final token = await SessionManager.getToken();

      // Find the document in the current detail
      final document = marketDetail.value?.documents?.firstWhere(
            (doc) => doc.id == documentId,
        orElse: () => Document(
          id: 0,
          propertyId: 0,
          file: '',
          type: '',
          docType: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          downloadUrl: '',
        ),
      );

      if (document!.downloadUrl.isEmpty) {
        SnackBarHelper.showError("Download URL not available");
        return;
      }

      // Show loading dialog
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: AppColor.primary),
        ),
        barrierDismissible: false,
      );

      // Just launch the URL in browser
      final success = await _launchUrl(document.downloadUrl, token ?? '');

      Get.back();

      if (success) {
        SnackBarHelper.showSuccess("Opening document in browser...");
      }
    } catch (e) {
      Get.back();
      SnackBarHelper.showError("Failed to open document: $e");
    }
  }

  Future<bool> _launchUrl(String url, String token) async {
    try {
      final uri = Uri.parse(url);

      // Add authorization token if available
      final headers = {
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

      // For webview or browser, we can't directly add headers
      // So we'll just open the URL directly
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        return true;
      } else {
        SnackBarHelper.showError("Could not launch URL: $url");
        return false;
      }
    } catch (e) {
      rethrow;
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
  int getActiveFilterCount() {
    int count = selectedPlotTypes.length;
    if (searchQuery.value.isNotEmpty) count++;
    if (selectedState.value != null) count++;
    if (selectedCity.value != null) count++;
    if (minPrice.value.isNotEmpty || maxPrice.value.isNotEmpty) count++;
    if (minAreaSqft.value.isNotEmpty || maxAreaSqft.value.isNotEmpty) count++;
    return count;
  }
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
  Future<Map<String, dynamic>> submitMarketPlot({
    required Map<String, dynamic> formData,
    List<File> images = const [],
    File? plotImage,
    File? bluePrint,
    File? threeDImage,
    List<int>? selectedFacilityIds,
    bool isUpdate = false,
  }) async {
    try {
      isLoading(true);
      final formDataToSend = dio.FormData();

      print('📤 Preparing form data...');

      // Handle all form fields
      formData.forEach((key, value) {
        if (value != null) {
          // Handle nearby places - send as JSON string
          if (key == 'nearby' && value is List) {
            print('📍 Processing nearby places: $value');
            // Send as JSON string
            final nearbyJson = jsonEncode(value);
            formDataToSend.fields.add(MapEntry(
              'nearby',
              nearbyJson,
            ));
            print('   Added nearby as JSON: $nearbyJson');
          }
          // Handle amenities list
          else if (key == 'amenities' && value is List) {
            final amenitiesStr = value.map((e) => e.toString()).join(',');
            formDataToSend.fields.add(MapEntry(key, amenitiesStr));
            print('   Added amenities: $amenitiesStr');
          }
          // Handle regular fields
          else {
            formDataToSend.fields.add(MapEntry(key, value.toString()));
            print('   Added $key: $value');
          }
        }
      });

      if(selectedFacilityIds !=null && selectedFacilityIds.isNotEmpty){
        for (var facility in selectedFacilityIds) {
          formDataToSend.fields.add(
            MapEntry('commonfacility[]', facility.toString()),
          );
        }
      }

      // Add user ID (make sure this is included)
      final userId = await SessionManager.getUserId();
      if (userId != null) {
        formDataToSend.fields.add(MapEntry('user_id', userId.toString()));
        print('   Added user_id: $userId');
      }

      // Add images
      for (int i = 0; i < images.length; i++) {
        formDataToSend.files.add(MapEntry(
          'plot_image',
          await dio.MultipartFile.fromFile(
            images[i].path,
            filename: 'image_$i.jpg',
          ),
        ));
        print('📸 Added image ${i + 1}: ${images[i].path}');
      }

      if (threeDImage != null) {
        formDataToSend.files.add(MapEntry(
          'three_d_image',
          await dio.MultipartFile.fromFile(
            threeDImage.path,
            filename: 'three_d_image.jpg',
          ),
        ));
      }

      // Add plot image
      if (plotImage != null) {
        formDataToSend.files.add(MapEntry(
          'image[]',
          await dio.MultipartFile.fromFile(
            plotImage.path,
            filename: 'plot_image.jpg',
          ),
        ));
        print('📸 Added plot image: ${plotImage.path}');
      }

      print('📦 FORM DATA FIELDS');
      for (var field in formDataToSend.fields) {
        print('${field.key}: ${field.value}');
      }

      print('📦 FORM DATA FILES');
      for (var file in formDataToSend.files) {
        print('${file.key}: ${file.value.filename}');
      }

      final token = await SessionManager.getToken();
      print('🔑 Using token: ${token != null ? "YES" : "NO"}');
      final url = isUpdate ? ApiUrl.marketPlotEdit : ApiUrl.marketPlotAdd;
      print('🌐 ${isUpdate ? 'Updating' : 'Adding'} market plot: $url');

      final dioInstance = dio.Dio();
      final response = await dioInstance.post(
        url,
        data: formDataToSend,
        options: dio.Options(
          headers: {
            "Accept": "application/json",
            "Content-Type": "multipart/form-data",
            if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
          },
          sendTimeout: const Duration(seconds: 50),
          receiveTimeout: const Duration(seconds: 50),
        ),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('✅ ${isUpdate ? 'Updated' : 'Added'} market plot successfully');
        await fetchMarketPlots();
        Navigator.pop(Get.context!);
        return {
          'status': 200,
          'message': responseData['message'] ?? 'Success',
          'data': responseData['data'],
        };
      } else {
        print('❌ Error response: ${response.data}');
        final errorMsg = response.data?['message'] ??
            response.data?['error'] ??
            'Failed to ${isUpdate ? 'update' : 'add'} market plot';

        // Check for validation errors
        if (response.data?['errors'] != null) {
          final errors = response.data?['errors'];
          print('❌ Validation errors: $errors');
        }

        return {
          'status': response.statusCode ?? 500,
          'message': errorMsg,
          'errors': response.data?['errors'],
        };
      }
    } on dio.DioException catch (e) {
      print('❌ Dio Exception: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      print('❌ Error type: ${e.type}');

      String errorMessage = 'Network error';
      if (e.response?.data?['message'] != null) {
        errorMessage = e.response!.data!['message'];
      } else if (e.message != null) {
        errorMessage = e.message!;
      }

      return {
        'status': e.response?.statusCode ?? 500,
        'message': errorMessage,
        'errors': e.response?.data?['errors'],
      };
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

  Future<void> initiateVerificationPayment(MarketPlot plot) async {
    try {
      final razorpayController = Get.put(RazorpayController());
      final dashboardController = Get.put(DashboardController());

      // --- LOGIC SECTION (Keep your existing logic for amount calculation) ---
      if (plot.verifyStatus == 1) {
        Get.snackbar("Already Verified", "This plot is already verified!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
        return;
      }

      double amountToCharge = 499.0;
      final businessSettings = dashboardController.businessSettings.value;

      if (businessSettings?.marketPlotVerifyAmount != null && businessSettings!.marketPlotVerifyAmount! > 0) {
        amountToCharge = businessSettings.marketPlotVerifyAmount!;
      } else if (plot.verification != null && plot.verification! > 0) {
        amountToCharge = plot.verification!.toDouble();
      }

      razorpayController.setupMarketVerificationPayment(
        marketPlotId: plot.id,
        amount: amountToCharge,
        propertyName: plot.name,
      );

      // --- UPDATED DESIGN SECTION ---
      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.05),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.verified_user_rounded, color: AppColor.primary, size: 22.sp),
                ),
                SizedBox(width: 12.w),
                Text(
                  "Verify Your Plot",
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColor.primary,
                  ),
                ),
              ],
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Get a verified badge and increase your buyer's trust instantly.",
                style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 16.h),

              // Selected Property Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plot.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      plot.location,
                      maxLines: 1,
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Benefits List
              _buildBenefitItem("Higher search ranking"),
              _buildBenefitItem("Official verification badge"),
              _buildBenefitItem("Verified seller protection"),

              SizedBox(height: 20.h),

              // Price Section
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColor.primary.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Amount", style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)),
                    Text(
                      "₹${amountToCharge.toStringAsFixed(0)}",
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: AppColor.primary),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // Terms
              Obx(() => InkWell(
                onTap: () => razorpayController.toggleTerms(),
                child: Row(
                  children: [
                    SizedBox(
                      height: 24.w,
                      width: 24.w,
                      child: Checkbox(
                        value: razorpayController.isTermsAccepted.value,
                        onChanged: (v) => razorpayController.toggleTerms(),
                        activeColor: AppColor.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        "I accept the terms & conditions",
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
          actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),

          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: Text("Later", style: TextStyle(color: Colors.grey[600],fontSize: 15.w)),
                  ),
                ),
                SizedBox(width: 5.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!razorpayController.isTermsAccepted.value) {
                        Get.snackbar("Required", "Please accept terms", backgroundColor: Colors.red, colorText: Colors.white);
                        return;
                      }
                      Get.back();
                      razorpayController.initiatePayment();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: Text("Proceed", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      // Error handling remains same
    }
  }

// Updated Helper Widget
  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColor.primary, size: 14.sp),
          SizedBox(width: 8.w),
          Text(text, style: TextStyle(fontSize: 12.sp, color: Colors.black87)),
        ],
      ),
    );
  }


  void openAddForm() {
    Get.to(() => MarketPlotForm());
  }


  Future<void> fetchAmenities() async {
    try {
      final response = await ApiService.getRequest('${ApiUrl.baseUrl}/api/v2/amenities');
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == 200 && responseData['data'] != null && responseData['data']['amenities'] != null) {
          amenities.value = responseData['data']['amenities'];
          print('✅ Loaded ${amenities.length} amenities');
        }
      }
    } catch (e) {
      print('❌ Error fetching amenities: $e');
    }
  }

  Future<void> fetchNearbyPlaces() async {
    try {
      final response = await ApiService.getRequest('${ApiUrl.baseUrl}/api/v2/nearby_place');
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == 200 && responseData['data'] != null && responseData['data']['nearby_places'] != null) {
          nearbyPlaces.value = responseData['data']['nearby_places'];
          print('✅ Loaded ${nearbyPlaces.length} nearby places');
        }
      }
    } catch (e) {
      print('❌ Error fetching nearby places: $e');
    }
  }

  Future<void> fetchPropertyTypes() async {
    try {
      final response = await ApiService.getRequest('${ApiUrl.baseUrl}/api/v2/property_category');
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == 200 && responseData['data'] != null) {
          plotTypes.assignAll((responseData['data'] as List)
              .map((item) => PropertyType(
            id: item['id'] ?? 0,
            categoryName: item['category_name'] ?? '',
            status: item['status'] ?? 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ))
              .toList());
          print('✅ Loaded ${plotTypes.length} property types');
        }
      }
    } catch (e) {
      print('   $e');
    }
  }

  Future<void> fetchStates() async {
    try {
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
    } catch (e) {
      print('❌ Error fetching states: $e');
    }
  }

  Future<void> fetchCitiesForState(int stateId) async {
    try {
      isCityLoading.value = true;
      cities.clear();

      final url = '${ApiUrl.cities}/$stateId';
      final response = await ApiService.getRequest(url);

      if (response.statusCode == 200) {
        final citiesData = response.data;

        if (citiesData['data'] != null && citiesData['data'] is List) {
          cities.assignAll(
            (citiesData['data'] as List)
                .map((item) => City.fromJson(item))
                .toList(),
          );

          print('✅ Loaded ${cities.length} cities for state $stateId');
        }
      }
    } catch (e) {
      print('❌ Error fetching cities: $e');
      cities.clear();
    } finally {
      isCityLoading.value = false;
    }
  }

  void onStateChanged(AppState? state) async {
    selectedState.value = state;
    selectedCity.value = null;
    cities.clear();

    if (state != null) {
      await fetchCitiesForState(state.id);
    }
  }
  Future<void> fetchMyMarketPlots({bool loadMore = false}) async {
    try {
      if (loadMore) {
        isLoadMoreMyPlots(true);
      } else {
        isLoadingMyPlots(true);
        myCurrentPage.value = 1;
        myHasMoreData.value = true;
        myMarketPlots.clear();
      }

      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        SnackBarHelper.showError("Please login to view your properties");
        isLoadingMyPlots(false);
        isLoadMoreMyPlots(false);
        return;
      }

      final url = '${ApiUrl.myMarketPlots}?page_no=${myCurrentPage.value}';
      print('🌐 Fetching My Plots URL: $url');
      final response = await dio.Dio().get(
        url,
        options: dio.Options(
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",

          },
        ),
      );

      print('📥 My Plots Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('🔍 Response type: ${responseData.runtimeType}');
        print('🔍 Response keys: ${responseData is Map ? responseData.keys.toList() : 'Not a map'}');
        if (responseData != null && responseData is Map) {
          List<dynamic> marketDataList = [];
          if (responseData['data'] != null && responseData['data'] is List) {
            print('✅ Found data in "data" key as List');
            marketDataList = responseData['data'];
          }
          else if (responseData['market'] != null && responseData['market'] is List) {
            print('✅ Found data in "market" key as List');
            marketDataList = responseData['market'];
          }
          else {
            print('❌ No list data found in response');
            SnackBarHelper.showError("No properties found");
          }

          // Parse the market plots
          List<MarketPlot> parsedPlots = [];
          try {
            parsedPlots = marketDataList.map((item) {
              try {
                if (item is Map<String, dynamic>) {
                  return MarketPlot.fromJson(item);
                } else {
                  print('⚠️ Item is not a Map: ${item.runtimeType}');
                  throw FormatException('Invalid item type');
                }
              } catch (e, stackTrace) {
                print('❌ Error parsing individual plot: $e');
                print('❌ Stack trace: $stackTrace');
                print('❌ Problematic item: $item');
                // Return a placeholder or skip this item
                rethrow;
              }
            }).toList();

            print('✅ Successfully parsed ${parsedPlots.length} plots');

          } catch (parseError) {
            print('❌ Error parsing market plots: $parseError');
            SnackBarHelper.showError("Error parsing property data");
          }

          if (loadMore) {
            myMarketPlots.addAll(parsedPlots);
          } else {
            myMarketPlots.assignAll(parsedPlots);
          }
          myTotalItems.value = myMarketPlots.length;
          print('✅ Total my plots loaded: ${myMarketPlots.length}');
        } else {
          print('❌ Response data is null or not a Map');
          SnackBarHelper.showError("Invalid response from server");
        }
      } else if (response.statusCode == 401) {
        print('❌ Unauthorized - Token invalid');
        SnackBarHelper.showError("Session expired. Please login again");
      } else if (response.statusCode == 404) {
        print('❌ Endpoint not found');
        SnackBarHelper.showError("Service temporarily unavailable");
      } else {
        final errorMessage = response.data?['message'] ??
            response.data?['error'] ??
            'Failed to fetch your properties';
        print('❌ API Error: $errorMessage');
        SnackBarHelper.showError(errorMessage);
      }
    } catch (e, stackTrace) {
      print('❌ Exception in fetchMyMarketPlots: $e');
      print('❌ Stack trace: $stackTrace');
      print('❌ Error type: ${e.runtimeType}');

      // More specific error messages
      if (e is TypeError) {
        SnackBarHelper.showError("Data format error. Please try again.");
      } else if (e is FormatException) {
        SnackBarHelper.showError("Invalid data received from server.");
      } else {
        SnackBarHelper.showError("Error loading your properties: ${e.toString().split('\n').first}");
      }
    } finally {
      isLoadingMyPlots(false);
      isLoadMoreMyPlots(false);
    }
  }
  Future<void> loadMoreMyPlots() async {
    if (!isLoadMoreMyPlots.value && myHasMoreData.value) {
      myCurrentPage.value++;
      await fetchMyMarketPlots(loadMore: true);
    }
  }

  // Refresh My Plots
  Future<void> refreshMyPlots() async {
    await fetchMyMarketPlots();
  }
  Future<void> fetchMarketPlotEnquiries({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        isLoadingMarketEnquiries.value = true;
        marketEnquiryCurrentPage.value = 1;
        marketPlotEnquiries.clear();
      }

      // Get token using SessionManager
      final token = await SessionManager.getToken();

      if (token == null || token.isEmpty) {
        Get.snackbar(
          'Authentication Required',
          'Please login to view your enquiries',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        isLoadingMarketEnquiries.value = false;
        return;
      }

      final dioInstance = dio.Dio();
      final response = await dioInstance.get(
        '${ApiUrl.baseUrl}/api/v2/market_enquiry_list',
        options: dio.Options(
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
        queryParameters: {
          'page': marketEnquiryCurrentPage.value,
        },
      );

      print('🌐 Market Enquiry Response Status: ${response.statusCode}');
      print('🌐 Market Enquiry URL: ${response.requestOptions.uri}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;

        if (responseData['status'] == 200 || responseData['status'] == true) {
          final data = responseData['data'] ?? {};
          final List<dynamic> materialData = data['material'] ?? [];

          print('📦 Raw material data: $materialData');
          print('📦 Material data type: ${materialData.runtimeType}');
          print('📦 Material count: ${materialData.length}');

          // Parse enquiries
          final List<MarketPlotEnquiry> newEnquiries = [];
          for (var enquiryData in materialData) {
            try {
              print('🔍 Parsing enquiry: $enquiryData');
              final enquiry = MarketPlotEnquiry.fromJson(enquiryData);
              newEnquiries.add(enquiry);
              print('✅ Parsed enquiry ID: ${enquiry.id}');
            } catch (e, stackTrace) {
              print('❌ Error parsing enquiry: $e');
              print('❌ Stack trace: $stackTrace');
              print('❌ Problematic data: $enquiryData');
            }
          }

          if (loadMore) {
            marketPlotEnquiries.addAll(newEnquiries);
          } else {
            marketPlotEnquiries.assignAll(newEnquiries);
          }

          // Update pagination
          final pagination = data['pagination'] ?? {};
          marketEnquiryCurrentPage.value = pagination['current_page'] ?? 1;
          marketEnquiryTotalPages.value = pagination['last_page'] ?? 1;
          totalMarketEnquiries.value = pagination['total'] ?? 0;
          hasMoreMarketEnquiries.value = marketEnquiryCurrentPage.value < marketEnquiryTotalPages.value;

          print('✅ Fetched ${marketPlotEnquiries.length} market plot enquiries');
          print('📊 Pagination: Current ${marketEnquiryCurrentPage.value}, Total ${marketEnquiryTotalPages.value}');
          print('📊 Has property: ${marketPlotEnquiries.where((e) => e.property != null).length}');
          print('📊 Without property: ${marketPlotEnquiries.where((e) => e.property == null).length}');

        } else {
          throw Exception('API returned error status: ${responseData['status']}');
        }
      } else {
        throw Exception('Failed to load market enquiries: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      print('❌ Dio Error fetching market enquiries: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      print('❌ Error type: ${e.type}');

      if (e.response?.statusCode == 401) {
        Get.snackbar(
          'Session Expired',
          'Please login again',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else if (e.response?.statusCode == 404) {
        Get.snackbar(
          'Endpoint Not Found',
          'Market enquiry endpoint not available',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          'Network Error',
          'Unable to fetch market enquiries. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching market enquiries: $e');
      print('❌ Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to load market enquiries: ${e.toString().split('\n').first}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoadingMarketEnquiries.value = false;
    }
  }

  Future<void> loadMoreMarketEnquiries() async {
    if (!isLoadingMarketEnquiries.value &&
        hasMoreMarketEnquiries.value &&
        marketEnquiryCurrentPage.value < marketEnquiryTotalPages.value) {
      marketEnquiryCurrentPage.value++;
      await fetchMarketPlotEnquiries(loadMore: true);
    }
  }

  Future<void> refreshMarketEnquiries() async {
    await fetchMarketPlotEnquiries();
  }

// Clear market enquiries
  void clearMarketEnquiries() {
    marketPlotEnquiries.clear();
    marketEnquiryCurrentPage.value = 1;
    marketEnquiryTotalPages.value = 1;
    totalMarketEnquiries.value = 0;
    hasMoreMarketEnquiries.value = true;
  }

// Get enquiry by ID
  MarketPlotEnquiry? getMarketEnquiryById(int id) {
    try {
      return marketPlotEnquiries.firstWhere((enquiry) => enquiry.id == id);
    } catch (e) {
      return null;
    }
  }

// Get total enquiry count
  int getTotalMarketEnquiries() {
    return marketPlotEnquiries.length;
  }

// Get enquiries with property
  List<MarketPlotEnquiry> getEnquiriesWithProperty() {
    return marketPlotEnquiries.where((enquiry) => enquiry.property != null).toList();
  }

// Get enquiries without property
  List<MarketPlotEnquiry> getEnquiriesWithoutProperty() {
    return marketPlotEnquiries.where((enquiry) => enquiry.property == null).toList();
  }
  @override
  void onClose() {
    _clearDetailData();
    super.onClose();
  }
}