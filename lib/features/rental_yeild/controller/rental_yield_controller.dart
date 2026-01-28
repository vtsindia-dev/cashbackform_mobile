import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../model/rental_yeild_model.dart';

class RentalYieldController extends GetxController {
  // Loading state
  RxBool isLoading = false.obs;

  // API Configuration
  final String baseUrl = 'https://admincashback.vrikshatech.in/public/api/v2';
  final Dio _dio = Dio();

  // Search
  TextEditingController searchController = TextEditingController();
  RxString searchQuery = ''.obs;
  Timer? _searchTimer;

  // Filters
  RxInt selectedStateId = 0.obs;
  RxInt selectedCityId = 0.obs;
  RxInt selectedPropertyTypeId = 0.obs; // ADDED
  RxString selectedMinPrice = ''.obs;
  RxString selectedMaxPrice = ''.obs;
  RxString selectedMinRent = ''.obs;
  RxString selectedMaxRent = ''.obs;
  RxString selectedMinYield = ''.obs;
  RxString selectedMaxYield = ''.obs;
  RxString selectedMinArea = ''.obs;
  RxString selectedMaxArea = ''.obs;
  RxString selectedFurnishingStatus = ''.obs; // ADDED
  RxString selectedPropertyAge = ''.obs; // ADDED
  RxInt selectedBedrooms = 0.obs; // ADDED
  RxBool includeCommercial = false.obs; // ADDED

  // Properties list
  RxList<RentalYieldModel> properties = <RentalYieldModel>[].obs;
  RxList<RentalYieldModel> filteredProperties = <RentalYieldModel>[].obs;

  // Static data from API
  RxList<StateModel> statesList = <StateModel>[].obs;
  RxList<CityModel> citiesList = <CityModel>[].obs;
  RxList<PropertyTypeModel> propertyTypes = <PropertyTypeModel>[].obs; // ADDED

  // Range values from API
  RxDouble priceMin = 0.0.obs;
  RxDouble priceMax = 100.0.obs;
  RxDouble rentMin = 0.0.obs;
  RxDouble rentMax = 50.0.obs;
  RxDouble yieldMin = 0.0.obs;
  RxDouble yieldMax = 10.0.obs;
  RxInt sqftMin = 0.obs; // CHANGED from Double to Int
  RxInt sqftMax = 5000.obs; // CHANGED from Double to Int

  // Pagination
  RxInt currentPage = 1.obs;
  RxInt totalPages = 1.obs;
  RxBool hasMore = true.obs;
  RxInt totalItems = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeStaticData();
    fetchProperties();

