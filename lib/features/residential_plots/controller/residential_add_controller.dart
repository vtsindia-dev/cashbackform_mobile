import 'dart:convert';
import 'dart:io';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../../common/api_constant.dart';
import '../../../common/colours.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';
import '../model/residential_model.dart';
import 'package:flutter/material.dart';
class ResidentialPropertyFormController extends GetxController {
  var properties = <Property>[].obs;
  var enquiryProperties = <Property>[].obs;
  var isLoadingEnquiries = false.obs;
  var isLoading = false.obs;
  var selectedFilter = 'all'.obs;
  var filteredProperties = <Property>[].obs;
  var isSubmitting = false.obs;
  var editingPropertyId = 0.obs;
  var currentStep = 0.obs;
  var propertyName = ''.obs;
  var location = ''.obs;
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;
  var price = ''.obs;
  var aboutProperty = ''.obs;
  var areaSqft = ''.obs;
  var userType = ''.obs;
  var propertyCategories = <PropertyCategory>[].obs;
  var selectedCategoryId = 0.obs;
  var selectedSubCategoryId = 0.obs;
  var selectedStateId = 0.obs;
  var selectedCityId = 0.obs;
  var statesList = <StateList>[].obs;
  var citiesList = <CityModel>[].obs;
  var facilities = <Facility>[].obs;
  var facilityValues = <int, dynamic>{}.obs;
  var facilityControllers = <int, TextEditingController>{};
  var documents = <Document>[].obs;
  var documentFiles = <int, File?>{}.obs;
  var documentUrls = <int, String?>{}.obs;
  var availableAmenities = <AmenityItem>[].obs;
  var selectedAmenityIds = <int>[].obs;
  var nearbyPlacesList = <NearbyPlace>[].obs;
  var selectedNearbyPlaces = <Map<String, dynamic>>[].obs; // Format: [{"place_id": 2, "distance": 10}]
  var nearbyDistanceControllers = <int, TextEditingController>{};
  final MapController mapController = MapController();
  var showMap = false.obs;
  var currentPosition = const LatLng(28.6139, 77.2090).obs; // Default to Delhi
  var selectedLocation = const LatLng(28.6139, 77.2090).obs;
  var isSearchingLocation = false.obs;
  var locationSearchResults = <Place>[].obs;
  var galleryImages = <File>[].obs;
  var galleryImageUrls = <String>[].obs;
  final ImagePicker _imagePicker = ImagePicker();
  var formErrors = <String, String>{}.obs;
  var completedSteps = <int>[].obs;
  @override
  void onInit() {
    super.onInit();
    _initializeData();
    fetchMyProperties();
    fetchEnquiredProperties();
  }
  Future<void> _initializeData() async {
    try {
      isLoading(true);
      await Future.wait([
        fetchPropertyCategories(),
        fetchAvailableAmenities(),
        fetchStates(),
        getCurrentLocation(),
        fetchNearbyPlaces(),
      ]);
    } catch (e) {
      print('❌ Error initializing data: $e');
      SnackBarHelper.showError('Failed to load form data');
    } finally {
      isLoading(false);
    }
  }
  Future<void> fetchNearbyPlaces() async {
    try {
      final url = '${ApiUrl.baseUrl}/api/v2/nearby_place';
      print('🌐 Fetching nearby places from: $url');

      final response = await ApiService.getRequest(url);
      if (response.statusCode == 200) {
        final responseData = response.data;
        print('📍 Nearby places response: ${jsonEncode(responseData)}');

        if (responseData['status'] == true || responseData['status'] == 200) {
          final data = responseData['data'];
          if (data['nearby_places'] is List) {
            final places = (data['nearby_places'] as List)
                .map((item) => NearbyPlace.fromJson(item))
                .toList();
            nearbyPlacesList.assignAll(places);
            for (var place in places) {
              nearbyDistanceControllers[place.id] = TextEditingController();
            }
            print('✅ Loaded ${nearbyPlacesList.length} nearby places');
          }
        }
      }
    } catch (e) {
      print('❌ Error fetching nearby places: $e');
    }
  }
  void toggleNearbyPlace(int placeId, String? distanceText) {
    try {
      if (distanceText == null || distanceText.isEmpty) {
        SnackBarHelper.showError('Please enter distance for this place');
        return;
      }
      final distance = int.tryParse(distanceText);
      if (distance == null || distance <= 0) {
        SnackBarHelper.showError('Please enter a valid distance (positive number)');
        return;
      }
      final placeIndex = selectedNearbyPlaces.indexWhere((place) => place['place_id'] == placeId);
      if (placeIndex >= 0) {
        selectedNearbyPlaces[placeIndex] = {
          'place_id': placeId,
          'distance': distance,
        };
        print('📝 Updated nearby place: place_id=$placeId, distance=$distance');
      } else {
        selectedNearbyPlaces.add({
          'place_id': placeId,
          'distance': distance,
        });
        print('➕ Added nearby place: place_id=$placeId, distance=$distance');
      }
      update();
      SnackBarHelper.showSuccess('Nearby place updated');
    } catch (e) {
      print('❌ Error toggling nearby place: $e');
      SnackBarHelper.showError('Failed to update nearby place');
    }
  }
  void removeNearbyPlace(int placeId) {
    selectedNearbyPlaces.removeWhere((place) => place['place_id'] == placeId);
    if (nearbyDistanceControllers.containsKey(placeId)) {
      nearbyDistanceControllers[placeId]?.clear();
    }
    print('➖ Removed nearby place: $placeId');
    update();
  }
  bool isNearbyPlaceSelected(int placeId) {
    return selectedNearbyPlaces.any((place) => place['place_id'] == placeId);
  }
  int? getSelectedPlaceDistance(int placeId) {
    final place = selectedNearbyPlaces.firstWhereOrNull((place) => place['place_id'] == placeId);
    return place != null ? place['distance'] as int? : null;
  }
  Future<void> fetchPropertyCategories() async {
    try {
      final url = '${ApiUrl.baseUrl}/api/v2/plot_category';
      print('🌐 Fetching property categories from: $url');
      final response = await ApiService.getRequest(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true || response.data['status'] == 200) {
          final categories = (response.data['data'] as List)
              .map((item) => PropertyCategory.fromJson(item))
              .toList();
          propertyCategories.assignAll(categories);
          print('✅ Loaded ${propertyCategories.length} categories');
        } else {
          print('⚠️ API status false: ${response.data}');
        }
      } else {
        print('❌ HTTP Error ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      print('❌ Error fetching categories: $e');
    }
  }
  void onCategoryChanged(int categoryId) {
    print('📝 Category changed to: $categoryId');
    selectedCategoryId.value = categoryId;
    selectedSubCategoryId.value = 0;
    facilities.clear();
    facilityValues.clear();
    facilityControllers.forEach((key, controller) => controller.dispose());
    facilityControllers.clear();
    documents.clear();
    documentFiles.clear();
    documentUrls.clear();
    if (categoryId > 0) {
      fetchFacilitiesAndDocumentsByCategory(categoryId);
    }
    update();
  }
  void onSubCategoryChanged(int subCategoryId) {
    selectedSubCategoryId.value = subCategoryId;
    update();
  }
  Future<void> fetchFacilitiesAndDocumentsByCategory(int categoryId) async {
    try {
      final url = '${ApiUrl.baseUrl}/api/v2/plot_facility/$categoryId';
      print('🌐 Fetching facilities for category: $categoryId from: $url');
      final response = await ApiService.getRequest(url);
      if (response.statusCode == 200) {
        final responseData = response.data;
        print('📦 Raw facilities API response: ${jsonEncode(responseData)}');
        if (responseData['status'] == true || responseData['status'] == 200) {
          final dataList = responseData['data'] as List;
          print('📋 Total items in response: ${dataList.length}');
          final List<Facility> facilitiesList = [];
          final List<Document> documentsList = [];
          for (var item in dataList) {
            try {
              final type = (item['type'] as String? ?? '').toLowerCase();
              final name = item['name'] as String? ?? 'Unnamed';
              if (type == 'file' || type == 'document' || item['file'] != null) {
                try {
                  final document = Document.fromJson(item);
                  documentsList.add(document);
                  print('📄 Found document: ${document.name} (ID: ${document.id})');
                } catch (e) {
                  print('⚠️ Error parsing document: $e for item: $item');
                  documentsList.add(Document(
                    id: item['id'] ?? 0,
                    name: name,
                    file: item['file'],
                    type: type,
                    status: 1,
                    createdAt: item['created_at'] ?? DateTime.now().toIso8601String(),
                    updatedAt: item['updated_at'] ?? DateTime.now().toIso8601String(),
                    description: null,
                    helpText: null,
                    allowedFormats: ['pdf', 'jpg', 'png', 'jpeg', 'doc', 'docx'],
                    maxSize: 2048,
                    isRequired: item['is_required'] ?? 1,
                  ));
                }
              } else {
                try {
                  final facility = Facility.fromJson(item);
                  facilitiesList.add(facility);
                  print('📝 Found facility: ${facility.name} (Type: ${facility.type})');
                } catch (e) {
                  print('⚠️ Error parsing facility: $e for item: $item');
                }
              }
            } catch (e) {
              print('⚠️ Error processing item: $e, Item: $item');
            }
          }
          facilities.assignAll(facilitiesList);
          documents.assignAll(documentsList);
          print('✅ Loaded ${facilities.length} facilities and ${documents.length} documents');
          for (var facility in facilities) {
            facilityControllers[facility.id] = TextEditingController();
            if (facility.name.toLowerCase().contains('posted by') &&
                facility.dropdownValues.isNotEmpty) {
              facilityValues[facility.id] = facility.dropdownValues.first;
              userType.value = facility.dropdownValues.first;
            }
          }
          update();
        } else {
          print('❌ API status false: $responseData');
        }
      } else {
        print('❌ HTTP Error ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      print('❌ Error fetching facilities: $e');
      SnackBarHelper.showError('Failed to load facilities and documents');
    }
  }
  void updateFacilityValue(int facilityId, dynamic value) {
    facilityValues[facilityId] = value;

    final facility = facilities.firstWhereOrNull((f) => f.id == facilityId);
    if (facility != null && facility.name.toLowerCase().contains('posted by')) {
      userType.value = value.toString();
    }

    update(['facility_$facilityId']);
  }

  // ===========================
  // DOCUMENT HANDLING
  // ===========================

  Future<void> pickDocumentFile(int documentId) async {
    try {
      print('📎 Picking document for ID: $documentId');
      final document = documents.firstWhereOrNull((doc) => doc.id == documentId);
      if (document == null) {
        print('❌ Document not found for ID: $documentId');
        SnackBarHelper.showError('Document not found');
        return;
      }

      print('📎 Document details: ${document.name}, Allowed formats: ${document.allowedFormats}');

      // Show file picker options
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        print('📎 File picked: ${pickedFile.path}');
        final file = File(pickedFile.path);
        final fileSize = await file.length();
        final fileSizeKB = fileSize / 1024;

        // Check file size
        if (document.maxSize != null && fileSizeKB > document.maxSize!) {
          SnackBarHelper.showError('File size must be less than ${document.maxSize}KB (Current: ${fileSizeKB.toStringAsFixed(1)}KB)');
          return;
        }

        // Check file format
        if (document.allowedFormats != null && document.allowedFormats!.isNotEmpty) {
          final extension = pickedFile.path.split('.').last.toLowerCase();
          final isAllowed = document.allowedFormats!.any((format) {
            final formatLower = format.toLowerCase().replaceAll('.', '');
            return formatLower == extension;
          });

          if (!isAllowed) {
            SnackBarHelper.showError('Allowed formats: ${document.allowedFormats!.join(', ')}');
            return;
          }
        }

        documentFiles[documentId] = file;
        print('✅ Document file saved for ID: $documentId');
        update();
        SnackBarHelper.showSuccess('${document.name} uploaded successfully');
      }
    } catch (e) {
      print('❌ Error picking document: $e');
      SnackBarHelper.showError('Failed to pick document: ${e.toString()}');
    }
  }

  void removeDocumentFile(int documentId) {
    print('🗑️ Removing document file for ID: $documentId');
    documentFiles.remove(documentId);
    documentUrls.remove(documentId);
    update();
    SnackBarHelper.showSuccess('Document removed');
  }

  // ===========================
  // AMENITIES
  // ===========================

  Future<void> fetchAvailableAmenities() async {
    try {
      final url = '${ApiUrl.baseUrl}/api/v2/amenities';
      print('🌐 Fetching amenities from: $url');

      final response = await ApiService.getRequest(url);
      if (response.statusCode == 200) {
        final responseData = response.data;
        final status = responseData['status'];
        final isSuccess = status == true || status == 200;

        if (isSuccess) {
          final amenitiesArray = responseData['data']['amenities'] as List<dynamic>?;
          if (amenitiesArray != null) {
            final amenitiesList = amenitiesArray
                .map((item) => AmenityItem.fromJson(item as Map<String, dynamic>))
                .toList();
            availableAmenities.assignAll(amenitiesList);
            print('✅ Loaded ${availableAmenities.length} amenities');
          }
        }
      }
    } catch (e) {
      print('❌ Error fetching amenities: $e');
    }
  }

  void toggleAmenitySelection(int amenityId) {
    if (selectedAmenityIds.contains(amenityId)) {
      selectedAmenityIds.remove(amenityId);
      print('➖ Removed amenity: $amenityId');
    } else {
      selectedAmenityIds.add(amenityId);
      print('➕ Added amenity: $amenityId');
    }
    update();
  }

  // ===========================
  // STATES & CITIES
  // ===========================

  Future<void> fetchStates() async {
    try {
      final url = '${ApiUrl.baseUrl}/api/v2/state';
      print('🌐 Fetching states from: $url');

      final response = await ApiService.getRequest(url);
      if (response.statusCode == 200 &&
          (response.data['status'] == true || response.data['status'] == 200)) {
        final states = (response.data['data'] as List)
            .map((item) => StateList.fromJson(item))
            .toList();
        statesList.assignAll(states);
        print('✅ Loaded ${statesList.length} states');
      }
    } catch (e) {
      print('❌ Error fetching states: $e');
    }
  }

  Future<void> fetchCitiesByState(int stateId) async {
    try {
      final url = '${ApiUrl.baseUrl}/api/v2/city/$stateId';
      print('🌐 Fetching cities for state: $stateId from: $url');

      final response = await ApiService.getRequest(url);
      if (response.statusCode == 200 && response.data['status'] == 200) {
        final cities = (response.data['data'] as List)
            .map((item) => CityModel.fromJson(item))
            .toList();
        citiesList.assignAll(cities);
        print('✅ Loaded ${citiesList.length} cities for state $stateId');
      } else {
        citiesList.clear();
        print('⚠️ No cities found for state: $stateId');
      }
    } catch (e) {
      print('❌ Error fetching cities: $e');
      citiesList.clear();
    }
  }

  void onStateChanged(int stateId) {
    print('🗺️ State changed to: $stateId');
    selectedStateId.value = stateId;
    selectedCityId.value = 0;
    citiesList.clear();

    if (stateId > 0) {
      fetchCitiesByState(stateId);
    }
    update();
  }

  void onCityChanged(int cityId) {
    selectedCityId.value = cityId;
    print('🏙️ City changed to: $cityId');
    update();
  }

  // ===========================
  // LOCATION & REVERSE GEOCODING
  // ===========================

  Future<void> getCurrentLocation() async {
    try {
      print('📍 Getting current location...');

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('⚠️ Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('⚠️ Location permission permanently denied');
        return;
      }

      // Get position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(const Duration(seconds: 10));

      print('📍 Position: ${position.latitude}, ${position.longitude}');

      currentPosition.value = LatLng(position.latitude, position.longitude);
      selectedLocation.value = currentPosition.value;
      latitude.value = position.latitude;
      longitude.value = position.longitude;

      // Get address
      await _reverseGeocode(selectedLocation.value);

      update();

    } catch (e) {
      print('❌ Error getting location: $e');
      // Set default location
      latitude.value = 28.6139;
      longitude.value = 77.2090;
      location.value = 'Delhi, India';
      update();
    }
  }

  Future<void> _reverseGeocode(LatLng point) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );

      if (placemarks.isNotEmpty) {
        final address = _buildAddressFromPlacemark(placemarks.first);
        location.value = address;
        print('📍 Address: $address');
        update();
      }
    } catch (e) {
      print('❌ Reverse geocode error: $e');
    }
  }

  String _buildAddressFromPlacemark(Placemark placemark) {
    final parts = <String>[];
    if (placemark.street?.isNotEmpty == true) parts.add(placemark.street!);
    if (placemark.subLocality?.isNotEmpty == true) parts.add(placemark.subLocality!);
    if (placemark.locality?.isNotEmpty == true) parts.add(placemark.locality!);
    if (placemark.administrativeArea?.isNotEmpty == true) parts.add(placemark.administrativeArea!);
    if (placemark.country?.isNotEmpty == true) parts.add(placemark.country!);
    return parts.join(', ');
  }

  void onMapTap(LatLng point) {
    selectedLocation.value = point;
    latitude.value = point.latitude;
    longitude.value = point.longitude;
    _reverseGeocode(point);
    mapController.move(point, 15);
    update();
  }

  Future<void> searchLocation(String query) async {
    if (query.length < 3) return;

    try {
      isSearchingLocation(true);
      final locations = await locationFromAddress(query);
      locationSearchResults.assignAll(
        locations.map((loc) => Place(
          coordinates: Coordinates(loc.latitude, loc.longitude),
          name: query,
          address: '',
        )).toList(),
      );
    } catch (e) {
      print('❌ Search error: $e');
    } finally {
      isSearchingLocation(false);
    }
  }

  void selectSearchLocation(Place place) {
    selectedLocation.value = place.coordinates.toLatLng();
    latitude.value = place.coordinates.latitude;
    longitude.value = place.coordinates.longitude;
    location.value = place.address.isNotEmpty ? place.address : place.name;
    mapController.move(selectedLocation.value, 15);
    locationSearchResults.clear();
    update();
  }

  // ===========================
  // MEDIA HANDLING
  // ===========================

  Future<void> pickGalleryImages() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (pickedFiles != null) {
        for (var pickedFile in pickedFiles) {
          if (galleryImages.length < 10) {
            galleryImages.add(File(pickedFile.path));
          } else {
            SnackBarHelper.showError('Maximum 10 images allowed');
            break;
          }
        }
        print('📸 Added ${pickedFiles.length} images, Total: ${galleryImages.length}');
        update();
      }
    } catch (e) {
      print('❌ Error picking images: $e');
      SnackBarHelper.showError('Failed to pick images');
    }
  }

  void removeGalleryImage(int index) {
    if (index >= 0 && index < galleryImages.length) {
      galleryImages.removeAt(index);
      print('🗑️ Removed image at index $index');
      update();
    }
  }

  // ===========================
  // FORM VALIDATION
  // ===========================

  Map<String, String> validateCurrentStep() {
    formErrors.clear();

    switch (currentStep.value) {
      case 0: // Basic Info
        if (propertyName.value.isEmpty) formErrors['property_name'] = 'Property name is required';
        if (selectedCategoryId.value <= 0) formErrors['category_id'] = 'Please select a category';
        if (price.value.isEmpty) formErrors['price'] = 'Price is required';
        if (areaSqft.value.isEmpty) formErrors['area_sqft'] = 'Area is required';
        break;

      case 1: // Facilities
        for (var facility in facilities) {
          if (facility.isRequired == 1) {
            final value = facilityValues[facility.id];
            if (value == null || value.toString().isEmpty) {
              formErrors['facility_${facility.id}'] = '${facility.name} is required';
            }
          }
        }
        // Also validate required documents
        for (var document in documents) {
          if (document.isRequired == 1 &&
              !documentFiles.containsKey(document.id) &&
              !documentUrls.containsKey(document.id)) {
            formErrors['document_${document.id}'] = '${document.name} is required';
          }
        }
        break;

      case 2: // Media
        if (galleryImages.isEmpty) formErrors['gallery'] = 'At least one image is required';
        break;

      case 3: // Location
        if (location.value.isEmpty) formErrors['location'] = 'Location is required';
        if (latitude.value == 0.0 || longitude.value == 0.0) {
          formErrors['coordinates'] = 'Please select location on map';
        }
        break;
    }

    return formErrors;
  }

  bool isStepValid() => validateCurrentStep().isEmpty;

  void markStepComplete(int step) {
    if (!completedSteps.contains(step)) completedSteps.add(step);
  }

  void nextStep() {
    if (isStepValid()) {
      markStepComplete(currentStep.value);
      if (currentStep.value < 3) {
        currentStep.value++;
      } else {
        _submitProperty();
      }
    } else {
      final errors = validateCurrentStep();
      if (errors.isNotEmpty) {
        SnackBarHelper.showError(errors.values.first);
      }
    }
  }

  void previousStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  // ===========================
  // LOAD PROPERTY FOR EDITING
  // ===========================

  Future<void> loadPropertyForEditing(int propertyId) async {
    try {
      isLoading(true);
      editingPropertyId.value = propertyId;

      final url = '${ApiUrl.baseUrl}/api/v2/plot_details/$propertyId';
      final response = await ApiService.getRequest(url);

      if (response.statusCode == 200 &&
          (response.data['status'] == true || response.data['status'] == 200)) {

        final property = Property.fromJson(response.data['data']);

        // Set basic fields
        propertyName.value = property.propertyName;
        price.value = property.price.toString();
        areaSqft.value = property.areaSqft.toString();
        aboutProperty.value = property.aboutProperty ?? '';
        location.value = property.location;
        latitude.value = double.tryParse(property.lat ?? '0') ?? 0.0;
        longitude.value = double.tryParse(property.lng ?? '0') ?? 0.0;
        selectedLocation.value = LatLng(latitude.value, longitude.value);

        // Load category and facilities
        selectedCategoryId.value = property.categoryId;
        if (selectedCategoryId.value > 0) {
          await fetchFacilitiesAndDocumentsByCategory(selectedCategoryId.value);

          // Set facility values from property
          if (property.facilities != null && property.facilities!.isNotEmpty) {
            for (var facility in facilities) {
              for (var propFacility in property.facilities!) {
                if (propFacility.facilityName?.toLowerCase() == facility.name.toLowerCase() ||
                    propFacility.name?.toLowerCase() == facility.name.toLowerCase()) {
                  if (propFacility.value?.isNotEmpty == true) {
                    facilityValues[facility.id] = propFacility.value;
                  }
                  break;
                }
              }
            }
          }
        }

        // Set amenities
        selectedAmenityIds.assignAll(property.amenitiesAll.map((a) => a.id).toList());

        // Set existing images
        galleryImageUrls.assignAll(property.galleryImages);

        // Set nearby places if available
        if (property.nearbyPlaces != null && property.nearbyPlaces!.isNotEmpty) {
          selectedNearbyPlaces.assignAll(property.nearbyPlaces!);
          // Set distance controllers
          for (var place in property.nearbyPlaces!) {
            final placeId = place['place_id'] as int? ?? 0;
            final distance = place['distance'] as int? ?? 0;
            if (placeId > 0 && nearbyDistanceControllers.containsKey(placeId)) {
              nearbyDistanceControllers[placeId]?.text = distance.toString();
            }
          }
        }

        // Mark steps as complete
        completedSteps.assignAll([0, 1, 2, 3]);

        print('✅ Property loaded for editing: ${property.propertyName}');
      }
    } catch (e) {
      print('❌ Error loading property: $e');
      SnackBarHelper.showError('Failed to load property details');
    } finally {
      isLoading(false);
    }
  }

  // ===========================
  // FETCH MY PROPERTIES
  // ===========================

  Future<void> fetchMyProperties() async {
    try {
      isLoading(true);
      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        SnackBarHelper.showError('Please login to continue');
        return;
      }

      final url = '${ApiUrl.baseUrl}/api/v2/my_residential_plots';
      print('🌐 Fetching my properties from: $url');

      final response = await ApiService.getRequest(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('📦 My properties response: ${jsonEncode(responseData)}');

        if (responseData['status'] == true || responseData['status'] == 200) {
          final dynamic data = responseData['data'];

          List<Property> propertiesList = [];

          // Handle both List and Map responses
          if (data is List) {
            // If data is already a List
            propertiesList = (data as List)
                .map((item) => Property.fromJson(item))
                .toList();
          } else if (data is Map<String, dynamic>) {
            // If data is a Map, check for common keys that might contain the list
            if (data.containsKey('plots') && data['plots'] is List) {
              propertiesList = (data['plots'] as List)
                  .map((item) => Property.fromJson(item))
                  .toList();
            } else if (data.containsKey('properties') && data['properties'] is List) {
              propertiesList = (data['properties'] as List)
                  .map((item) => Property.fromJson(item))
                  .toList();
            } else if (data.containsKey('data') && data['data'] is List) {
              propertiesList = (data['data'] as List)
                  .map((item) => Property.fromJson(item))
                  .toList();
            } else if (data.containsKey('items') && data['items'] is List) {
              propertiesList = (data['items'] as List)
                  .map((item) => Property.fromJson(item))
                  .toList();
            } else {
              // Try to check if the Map has structure that indicates it's a single property
              // wrapped in a Map instead of List
              try {
                // Check if this Map has property-like keys
                if (data.containsKey('property_name') || data.containsKey('id')) {
                  propertiesList = [Property.fromJson(data)];
                } else {
                  // Extract all values that might be Lists
                  for (var value in data.values) {
                    if (value is List) {
                      propertiesList = (value as List)
                          .map((item) => Property.fromJson(item))
                          .toList();
                      break;
                    }
                  }
                }
              } catch (e) {
                print('⚠️ Could not parse properties from Map: $e');
              }
            }
          } else {
            print('⚠️ Unexpected data type: ${data.runtimeType}');
          }
          properties.assignAll(propertiesList);
          filteredProperties.assignAll(propertiesList);
          print('✅ Loaded ${properties.length} properties');
        } else {
          print('❌ API status false: ${response.data}');
          SnackBarHelper.showError(responseData['message'] ?? 'Failed to load properties');
        }
      } else {
        print('❌ HTTP Error ${response.statusCode}: ${response.data}');
        SnackBarHelper.showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching properties: $e');
      SnackBarHelper.showError('Failed to load properties: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }
  Future<void> _submitProperty() async {
    try {
      if (!isStepValid()) {
        SnackBarHelper.showError('Please fix all errors before submitting');
        return;
      }
      isSubmitting(true);
      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        SnackBarHelper.showError('Please login to continue');
        isSubmitting(false);
        return;
      }
      final requestData = await _prepareRequestData();
      final url = editingPropertyId.value > 0
          ? '${ApiUrl.baseUrl}/api/v2/plot_update/${editingPropertyId.value}'
          : '${ApiUrl.baseUrl}/api/v2/plot_store';
      print('🚀 Submitting property to: $url');
      print('📦 Request data keys: ${requestData.keys.toList()}');
      print('📍 Nearby places to submit: ${requestData['nearby_places']}');
      final multipartData = Map<String, dynamic>.from(requestData);
      final facilitiesData = requestData['facilities'];
      if (facilitiesData != null) {
        multipartData.remove('facilities');
        final Map<String, dynamic> parsedFacilities = jsonDecode(facilitiesData);
        for (var entry in parsedFacilities.entries) {
          multipartData['facilities[${entry.key}]'] = entry.value.toString();
          print('   - facilities[${entry.key}]: ${entry.value}');
        }
      }

      final response = await ApiService.postMultipartRequest(
        url: url,
        data: multipartData,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      _handleSubmissionResponse(response);
    } catch (e) {
      print('❌ Submit error: $e');
      SnackBarHelper.showError('Error: ${e.toString()}');
    } finally {
      isSubmitting(false);
    }
  }

  void _handleSubmissionResponse(dynamic response) {
    print('📨 Response status: ${response.statusCode}');
    print('📨 Response data: ${response.data}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = response.data;
      if (responseData['status'] == true || responseData['status'] == 200) {
        SnackBarHelper.showSuccess(responseData['message'] ?? 'Property saved successfully!');
        resetForm();
        Get.back();
        // Refresh the properties list
        fetchMyProperties();
      } else {
        SnackBarHelper.showError(responseData['message'] ?? 'Failed to save property');
      }
    } else {
      SnackBarHelper.showError('Server error: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> _prepareRequestData() async {
    final data = <String, dynamic>{
      'property_name': propertyName.value,
      'category_id': selectedCategoryId.value,
      'price': price.value,
      'area_sqft': areaSqft.value,
      'location': location.value,
      'lat': latitude.value.toString(),
      'lng': longitude.value.toString(),
      'about_property': aboutProperty.value,
      'user_type': userType.value.isNotEmpty ? userType.value : 'customer',
    };

    if (selectedStateId.value > 0) data['state'] = selectedStateId.value;
    if (selectedCityId.value > 0) data['city'] = selectedCityId.value;
    if (selectedSubCategoryId.value > 0) data['sub_category_id'] = selectedSubCategoryId.value;
    if (selectedAmenityIds.isNotEmpty) data['amenities_data'] = selectedAmenityIds.join(',');

    // Add facilities data in JSON format
    final facilitiesData = <String, dynamic>{};
    for (var facility in facilities) {
      if (facility.type != 'file' && facility.type != 'document') {
        final value = facilityValues[facility.id];
        if (value != null && value.toString().isNotEmpty) {
          facilitiesData[facility.id.toString()] = value;
        }
      }
    }
    if (facilitiesData.isNotEmpty) {
      data['facilities'] = jsonEncode(facilitiesData);
    }

    // Add nearby places in the required format
    if (selectedNearbyPlaces.isNotEmpty) {
      data['nearby_places'] = jsonEncode(selectedNearbyPlaces);
      print('📍 Nearby places JSON: ${data['nearby_places']}');
    }

    // Add existing data for edit mode
    if (editingPropertyId.value > 0) {
      if (galleryImageUrls.isNotEmpty) data['existing_images'] = galleryImageUrls.join(',');

      final existingDocs = <String, String>{};
      for (var entry in documentUrls.entries) {
        if (entry.value != null) existingDocs[entry.key.toString()] = entry.value!;
      }
      if (existingDocs.isNotEmpty) data['existing_documents'] = jsonEncode(existingDocs);
    }

    return data;
  }

  // ===========================
  // RESET FORM
  // ===========================

  void resetForm() {
    propertyName.value = '';
    location.value = '';
    latitude.value = 0.0;
    longitude.value = 0.0;
    price.value = '';
    aboutProperty.value = '';
    areaSqft.value = '';
    userType.value = '';

    selectedCategoryId.value = 0;
    selectedSubCategoryId.value = 0;
    selectedStateId.value = 0;
    selectedCityId.value = 0;

    facilities.clear();
    facilityValues.clear();
    facilityControllers.forEach((key, controller) => controller.dispose());
    facilityControllers.clear();

    documents.clear();
    documentFiles.clear();
    documentUrls.clear();

    selectedAmenityIds.clear();
    selectedNearbyPlaces.clear();
    nearbyDistanceControllers.forEach((key, controller) => controller.clear());

    galleryImages.clear();
    galleryImageUrls.clear();

    editingPropertyId.value = 0;
    currentStep.value = 0;
    completedSteps.clear();
    formErrors.clear();
    showMap.value = false;

    update();
  }


  void setFilter(String filter) {
    selectedFilter.value = filter;
    if (filter == 'all') {
      filteredProperties.assignAll(properties);
    } else {
      filteredProperties.assignAll(
          properties.where((property) =>
          (property.status ?? '').toLowerCase() == filter.toLowerCase()
          ).toList()
      );
    }
  }

  void clearFilter() {
    selectedFilter.value = 'all';
    filteredProperties.assignAll(properties);
  }
  Future<void> fetchEnquiredProperties() async {
    try {
      isLoadingEnquiries(true);
      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        SnackBarHelper.showError('Please login to continue');
        return;
      }

      final url = '${ApiUrl.baseUrl}/api/v2/plot_enquiry_list';
      print('🌐 Fetching enquired properties from: $url');

      final response = await ApiService.getRequest(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('📦 Enquired properties response: ${jsonEncode(responseData)}');

        if (responseData['status'] == true || responseData['status'] == 200) {
          final data = responseData['data'];
          List<Property> propertiesList = [];

          if (data is Map<String, dynamic> && data.containsKey('plot')) {
            final plotsList = data['plot'] as List;

            // Extract nested plot objects from each enquiry
            propertiesList = plotsList.map((enquiryItem) {
              try {
                if (enquiryItem is Map<String, dynamic> &&
                    enquiryItem.containsKey('plot') &&
                    enquiryItem['plot'] is Map<String, dynamic>) {

                  final plotData = Map<String, dynamic>.from(enquiryItem['plot']);

                  // Debug: Print original data types
                  print('🔍 Original plotData types:');
                  plotData.forEach((key, value) {
                    print('   $key: ${value.runtimeType}');
                  });

                  // Handle amenities: Keep as List (don't convert to String!)
                  if (plotData.containsKey('amenities')) {
                    if (plotData['amenities'] is List) {
                      // Keep as List, Property.fromJson will handle conversion to List<String>
                      // This is correct: amenities should remain List
                    } else if (plotData['amenities'] is String) {
                      // If it's a string, try to parse it as JSON or split by comma
                      final amenitiesString = plotData['amenities'] as String;
                      if (amenitiesString.startsWith('[')) {
                        try {
                          plotData['amenities'] = jsonDecode(amenitiesString);
                        } catch (e) {
                          plotData['amenities'] = amenitiesString.split(',');
                        }
                      } else {
                        plotData['amenities'] = amenitiesString.split(',');
                      }
                    }
                  }

                  // Handle gallery_images: Ensure it's List<String>
                  if (plotData.containsKey('gallery_images')) {
                    if (plotData['gallery_images'] is String) {
                      final galleryString = plotData['gallery_images'] as String;
                      if (galleryString.startsWith('[')) {
                        try {
                          plotData['gallery_images'] = jsonDecode(galleryString);
                        } catch (e) {
                          plotData['gallery_images'] = galleryString.split(',');
                        }
                      } else {
                        plotData['gallery_images'] = galleryString.split(',');
                      }
                    }
                    // If it's already List, keep it as is
                  }

                  // Handle nearby_places: Ensure it's List<Map<String, dynamic>>
                  if (plotData.containsKey('nearby_places')) {
                    if (plotData['nearby_places'] is String) {
                      final nearbyString = plotData['nearby_places'] as String;
                      if (nearbyString.isNotEmpty) {
                        try {
                          plotData['nearby_places'] = jsonDecode(nearbyString);
                        } catch (e) {
                          print('⚠️ Failed to parse nearby_places JSON: $e');
                          plotData['nearby_places'] = [];
                        }
                      }
                    }
                    // If it's already List, keep it as is
                  }

                  // DON'T convert to String! The Property model expects Lists
                  // Remove the _sanitizePlotData call entirely

                  // Add enquiry metadata to the property
                  if (enquiryItem.containsKey('id')) {
                    plotData['enquiry_id'] = enquiryItem['id'];
                  }
                  if (enquiryItem.containsKey('residential_id')) {
                    plotData['enquiry_residential_id'] = enquiryItem['residential_id'];
                  }
                  if (enquiryItem.containsKey('user_id')) {
                    plotData['enquiry_user_id'] = enquiryItem['user_id'];
                  }
                  if (enquiryItem.containsKey('count')) {
                    plotData['enquiry_count'] = enquiryItem['count'];
                  }

                  // Debug: Print processed data types
                  print('🔍 Processed plotData types for ${plotData['property_name']}:');
                  print('   amenities: ${plotData['amenities']?.runtimeType}');
                  print('   gallery_images: ${plotData['gallery_images']?.runtimeType}');
                  print('   nearby_places: ${plotData['nearby_places']?.runtimeType}');

                  return Property.fromJson(plotData);
                }
              } catch (e) {
                print('❌ Error processing enquiry item: $e');
                print('❌ Stack trace: ${e.toString()}');
                print('❌ Enquiry item: ${jsonEncode(enquiryItem)}');
              }
              return Property.fromJson({}); // Return empty property if structure is invalid
            }).toList();
          }

          enquiryProperties.assignAll(propertiesList);
          print('✅ Loaded ${propertiesList.length} enquired properties');
        } else {
          print('❌ API status false for enquiries: ${response.data}');
        }
      } else {
        print('❌ HTTP Error ${response.statusCode} for enquiries: ${response.data}');
      }
    } catch (e) {
      print('❌ Error fetching enquired properties: $e');
      SnackBarHelper.showError('Failed to load enquiries: ${e.toString()}');
    } finally {
      isLoadingEnquiries(false);
    }
  }

// REMOVE or FIX the _sanitizePlotData method - DON'T use it for enquired properties
// Or update it to NOT convert Lists to Strings:
  void _sanitizePlotData(Map<String, dynamic> plotData) {
    // DON'T convert Lists to Strings - Property model expects Lists
    // Only handle type safety for other fields

    // Ensure string fields are strings
    final stringFields = ['status', 'transaction_type', 'user_type'];
    for (var field in stringFields) {
      if (plotData.containsKey(field) && plotData[field] != null) {
        plotData[field] = plotData[field].toString();
      }
    }

    // Handle numeric conversions
    if (plotData.containsKey('price') && plotData['price'] != null) {
      if (plotData['price'] is! String) {
        plotData['price'] = plotData['price'].toString();
      }
    }
    if (plotData.containsKey('area_sqft') && plotData['area_sqft'] != null) {
      if (plotData['area_sqft'] is! String) {
        plotData['area_sqft'] = plotData['area_sqft'].toString();
      }
    }
  }  Future<void> deleteProperty(int propertyId, int index) async {
    try {
      // Show loading
      Get.dialog(
        Center(child: CircularProgressIndicator(color: AppColor.primary)),
        barrierDismissible: false,
      );

      // Call delete API
      // Example: final response = await ApiService.deleteRequest('${ApiUrl.baseUrl}/api/v2/plot_delete/$propertyId');

      Get.back(); // Close loading dialog

      // Remove from list
      if (index >= 0 && index < properties.length) {
        properties.removeAt(index);
      }

      SnackBarHelper.showSuccess('Property deleted successfully');
    } catch (e) {
      Get.back(); // Close loading dialog
      print('Error deleting property: $e');
      SnackBarHelper.showError('Failed to delete property');
    }
  }

  @override
  void onClose() {
    facilityControllers.forEach((key, controller) => controller.dispose());
    nearbyDistanceControllers.forEach((key, controller) => controller.dispose());
    mapController.dispose();
    super.onClose();
  }
}