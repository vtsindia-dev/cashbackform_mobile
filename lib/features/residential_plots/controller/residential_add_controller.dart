import 'dart:convert';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../../common/api_constant.dart';
import '../../../common/colours.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';
import '../../menu/controller/dashboard_menu_controller.dart';
import '../../payment/controller/razorpay_controller.dart';
import '../model/residential_model.dart';
import 'package:flutter/material.dart';

class ResidentialPropertyFormController extends GetxController {
  // Observable variables
  var properties = <Property>[].obs;
  var enquiryProperties = <Property>[].obs;
  var isLoadingEnquiries = false.obs;
  var isLoading = false.obs;
  var selectedFilter = 'all'.obs;
  var filteredProperties = <Property>[].obs;
  var isSubmitting = false.obs;
  var editingPropertyId = 0.obs;
  var currentStep = 0.obs;

  // Form fields
  var propertyName = ''.obs;
  var location = ''.obs;
  var latitude = 0.0.obs;
  var longitude = 0.0.obs;
  var price = ''.obs;
  var pricePerSqft = ''.obs;
  var aboutProperty = ''.obs;
  var areaSqft = ''.obs;
  var userType = ''.obs;

  // Categories
  var propertyCategories = <PropertyCategory>[].obs;
  var selectedCategoryId = 0.obs;
  var selectedSubCategoryId = 0.obs;

  // Location
  var selectedStateId = 0.obs;
  var selectedCityId = 0.obs;
  var statesList = <StateList>[].obs;
  var citiesList = <CityModel>[].obs;

  // Facilities
  var facilities = <Facility>[].obs;
  var facilityValues = <int, dynamic>{}.obs;
  var facilityControllers = <int, TextEditingController>{};

  // Documents
  var documents = <Document>[].obs;
  var documentFiles = <int, File?>{}.obs;
  var documentUrls = <int, String?>{}.obs;

  // Amenities
  var availableAmenities = <AmenityItem>[].obs;
  var selectedAmenityIds = <int>[].obs;

  // Nearby Places
  var nearbyPlacesList = <NearbyPlace>[].obs;
  var selectedNearbyPlaces = <Map<String, dynamic>>[].obs;
  var nearbyDistanceControllers = <int, TextEditingController>{};

  // Map
  final MapController mapController = MapController();
  var showMap = false.obs;
  var currentPosition = const LatLng(28.6139, 77.2090).obs;
  var selectedLocation = const LatLng(28.6139, 77.2090).obs;
  var isSearchingLocation = false.obs;
  var locationSearchResults = <Place>[].obs;

  // Images
  var galleryImages = <File>[].obs;
  var galleryImageUrls = <String>[].obs;
  var threeDImageFile = Rxn<File>();
  var threeDImageUrl = ''.obs;
  final ImagePicker _imagePicker = ImagePicker();

  // Validation
  var formErrors = <String, String>{}.obs;
  var completedSteps = <int>[].obs;

  // Original property for comparison
  var _originalProperty = Rx<Property?>(null);

  @override
  void onInit() {
    super.onInit();
    _initializeData();
    fetchMyProperties();
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

  // ==================== RESET METHODS ====================

  void resetFormForEdit() {
    print('🔄 Resetting form for edit');

    // Clear editing data
    galleryImageUrls.clear();
    galleryImages.clear();
    selectedAmenityIds.clear();
    selectedNearbyPlaces.clear();
    documentFiles.clear();
    documentUrls.clear();
    facilityValues.clear();
    threeDImageFile.value = null;
    threeDImageUrl.value = '';

    // Clear all controllers
    facilityControllers.forEach((key, controller) => controller.clear());
    nearbyDistanceControllers.forEach((key, controller) => controller.clear());

    // Reset form fields
    propertyName.value = '';
    location.value = '';
    price.value = '';
    pricePerSqft.value = '';
    aboutProperty.value = '';
    areaSqft.value = '';
    userType.value = '';

    // Reset selections
    selectedCategoryId.value = 0;
    selectedSubCategoryId.value = 0;
    selectedStateId.value = 0;
    selectedCityId.value = 0;

    // Reset step
    currentStep.value = 0;
    completedSteps.clear();

    _originalProperty.value = null;

    update();
  }

  void resetForm() {
    print('🔄 Resetting form completely');
    resetFormForEdit();

    // Clear additional data
    propertyCategories.clear();
    statesList.clear();
    citiesList.clear();
    facilities.clear();
    documents.clear();
    availableAmenities.clear();
    nearbyPlacesList.clear();

    // Clear all controllers
    facilityControllers.clear();
    nearbyDistanceControllers.clear();

    // Reset map
    selectedLocation.value = const LatLng(28.6139, 77.2090);
    latitude.value = 28.6139;
    longitude.value = 77.2090;
    showMap.value = false;

    editingPropertyId.value = 0;

    update();
  }

  // ==================== 3D IMAGE HANDLING ====================

  Future<void> pick3DImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();
        final fileSizeMB = fileSize / (1024 * 1024);

        if (fileSizeMB > 10) {
          SnackBarHelper.showError('3D image size must be less than 10MB');
          return;
        }

        final extension = pickedFile.path.split('.').last.toLowerCase();
        final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'svg', 'glb', 'gltf'];
        if (!allowedExtensions.contains(extension)) {
          SnackBarHelper.showError('Allowed formats: ${allowedExtensions.join(', ')}');
          return;
        }

