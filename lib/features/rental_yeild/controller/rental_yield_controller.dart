import 'dart:async';
import 'package:cashback_farms/common/api_constant.dart';
import 'package:cashback_farms/common/colours.dart';
import 'package:cashback_farms/features/menu/controller/dashboard_menu_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';
import '../../payment/controller/razorpay_controller.dart';
import '../model/rental_yeild_model.dart';

class RentalYieldController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<RentalEnquiry> rentalEnquiries = <RentalEnquiry>[].obs;
  RxInt enquiryCurrentPage = 1.obs;
  RxInt enquiryTotalPages = 1.obs;
  RxBool isLoadingEnquiries = false.obs;

  // API Configuration
  final String baseUrl = '${ApiUrl.baseUrl}/api/v2/';
  final Dio _dio = Dio(BaseOptions(
    baseUrl: '${ApiUrl.baseUrl}/api/v2/',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  TextEditingController searchController = TextEditingController();
  RxString searchQuery = ''.obs;
  Timer? _searchTimer;

  // Filters
  RxInt selectedStateId = 0.obs;
  RxInt selectedCityId = 0.obs;
  RxString selectedMinRent = ''.obs;
  RxString selectedMaxRent = ''.obs;
  RxString selectedMinYield = ''.obs;
  RxString selectedMaxYield = ''.obs;
  RxString selectedMinArea = ''.obs;
  RxString selectedMaxArea = ''.obs;
  RxString selectedFurnishingStatus = ''.obs;
  RxString selectedPropertyAge = ''.obs;
  RxInt selectedBedrooms = 0.obs;
  RxInt selectedPropertyTypeId = 0.obs;
  RxBool includeCommercial = false.obs;

  // Properties list
  RxList<RentalListProperty> properties = <RentalListProperty>[].obs;
  RxList<RentalListProperty> filteredProperties = <RentalListProperty>[].obs;

  // For details page
  Rx<RentalDetailProperty?> rentalDetail = Rx<RentalDetailProperty?>(null);
  RxBool isLoadingDetail = false.obs;

  // Static data from API
  RxList<StateModel> statesList = <StateModel>[].obs;
  RxList<CityModel> citiesList = <CityModel>[].obs;
  RxList<PropertyTypeModel> propertyTypes = <PropertyTypeModel>[].obs;

  // Range values from API
  RxDouble rentMin = 0.0.obs;
  RxDouble rentMax = 0.0.obs;
  RxDouble yieldMin = 0.0.obs;
  RxDouble yieldMax = 20.0.obs;
  RxInt sqftMin = 0.obs;
  RxInt sqftMax = 5000.obs;

  // Pagination
  RxInt currentPage = 1.obs;
  RxInt totalPages = 1.obs;
  RxBool hasMore = true.obs;
  RxInt totalItems = 0.obs;
  RxInt itemsPerPage = 10.obs;

  // Enquiry loading state
  RxBool isEnquiryLoading = false.obs;

  // Expansion state for property details
  RxBool isExpanded = true.obs;

  // Property details cache
  final Map<int, RentalDetailProperty> _propertyDetailsCache = {};

  // Terms acceptance state
  RxBool isTermsAccepted = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProperties();
  }

  @override
  void onClose() {
    searchController.dispose();
    _searchTimer?.cancel();
    super.onClose();
  }

  // Toggle terms acceptance
  void toggleTerms() => isTermsAccepted.value = !isTermsAccepted.value;

  // Search method for UI to call
  void onSearchChanged(String value) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      searchQuery.value = value;
      currentPage.value = 1;
      fetchProperties();
    });
  }

  // Fetch properties from API
  Future<void> fetchProperties({bool loadMore = false}) async {
    if (!loadMore) {
      isLoading.value = true;
      currentPage.value = 1;
      properties.clear();
      filteredProperties.clear();
    }

    try {
      final Map<String, dynamic> queryParams = {
        'page_no': currentPage.value,
      };

      if (searchQuery.value.isNotEmpty && searchQuery.value.trim().length >= 2) {
        queryParams['search'] = searchQuery.value.trim();
      }

      if (selectedStateId.value > 0) {
        queryParams['state_id'] = selectedStateId.value;
      }

      if (selectedCityId.value > 0) {
        queryParams['city_id'] = selectedCityId.value;
      }

      if (selectedMinRent.value.isNotEmpty) {
        queryParams['min_rent'] = selectedMinRent.value;
      }
      if (selectedMaxRent.value.isNotEmpty) {
        queryParams['max_rent'] = selectedMaxRent.value;
      }

      final response = await _dio.get(
        'rental',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final rentalListResponse = RentalListResponse.fromJson(response.data);
        final rentalListData = rentalListResponse.data;

        if (loadMore) {
          properties.addAll(rentalListData.rentals);
        } else {
          properties.assignAll(rentalListData.rentals);
        }

        final pagination = rentalListData.pagination;
        currentPage.value = pagination.currentPage;
        totalPages.value = pagination.lastPage;
        totalItems.value = pagination.total;
        itemsPerPage.value = pagination.perPage;
        hasMore.value = currentPage.value < totalPages.value;

        statesList.assignAll(rentalListData.stateList);
        rentMin.value = rentalListData.priceMin;
        rentMax.value = rentalListData.priceMax;

        _applyFilters();

        print('✅ Fetched ${properties.length} properties (Page $currentPage/$totalPages)');
      } else {
        throw Exception('Failed to load properties: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Dio Error fetching properties: $e');
      print('   Response: ${e.response?.data}');
      Get.snackbar(
        'Network Error',
        'Unable to connect to server. Please check your internet connection.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('❌ Error fetching properties: $e');
      Get.snackbar(
        'Error',
        'Failed to load properties. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch cities by state
  Future<void> fetchCitiesByState(int stateId) async {
    if (stateId <= 0) {
      citiesList.clear();
      return;
    }

    try {
      final response = await _dio.get(
        'cities',
        queryParameters: {'state_id': stateId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<CityModel> cities = [];

        for (var cityData in data) {
          try {
            cities.add(CityModel.fromJson(cityData));
          } catch (e) {
            print('Error parsing city: $e');
          }
        }

        citiesList.assignAll(cities);
        print('✅ Fetched ${cities.length} cities for state $stateId');
      } else {
        citiesList.clear();
        print('Failed to fetch cities: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Dio Error fetching cities: $e');
      citiesList.clear();
    } catch (e) {
      print('Error fetching cities: $e');
      citiesList.clear();
    }
  }

  // Apply filters to properties
  void _applyFilters() {
    if (properties.isEmpty) {
      filteredProperties.assignAll(properties);
      return;
    }

    List<RentalListProperty> result = List.from(properties);

    if (selectedStateId.value > 0) {
      result = result.where((property) {
        return property.state?.id == selectedStateId.value;
      }).toList();
    }

    if (selectedCityId.value > 0) {
      result = result.where((property) {
        return property.city?.id == selectedCityId.value;
      }).toList();
    }

    if (selectedMinRent.value.isNotEmpty) {
      try {
        double minRent = double.parse(selectedMinRent.value);
        result = result.where((property) => property.rentAmountDouble >= minRent).toList();
      } catch (e) {
        print('Error parsing min rent filter: $e');
      }
    }

    if (selectedMaxRent.value.isNotEmpty) {
      try {
        double maxRent = double.parse(selectedMaxRent.value);
        result = result.where((property) => property.rentAmountDouble <= maxRent).toList();
      } catch (e) {
        print('Error parsing max rent filter: $e');
      }
    }

    if (selectedMinYield.value.isNotEmpty) {
      try {
        double minYield = double.parse(selectedMinYield.value);
        result = result.where((property) => property.yieldAmountDouble >= minYield).toList();
      } catch (e) {
        print('Error parsing min yield filter: $e');
      }
    }

    if (selectedMaxYield.value.isNotEmpty) {
      try {
        double maxYield = double.parse(selectedMaxYield.value);
        result = result.where((property) => property.yieldAmountDouble <= maxYield).toList();
      } catch (e) {
        print('Error parsing max yield filter: $e');
      }
    }

    if (selectedMinArea.value.isNotEmpty) {
      try {
        double minArea = double.parse(selectedMinArea.value);
        result = result.where((property) => property.areaDouble != null && property.areaDouble! >= minArea).toList();
      } catch (e) {
        print('Error parsing min area filter: $e');
      }
    }

    if (selectedMaxArea.value.isNotEmpty) {
      try {
        double maxArea = double.parse(selectedMaxArea.value);
        result = result.where((property) => property.areaDouble != null && property.areaDouble! <= maxArea).toList();
      } catch (e) {
        print('Error parsing max area filter: $e');
      }
    }

    if (searchQuery.value.isNotEmpty) {
      String query = searchQuery.value.toLowerCase().trim();
      result = result.where((property) {
        bool matches = false;

        if (property.name.toLowerCase().contains(query)) {
          matches = true;
        }

        if (!matches && property.address.toLowerCase().contains(query)) {
          matches = true;
        }

        if (!matches && property.cityName.toLowerCase().contains(query)) {
          matches = true;
        }

        if (!matches && property.stateName.toLowerCase().contains(query)) {
          matches = true;
        }

        if (!matches && property.description.toLowerCase().contains(query)) {
          matches = true;
        }

        return matches;
      }).toList();
    }

    filteredProperties.assignAll(result);
    print('✅ Applied filters: ${result.length} properties match criteria');
  }

  // Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    currentPage.value = 1;
    fetchProperties();
  }

  // Apply filters
  Future<void> applyFilters() async {
    currentPage.value = 1;
    await fetchProperties();
  }

  // Clear all filters
  void clearAllFilters() {
    selectedStateId.value = 0;
    selectedCityId.value = 0;
    selectedMinRent.value = '';
    selectedMaxRent.value = '';
    selectedMinYield.value = '';
    selectedMaxYield.value = '';
    selectedMinArea.value = '';
    selectedMaxArea.value = '';
    selectedFurnishingStatus.value = '';
    selectedPropertyAge.value = '';
    selectedBedrooms.value = 0;
    selectedPropertyTypeId.value = 0;
    includeCommercial.value = false;
    searchController.clear();
    searchQuery.value = '';
    currentPage.value = 1;

    fetchProperties();
  }

  // State change handler
  void onStateChanged(int stateId) {
    selectedStateId.value = stateId;
    selectedCityId.value = 0;
    citiesList.clear();

    if (stateId > 0) {
      fetchCitiesByState(stateId);
    }

    currentPage.value = 1;
    fetchProperties();
  }

  // City change handler
  void onCityChanged(int cityId) {
    selectedCityId.value = cityId;
    currentPage.value = 1;
    fetchProperties();
  }

  // Load more for pagination
  Future<void> loadMore() async {
    if (hasMore.value && !isLoading.value && currentPage.value < totalPages.value) {
      currentPage.value++;
      await fetchProperties(loadMore: true);
    }
  }

  // Check if filters are applied
  bool get hasFiltersApplied {
    return selectedStateId.value > 0 ||
        selectedCityId.value > 0 ||
        selectedMinRent.value.isNotEmpty ||
        selectedMaxRent.value.isNotEmpty ||
        selectedMinYield.value.isNotEmpty ||
        selectedMaxYield.value.isNotEmpty ||
        selectedMinArea.value.isNotEmpty ||
        selectedMaxArea.value.isNotEmpty ||
        selectedFurnishingStatus.value.isNotEmpty ||
        selectedPropertyAge.value.isNotEmpty ||
        selectedBedrooms.value > 0 ||
        selectedPropertyTypeId.value > 0 ||
        includeCommercial.value ||
        searchQuery.value.isNotEmpty;
  }

  // Get property details with caching
  Future<RentalDetailProperty?> getPropertyDetails(int propertyId) async {
    if (_propertyDetailsCache.containsKey(propertyId)) {
      print('✅ Returning cached property details for ID: $propertyId');
      rentalDetail.value = _propertyDetailsCache[propertyId];
      return rentalDetail.value;
    }

    try {
      isLoadingDetail.value = true;
      print('📡 Fetching property details for ID: $propertyId');

      // Get token but don't require it
      final token = await SessionManager.getToken();

      // Create headers conditionally
      final Map<String, String> headers = {};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        print('🔑 Request with authentication token');
      } else {
        print('👤 Request without authentication (public access)');
      }

      final response = await _dio.get(
        'rental_details/$propertyId',
        options: Options(headers: headers), // Pass headers conditionally
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['status'] == true && responseData['data'] != null) {
          final detailResponse = RentalDetailResponse.fromJson(responseData);
          rentalDetail.value = detailResponse.data;

          _propertyDetailsCache[propertyId] = detailResponse.data!;

          print('✅ Successfully fetched property details for ID: $propertyId');
          return rentalDetail.value;
        } else {
          print('❌ API returned false status or no data for property ID: $propertyId');
          print('   Response: $responseData');
          return null;
        }
      } else {
        print('❌ Failed to fetch property details: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      print('❌ Dio Error fetching property details: $e');
      print('   Response: ${e.response?.data}');
      return null;
    } catch (e) {
      print('❌ Error fetching property details: $e');
      return null;
    } finally {
      isLoadingDetail.value = false;
    }
  }
  // Clear property details cache
  void clearPropertyDetailsCache() {
    _propertyDetailsCache.clear();
    rentalDetail.value = null;
  }

  // Send rental enquiry
  Future<void> sendRentalEnquiry(Map<String, dynamic> enquiryData) async {
    try {
      isEnquiryLoading.value = true;
      print('📤 Sending rental enquiry: $enquiryData');

      final token = await SessionManager.getToken();

      if (token == null || token.isEmpty) {
        print('❌ No token found - user not logged in');
        SnackBarHelper.showError('Please login to send an enquiry');
        return;
      }

      final dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));

      final response = await dio.post(
        'rental_enquiry',
        data: enquiryData,
      );

      print('📥 Enquiry API Response: ${response.statusCode}');
      print('   Data: ${response.data}');

      if (response.statusCode == 200 && response.data['status'] == true) {
        SnackBarHelper.showSuccess(response.data['message'] ?? 'Enquiry sent successfully!');
      } else {
        SnackBarHelper.showError(response.data['message'] ?? 'Failed to send enquiry');
      }
    } on DioException catch (e) {
      print('❌ Dio Error sending enquiry: ${e.message}');
      print('   Response: ${e.response?.data}');

      String errorMessage = 'Unable to send enquiry. Please try again.';

      if (e.response?.statusCode == 401) {
        errorMessage = 'Session expired. Please login again.';
      } else if (e.response?.statusCode == 422) {
        errorMessage = 'Please fill all required fields.';
      }

      SnackBarHelper.showError(errorMessage);
    } catch (e) {
      print('❌ Error sending enquiry: $e');
      SnackBarHelper.showError('Failed to send enquiry. Please try again.');
    } finally {
      isEnquiryLoading.value = false;
    }
  }

  // Fetch rental enquiries
  Future<void> fetchRentalEnquiries() async {
    try {
      isLoadingEnquiries.value = true;
      print('📡 Fetching rental enquiries...');

      final token = await SessionManager.getToken();

      if (token == null || token.isEmpty) {
        print('❌ No token found - user not logged in');
        SnackBarHelper.showError('Please login to view your enquiries');
        isLoadingEnquiries.value = false;
        return;
      }

      final dio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ));

      final response = await dio.get('rental_enquiry_list');

      print('📥 Enquiries API Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;

        if (responseData['status'] == 200 || responseData['status'] == true) {
          final data = responseData['data'] ?? {};
          final List<dynamic> enquiriesData = data['rental'] ?? [];

          final List<RentalEnquiry> newEnquiries = [];
          for (var enquiryData in enquiriesData) {
            try {
              newEnquiries.add(RentalEnquiry.fromJson(enquiryData));
            } catch (e) {
              print('Error parsing enquiry: $e');
            }
          }

          rentalEnquiries.assignAll(newEnquiries);
          print('✅ Fetched ${rentalEnquiries.length} rental enquiries');
        } else {
          print('❌ API returned error status: $responseData');
          throw Exception('API returned error status');
        }
      } else {
        print('❌ Failed to load enquiries: ${response.statusCode}');
        throw Exception('Failed to load enquiries: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ Dio Error fetching rental enquiries: ${e.message}');
      print('   Response: ${e.response?.data}');

      if (e.response?.statusCode == 401) {
        SnackBarHelper.showError('Session expired. Please login again.');
      } else {
        SnackBarHelper.showError('Unable to fetch enquiries. Please try again.');
      }
    } catch (e) {
      print('❌ Error fetching rental enquiries: $e');
      SnackBarHelper.showError('Failed to load enquiries');
    } finally {
      isLoadingEnquiries.value = false;
    }
  }

  // Refresh method for enquiries
  Future<void> refreshRentalEnquiries() async {
    await fetchRentalEnquiries();
  }

  // Load more enquiries
  Future<void> loadMoreEnquiries() async {
    if (enquiryCurrentPage.value < enquiryTotalPages.value &&
        !isLoadingEnquiries.value) {
      enquiryCurrentPage.value++;
      await fetchRentalEnquiries();
    }
  }

  // Toggle expansion for property details
  void toggleExpansion() {
    isExpanded.value = !isExpanded.value;
    update();
  }

  void initiateDocumentPayment(int documentId, String documentType, {double? customAmount}) {
    final detail = rentalDetail.value;
    if (detail == null) {
      SnackBarHelper.showError("Property details not available");
      return;
    }

    final dashboardController = Get.put(DashboardController());
    final businessSettings = dashboardController.businessSettings.value;


    final double baseAmount = customAmount ?? detail.amountPay ?? 0.0;
    if (baseAmount <= 0) {
      SnackBarHelper.showError("Document price not available");
      return;
    }

    final double rentalIgstPct =
    (businessSettings?.rentalIgst ?? 0).toDouble();
    final double rentalServicePct =
    (businessSettings?.rentalServiceCharge ?? 0).toDouble();


    final double serviceChargeAmount = (baseAmount * rentalServicePct) / 100;
    final double igstAmount = (baseAmount * rentalIgstPct) / 100;
    final double totalAmount = baseAmount + serviceChargeAmount + igstAmount;

    final paymentController = Get.put(RazorpayController());
    paymentController.isTermsAccepted.value = isTermsAccepted.value;
    paymentController.setupRentalDocumentPayment(
      propertyId: detail.id,
      documentId: documentId,
      documentType: documentType,
      amount: totalAmount,
      propertyName: detail.name,
    );

    _showDocumentPaymentSummaryDialog(
      baseAmount: baseAmount,
      serviceChargeAmount: serviceChargeAmount,
      igstAmount: igstAmount,
      servicePct: rentalServicePct,
      igstPct: rentalIgstPct,
      totalAmount: totalAmount,
      documentType: documentType,
    );
  }

  void _showDocumentPaymentSummaryDialog({
    required double baseAmount,
    required double serviceChargeAmount,
    required double igstAmount,
    required double servicePct,
    required double igstPct,
    required double totalAmount,
    required String documentType,
  }) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        titlePadding: EdgeInsets.zero,

        // ── Header ────────────────────────────────────────────────────────
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
                child: Icon(
                  Icons.description_rounded,
                  color: AppColor.primary,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                "Payment Summary",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColor.primary,
                ),
              ),
            ],
          ),
        ),

        // ── Body ──────────────────────────────────────────────────────────
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Review the charges before proceeding to payment.",
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
            ),

            SizedBox(height: 14.h),

            // Document type pill
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.folder_outlined,
                      size: 18.sp, color: AppColor.primary),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      documentType,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // ── Amount breakdown ─────────────────────────────────────────
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.03),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: AppColor.primary.withOpacity(0.1),
                ),
              ),
              child: Column(
                children: [
                  // Base amount
                  _buildAmountRow(
                    "Document Fee",
                    "₹${baseAmount.toStringAsFixed(2)}",
                  ),

                  // Service charge (only if > 0)
                  if (serviceChargeAmount > 0) ...[
                    SizedBox(height: 10.h),
                    _buildAmountRow(
                      "Service Charge (${servicePct.toStringAsFixed(0)}%)",
                      "₹${serviceChargeAmount.toStringAsFixed(2)}",
                    ),
                  ],

                  // IGST (only if > 0)
                  if (igstAmount > 0) ...[
                    SizedBox(height: 10.h),
                    _buildAmountRow(
                      "IGST (${igstPct.toStringAsFixed(0)}%)",
                      "₹${igstAmount.toStringAsFixed(2)}",
                    ),
                  ],

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: const Divider(height: 1),
                  ),

                  // Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total Amount",
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        "₹${totalAmount.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColor.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            Text(
              "You will be redirected to a secure payment gateway.",
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
            ),
          ],
        ),

        // ── Actions ───────────────────────────────────────────────────────
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        actions: [
          Row(
            children: [
              // Cancel
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              ),

              SizedBox(width: 8.w),

              // Proceed
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    final paymentController = Get.find<RazorpayController>();
                    paymentController.initiatePayment();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    "Proceed to Pay",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Reuse the same row builder pattern as the rest of the codebase
  Widget _buildAmountRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.textMain,
          ),
        ),
      ],
    );
  }
  // View document method
  Future<void> viewDocument(int documentId, String fileUrl) async {
    try {
      print('👀 Viewing document $documentId from URL: $fileUrl');

      if (fileUrl.isEmpty) {
        SnackBarHelper.showError("Document URL is empty");
        return;
      }

      // TODO: Implement actual document viewing logic
      SnackBarHelper.showInfo("Document viewing feature will be available soon");
    } catch (e) {
      print('❌ Error viewing document: $e');
      SnackBarHelper.showError("Failed to view document");
    }
  }

  // Download document method

  Future<void> downloadDocument(int documentId, String fileUrl) async {
    try {
      print('⬇️ Downloading document $documentId from URL: $fileUrl');

      if (fileUrl.isEmpty) {
        SnackBarHelper.showError("Document URL is empty");
        return;
      }

      // Check if URL is valid
      if (!fileUrl.startsWith('http')) {
        SnackBarHelper.showError("Invalid document URL");
        return;
      }

      // Launch the URL in browser
      final uri = Uri.parse(fileUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Opens in external browser/app
          // mode: LaunchMode.inAppWebView, // Alternative: Opens in in-app webview
        );
        print('✅ Launched document URL: $fileUrl');
      } else {
        print('❌ Could not launch URL: $fileUrl');
        SnackBarHelper.showError("Cannot open document. Please check the URL.");
      }
    } on FormatException catch (e) {
      print('❌ Invalid URL format: $e');
      SnackBarHelper.showError("Invalid document URL format");
    } catch (e) {
      print('❌ Error downloading document: $e');
      SnackBarHelper.showError("Failed to open document");
    }
  }
  // Refresh properties after payment
  Future<void> refreshProperties() async {
    print('🔄 Refreshing properties list...');
    await fetchProperties();
  }

  // Clear all data (for logout)
  void clearAllData() {
    properties.clear();
    filteredProperties.clear();
    rentalEnquiries.clear();
    _propertyDetailsCache.clear();
    rentalDetail.value = null;
    statesList.clear();
    citiesList.clear();
    searchController.clear();
    searchQuery.value = '';

    // Reset all filters
    selectedStateId.value = 0;
    selectedCityId.value = 0;
    selectedMinRent.value = '';
    selectedMaxRent.value = '';
    selectedMinYield.value = '';
    selectedMaxYield.value = '';
    selectedMinArea.value = '';
    selectedMaxArea.value = '';
    selectedFurnishingStatus.value = '';
    selectedPropertyAge.value = '';
    selectedBedrooms.value = 0;
    selectedPropertyTypeId.value = 0;
    includeCommercial.value = false;

    currentPage.value = 1;
    enquiryCurrentPage.value = 1;

    print('🧹 Cleared all rental data');
  }

  // Helper method to convert RentalListProperty to RentalDetailProperty if needed
  RentalDetailProperty? convertToListPropertyForDetail(RentalListProperty listProperty) {
    try {
      return RentalDetailProperty(
        id: listProperty.id,
        name: listProperty.name,
        type: listProperty.type,
        address: listProperty.address,
        rentAmount: listProperty.rentAmount,
        area: listProperty.area,
        yieldAmount: listProperty.yieldAmount,
        description: listProperty.description,
        plotImage: listProperty.plotImage ?? '',
        files: listProperty.files,
        city: listProperty.city,
        state: listProperty.state,
        amenities: listProperty.amenities,
        documents: listProperty.documents,
        nearbyLocations: [],
        nearbyPlaces: listProperty.nearbyPlaces,
        lat: listProperty.lat,
        lng: listProperty.lng,
        agentId: null,
        status: listProperty.status,
        featured: listProperty.featured,
        verifyStatus: listProperty.verifyStatus,
        createdAt: listProperty.createdAt,
        updatedAt: listProperty.updatedAt,
        doucmentVerficaiton: false,
        amountPay: 0.0,
      );
    } catch (e) {
      print('❌ Error converting list property to detail: $e');
      return null;
    }
  }
}