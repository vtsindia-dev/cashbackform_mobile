import 'dart:async';
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
  var selectedTabIndex = 0.obs;
  var isLoadingMyPlots = false.obs;
  var myCurrentPage = 1.obs;
  var myTotalPages = 1.obs;
  var hasMoreMyPlots = true.obs;

  // Filter data from API
  var states = <AppState>[].obs;
  var cities = <City>[].obs;
  var plotTypes = <PropertyType>[].obs;

  // Dynamic price ranges
  var priceMin = 0.0.obs;
  var priceMax = 10000000.0.obs;
  var areaMin = 0.0.obs;
  var areaMax = 10000.0.obs;

  // Other
  var errorMessage = ''.obs;
  var isExpanded = true.obs;
  var verificationAmount = 499.0.obs;
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

  // Market enquiries
  RxList<MarketPlotEnquiry> marketPlotEnquiries = <MarketPlotEnquiry>[].obs;
  RxBool isLoadingMarketEnquiries = false.obs;
  RxInt marketEnquiryCurrentPage = 1.obs;
  RxInt marketEnquiryTotalPages = 1.obs;
  RxBool hasMoreMarketEnquiries = true.obs;
  RxInt totalMarketEnquiries = 0.obs;

  // ── Autocomplete / debounce ──────────────────────────────────────────────
  Timer? _searchDebounce;

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
        SnackBarHelper.showSuccess("Enquiry Submitted successfully");
      } else {
        SnackBarHelper.showError(data['message'] ?? 'Something went wrong');
      }
    } on dio.DioException catch (e) {
      SnackBarHelper.showError(
          e.response?.data['message'] ?? e.message ?? 'Request failed');
    } catch (e) {
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
        print('📦 Full Response: ${responseData.toString()}');

        if (responseData != null && responseData['data'] != null) {
          try {
            marketDetail.value =
                MarketPlotDetail.fromJson(responseData['data']);
            print(
                '✅ Fetched market plot detail: ${marketDetail.value?.name}');
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
        final errorMsg = response.data?['message'] ??
            'Failed to fetch market plot details';
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

      await _launchUrl(document.downloadUrl, token ?? '');
    } catch (e) {
      SnackBarHelper.showError("Failed to open document: $e");
    }
  }

  Future<void> downloadDocument(int documentId) async {
    try {
      final token = await SessionManager.getToken();

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

      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: AppColor.primary),
        ),
        barrierDismissible: false,
      );

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
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
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

      final url =
          '${ApiUrl.marketPlotList}?page_no=${currentPage.value}${_buildQueryParams()}';
      print('🌐 Fetching URL: $url');

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

          if (!loadMore && responseData['data']['property_type'] != null) {
            final propertyTypesData = responseData['data']['property_type'];
            if (propertyTypesData is List) {
              plotTypes.value = (propertyTypesData as List)
                  .map((item) => PropertyType.fromJson(item))
                  .toList();
              print(
                  '✅ Loaded ${plotTypes.length} plot types from market response');
            }
          }

          _extractDynamicRanges(responseData['data']);

          currentPage.value = paginationData['current_page'] ?? 1;
          totalPages.value = paginationData['last_page'] ?? 1;
          totalItems.value = paginationData['total'] ?? 0;
          hasMoreData.value = currentPage.value < totalPages.value;

          print('✅ Fetched ${marketPlots.length} market plots');
        } else {
          SnackBarHelper.showError("Invalid response format from server");
        }
      } else if (response.statusCode == 404) {
        SnackBarHelper.showError("Market plots not found");
      } else {
        final errorMessage =
            response.data?['message'] ?? 'Failed to fetch market plots';
        SnackBarHelper.showError("Error $errorMessage");
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

  // ── Silent background search (no loading indicator) ──────────────────────
  void onSearchChanged(String value) {
    searchQuery.value = value;

    // Cancel any previous pending timer
    _searchDebounce?.cancel();

    // If field is cleared, reload immediately without filters
    if (value.trim().isEmpty) {
      fetchMarketPlots();
      return;
    }

    // Wait 300 ms after the user stops typing, then silently fetch
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _silentSearch();
    });
  }

  Future<void> _silentSearch() async {
    try {
      final url =
          '${ApiUrl.marketPlotList}?page_no=1${_buildQueryParams()}';
      print('🔍 Silent search URL: $url');

      final response = await ApiService.getRequest(url);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData?['data']?['market'] != null) {
          final marketData = responseData['data']['market'];
          final paginationData = responseData['data']['pagination'];

          marketPlots.assignAll(_parseMarketPlots(marketData));

          // Reset pagination to match the new filtered set
          currentPage.value = paginationData['current_page'] ?? 1;
          totalPages.value = paginationData['last_page'] ?? 1;
          totalItems.value = paginationData['total'] ?? 0;
          hasMoreData.value = currentPage.value < totalPages.value;

          print(
              '✅ Silent search returned ${marketPlots.length} results');
        }
      }
    } catch (_) {
      // Fail silently — user may still be typing
    }
  }
  // ─────────────────────────────────────────────────────────────────────────

  void _extractDynamicRanges(Map<String, dynamic>? data) {
    try {
      if (data != null) {
        if (data['price_min'] != null) {
          priceMin.value =
              double.tryParse(data['price_min'].toString()) ?? 0.0;
        }
        if (data['price_max'] != null) {
          priceMax.value =
              double.tryParse(data['price_max'].toString()) ?? 10000000.0;
        }
        if (data['sqft_min'] != null) {
          areaMin.value =
              double.tryParse(data['sqft_min'].toString()) ?? 0.0;
        }
        if (data['sqft_max'] != null) {
          areaMax.value =
              double.tryParse(data['sqft_max'].toString()) ?? 10000.0;
        }
        if (data['area_min'] != null && areaMin.value == 0.0) {
          areaMin.value =
              double.tryParse(data['area_min'].toString()) ?? 0.0;
        }
        if (data['area_max'] != null && areaMax.value == 10000.0) {
          areaMax.value =
              double.tryParse(data['area_max'].toString()) ?? 10000.0;
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

  void applySearch() {
    if (searchQuery.value.trim().isEmpty) return;
    recentSearch.value = searchQuery.value.trim();
    fetchMarketPlots();
  }

  void clearRecentSearch() {
    recentSearch.value = '';
    searchQuery.value = '';
    searchController.clear();
    _searchDebounce?.cancel();
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
    _searchDebounce?.cancel();
    await fetchMarketPlots();
  }

  String _buildQueryParams() {
    final params = <String>[];

    if (searchQuery.value.isNotEmpty) {
      params.add('search=${Uri.encodeComponent(searchQuery.value)}');
    }
    if (selectedState.value != null) {
      params.add('state=${selectedState.value!.id}');
    }
    if (selectedCity.value != null) {
      params.add('city=${selectedCity.value!.id}');
    }
    if (selectedPlotTypes.isNotEmpty) {
      final typeIds = selectedPlotTypes.map((type) => type.id).toList();
      params.add('plot_type=${typeIds.join(',')}');
    }
    if (minPrice.value.isNotEmpty) {
      params.add('min_price=${Uri.encodeComponent(minPrice.value)}');
    }
    if (maxPrice.value.isNotEmpty) {
      params.add('max_price=${Uri.encodeComponent(maxPrice.value)}');
    }
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

      formData.forEach((key, value) {
        if (value != null) {
          if (key == 'nearby' && value is List) {
            final nearbyJson = jsonEncode(value);
            formDataToSend.fields.add(MapEntry('nearby', nearbyJson));
          } else if (key == 'amenities' && value is List) {
            final amenitiesStr = value.map((e) => e.toString()).join(',');
            formDataToSend.fields.add(MapEntry(key, amenitiesStr));
          } else {
            formDataToSend.fields.add(MapEntry(key, value.toString()));
          }
        }
      });

      if (selectedFacilityIds != null && selectedFacilityIds.isNotEmpty) {
        for (var facility in selectedFacilityIds) {
          formDataToSend.fields
              .add(MapEntry('commonfacility[]', facility.toString()));
        }
      }

      final userId = await SessionManager.getUserId();
      if (userId != null) {
        formDataToSend.fields.add(MapEntry('user_id', userId.toString()));
      }

      for (int i = 0; i < images.length; i++) {
        formDataToSend.files.add(MapEntry(
          'plot_image',
          await dio.MultipartFile.fromFile(images[i].path,
              filename: 'image_$i.jpg'),
        ));
      }

      if (threeDImage != null) {
        formDataToSend.files.add(MapEntry(
          'three_d_image',
          await dio.MultipartFile.fromFile(threeDImage.path,
              filename: 'three_d_image.jpg'),
        ));
      }

      if (plotImage != null) {
        formDataToSend.files.add(MapEntry(
          'image[]',
          await dio.MultipartFile.fromFile(plotImage.path,
              filename: 'plot_image.jpg'),
        ));
      }

      final token = await SessionManager.getToken();
      final url =
      isUpdate ? ApiUrl.marketPlotEdit : ApiUrl.marketPlotAdd;

      final dioInstance = dio.Dio();
      final response = await dioInstance.post(
        url,
        data: formDataToSend,
        options: dio.Options(
          headers: {
            "Accept": "application/json",
            "Content-Type": "multipart/form-data",
            if (token != null && token.isNotEmpty)
              "Authorization": "Bearer $token",
          },
          sendTimeout: const Duration(seconds: 50),
          receiveTimeout: const Duration(seconds: 50),
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        await fetchMarketPlots();
        Navigator.pop(Get.context!);
        return {
          'status': 200,
          'message': responseData['message'] ?? 'Success',
          'data': responseData['data'],
        };
      } else {
        final errorMsg = response.data?['message'] ??
            response.data?['error'] ??
            'Failed to ${isUpdate ? 'update' : 'add'} market plot';
        return {
          'status': response.statusCode ?? 500,
          'message': errorMsg,
          'errors': response.data?['errors'],
        };
      }
    } on dio.DioException catch (e) {
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
      final response = await dio.Dio().delete(url);
      if (response.statusCode == 200) {
        marketPlots.removeWhere((plot) => plot.id == id);
        refresh();
        return true;
      } else {
        final errorMsg =
            response.data?['message'] ?? 'Failed to delete market plot';
        SnackBarHelper.showError(errorMsg);
        return false;
      }
    } catch (e) {
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

      if (plot.verifyStatus == 1) {
        Get.snackbar("Already Verified", "This plot is already verified!",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white);
        return;
      }

      double amountToCharge = 499.0;
      final businessSettings = dashboardController.businessSettings.value;

      if (businessSettings?.marketPlotVerifyAmount != null &&
          businessSettings!.marketPlotVerifyAmount! > 0) {
        amountToCharge = businessSettings.marketPlotVerifyAmount!;
      } else if (plot.verification != null && plot.verification! > 0) {
        amountToCharge = plot.verification!.toDouble();
      }

      razorpayController.setupMarketVerificationPayment(
        marketPlotId: plot.id,
        amount: amountToCharge,
        propertyName: plot.name,
      );

      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding:
            EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
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
                  child: Icon(Icons.verified_user_rounded,
                      color: AppColor.primary, size: 22.sp),
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
                      style: TextStyle(
                          fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      plot.location,
                      maxLines: 1,
                      style:
                      TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              _buildBenefitItem("Higher search ranking"),
              _buildBenefitItem("Official verification badge"),
              _buildBenefitItem("Verified seller protection"),
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 12.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(12.r),
                  border:
                  Border.all(color: AppColor.primary.withOpacity(0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Total Amount",
                        style: TextStyle(
                            fontSize: 13.sp, fontWeight: FontWeight.w500)),
                    Text(
                      "₹${amountToCharge.toStringAsFixed(0)}",
                      style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColor.primary),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r)),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        "I accept the terms & conditions",
                        style: TextStyle(
                            fontSize: 11.sp, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
          actionsPadding:
          EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: Text("Later",
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 15.w)),
                  ),
                ),
                SizedBox(width: 5.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!razorpayController.isTermsAccepted.value) {
                        Get.snackbar("Required", "Please accept terms",
                            backgroundColor: Colors.red,
                            colorText: Colors.white);
                        return;
                      }
                      Get.back();
                      razorpayController.initiatePayment();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: Text("Proceed",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      // Error handling
    }
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColor.primary, size: 14.sp),
          SizedBox(width: 8.w),
          Text(text,
              style: TextStyle(fontSize: 12.sp, color: Colors.black87)),
        ],
      ),
    );
  }

  void openAddForm() {
    Get.to(() => MarketPlotForm());
  }

  Future<void> fetchAmenities() async {
    try {
      final response = await ApiService.getRequest(
          '${ApiUrl.baseUrl}/api/v2/amenities');
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == 200 &&
            responseData['data'] != null &&
            responseData['data']['amenities'] != null) {
          amenities.value = responseData['data']['amenities'];
        }
      }
    } catch (e) {
      print('❌ Error fetching amenities: $e');
    }
  }

  Future<void> fetchNearbyPlaces() async {
    try {
      final response = await ApiService.getRequest(
          '${ApiUrl.baseUrl}/api/v2/nearby_place');
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == 200 &&
            responseData['data'] != null &&
            responseData['data']['nearby_places'] != null) {
          nearbyPlaces.value = responseData['data']['nearby_places'];
        }
      }
    } catch (e) {
      print('❌ Error fetching nearby places: $e');
    }
  }

  Future<void> fetchPropertyTypes() async {
    try {
      final response = await ApiService.getRequest(
          '${ApiUrl.baseUrl}/api/v2/property_category');
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
        }
      }
    } catch (e) {
      print('❌ Error fetching property types: $e');
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

      final url =
          '${ApiUrl.myMarketPlots}?page_no=${myCurrentPage.value}';
      final response = await dio.Dio().get(
        url,
        options: dio.Options(
          headers: {
            "Accept": "application/json",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null && responseData is Map) {
          List<dynamic> marketDataList = [];
          if (responseData['data'] != null &&
              responseData['data'] is List) {
            marketDataList = responseData['data'];
          } else if (responseData['market'] != null &&
              responseData['market'] is List) {
            marketDataList = responseData['market'];
          } else {
            SnackBarHelper.showError("No properties found");
          }

          List<MarketPlot> parsedPlots = [];
          try {
            parsedPlots = marketDataList.map((item) {
              if (item is Map<String, dynamic>) {
                return MarketPlot.fromJson(item);
              } else {
                throw FormatException('Invalid item type');
              }
            }).toList();
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
        } else {
          SnackBarHelper.showError("Invalid response from server");
        }
      } else if (response.statusCode == 401) {
        SnackBarHelper.showError("Session expired. Please login again");
      } else if (response.statusCode == 404) {
        SnackBarHelper.showError("Service temporarily unavailable");
      } else {
        final errorMessage = response.data?['message'] ??
            response.data?['error'] ??
            'Failed to fetch your properties';
        SnackBarHelper.showError(errorMessage);
      }
    } catch (e, stackTrace) {
      print('❌ Exception in fetchMyMarketPlots: $e');
      print('❌ Stack trace: $stackTrace');
      if (e is TypeError) {
        SnackBarHelper.showError("Data format error. Please try again.");
      } else if (e is FormatException) {
        SnackBarHelper.showError("Invalid data received from server.");
      } else {
        SnackBarHelper.showError(
            "Error loading your properties: ${e.toString().split('\n').first}");
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

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;

        if (responseData['status'] == 200 ||
            responseData['status'] == true) {
          final data = responseData['data'] ?? {};
          final List<dynamic> materialData = data['material'] ?? [];

          final List<MarketPlotEnquiry> newEnquiries = [];
          for (var enquiryData in materialData) {
            try {
              final enquiry = MarketPlotEnquiry.fromJson(enquiryData);
              newEnquiries.add(enquiry);
            } catch (e, stackTrace) {
              print('❌ Error parsing enquiry: $e');
              print('❌ Stack trace: $stackTrace');
            }
          }

          if (loadMore) {
            marketPlotEnquiries.addAll(newEnquiries);
          } else {
            marketPlotEnquiries.assignAll(newEnquiries);
          }

          final pagination = data['pagination'] ?? {};
          marketEnquiryCurrentPage.value =
              pagination['current_page'] ?? 1;
          marketEnquiryTotalPages.value = pagination['last_page'] ?? 1;
          totalMarketEnquiries.value = pagination['total'] ?? 0;
          hasMoreMarketEnquiries.value =
              marketEnquiryCurrentPage.value < marketEnquiryTotalPages.value;
        } else {
          throw Exception(
              'API returned error status: ${responseData['status']}');
        }
      } else {
        throw Exception(
            'Failed to load market enquiries: ${response.statusCode}');
      }
    } on dio.DioException catch (e) {
      print('❌ Dio Error fetching market enquiries: ${e.message}');
      if (e.response?.statusCode == 401) {
        Get.snackbar('Session Expired', 'Please login again',
            backgroundColor: Colors.red, colorText: Colors.white);
      } else if (e.response?.statusCode == 404) {
        Get.snackbar('Endpoint Not Found',
            'Market enquiry endpoint not available',
            backgroundColor: Colors.red, colorText: Colors.white);
      } else {
        Get.snackbar('Network Error',
            'Unable to fetch market enquiries. Please try again.',
            backgroundColor: Colors.red, colorText: Colors.white);
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

  void clearMarketEnquiries() {
    marketPlotEnquiries.clear();
    marketEnquiryCurrentPage.value = 1;
    marketEnquiryTotalPages.value = 1;
    totalMarketEnquiries.value = 0;
    hasMoreMarketEnquiries.value = true;
  }

  MarketPlotEnquiry? getMarketEnquiryById(int id) {
    try {
      return marketPlotEnquiries.firstWhere((enquiry) => enquiry.id == id);
    } catch (e) {
      return null;
    }
  }

  int getTotalMarketEnquiries() {
    return marketPlotEnquiries.length;
  }

  List<MarketPlotEnquiry> getEnquiriesWithProperty() {
    return marketPlotEnquiries
        .where((enquiry) => enquiry.property != null)
        .toList();
  }

  List<MarketPlotEnquiry> getEnquiriesWithoutProperty() {
    return marketPlotEnquiries
        .where((enquiry) => enquiry.property == null)
        .toList();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    _clearDetailData();
    super.onClose();
  }
}