        threeDImageFile.value = file;
        update();
        SnackBarHelper.showSuccess('3D image selected');
      }
    } catch (e) {
      print('❌ Error picking 3D image: $e');
      SnackBarHelper.showError('Failed to pick 3D image');
    }
  }

  void remove3DImage() {
    threeDImageFile.value = null;
    threeDImageUrl.value = '';
    update();
    SnackBarHelper.showSuccess('3D image removed');
  }

  // ==================== PROPERTY LOADING ====================

  Future<void> loadPropertyForEditing(int propertyId) async {
    try {
      isLoading(true);
      editingPropertyId.value = propertyId;

      print('🔄 Loading property for editing ID: $propertyId');

      final url = '${ApiUrl.baseUrl}/api/v2/plot_details/$propertyId';
      final response = await ApiService.getRequest(url);

      if (response.statusCode == 200 &&
          (response.data['status'] == true || response.data['status'] == 200)) {

        final property = Property.fromJson(response.data['data']);
        _originalProperty.value = property;

        print('✅ Property loaded: ${property.propertyName}');

        // 1. Set basic fields
        propertyName.value = property.propertyName;
        price.value = property.price.toString();

        if (property.price != null && property.areaSqft != null && property.areaSqft! > 0) {
          final pricePerSqftValue = property.price! / property.areaSqft!;
          pricePerSqft.value = pricePerSqftValue.toStringAsFixed(2);
        }

        areaSqft.value = property.areaSqft.toString();
        aboutProperty.value = property.aboutProperty;
        location.value = property.location;
        latitude.value = double.tryParse(property.lat ?? '0') ?? 0.0;
        longitude.value = double.tryParse(property.lng ?? '0') ?? 0.0;
        selectedLocation.value = LatLng(latitude.value, longitude.value);

        // 2. Set state and city
        selectedStateId.value = property.state ?? 0;
        selectedCityId.value = property.city ?? 0;

        print('🗺️ Setting state: ${selectedStateId.value}, city: ${selectedCityId.value}');

        // Load cities for selected state
        if (selectedStateId.value > 0) {
          await fetchCitiesByState(selectedStateId.value);
          await Future.delayed(const Duration(milliseconds: 300));
        }

        // 3. Set category
        selectedCategoryId.value = property.categoryId;
        if (selectedCategoryId.value > 0) {
          print('📋 Loading facilities for category: ${selectedCategoryId.value}');
          await fetchFacilitiesAndDocumentsByCategory(selectedCategoryId.value);
          await Future.delayed(const Duration(milliseconds: 500));

          // Set facility values from property
          if (property.facilities.isNotEmpty) {
            for (var propFacility in property.facilities) {
              for (var facility in facilities) {
                final propFacilityName = propFacility.name ?? propFacility.facilityName ?? '';
                if (propFacilityName.isNotEmpty &&
                    facility.name.toLowerCase() == propFacilityName.toLowerCase()) {

                  if (propFacility.value != null && propFacility.value!.isNotEmpty) {
                    facilityValues[facility.id] = propFacility.value;

                    if (facilityControllers.containsKey(facility.id)) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        facilityControllers[facility.id]?.text = propFacility.value!;
                      });
                    }

                    if (facility.name.toLowerCase().contains('posted by')) {
                      userType.value = propFacility.value!;
                    }
                  }
                  break;
                }
              }
            }
          }
        }

        // 4. Set amenities
        selectedAmenityIds.clear();
        if (property.amenitiesAll.isNotEmpty) {
          selectedAmenityIds.assignAll(property.amenitiesAll.map((a) => a.id).toList());
        }

        // 5. Set existing images
        galleryImageUrls.clear();
        if (property.galleryImages.isNotEmpty) {
          galleryImageUrls.assignAll(property.galleryImages.map((img) {
            if (img.startsWith('http')) {
              return img;
            } else {
              final cleanPath = img.startsWith('/') ? img.substring(1) : img;
              return '${ApiUrl.baseUrl}/$cleanPath';
            }
          }).toList());
        }

        // 6. Set 3D image if exists
        if (property.threeDImage != null && property.threeDImage!.isNotEmpty) {
          threeDImageUrl.value = property.threeDImage!;
        }

        // 7. Set nearby places
        selectedNearbyPlaces.clear();
        if (property.nearbyPlaces != null && property.nearbyPlaces!.isNotEmpty) {
          selectedNearbyPlaces.assignAll(property.nearbyPlaces!);

          for (var place in property.nearbyPlaces!) {
            final placeId = place['place_id'] as int? ?? place['id'] as int? ?? 0;
            final distance = place['distance'] as int? ?? 0;
            if (placeId > 0 && nearbyDistanceControllers.containsKey(placeId)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                nearbyDistanceControllers[placeId]?.text = distance.toString();
              });
            }
          }
        }

        // 8. Set existing documents URLs - FIXED VERSION
        documentUrls.clear();

        // Check if documents are in the API response
        final responseData = response.data['data'];

        // Try multiple possible document data locations in the response
        if (responseData['documents'] != null && responseData['documents'] is List) {
          // Case 1: Documents are in a 'documents' array
          final docsList = List<dynamic>.from(responseData['documents']);
          for (var doc in docsList) {
            if (doc is Map<String, dynamic>) {
              final docId = doc['document_id'] as int? ?? doc['id'] as int? ?? 0;
              final docUrl = doc['value'] as String? ?? doc['url'] as String? ?? doc['document_url'] as String?;

              if (docId > 0 && docUrl != null && docUrl.isNotEmpty) {
                documentUrls[docId] = docUrl;
                print('📄 Loaded document ID $docId: $docUrl');
              }
            }
          }
        } else if (property.documents != null && property.documents!.isNotEmpty) {
          // Case 2: Documents are stored as JSON string in property.documents
          try {
            if (property.documents!.startsWith('[')) {
              final parsedDocs = jsonDecode(property.documents!) as List;
              for (var doc in parsedDocs) {
                if (doc is Map<String, dynamic>) {
                  final docId = doc['document_id'] as int? ?? doc['id'] as int? ?? 0;
                  final docUrl = doc['value'] as String? ?? doc['url'] as String? ?? doc['document_url'] as String?;

                  if (docId > 0 && docUrl != null && docUrl.isNotEmpty) {
                    documentUrls[docId] = docUrl;
                    print('📄 Loaded document ID $docId: $docUrl');
                  }
                }
              }
            }
          } catch (e) {
            print('❌ Error parsing documents string: $e');
          }
        } else if (responseData['category_documents'] != null) {
          // Case 3: Check for category documents
          try {
            final categoryDocs = List<dynamic>.from(responseData['category_documents'] ?? []);
            for (var doc in categoryDocs) {
              if (doc is Map<String, dynamic>) {
                final docId = doc['id'] as int? ?? 0;
                final docUrl = doc['value'] as String?;

                if (docId > 0 && docUrl != null && docUrl.isNotEmpty) {
                  documentUrls[docId] = docUrl;
                  print('📄 Loaded category document ID $docId: $docUrl');
                }
              }
            }
          } catch (e) {
            print('❌ Error parsing category documents: $e');
          }
        }

        // Debug print all loaded documents
        print('📋 Total documents loaded: ${documentUrls.length}');
        documentUrls.forEach((key, value) {
          print('   - Document $key: $value');
        });

        // 9. Check for subcategory
        if (responseData['sub_category_id'] != null) {
          selectedSubCategoryId.value = int.tryParse(responseData['sub_category_id'].toString()) ?? 0;
        }

        userType.value = property.userType;

        // 10. Mark steps as complete
        completedSteps.assignAll([0, 1, 2, 3]);

        update();

        print('✅ Property edit data fully loaded');

      } else {
        print('❌ Failed to load property: ${response.statusCode}');
        SnackBarHelper.showError('Failed to load property details');
      }
    } catch (e) {
      print('❌ Error loading property: $e');
      SnackBarHelper.showError('Failed to load property details: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  // ==================== NEARBY PLACES ====================

  Future<void> fetchNearbyPlaces() async {
    try {
      final url = '${ApiUrl.baseUrl}/api/v2/nearby_place';
      final response = await ApiService.getRequest(url);
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == true || responseData['status'] == 200) {
          final data = responseData['data'];
          if (data['nearby_places'] is List) {
            final places = (data['nearby_places'] as List)
                .map((item) => NearbyPlace.fromJson(item))
                .toList();
            nearbyPlacesList.assignAll(places);

            for (var place in places) {
              if (!nearbyDistanceControllers.containsKey(place.id)) {
                nearbyDistanceControllers[place.id] = TextEditingController();
              }
            }
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
      } else {
        selectedNearbyPlaces.add({
          'place_id': placeId,
          'distance': distance,
        });
      }
      update();
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
    update();
  }

  bool isNearbyPlaceSelected(int placeId) {
    return selectedNearbyPlaces.any((place) => place['place_id'] == placeId);
  }

  int? getSelectedPlaceDistance(int placeId) {
    final place = selectedNearbyPlaces.firstWhereOrNull((place) => place['place_id'] == placeId);
    return place != null ? place['distance'] as int? : null;
  }

  // ==================== CATEGORIES ====================

  Future<void> fetchPropertyCategories() async {
    try {
      final url = '${ApiUrl.baseUrl}/api/v2/plot_category';
      final response = await ApiService.getRequest(url);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['status'] == true || response.data['status'] == 200) {
          final categories = (response.data['data'] as List)
              .map((item) => PropertyCategory.fromJson(item))
              .toList();
          propertyCategories.assignAll(categories);
        }
      }
    } catch (e) {
      print('❌ Error fetching categories: $e');
    }
  }

  void onCategoryChanged(int categoryId) {
    selectedCategoryId.value = categoryId;
    selectedSubCategoryId.value = 0;

    // Clear previous category data
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

  // ==================== FACILITIES & DOCUMENTS ====================

  Future<void> fetchFacilitiesAndDocumentsByCategory(int categoryId) async {
    try {
      final url = '${ApiUrl.baseUrl}/api/v2/plot_facility/$categoryId';
      final response = await ApiService.getRequest(url);
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == true || responseData['status'] == 200) {
          final dataList = responseData['data'] as List;
          final List<Facility> facilitiesList = [];
          final List<Document> documentsList = [];

          for (var item in dataList) {
            try {
              final type = (item['type'] as String? ?? '').toLowerCase();
              final hasFile = item['file'] != null && item['file'].toString().isNotEmpty;

              // Check if it's a document (either has type='file/document' OR has a file field)
              if (type == 'file' || type == 'document' || hasFile) {
                final document = Document(
                  id: item['id'] ?? 0,
                  name: item['name'] as String? ?? 'Unnamed',
                  file: item['file'],
                  type: type.isNotEmpty ? type : (hasFile ? 'file' : 'unknown'),
                  status: 1,
                  createdAt: item['created_at'] ?? DateTime.now().toIso8601String(),
                  updatedAt: item['updated_at'] ?? DateTime.now().toIso8601String(),
                  description: item['description'] as String?,
                  helpText: null,
                  allowedFormats: ['pdf', 'jpg', 'png', 'jpeg', 'doc', 'docx'],
                  maxSize: 2048,
                  isRequired: item['is_required'] ?? 1,
                );
                documentsList.add(document);
              } else {
                try {
                  final facility = Facility.fromJson(item);
                  facilitiesList.add(facility);
                } catch (e) {
                  print('⚠️ Error parsing facility: $e for item: $item');
                }
              }
            } catch (e) {
              print('⚠️ Error processing item: $e, Item: $item');
            }
          }

          // Debug: Print what we found
          print('📋 Found ${facilitiesList.length} facilities');
          print('📋 Found ${documentsList.length} documents');

          if (documentsList.isNotEmpty) {
            print('📋 Document names: ${documentsList.map((d) => d.name).toList()}');
          }

          facilities.assignAll(facilitiesList);
          documents.assignAll(documentsList);

          // Initialize controllers for facilities
          for (var facility in facilities) {
            if (!facilityControllers.containsKey(facility.id)) {
              facilityControllers[facility.id] = TextEditingController();
            }
          }

          update();
        }
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

  // ==================== DOCUMENT HANDLING ====================

  Future<void> pickDocumentFile(int documentId) async {
    try {
      final document = documents.firstWhereOrNull((doc) => doc.id == documentId);
      if (document == null) {
        SnackBarHelper.showError('Document not found');
        return;
      }

      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();
        final fileSizeKB = fileSize / 1024;

        if (document.maxSize != null && fileSizeKB > document.maxSize!) {
          SnackBarHelper.showError('File size must be less than ${document.maxSize}KB');
          return;
        }

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
        update();
        SnackBarHelper.showSuccess('${document.name} uploaded successfully');
      }
    } catch (e) {
      print('❌ Error picking document: $e');
      SnackBarHelper.showError('Failed to pick document');
    }
  }

  void removeDocumentFile(int documentId) {
    documentFiles.remove(documentId);
    documentUrls.remove(documentId);
    update();
    SnackBarHelper.showSuccess('Document removed');
  }

  // ==================== AMENITIES ====================

  Future<void> fetchAvailableAmenities() async {
    try {
      final url = '${ApiUrl.baseUrl}/api/v2/amenities';
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
    } else {
      selectedAmenityIds.add(amenityId);
    }
    update();
  }

  // ==================== LOCATION ====================

  Future<void> fetchStates() async {
    try {
      final url = '${ApiUrl.baseUrl}/api/v2/state';
      final response = await ApiService.getRequest(url);
      if (response.statusCode == 200 &&
          (response.data['status'] == true || response.data['status'] == 200)) {
        final states = (response.data['data'] as List)
            .map((item) => StateList.fromJson(item))
            .toList();
        statesList.assignAll(states);
      }
    } catch (e) {
      print('❌ Error fetching states: $e');
    }
  }

  Future<void> fetchCitiesByState(int stateId) async {
    try {
      final url = '${ApiUrl.baseUrl}/api/v2/city/$stateId';
      final response = await ApiService.getRequest(url);
      if (response.statusCode == 200 && response.data['status'] == 200) {
        final cities = (response.data['data'] as List)
            .map((item) => CityModel.fromJson(item))
            .toList();
        citiesList.assignAll(cities);
      } else {
        citiesList.clear();
      }
    } catch (e) {
      print('❌ Error fetching cities: $e');
      citiesList.clear();
    }
  }

  void onStateChanged(int stateId) {
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
    update();
  }

  // ==================== MAP & GEOLOCATION ====================

  Future<void> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(const Duration(seconds: 10));

      currentPosition.value = LatLng(position.latitude, position.longitude);
      selectedLocation.value = currentPosition.value;
      latitude.value = position.latitude;
      longitude.value = position.longitude;

      await _reverseGeocode(selectedLocation.value);

      update();
    } catch (e) {
      print('❌ Error getting location: $e');
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

  // ==================== IMAGE HANDLING ====================

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
      update();
    } else if (index >= 0 && index < galleryImageUrls.length) {
      galleryImageUrls.removeAt(index);
      update();
    }
  }

  // ==================== VALIDATION ====================

  Map<String, String> validateCurrentStep() {
    formErrors.clear();

    switch (currentStep.value) {
      case 0:
        if (propertyName.value.isEmpty) formErrors['property_name'] = 'Property name is required';
        if (selectedCategoryId.value <= 0) formErrors['category_id'] = 'Please select a category';
        if (price.value.isEmpty) formErrors['price'] = 'Total price is required';
        if (areaSqft.value.isEmpty) formErrors['area_sqft'] = 'Area is required';
        if (selectedStateId.value <= 0) formErrors['state'] = 'Please select a state';
        if (selectedCityId.value <= 0) formErrors['city'] = 'Please select a city';
        break;

      case 1:
        for (var facility in facilities) {
          if (facility.isRequired == 1) {
            final value = facilityValues[facility.id];
            if (value == null || value.toString().isEmpty) {
              formErrors['facility_${facility.id}'] = '${facility.name} is required';
            }
          }
        }
        for (var document in documents) {
          if (document.isRequired == 1 &&
              !documentFiles.containsKey(document.id) &&
              !documentUrls.containsKey(document.id)) {
            formErrors['document_${document.id}'] = '${document.name} is required';
          }
        }
        break;

      case 2:
        if (galleryImages.isEmpty && galleryImageUrls.isEmpty) {
          formErrors['gallery'] = 'At least one image is required';
        }
        break;

      case 3:
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

  // ==================== SUBMIT PROPERTY ====================

  Future<void> submitProperty() async {
    try {
      // Validate all steps before submission
      bool allStepsValid = true;
      Map<String, String> allErrors = {};

      for (int step = 0; step < 4; step++) {
        currentStep.value = step;
        final stepErrors = validateCurrentStep();
        if (stepErrors.isNotEmpty) {
          allStepsValid = false;
          allErrors.addAll(stepErrors);
        }
      }

      if (!allStepsValid) {
        final errorMessage = allErrors.isNotEmpty ? allErrors.values.first : 'Please fix all errors';
        SnackBarHelper.showError(errorMessage);
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

      String url;
      String successMessage;
      if (editingPropertyId.value > 0) {
        url = '${ApiUrl.baseUrl}/api/v2/plot_update';
        successMessage = 'Property updated successfully!';
      } else {
        url = '${ApiUrl.baseUrl}/api/v2/plot_store';
        successMessage = 'Property added successfully!';
      }

      print('🚀 Submitting to: $url');
      print('📱 Edit Mode: ${editingPropertyId.value > 0}');

      final headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll(headers);

      if (editingPropertyId.value > 0) {
        request.fields['id'] = editingPropertyId.value.toString();
      }

      // Add regular form fields
      requestData.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          if (key != 'facilities' && key != 'gallery_images' &&
              key != 'documents' && key != 'three_d_image' && key != 'existing_documents') {
            request.fields[key] = value.toString();
          }
        }
      });

      // Handle facilities
      final facilitiesData = requestData['facilities'];
      if (facilitiesData != null && facilitiesData is String) {
        try {
          final Map<String, dynamic> parsedFacilities = jsonDecode(facilitiesData);
          for (var entry in parsedFacilities.entries) {
            if (entry.value != null && entry.value.toString().isNotEmpty) {
              request.fields['facilities[${entry.key}]'] = entry.value.toString();
            }
          }
        } catch (e) {
          print('❌ Error parsing facilities: $e');
        }
      }

      // Handle gallery images - NEW images only
      for (int i = 0; i < galleryImages.length; i++) {
        final imageFile = galleryImages[i];
        try {
          final fileName = imageFile.path.split('/').last;
          final fileStream = http.ByteStream(imageFile.openRead());
          final length = await imageFile.length();

          final multipartFile = http.MultipartFile(
            'gallery_images[]',
            fileStream,
            length,
            filename: fileName,
          );
          request.files.add(multipartFile);
        } catch (e) {
          print('❌ Error processing image $i: $e');
        }
      }

      // For edit mode: include existing image URLs
      if (editingPropertyId.value > 0 && galleryImageUrls.isNotEmpty) {
        for (var imageUrl in galleryImageUrls) {
          final cleanUrl = imageUrl.startsWith('http')
              ? imageUrl
              : '${ApiUrl.baseUrl}/${imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl}';
          request.fields['gallery_images_urls[]'] = cleanUrl;
        }
      }

      // Handle 3D image
      if (threeDImageFile.value != null) {
        try {
          final file = threeDImageFile.value!;
          final fileName = file.path.split('/').last;
          final fileStream = http.ByteStream(file.openRead());
          final length = await file.length();

          final multipartFile = http.MultipartFile(
            'three_d_image',
            fileStream,
            length,
            filename: fileName,
          );
          request.files.add(multipartFile);
        } catch (e) {
          print('❌ Error processing 3D image: $e');
        }
      }

      // For edit mode: include existing 3D image URL
      if (editingPropertyId.value > 0 && threeDImageUrl.value.isNotEmpty) {
        request.fields['three_d_image_url'] = threeDImageUrl.value;
      }

      // Add document files
      documentFiles.forEach((documentId, file) async {
        if (file != null) {
          try {
            final fileName = file.path.split('/').last;
            final fileStream = http.ByteStream(file.openRead());
            final length = await file.length();

            final multipartFile = http.MultipartFile(
              'documents[$documentId]',
              fileStream,
              length,
              filename: fileName,
            );
            request.files.add(multipartFile);
          } catch (e) {
            print('❌ Error processing document $documentId: $e');
          }
        }
      });

      // Add existing document URLs for edit mode
      if (editingPropertyId.value > 0 && documentUrls.isNotEmpty) {
        documentUrls.forEach((documentId, url) {
          if (url != null && url.isNotEmpty) {
            request.fields['existing_documents[$documentId]'] = url;
          }
        });
      }

      // Send request
      print('📤 Sending multipart request...');
      final streamedResponse = await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      // Handle response
      try {
        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          if (responseData['status'] == true || responseData['status'] == 200) {
            // Show success message
            SnackBarHelper.showSuccess(responseData['message'] ?? successMessage);

            // Wait a bit for the message to show
            await Future.delayed(const Duration(seconds: 1));

            // Clear form
            resetForm();

            // Navigate back with success flag
            if (Get.isSnackbarOpen) Get.back();

            // Navigate to residential plots list
            Get.offNamed('/myResidential');

            // Force refresh the list
            final listController = Get.find<ResidentialPropertyFormController>();
            listController.fetchMyProperties();
          } else {
            SnackBarHelper.showError(responseData['message'] ?? 'Failed to save property');
          }
        } else if (response.statusCode == 422) {
          // Validation errors
          final errors = responseData['errors'] ?? {};
          String errorMessage = 'Validation failed';
          if (errors is Map<String, dynamic> && errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              errorMessage = firstError.first.toString();
            }
          }
          SnackBarHelper.showError(errorMessage);
        } else {
          SnackBarHelper.showError('Server error: ${response.statusCode}');
        }
      } catch (e) {
        print('❌ Error parsing response: $e');
        SnackBarHelper.showError('Error processing server response');
      }
    } catch (e) {
      print('❌ Submit error: $e');
      SnackBarHelper.showError('Network error: ${e.toString()}');
    } finally {
      isSubmitting(false);
    }
  }

  Future<Map<String, dynamic>> _prepareRequestData() async {
    final data = <String, dynamic>{
      'property_name': propertyName.value,
      'category_id': selectedCategoryId.value.toString(),
      'price': price.value,
      'price_per_sqft': pricePerSqft.value,
      'area_sqft': areaSqft.value,
      'location': location.value,
      'lat': latitude.value.toString(),
      'lng': longitude.value.toString(),
      'about_property': aboutProperty.value,
      'user_type': userType.value.isNotEmpty ? userType.value : 'customer',
    };

    // Add state and city - ensure they're not 0
    if (selectedStateId.value > 0) {
      data['state'] = selectedStateId.value.toString();
    }

    if (selectedCityId.value > 0) {
      data['city'] = selectedCityId.value.toString();
    }

    // Only add subcategory if it's selected
    if (selectedSubCategoryId.value > 0) {
      data['sub_category_id'] = selectedSubCategoryId.value.toString();
    }

    // Add amenities if any
    if (selectedAmenityIds.isNotEmpty) {
      data['amenities_data'] = selectedAmenityIds.map((id) => id.toString()).join(',');
    }

    // Add facilities - ensure all required fields are included
    final facilitiesData = <String, dynamic>{};
    for (var facility in facilities) {
      if (facility.type != 'file' && facility.type != 'document') {
        final value = facilityValues[facility.id];
        if (value != null && value.toString().isNotEmpty) {
          facilitiesData[facility.id.toString()] = value;
        } else if (facility.isRequired == 1) {
          // For required fields in edit mode, send empty string if not set
          facilitiesData[facility.id.toString()] = '';
        }
      }
    }
    if (facilitiesData.isNotEmpty) {
      data['facilities'] = jsonEncode(facilitiesData);
    }

    // Add nearby places
    if (selectedNearbyPlaces.isNotEmpty) {
      final nearbyPlacesData = selectedNearbyPlaces.map((place) {
        return {
          'place_id': place['place_id'],
          'distance': place['distance'],
        };
      }).toList();
      data['nearby_places'] = jsonEncode(nearbyPlacesData);
    }

    // For edit mode - prepare existing documents
    if (editingPropertyId.value > 0 && documentUrls.isNotEmpty) {
      final existingDocs = <String, dynamic>{};
      for (var entry in documentUrls.entries) {
        if (entry.value != null) {
          existingDocs[entry.key.toString()] = {
            'url': entry.value,
            'existing': true
          };
        }
      }
      if (existingDocs.isNotEmpty) {
        data['existing_documents'] = jsonEncode(existingDocs);
      }
    }

    print('📦 Prepared request data:');
    data.forEach((key, value) {
      print('   $key: $value');
    });

    return data;
  }

  // ==================== OTHER METHODS ====================

  Future<void> fetchMyProperties() async {
    try {
      isLoading(true);
      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        SnackBarHelper.showError('Please login to continue');
        return;
      }

      final url = '${ApiUrl.baseUrl}/api/v2/my_residential_plots';
      final response = await ApiService.getRequest(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == true || responseData['status'] == 200) {
          final dynamic data = responseData['data'];
          List<Property> propertiesList = [];

          if (data is List) {
            propertiesList = (data as List)
                .map((item) => Property.fromJson(item))
                .toList();
          } else if (data is Map<String, dynamic>) {
            if (data.containsKey('plots') && data['plots'] is List) {
              propertiesList = (data['plots'] as List)
                  .map((item) => Property.fromJson(item))
                  .toList();
            } else {
              try {
                if (data.containsKey('property_name') || data.containsKey('id')) {
                  propertiesList = [Property.fromJson(data)];
                }
              } catch (e) {
                print('⚠️ Could not parse properties from Map: $e');
              }
            }
          }

          properties.assignAll(propertiesList);
          filteredProperties.assignAll(propertiesList);
        }
      }
    } catch (e) {
      print('❌ Error fetching properties: $e');
      SnackBarHelper.showError('Failed to load properties');
    } finally {
      isLoading(false);
    }
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

  Future<void> fetchEnquiredProperties() async {
    try {
      isLoadingEnquiries(true);
      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        SnackBarHelper.showError('Please login to continue');
        return;
      }

      final url = '${ApiUrl.baseUrl}/api/v2/plot_enquiry_list';
      final response = await ApiService.getRequest(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['status'] == true || responseData['status'] == 200) {
          final data = responseData['data'];
          List<Property> propertiesList = [];

          if (data is Map<String, dynamic> && data.containsKey('plot')) {
            final plotsList = data['plot'] as List;
            propertiesList = plotsList.map((enquiryItem) {
              try {
                if (enquiryItem is Map<String, dynamic> &&
                    enquiryItem.containsKey('plot') &&
                    enquiryItem['plot'] is Map<String, dynamic>) {

                  final plotData = Map<String, dynamic>.from(enquiryItem['plot']);

                  // Add enquiry metadata
                  if (enquiryItem.containsKey('id')) {
                    plotData['enquiry_id'] = enquiryItem['id'];
                  }

                  return Property.fromJson(plotData);
                }
              } catch (e) {
                print('❌ Error processing enquiry item: $e');
              }
              return Property.fromJson({});
            }).toList();
          }

          enquiryProperties.assignAll(propertiesList);
        }
      }
    } catch (e) {
      print('❌ Error fetching enquired properties: $e');
      SnackBarHelper.showError('Failed to load enquiries');
    } finally {
      isLoadingEnquiries(false);
    }
  }

  Future<void> deleteProperty(int propertyId, int index) async {
    try {
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary),
          ),
        ),
        barrierDismissible: false,
      );

      final response = await ApiService.deleteRequest(
          '${ApiUrl.baseUrl}/api/v2/my_residential_plots/$propertyId'
      );

      Get.back();

      if (index >= 0 && index < properties.length) {
        properties.removeAt(index);
        update();
      }

      SnackBarHelper.showSuccess('Property deleted successfully');
    } catch (e) {
      if (Get.isDialogOpen!) Get.back();

      print('Error deleting property: $e');
      SnackBarHelper.showError('Failed to delete property. Please try again.');
    }
  }

  double getVerificationAmount() {
    try {
      // Get DashboardController to access business settings
      final dashboardController = Get.put(DashboardController());

      // Check if business settings are loaded
      if (dashboardController.businessSettings.value?.residentialDocumentAmount != null &&
          dashboardController.businessSettings.value!.residentialDocumentAmount! > 0) {
        return dashboardController.businessSettings.value!.residentialDocumentAmount!;
      }

      // Default fallback
      return 499.0;
    } catch (e) {
      print('❌ Error getting verification amount: $e');
      return 499.0;
    }
  }

  Future<void> initiateVerificationPayment(Property property) async {
    try {
      final razorpayController = Get.put(RazorpayController());

      if (property.isVerified) {
        Get.snackbar(
          "Already Verified",
          "This property is already verified!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return;
      }

      double amountToCharge = getVerificationAmount();

      razorpayController.setupResidentialVerificationPayment(
        residentialPlotId: property.id,
        amount: amountToCharge,
        propertyName: property.propertyName,
      );

      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 24.w),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColor.primary,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(Icons.home_work_rounded, color: Colors.white, size: 22.sp),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      "Property Verification",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColor.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Secure your listing and reach more buyers with our verified badge.",
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[600], height: 1.4),
                ),
                SizedBox(height: 16.h),

                // Property Info Card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: AppColor.primary.withOpacity(0.15)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.propertyName,
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColor.black),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 10.sp, color: Colors.grey[400]),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              property.location,
                              style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Benefits Section
                _buildBenefitItem("Priority search ranking for residential listings"),
                _buildBenefitItem("Trusted Seller badge added to profile"),
                _buildBenefitItem("Document validation for buyer confidence"),

                SizedBox(height: 20.h),

                // Dynamic Price Box
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColor.primary.withOpacity(0.05), AppColor.primary.withOpacity(0.1)],
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Verification Fee", style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                      Text(
                        "₹${amountToCharge.toStringAsFixed(0)}",
                        style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900, color: AppColor.primary),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                // Terms Row
                Obx(() => InkWell(
                  onTap: () => razorpayController.toggleTerms(),
                  child: Row(
                    children: [
                      Checkbox(
                        value: razorpayController.isTermsAccepted.value,
                        onChanged: (v) => razorpayController.toggleTerms(),
                        activeColor: AppColor.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _showTermsDialog(),
                          child: Text.rich(
                            TextSpan(
                              text: "I agree to the ",
                              style: TextStyle(fontSize: 11.sp, color: Colors.grey[600]),
                              children: [
                                TextSpan(
                                  text: "Terms & Conditions",
                                  style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
          actionsPadding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
                      Get.back();
                    },
                    child: Text("Cancel", style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w600)),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!razorpayController.isTermsAccepted.value) {
                        Get.snackbar("Action Required", "Please accept the terms to proceed.",
                            backgroundColor: Colors.redAccent, colorText: Colors.white, snackPosition: SnackPosition.BOTTOM);
                        return;
                      }
                      if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
                      Get.back();
                      razorpayController.initiatePayment();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text("Proceed to Pay", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      print('❌ Error initiating verification payment: $e');
      SnackBarHelper.showError('Failed to initiate payment');
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
                "3. We verify property details, documents, and ownership.\n"
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

  @override
  void onClose() {
    facilityControllers.forEach((key, controller) => controller.dispose());
    nearbyDistanceControllers.forEach((key, controller) => controller.dispose());
    mapController.dispose();
    super.onClose();
  }
}