    // Listen to search changes
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    _searchTimer?.cancel();
    super.onClose();
  }

  Future<void> _initializeStaticData() async {
    try {
      await fetchStates();
      await fetchPropertyTypes(); // ADDED
    } catch (e) {
      print('Error initializing static data: $e');
    }
  }

  Future<void> fetchStates() async {
    try {
      final response = await _dio.get('$baseUrl/states');
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        statesList.assignAll(data.map((state) => StateModel.fromJson(state)).toList());
      }
    } catch (e) {
      print('Error fetching states: $e');
      // Fallback to static states from rental API response
      await fetchProperties();
    }
  }

  Future<void> fetchPropertyTypes() async { // ADDED
    try {
      // This is a mock - you'll need to create this endpoint or use existing one
      final response = await _dio.get('$baseUrl/property-types');
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        propertyTypes.assignAll(data.map((type) => PropertyTypeModel.fromJson(type)).toList());
      } else {
        // Default property types
        propertyTypes.assignAll([
          PropertyTypeModel(id: 1, typeName: 'Apartment'),
          PropertyTypeModel(id: 2, typeName: 'Villa'),
          PropertyTypeModel(id: 3, typeName: 'Independent House'),
          PropertyTypeModel(id: 4, typeName: 'Plot'),
        ]);
      }
    } catch (e) {
      print('Error fetching property types: $e');
      // Default property types as fallback
      propertyTypes.assignAll([
        PropertyTypeModel(id: 1, typeName: 'Apartment'),
        PropertyTypeModel(id: 2, typeName: 'Villa'),
        PropertyTypeModel(id: 3, typeName: 'Independent House'),
        PropertyTypeModel(id: 4, typeName: 'Plot'),
      ]);
    }
  }

  Future<void> fetchProperties({bool loadMore = false}) async {
    if (!loadMore) {
      isLoading.value = true;
      currentPage.value = 1;
    }

    try {
      final Map<String, dynamic> params = {
        'page': currentPage.value,
        'per_page': 10,
      };

      // Add filters
      if (selectedStateId.value > 0) {
        params['state_id'] = selectedStateId.value;
      }
      if (selectedCityId.value > 0) {
        params['city_id'] = selectedCityId.value;
      }
      if (selectedPropertyTypeId.value > 0) {
        params['property_type_id'] = selectedPropertyTypeId.value;
      }
      if (searchQuery.value.isNotEmpty) {
        params['search'] = searchQuery.value;
      }
      if (selectedMinPrice.value.isNotEmpty) {
        params['min_price'] = selectedMinPrice.value;
      }
      if (selectedMaxPrice.value.isNotEmpty) {
        params['max_price'] = selectedMaxPrice.value;
      }
      if (selectedMinRent.value.isNotEmpty) {
        params['min_rent'] = selectedMinRent.value;
      }
      if (selectedMaxRent.value.isNotEmpty) {
        params['max_rent'] = selectedMaxRent.value;
      }
      if (selectedMinYield.value.isNotEmpty) {
        params['min_yield'] = selectedMinYield.value;
      }
      if (selectedMaxYield.value.isNotEmpty) {
        params['max_yield'] = selectedMaxYield.value;
      }
      if (selectedMinArea.value.isNotEmpty) {
        params['min_area'] = selectedMinArea.value;
      }
      if (selectedMaxArea.value.isNotEmpty) {
        params['max_area'] = selectedMaxArea.value;
      }
      if (selectedFurnishingStatus.value.isNotEmpty) {
        params['furnishing_status'] = selectedFurnishingStatus.value;
      }
      if (selectedPropertyAge.value.isNotEmpty) {
        params['property_age'] = selectedPropertyAge.value;
      }
      if (selectedBedrooms.value > 0) {
        params['bedrooms'] = selectedBedrooms.value;
      }
      if (includeCommercial.value) {
        params['include_commercial'] = 1;
      }

      final response = await _dio.get(
        '$baseUrl/rental',
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = response.data['data'];

        // Update range values from API
        priceMin.value = double.parse(data['price_min']?.toString() ?? '0');
        priceMax.value = double.parse(data['price_max']?.toString() ?? '100');

        // Assuming API returns rent/yield/area min/max
        rentMin.value = double.parse(data['rent_min']?.toString() ?? '0');
        rentMax.value = double.parse(data['rent_max']?.toString() ?? '50000');
        yieldMin.value = double.parse(data['yield_min']?.toString() ?? '0');
        yieldMax.value = double.parse(data['yield_max']?.toString() ?? '20');
        sqftMin.value = int.parse(data['sqft_min']?.toString() ?? '0');
        sqftMax.value = int.parse(data['sqft_max']?.toString() ?? '5000');

        // Extract rental properties
        final List<dynamic> rentalData = data['rental'];
        final List<RentalYieldModel> newProperties = rentalData
            .map((item) => RentalYieldModel.fromJson(item))
            .toList();

        // Update pagination info
        final pagination = data['pagination'];
        totalPages.value = pagination['last_page'] ?? 1;
        totalItems.value = pagination['total'] ?? 0;
        hasMore.value = currentPage.value < totalPages.value;

        // Update properties list
        if (loadMore) {
          properties.addAll(newProperties);
        } else {
          properties.assignAll(newProperties);
        }

        // Update states list from API if empty
        if (statesList.isEmpty && data['state_list'] != null) {
          statesList.assignAll(
            (data['state_list'] as List)
                .map((state) => StateModel.fromJson(state))
                .toList(),
          );
        }

        // Update cities list from API
        if (data['city_list'] != null) {
          citiesList.assignAll(
            (data['city_list'] as List)
                .map((city) => CityModel.fromJson(city))
                .toList(),
          );
        }

        // Apply filters after fetching
        _applyFilters();
      } else {
        throw Exception('Failed to load properties');
      }
    } catch (e) {
      print('Error fetching properties: $e');
      Get.snackbar(
        'Error',
        'Failed to load properties. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCitiesByState(int stateId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/cities',
        queryParameters: {'state_id': stateId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        citiesList.assignAll(data.map((city) => CityModel.fromJson(city)).toList());
      }
    } catch (e) {
      print('Error fetching cities: $e');
      citiesList.clear();
    }
  }

  void _applyFilters() {
    if (properties.isEmpty) {
      filteredProperties.assignAll(properties);
      return;
    }

    List<RentalYieldModel> result = List.from(properties);

    // Apply state filter
    if (selectedStateId.value > 0) {
      result = result.where((property) => property.stateId == selectedStateId.value).toList();
    }

    // Apply city filter
    if (selectedCityId.value > 0) {
      result = result.where((property) => property.cityId == selectedCityId.value).toList();
    }

    // Apply property type filter
    if (selectedPropertyTypeId.value > 0) {
      // Since propertyType is a string in model, we need to map it
      // This assumes your API returns consistent property type names
      result = result.where((property) =>
      property.propertyType?.toLowerCase() ==
          propertyTypes.firstWhere(
                  (type) => type.id == selectedPropertyTypeId.value,
              orElse: () => PropertyTypeModel(id: 0, typeName: '')
          ).typeName.toLowerCase()
      ).toList();
    }

    // Apply price filter
    if (selectedMinPrice.value.isNotEmpty) {
      double minPrice = double.parse(selectedMinPrice.value) * 100000; // Convert lakhs to actual
      result = result.where((property) => property.price >= minPrice).toList();
    }
    if (selectedMaxPrice.value.isNotEmpty) {
      double maxPrice = double.parse(selectedMaxPrice.value) * 100000; // Convert lakhs to actual
      result = result.where((property) => property.price <= maxPrice).toList();
    }

    // Apply rent filter
    if (selectedMinRent.value.isNotEmpty) {
      double minRent = double.parse(selectedMinRent.value);
      result = result.where((property) => property.rentAmount >= minRent).toList();
    }
    if (selectedMaxRent.value.isNotEmpty) {
      double maxRent = double.parse(selectedMaxRent.value);
      result = result.where((property) => property.rentAmount <= maxRent).toList();
    }

    // Apply yield filter
    if (selectedMinYield.value.isNotEmpty) {
      double minYield = double.parse(selectedMinYield.value);
      result = result.where((property) => property.annualYield >= minYield).toList();
    }
    if (selectedMaxYield.value.isNotEmpty) {
      double maxYield = double.parse(selectedMaxYield.value);
      result = result.where((property) => property.annualYield <= maxYield).toList();
    }

    // Apply area filter
    if (selectedMinArea.value.isNotEmpty) {
      double minArea = double.parse(selectedMinArea.value);
      result = result.where((property) => property.area != null && property.area! >= minArea).toList();
    }
    if (selectedMaxArea.value.isNotEmpty) {
      double maxArea = double.parse(selectedMaxArea.value);
      result = result.where((property) => property.area != null && property.area! <= maxArea).toList();
    }

    // Apply furnishing filter
    if (selectedFurnishingStatus.value.isNotEmpty) {
      result = result.where((property) =>
      property.furnishingStatus?.toLowerCase() == selectedFurnishingStatus.value.toLowerCase()
      ).toList();
    }

    // Apply property age filter
    if (selectedPropertyAge.value.isNotEmpty) {
      // This would need custom logic based on how age is stored
      result = result.where((property) =>
      property.propertyAge?.toLowerCase() == selectedPropertyAge.value.toLowerCase()
      ).toList();
    }

    // Apply bedrooms filter
    if (selectedBedrooms.value > 0) {
      result = result.where((property) => property.bedrooms == selectedBedrooms.value).toList();
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      String query = searchQuery.value.toLowerCase();
      result = result.where((property) =>
      property.name.toLowerCase().contains(query) ||
          property.address.toLowerCase().contains(query) ||
          property.description.toLowerCase().contains(query)
      ).toList();
    }

    filteredProperties.assignAll(result);
  }

  // Search methods
  void onSearchChanged(String value) {
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      searchQuery.value = value;
      currentPage.value = 1;
      fetchProperties();
    });
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    currentPage.value = 1;
    fetchProperties();
  }

  // Filter methods
  Future<void> applyFilters() async {
    currentPage.value = 1;
    await fetchProperties();
  }

  void clearAllFilters() {
    selectedStateId.value = 0;
    selectedCityId.value = 0;
    selectedPropertyTypeId.value = 0;
    selectedMinPrice.value = '';
    selectedMaxPrice.value = '';
    selectedMinRent.value = '';
    selectedMaxRent.value = '';
    selectedMinYield.value = '';
    selectedMaxYield.value = '';
    selectedMinArea.value = '';
    selectedMaxArea.value = '';
    selectedFurnishingStatus.value = '';
    selectedPropertyAge.value = '';
    selectedBedrooms.value = 0;
    includeCommercial.value = false;
    searchController.clear();
    searchQuery.value = '';
    currentPage.value = 1;

    fetchProperties();
  }

  // Load more for pagination
  Future<void> loadMore() async {
    if (hasMore.value && !isLoading.value) {
      currentPage.value++;
      await fetchProperties(loadMore: true);
    }
  }

  // Check if filters are applied
  bool get hasFiltersApplied {
    return selectedStateId.value > 0 ||
        selectedCityId.value > 0 ||
        selectedPropertyTypeId.value > 0 ||
        selectedMinPrice.value.isNotEmpty ||
        selectedMaxPrice.value.isNotEmpty ||
        selectedMinRent.value.isNotEmpty ||
        selectedMaxRent.value.isNotEmpty ||
        selectedMinYield.value.isNotEmpty ||
        selectedMaxYield.value.isNotEmpty ||
        selectedMinArea.value.isNotEmpty ||
        selectedMaxArea.value.isNotEmpty ||
        selectedFurnishingStatus.value.isNotEmpty ||
        selectedPropertyAge.value.isNotEmpty ||
        selectedBedrooms.value > 0 ||
        includeCommercial.value ||
        searchQuery.value.isNotEmpty;
  }
}

// ADD THIS MODEL to rental_yield_model.dart or here
class PropertyTypeModel {
  final int id;
  final String typeName;

  PropertyTypeModel({
    required this.id,
    required this.typeName,
  });

  factory PropertyTypeModel.fromJson(Map<String, dynamic> json) {
    return PropertyTypeModel(
      id: json['id'] ?? json['property_type_id'] ?? 0,
      typeName: json['type_name'] ?? json['property_type'] ?? '',
    );
  }
}