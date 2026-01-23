// rental_yield_controller.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RentalYieldController extends GetxController {
  // Loading state
  RxBool isLoading = false.obs;

  // Search
  TextEditingController searchController = TextEditingController();
  RxString searchQuery = ''.obs;
  Timer? _searchTimer;

  // Filters
  RxInt selectedStateId = 0.obs;
  RxInt selectedCityId = 0.obs;
  RxInt selectedPropertyTypeId = 0.obs;
  RxString selectedMinPrice = ''.obs;
  RxString selectedMaxPrice = ''.obs;
  RxString selectedMinRent = ''.obs;
  RxString selectedMaxRent = ''.obs;
  RxString selectedMinYield = ''.obs;
  RxString selectedMaxYield = ''.obs;
  RxString selectedMinArea = ''.obs;
  RxString selectedMaxArea = ''.obs;
  RxString selectedFurnishingStatus = ''.obs;
  RxString selectedPropertyAge = ''.obs;
  RxInt selectedBedrooms = 0.obs;
  RxBool includeCommercial = false.obs;

  // Properties list
  RxList<RentalYieldModel> properties = <RentalYieldModel>[].obs;
  RxList<RentalYieldModel> filteredProperties = <RentalYieldModel>[].obs;

  // Static data lists
  RxList<StateModel> statesList = <StateModel>[].obs;
  RxList<CityModel> citiesList = <CityModel>[].obs;
  RxList<PropertyTypeModel> propertyTypes = <PropertyTypeModel>[].obs;

  // Range values
  RxDouble priceMin = 0.0.obs;
  RxDouble priceMax = 100.0.obs;
  RxDouble rentMin = 0.0.obs;
  RxDouble rentMax = 50.0.obs;
  RxDouble yieldMin = 0.0.obs;
  RxDouble yieldMax = 10.0.obs;
  RxInt sqftMin = 0.obs;
  RxInt sqftMax = 5000.obs;

  // Pagination
  RxInt currentPage = 1.obs;
  RxBool hasMore = true.obs;

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

  void _initializeStaticData() {
    // Initialize states
    statesList.assignAll([
      StateModel(id: 1, stateName: "Delhi"),
      StateModel(id: 2, stateName: "Maharashtra"),
      StateModel(id: 3, stateName: "Karnataka"),
      StateModel(id: 4, stateName: "Tamil Nadu"),
      StateModel(id: 5, stateName: "Uttar Pradesh"),
      StateModel(id: 6, stateName: "Gujarat"),
      StateModel(id: 7, stateName: "Rajasthan"),
      StateModel(id: 8, stateName: "West Bengal"),
      StateModel(id: 9, stateName: "Telangana"),
      StateModel(id: 10, stateName: "Kerala"),
    ]);

    // Initialize cities
    citiesList.assignAll([
      CityModel(id: 1, name: "New Delhi", stateId: 1),
      CityModel(id: 2, name: "Mumbai", stateId: 2),
      CityModel(id: 3, name: "Pune", stateId: 2),
      CityModel(id: 4, name: "Bangalore", stateId: 3),
      CityModel(id: 5, name: "Chennai", stateId: 4),
      CityModel(id: 6, name: "Hyderabad", stateId: 9),
      CityModel(id: 7, name: "Ahmedabad", stateId: 6),
      CityModel(id: 8, name: "Kolkata", stateId: 8),
      CityModel(id: 9, name: "Jaipur", stateId: 7),
      CityModel(id: 10, name: "Lucknow", stateId: 5),
      CityModel(id: 11, name: "Noida", stateId: 5),
      CityModel(id: 12, name: "Gurgaon", stateId: 1),
      CityModel(id: 13, name: "Chandigarh", stateId: 1),
      CityModel(id: 14, name: "Goa", stateId: 2),
      CityModel(id: 15, name: "Indore", stateId: 6),
    ]);

    // Initialize property types
    propertyTypes.assignAll([
      PropertyTypeModel(id: 1, typeName: "Apartment"),
      PropertyTypeModel(id: 2, typeName: "Independent House"),
      // PropertyModel(id: 3, typeName: "Villa"),
      PropertyTypeModel(id: 4, typeName: "Studio"),
      PropertyTypeModel(id: 5, typeName: "Penthouse"),
      PropertyTypeModel(id: 6, typeName: "Farm House"),
      PropertyTypeModel(id: 7, typeName: "Row House"),
      PropertyTypeModel(id: 8, typeName: "Duplex"),
      PropertyTypeModel(id: 9, typeName: "Commercial Office"),
      PropertyTypeModel(id: 10, typeName: "Shop"),
    ]);

    // Initialize range values
    priceMin.value = 20.0; // 20L
    priceMax.value = 500.0; // 500L
    rentMin.value = 5.0; // 5K
    rentMax.value = 200.0; // 200K
    yieldMin.value = 2.0; // 2%
    yieldMax.value = 8.0; // 8%
    sqftMin.value = 300;
    sqftMax.value = 4000;
  }

  // Static rental yield data
  final List<RentalYieldModel> _staticProperties = [
    RentalYieldModel(
      id: 1,
      title: "Luxury 3BHK Apartment",
      address: "Bandra West, Mumbai",
      price: 150.0, // in Lakhs
      monthlyRent: 75.0, // in Thousands
      annualYield: 6.0, // percentage
      area: 1200,
      areaUnit: "sqft",
      propertyType: "Apartment",
      bedrooms: 3,
      bathrooms: 3,
      furnishingStatus: "Fully Furnished",
      propertyAge: "0-5 years",
      cityId: 2,
      stateId: 2,
      images: [
        "https://images.unsplash.com/photo-1613977257363-707ba9348227",
        "https://images.unsplash.com/photo-1616594039964-ae9021a400a0",
      ],
      amenities: ["Swimming Pool", "Gym", "Park", "24/7 Security"],
      description: "Premium apartment with sea view, modern amenities and excellent connectivity.",
      isCommercial: false,
    ),
    RentalYieldModel(
      id: 2,
      title: "Spacious 2BHK Flat",
      address: "Koramangala, Bangalore",
      price: 85.0,
      monthlyRent: 35.0,
      annualYield: 4.9,
      area: 950,
      areaUnit: "sqft",
      propertyType: "Apartment",
      bedrooms: 2,
      bathrooms: 2,
      furnishingStatus: "Semi Furnished",
      propertyAge: "5-10 years",
      cityId: 4,
      stateId: 3,
      images: [
        "https://images.unsplash.com/photo-1558036117-15e82a2c9a9a",
      ],
      amenities: ["Gym", "Club House", "Power Backup"],
      description: "Well maintained apartment in prime location with good rental demand.",
      isCommercial: false,
    ),
    RentalYieldModel(
      id: 3,
      title: "Independent Villa",
      address: "Gurgaon Sector 54",
      price: 320.0,
      monthlyRent: 120.0,
      annualYield: 4.5,
      area: 2500,
      areaUnit: "sqft",
      propertyType: "Villa",
      bedrooms: 4,
      bathrooms: 4,
      furnishingStatus: "Fully Furnished",
      propertyAge: "0-5 years",
      cityId: 12,
      stateId: 1,
      images: [
        "https://images.unsplash.com/photo-1613490493576-7fde63acd811",
      ],
      amenities: ["Private Garden", "Swimming Pool", "Home Theater", "Security"],
      description: "Luxury villa with private garden and premium amenities.",
      isCommercial: false,
    ),
    RentalYieldModel(
      id: 4,
      title: "Studio Apartment",
      address: "South Delhi",
      price: 45.0,
      monthlyRent: 25.0,
      annualYield: 6.7,
      area: 500,
      areaUnit: "sqft",
      propertyType: "Studio",
      bedrooms: 1,
      bathrooms: 1,
      furnishingStatus: "Fully Furnished",
      propertyAge: "0-5 years",
      cityId: 1,
      stateId: 1,
      images: [
        "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688",
      ],
      amenities: ["Modular Kitchen", "AC", "WiFi"],
      description: "Compact and efficient studio apartment for working professionals",
      isCommercial: false,
    ),
    RentalYieldModel(
      id: 5,
      title: "Penthouse with Terrace",
      address: "Pune, Kalyani Nagar",
      price: 280.0,
      monthlyRent: 95.0,
      annualYield: 4.1,
      area: 1800,
      areaUnit: "sqft",
      propertyType: "Penthouse",
      bedrooms: 3,
      bathrooms: 3,
      furnishingStatus: "Fully Furnished",
      propertyAge: "5-10 years",
      cityId: 3,
      stateId: 2,
      images: [
        "https://images.unsplash.com/photo-1512917774080-9991f1c4c750",
      ],
      amenities: ["Private Terrace", "Jacuzzi", "Bar", "City View"],
      description: "Exclusive penthouse with panoramic city views and luxury amenities.",
      isCommercial: false,
    ),
    RentalYieldModel(
      id: 6,
      title: "Commercial Office Space",
      address: "Connaught Place, Delhi",
      price: 420.0,
      monthlyRent: 250.0,
      annualYield: 7.1,
      area: 1800,
      areaUnit: "sqft",
      propertyType: "Commercial Office",
      bedrooms: 0,
      bathrooms: 3,
      furnishingStatus: "Unfurnished",
      propertyAge: "10-20 years",
      cityId: 1,
      stateId: 1,
      images: [
        "https://images.unsplash.com/photo-1497366754035-f200968a6e72",
      ],
      amenities: ["Reception", "Conference Room", "Parking", "Elevator"],
      description: "Prime commercial office space in central business district.",
      isCommercial: true,
    ),
    RentalYieldModel(
      id: 7,
      title: "2BHK Row House",
      address: "Ahmedabad, SG Highway",
      price: 65.0,
      monthlyRent: 22.0,
      annualYield: 4.1,
      area: 1100,
      areaUnit: "sqft",
      propertyType: "Row House",
      bedrooms: 2,
      bathrooms: 2,
      furnishingStatus: "Unfurnished",
      propertyAge: "0-5 years",
      cityId: 7,
      stateId: 6,
      images: [
        "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2",
      ],
      amenities: ["Car Parking", "Garden", "Security"],
      description: "Modern row house in developing area with good appreciation potential.",
      isCommercial: false,
    ),
    RentalYieldModel(
      id: 8,
      title: "Luxury 1BHK",
      address: "Chennai, OMR",
      price: 70.0,
      monthlyRent: 32.0,
      annualYield: 5.5,
      area: 750,
      areaUnit: "sqft",
      propertyType: "Apartment",
      bedrooms: 1,
      bathrooms: 1,
      furnishingStatus: "Fully Furnished",
      propertyAge: "0-5 years",
      cityId: 5,
      stateId: 4,
      images: [
        "https://images.unsplash.com/photo-1505843513577-22bb7d21e455",
      ],
      amenities: ["Swimming Pool", "Gym", "AC", "Modular Kitchen"],
      description: "Compact luxury apartment for IT professionals near tech parks.",
      isCommercial: false,
    ),
    RentalYieldModel(
      id: 9,
      title: "Retail Shop",
      address: "Hyderabad, Banjara Hills",
      price: 95.0,
      monthlyRent: 50.0,
      annualYield: 6.3,
      area: 400,
      areaUnit: "sqft",
      propertyType: "Shop",
      bedrooms: 0,
      bathrooms: 1,
      furnishingStatus: "Unfurnished",
      propertyAge: "5-10 years",
      cityId: 6,
      stateId: 9,
      images: [ "https://images.unsplash.com/photo-1563013544-824ae1b704d3",
        ],
      amenities: ["Display Windows", "Storage", "Parking"],
      description: "Prime retail space in upscale shopping area with high footfall.",
      isCommercial: true,
    ),
    RentalYieldModel(
      id: 10,
      title: "Farm House",
      address: "Outskirts of Jaipur",
      price: 180.0,
      monthlyRent: 40.0,
      annualYield: 2.7,
      area: 3500,
      areaUnit: "sqft",
      propertyType: "Farm House",
      bedrooms: 4,
      bathrooms: 4,
      furnishingStatus: "Fully Furnished",
      propertyAge: "20+ years",
      cityId: 9,
      stateId: 7,
      images: [
        "https://images.unsplash.com/photo-1518780664697-55e3ad937233",
      ],
      amenities: ["Garden", "Pool", "Servant Quarter", "Farm Land"],
      description: "Peaceful farm house away from city with organic farming potential.",
      isCommercial: false,
    ),

  ];

  Future<void> fetchProperties() async {
    isLoading.value = true;

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Apply pagination logic
    int start = (currentPage.value - 1) * 10;
    int end = start + 10;

    if (start >= _staticProperties.length) {
      hasMore.value = false;
      properties.assignAll([]);
    } else {
      List<RentalYieldModel> newProperties = _staticProperties.sublist(
        start,
        end < _staticProperties.length ? end : _staticProperties.length,
      );

      if (currentPage.value == 1) {
        properties.assignAll(newProperties);
      } else {
        properties.addAll(newProperties);
      }

      hasMore.value = end < _staticProperties.length;
    }

    _applyFilters();
    isLoading.value = false;
  }

  void _applyFilters() {
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
      result = result.where((property) =>
      property.propertyType.toLowerCase() ==
          propertyTypes.firstWhere((type) => type.id == selectedPropertyTypeId.value).typeName.toLowerCase()
      ).toList();
    }

    // Apply price filter
    if (selectedMinPrice.value.isNotEmpty) {
      double minPrice = double.parse(selectedMinPrice.value);
      result = result.where((property) => property.price >= minPrice).toList();
    }
    if (selectedMaxPrice.value.isNotEmpty) {
      double maxPrice = double.parse(selectedMaxPrice.value);
      result = result.where((property) => property.price <= maxPrice).toList();
    }

    // Apply rent filter
    if (selectedMinRent.value.isNotEmpty) {
      double minRent = double.parse(selectedMinRent.value);
      result = result.where((property) => property.monthlyRent >= minRent).toList();
    }
    if (selectedMaxRent.value.isNotEmpty) {
      double maxRent = double.parse(selectedMaxRent.value);
      result = result.where((property) => property.monthlyRent <= maxRent).toList();
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
      result = result.where((property) => property.area >= minArea).toList();
    }
    if (selectedMaxArea.value.isNotEmpty) {
      double maxArea = double.parse(selectedMaxArea.value);
      result = result.where((property) => property.area <= maxArea).toList();
    }

    // Apply furnishing filter
    if (selectedFurnishingStatus.value.isNotEmpty) {
      result = result.where((property) =>
      property.furnishingStatus.toLowerCase() == selectedFurnishingStatus.value.toLowerCase()
      ).toList();
    }

    // Apply property age filter
    if (selectedPropertyAge.value.isNotEmpty) {
      result = result.where((property) =>
      property.propertyAge == selectedPropertyAge.value
      ).toList();
    }

    // Apply bedrooms filter
    if (selectedBedrooms.value > 0) {
      result = result.where((property) => property.bedrooms == selectedBedrooms.value).toList();
    }

    // Apply commercial filter
    if (!includeCommercial.value) {
      result = result.where((property) => !property.isCommercial).toList();
    }

    // Apply search filter
    if (searchQuery.value.isNotEmpty) {
      String query = searchQuery.value.toLowerCase();
      result = result.where((property) =>
      property.title.toLowerCase().contains(query) ||
          property.address.toLowerCase().contains(query) ||
          property.description.toLowerCase().contains(query)
      ).toList();
    }

    filteredProperties.assignAll(result);
  }

  Future<void> fetchCitiesByState(int stateId) async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (stateId == 0) {
      citiesList.assignAll(_getAllCities());
    } else {
      citiesList.assignAll(_getAllCities().where((city) => city.stateId == stateId).toList());
    }
  }

  List<CityModel> _getAllCities() {
    return [
      CityModel(id: 1, name: "New Delhi", stateId: 1),
      CityModel(id: 2, name: "Mumbai", stateId: 2),
      CityModel(id: 3, name: "Pune", stateId: 2),
      CityModel(id: 4, name: "Bangalore", stateId: 3),
      CityModel(id: 5, name: "Chennai", stateId: 4),
      CityModel(id: 6, name: "Hyderabad", stateId: 9),
      CityModel(id: 7, name: "Ahmedabad", stateId: 6),
      CityModel(id: 8, name: "Kolkata", stateId: 8),
      CityModel(id: 9, name: "Jaipur", stateId: 7),
      CityModel(id: 10, name: "Lucknow", stateId: 5),
      CityModel(id: 11, name: "Noida", stateId: 5),
      CityModel(id: 12, name: "Gurgaon", stateId: 1),
      CityModel(id: 13, name: "Chandigarh", stateId: 1),
      CityModel(id: 14, name: "Goa", stateId: 2),
      CityModel(id: 15, name: "Indore", stateId: 6),
    ];
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
      await fetchProperties();
    }
  }
}

