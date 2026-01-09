import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../common/api_constant.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';
import '../model/residential_model.dart';

class ResidentialPropertyController extends GetxController {
  var isLoading = false.obs;
  var isLoadMore = false.obs;
  var isLoadingDetail = false.obs;
  var isLoadingFilters = false.obs;
  var properties = <Property>[].obs;
  var propertyDetail = Rxn<Property>();
  var propertyCategories = <PropertyCategory>[].obs;
  var statesList = <StateList>[].obs;
  var citiesList = <CityModel>[].obs;
  final amenitiesScrollController = ScrollController();
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalItems = 0.obs;
  var hasMoreData = true.obs;
  var perPage = 10.obs;
  var priceMin = 0.0.obs;
  var priceMax = 10000000.0.obs;
  var sqftMin = 0.obs;
  var sqftMax = 10000.obs;
  var searchQuery = ''.obs;
  var selectedStateId = 0.obs;
  var selectedCityId = 0.obs;
  var selectedCategoryId = 0.obs;
  var selectedMinPrice = ''.obs;
  var selectedMaxPrice = ''.obs;
  var selectedMinArea = ''.obs;
  var selectedMaxArea = ''.obs;
  var selectedAmenities = <String>[].obs;
  var selectedTransactionType = ''.obs;
  var selectedPostedBy = ''.obs;
  var showFilters = false.obs;
  var showAdvancedFilters = false.obs;
  var sortBy = 'created_at'.obs;
  var sortOrder = 'desc'.obs;
  Timer? _searchDebounce;
  var errorMessage = ''.obs;
  var detailErrorMessage = ''.obs;
  final isExpanded = false.obs;
  final isDescriptionExpanded = false.obs;
  var isEnquiryLoading = false.obs;
  var enquirySent = false.obs;

  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchProperties();
    loadFilterData();
  }

  void toggleExpansion() => isExpanded.toggle();

  void toggleDescription() => isDescriptionExpanded.toggle();

  void scrollAmenitiesLeft() {
    amenitiesScrollController.animateTo(
      amenitiesScrollController.offset - 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void scrollAmenitiesRight() {
    amenitiesScrollController.animateTo(
      amenitiesScrollController.offset + 100,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> fetchProperties({bool loadMore = false, bool refresh = false}) async {
    try {
      if (refresh) {
        properties.clear();
        currentPage.value = 1;
        hasMoreData.value = true;
      }

      if (loadMore) {
        isLoadMore(true);
      } else {
        isLoading(true);
      }

      errorMessage('');
      final url = '${ApiUrl.baseUrl}/api/v2/plots?${_buildQueryParams()}';
      print('🌐 Fetching Properties URL: $url');

      final response = await ApiService.getRequest(url);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == true) {
          final propertyList = _parseProperties(responseData['data']['plots'] ?? []);

          if (loadMore) {
            properties.addAll(propertyList);
          } else {
            properties.assignAll(propertyList);
          }

          if (responseData['data']['property_category'] != null) {
            propertyCategories.assignAll(
                _parsePropertyCategories(responseData['data']['property_category'])
            );
          }

          if (responseData['data']['state_list'] != null) {
            statesList.assignAll(
                _parseStateList(responseData['data']['state_list'])
            );
          }

          if (responseData['data']['price_min'] != null && responseData['data']['price_max'] != null) {
            priceMin.value = double.tryParse(responseData['data']['price_min'].toString()) ?? 0.0;
            priceMax.value = double.tryParse(responseData['data']['price_max'].toString()) ?? 10000000.0;
          }

          if (responseData['data']['sqft_min'] != null && responseData['data']['sqft_max'] != null) {
            sqftMin.value = responseData['data']['sqft_min'] ?? 0;
            sqftMax.value = responseData['data']['sqft_max'] ?? 10000;
          }

          if (responseData['data']['pagination'] != null) {
            final pagination = responseData['data']['pagination'];
            currentPage.value = pagination['current_page'] ?? 1;
            totalPages.value = pagination['last_page'] ?? 1;
            totalItems.value = pagination['total'] ?? 0;
            perPage.value = pagination['per_page'] ?? 10;
            hasMoreData.value = currentPage.value < totalPages.value;
          }

          print('✅ Fetched ${properties.length} properties');
        } else {
          errorMessage(responseData['message'] ?? 'Failed to fetch properties');
          SnackBarHelper.showError(errorMessage.value);
        }
      } else {
        errorMessage('Server error: ${response.statusCode}');
        SnackBarHelper.showError('Failed to fetch properties');
      }
    } catch (e) {
      errorMessage('Network error: $e');
      SnackBarHelper.showError('Network error occurred');
      print('❌ Error fetching properties: $e');
    } finally {
      isLoading(false);
      isLoadMore(false);
    }
  }

  Future<void> loadMoreProperties() async {
    if (!isLoadMore.value && hasMoreData.value) {
      currentPage.value++;
      await fetchProperties(loadMore: true);
    }
  }

  Future<void> refreshProperties() async {
    await fetchProperties(refresh: true);
  }

  Future<void> fetchPropertyDetail(int propertyId) async {
    try {
      isLoadingDetail(true);
      detailErrorMessage('');
      final url = '${ApiUrl.baseUrl}/api/v2/plot_details/$propertyId';
      print('🌐 Fetching Property Detail URL: $url');

      final response = await ApiService.getRequest(url);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == true) {
          propertyDetail.value = Property.fromJson(responseData['data']);
          print('✅ Fetched property detail: ${propertyDetail.value?.propertyName}');
        } else {
          detailErrorMessage(responseData['message'] ?? 'Failed to fetch property details');
          SnackBarHelper.showError(detailErrorMessage.value);
        }
      } else if (response.statusCode == 404) {
        detailErrorMessage('Property not found');
        SnackBarHelper.showError('Property not found');
      } else {
        detailErrorMessage('Server error: ${response.statusCode}');
        SnackBarHelper.showError('Failed to fetch property details');
      }
    } catch (e) {
      detailErrorMessage('Network error: $e');
      SnackBarHelper.showError('Network error occurred');
      print('❌ Error fetching property detail: $e');
    } finally {
      isLoadingDetail(false);
    }
  }

  void navigateToPropertyDetail(int propertyId) {
    Get.toNamed('/property-detail', arguments: propertyId);
    fetchPropertyDetail(propertyId);
  }

  Future<void> loadFilterData() async {
    try {
      isLoadingFilters(true);
      if (selectedStateId.value > 0) {
        await fetchCitiesByState(selectedStateId.value);
      }
      if (propertyCategories.isEmpty || statesList.isEmpty) {
        await fetchProperties();
      }
    } catch (e) {
      print('❌ Error loading filter data: $e');
    } finally {
      isLoadingFilters(false);
    }
  }

  Future<void> fetchCitiesByState(int stateId) async {
    try {
      final url = '${ApiUrl.baseUrl}/api/v2/city/$stateId';
      final response = await ApiService.getRequest(url);
      if (response.statusCode == 200 && response.data['status'] == 200) {
        citiesList.assignAll(
            (response.data['data'] as List).map((item) => CityModel.fromJson(item)).toList()
        );
        print('✅ Loaded ${citiesList.length} cities for state $stateId');
      }
    } catch (e) {
      print('❌ Error fetching cities: $e');
    }
  }

  Future<void> filterByState(int stateId) async {
    selectedStateId.value = stateId;
    selectedCityId.value = 0;
    citiesList.clear();
    currentPage.value = 1;
    await fetchProperties();
    if (stateId > 0) {
      await fetchCitiesByState(stateId);
    }
  }

  Future<void> filterByCity(int cityId) async {
    selectedCityId.value = cityId;
    currentPage.value = 1;
    await fetchProperties();
  }

  Future<void> filterByCategory(int categoryId) async {
    selectedCategoryId.value = categoryId;
    currentPage.value = 1;
    await fetchProperties();
  }

  void onSearchChanged(String query) {
    searchQuery.value = query;
    if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      if (query.trim().isNotEmpty) {
        currentPage.value = 1;
        fetchProperties();
      } else if (query.isEmpty && searchQuery.value.isNotEmpty) {
        searchQuery.value = '';
        currentPage.value = 1;
        fetchProperties();
      }
    });
  }

  void clearSearch() {
    searchQuery.value = '';
    searchController.clear();
    currentPage.value = 1;
    fetchProperties();
  }

  void onSearchSubmitted(String value) {
    if (value.trim().isNotEmpty) {
      searchQuery.value = value.trim();
      currentPage.value = 1;
      fetchProperties();
    }
  }

  Future<void> sortProperties(String field, {String order = 'desc'}) async {
    sortBy.value = field;
    sortOrder.value = order;
    currentPage.value = 1;
    await fetchProperties();
  }

  Future<void> clearAllFilters() async {
    selectedStateId.value = 0;
    selectedCityId.value = 0;
    selectedCategoryId.value = 0;
    selectedMinPrice.value = '';
    selectedMaxPrice.value = '';
    selectedMinArea.value = '';
    selectedMaxArea.value = '';
    selectedAmenities.clear();
    selectedTransactionType.value = '';
    selectedPostedBy.value = '';
    searchQuery.value = '';
    sortBy.value = 'created_at';
    sortOrder.value = 'desc';
    citiesList.clear();
    currentPage.value = 1;
    await fetchProperties();
  }

  void toggleFilters() => showFilters.value = !showFilters.value;

  void toggleAdvancedFilters() => showAdvancedFilters.value = !showAdvancedFilters.value;

  Future<void> applyFilters() async {
    showFilters.value = false;
    currentPage.value = 1;
    await fetchProperties();
  }

  Future<void> resetFilters() async {
    selectedMinPrice.value = '';
    selectedMaxPrice.value = '';
    selectedMinArea.value = '';
    selectedMaxArea.value = '';
    selectedAmenities.clear();
    selectedTransactionType.value = '';
    selectedPostedBy.value = '';
    currentPage.value = 1;
    await fetchProperties();
  }

  Future<void> sendEnquiry() async {
    try {
      if (propertyDetail.value == null) {
        SnackBarHelper.showError('Property details not loaded');
        return;
      }

      if (isEnquiryLoading.value) return;
      isEnquiryLoading.value = true;

      final token = await SessionManager.getToken();
      final userId = await SessionManager.getUserId();

      if (userId == null) {
        isEnquiryLoading.value = false;
        SnackBarHelper.showError('User information not found');
        return;
      }

      if (token == null || token.isEmpty) {
        isEnquiryLoading.value = false;
        SnackBarHelper.showError('Please login to send enquiry');
        return;
      }

      final Map<String, dynamic> requestData = {
        'property_id': propertyDetail.value!.id,
      };

      final url = '${ApiUrl.baseUrl}/api/v2/plot_enquiry';
      print('🌐 Sending enquiry to: $url');

      final response = await ApiService.EnquirypostRequest(
        url,
        data: requestData,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        if (responseData['status'] == true) {
          enquirySent.value = true;
          SnackBarHelper.showSuccess(
            responseData['message'] ?? 'Enquiry sent successfully!',
          );
          Future.delayed(const Duration(milliseconds: 500), () {
            isEnquiryLoading.value = false;
          });
        } else {
          SnackBarHelper.showError(
            responseData['message'] ?? 'Failed to send enquiry',
          );
          isEnquiryLoading.value = false;
        }
      } else {
        SnackBarHelper.showError(
          'Failed to send enquiry. Status: ${response.statusCode}',
        );
        isEnquiryLoading.value = false;
      }
    } catch (e) {
      print('❌ Enquiry error: $e');
      SnackBarHelper.showError('Error sending enquiry: $e');
      isEnquiryLoading.value = false;
    }
  }

  List<Property> _parseProperties(List<dynamic> data) {
    return data.map((item) => Property.fromJson(item)).toList();
  }

  List<PropertyCategory> _parsePropertyCategories(List<dynamic> data) {
    return data.map((item) => PropertyCategory.fromJson(item)).toList();
  }

  List<StateList> _parseStateList(List<dynamic> data) {
    return data.map((item) => StateList.fromJson(item)).toList();
  }

  String _buildQueryParams() {
    final params = <String>[
      'page=${currentPage.value}',
      'per_page=${perPage.value}',
    ];

    if (searchQuery.value.isNotEmpty) {
      params.add('search=${Uri.encodeComponent(searchQuery.value)}');
    }
    if (selectedStateId.value > 0) {
      params.add('state=${selectedStateId.value}');
    }
    if (selectedCityId.value > 0) {
      params.add('city=${selectedCityId.value}');
    }
    if (selectedCategoryId.value > 0) {
      params.add('category_id=${selectedCategoryId.value}');
    }
    if (selectedMinPrice.value.isNotEmpty) {
      params.add('min_price=${selectedMinPrice.value}');
    }
    if (selectedMaxPrice.value.isNotEmpty) {
      params.add('max_price=${selectedMaxPrice.value}');
    }
    if (selectedMinArea.value.isNotEmpty) {
      params.add('min_sqft=${selectedMinArea.value}');
    }
    if (selectedMaxArea.value.isNotEmpty) {
      params.add('max_sqft=${selectedMaxArea.value}');
    }
    if (selectedTransactionType.value.isNotEmpty) {
      params.add('transaction_type=${selectedTransactionType.value}');
    }
    if (selectedPostedBy.value.isNotEmpty) {
      params.add('posted_by=${selectedPostedBy.value}');
    }
    if (selectedAmenities.isNotEmpty) {
      params.add('amenities=${selectedAmenities.join(',')}');
    }
    params.add('sort_by=${sortBy.value}');
    params.add('sort_order=${sortOrder.value}');

    return params.join('&');
  }

  // Helper getters
  bool get hasFiltersApplied {
    return selectedStateId.value > 0 ||
        selectedCityId.value > 0 ||
        selectedCategoryId.value > 0 ||
        selectedMinPrice.value.isNotEmpty ||
        selectedMaxPrice.value.isNotEmpty ||
        selectedMinArea.value.isNotEmpty ||
        selectedMaxArea.value.isNotEmpty ||
        selectedAmenities.isNotEmpty ||
        selectedTransactionType.value.isNotEmpty ||
        selectedPostedBy.value.isNotEmpty ||
        searchQuery.value.isNotEmpty;
  }

  int get activeFilterCount {
    int count = 0;
    if (selectedStateId.value > 0) count++;
    if (selectedCityId.value > 0) count++;
    if (selectedCategoryId.value > 0) count++;
    if (selectedMinPrice.value.isNotEmpty || selectedMaxPrice.value.isNotEmpty) count++;
    if (selectedMinArea.value.isNotEmpty || selectedMaxArea.value.isNotEmpty) count++;
    if (selectedAmenities.isNotEmpty) count++;
    if (selectedTransactionType.value.isNotEmpty) count++;
    if (selectedPostedBy.value.isNotEmpty) count++;
    if (searchQuery.value.isNotEmpty) count++;
    return count;
  }

  Property? getPropertyById(int id) {
    return properties.firstWhereOrNull((p) => p.id == id);
  }

  List<Property> getPropertiesByCategory(int categoryId) {
    return properties.where((p) => p.categoryId == categoryId).toList();
  }

  List<Property> get verifiedProperties {
    return properties.where((p) => p.isVerified).toList();
  }

  List<Property> get featuredProperties {
    return properties.take(5).toList();
  }

  List<Property> get recentlyAddedProperties {
    return properties
        .where((p) => p.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 30))))
        .toList();
  }

  List<AmenityItem> get availableAmenities {
    final amenityMap = <int, AmenityItem>{};
    for (final property in properties) {
      for (final amenity in property.amenitiesAll) {
        if (!amenityMap.containsKey(amenity.id)) {
          amenityMap[amenity.id] = amenity;
        }
      }
    }
    return amenityMap.values.toList();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    amenitiesScrollController.dispose();
    super.onClose();
  }
}