// Supporting Models
class StateModel {
  final int id;
  final String stateName;

  StateModel({required this.id, required this.stateName});
}

class CityModel {
  final int id;
  final String name;
  final int stateId;

  CityModel({required this.id, required this.name, required this.stateId});
}

class PropertyTypeModel {
  final int id;
  final String typeName;

  PropertyTypeModel({required this.id, required this.typeName});
}


// rental_yield_model.dart

class RentalYieldModel {
  final int id;
  final String title;
  final String address;
  final double price; // in Lakhs
  final double monthlyRent; // in Thousands
  final double annualYield; // percentage
  final int area;
  final String areaUnit;
  final String propertyType;
  final int bedrooms;
  final int bathrooms;
  final String furnishingStatus;
  final String propertyAge;
  final int cityId;
  final int stateId;
  final List<String> images;
  final List<String> amenities;
  final String description;
  final bool isCommercial;

  // Additional calculated properties
  double get yearlyRent => monthlyRent * 12; // in Thousands
  double get yieldAmount => (price * 100) * (annualYield / 100); // in Lakhs

  RentalYieldModel({
    required this.id,
    required this.title,
    required this.address,
    required this.price,
    required this.monthlyRent,
    required this.annualYield,
    required this.area,
    this.areaUnit = "sqft",
    required this.propertyType,
    required this.bedrooms,
    required this.bathrooms,
    required this.furnishingStatus,
    required this.propertyAge,
    required this.cityId,
    required this.stateId,
    required this.images,
    required this.amenities,
    required this.description,
    required this.isCommercial,
  });
}