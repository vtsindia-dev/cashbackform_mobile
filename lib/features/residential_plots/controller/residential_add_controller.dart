import 'dart:convert';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  var plotCount = ''.obs;
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

  // Map (Google Maps)
  var showMap = false.obs;
  var currentPosition = const LatLng(28.6139, 77.2090).obs;
  var selectedLocation = const LatLng(28.6139, 77.2090).obs;
  var isSearchingLocation = false.obs;
  var locationSearchResults = <Place>[].obs;

  // Gallery Images
  var galleryImages = <File>[].obs;
  var galleryImageUrls = <String>[].obs;

  // ── NEW: Gallery Videos ──────────────────────────────────────
  var galleryVideos = <File>[].obs;
  var galleryVideoUrls = <String>[].obs;

  // ── NEW: Blueprint / Floor Plan ──────────────────────────────
  var blueprintFile = Rxn<File>();
  var blueprintUrl = ''.obs;

  // 3D Image
  var threeDImageFile = Rxn<File>();
  var threeDImageUrl = ''.obs;

  final ImagePicker _imagePicker = ImagePicker();

  // Validation
  var formErrors = <String, String>{}.obs;
  var completedSteps = <int>[].obs;

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
    } finally {
      isLoading(false);
    }
  }

  // ==================== RESET METHODS ====================

  void resetFormForEdit() {
    galleryImageUrls.clear();
    galleryImages.clear();
    galleryVideos.clear();
    galleryVideoUrls.clear();
    selectedAmenityIds.clear();
    selectedNearbyPlaces.clear();
    documentFiles.clear();
    documentUrls.clear();
    facilityValues.clear();
    threeDImageFile.value = null;
    threeDImageUrl.value = '';
    blueprintFile.value = null;
    blueprintUrl.value = '';

    facilityControllers.forEach((_, c) => c.clear());
    nearbyDistanceControllers.forEach((_, c) => c.clear());

    propertyName.value = '';
    location.value = '';
    price.value = '';
    pricePerSqft.value = '';
    aboutProperty.value = '';
    areaSqft.value = '';
    plotCount.value = '';
    userType.value = '';

    selectedCategoryId.value = 0;
    selectedSubCategoryId.value = 0;
    selectedStateId.value = 0;
    selectedCityId.value = 0;
    currentStep.value = 0;
    completedSteps.clear();
    _originalProperty.value = null;
    update();
  }

  void resetForm() {
    resetFormForEdit();
    propertyCategories.clear();
    statesList.clear();
    citiesList.clear();
    facilities.clear();
    documents.clear();
    availableAmenities.clear();
    nearbyPlacesList.clear();
    facilityControllers.clear();
    nearbyDistanceControllers.clear();

    selectedLocation.value = const LatLng(28.6139, 77.2090);
    latitude.value = 28.6139;
    longitude.value = 77.2090;
    showMap.value = false;
    editingPropertyId.value = 0;
    update();
  }

  // ==================== VIDEO HANDLING ====================

  Future<void> pickGalleryVideo() async {
    try {
      final totalMedia = galleryImages.length + galleryImageUrls.length + galleryVideos.length;
      if (totalMedia >= 10) {
        SnackBarHelper.showError('Maximum 10 media files allowed');
        return;
      }

      final pickedFile = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 3),
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();
        final fileSizeMB = fileSize / (1024 * 1024);

        if (fileSizeMB > 50) {
          SnackBarHelper.showError('Video size must be less than 50MB');
          return;
        }

        galleryVideos.add(file);
        update();
        SnackBarHelper.showSuccess('Video added successfully');
      }
    } catch (e) {
      print('❌ Error picking video: $e');
      SnackBarHelper.showError('Failed to pick video');
    }
  }

  void removeGalleryVideo(int index) {
    if (index >= 0 && index < galleryVideos.length) {
      galleryVideos.removeAt(index);
      update();
    }
  }

  void removeGalleryImageUrl(int index) {
    if (index >= 0 && index < galleryImageUrls.length) {
      galleryImageUrls.removeAt(index);
      update();
    }
  }

  // ==================== BLUEPRINT HANDLING ====================

  Future<void> pickBlueprint() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();
        final fileSizeMB = fileSize / (1024 * 1024);

        if (fileSizeMB > 10) {
          SnackBarHelper.showError('Blueprint file must be less than 10MB');
          return;
        }

        final extension = pickedFile.path.split('.').last.toLowerCase();
        final allowed = ['jpg', 'jpeg', 'png', 'pdf'];
        if (!allowed.contains(extension)) {
          SnackBarHelper.showError('Allowed formats: PDF, JPG, PNG');
          return;
        }

        blueprintFile.value = file;
        update();
        SnackBarHelper.showSuccess('Blueprint uploaded');
      }
    } catch (e) {
      print('❌ Error picking blueprint: $e');
      SnackBarHelper.showError('Failed to pick blueprint');
    }
  }

  void removeBlueprint() {
    blueprintFile.value = null;
    blueprintUrl.value = '';
    update();
    SnackBarHelper.showSuccess('Blueprint removed');
  }

  // ==================== 3D IMAGE HANDLING ====================

  Future<void> pick3DImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSizeMB = await file.length() / (1024 * 1024);
        if (fileSizeMB > 10) {
          SnackBarHelper.showError('3D image size must be less than 10MB');
          return;
        }
        final ext = pickedFile.path.split('.').last.toLowerCase();
        if (!['jpg', 'jpeg', 'png', 'gif', 'svg', 'glb', 'gltf'].contains(ext)) {
          SnackBarHelper.showError('Unsupported format');
          return;
        }
        threeDImageFile.value = file;
        update();
        SnackBarHelper.showSuccess('3D image selected');
      }
    } catch (e) {
      SnackBarHelper.showError('Failed to pick 3D image');
    }
  }

  void remove3DImage() {
    threeDImageFile.value = null;
    threeDImageUrl.value = '';
    update();
  }

  // ==================== PROPERTY LOADING ====================

  Future<void> loadPropertyForEditing(int propertyId) async {
    try {
      isLoading(true);
      editingPropertyId.value = propertyId;

      // ── Step 0: ensure lookup lists are loaded before we set values ──────
      await Future.wait([
        if (propertyCategories.isEmpty) fetchPropertyCategories(),
        if (statesList.isEmpty) fetchStates(),
        if (availableAmenities.isEmpty) fetchAvailableAmenities(),
        if (nearbyPlacesList.isEmpty) fetchNearbyPlaces(),
      ]);

      final url = '${ApiUrl.baseUrl}/api/v2/plot_details/$propertyId';
      final response = await ApiService.getRequest(url);
      print('📥 loadPropertyForEditing $propertyId → ${response.statusCode}');

      if (response.statusCode != 200 ||
          (response.data['status'] != true && response.data['status'] != 200)) {
        SnackBarHelper.showError('Failed to load property details');
        return;
      }

      final rawData = response.data['data'] as Map<String, dynamic>;
      final property = Property.fromJson(rawData);
      _originalProperty.value = property;

      // ── Step 1: basic scalar fields ──────────────────────────────────────
      propertyName.value = property.propertyName;
      price.value        = property.price > 0 ? property.price.toStringAsFixed(0) : '';
      areaSqft.value     = property.areaSqft > 0 ? property.areaSqft.toString() : '';
      plotCount.value    = (rawData['plot_count'] ?? 0).toString();
      aboutProperty.value = property.aboutProperty;
      location.value     = property.location;
      userType.value     = property.userType;

      if (property.price > 0 && property.areaSqft > 0) {
        pricePerSqft.value = (property.price / property.areaSqft).toStringAsFixed(2);
      }

      latitude.value  = double.tryParse(property.lat ?? '0') ?? 0.0;
      longitude.value = double.tryParse(property.lng ?? '0') ?? 0.0;
      selectedLocation.value = LatLng(latitude.value, longitude.value);

      // ── Step 2: State → load cities → then set city ───────────────────
      final stateId = property.state ?? 0;
      final cityId  = property.city  ?? 0;
      if (stateId > 0) {
        selectedStateId.value = stateId;
        await fetchCitiesByState(stateId);   // waits until citiesList is populated
      }
      // Set city AFTER citiesList is ready so the dropdown finds the value
      if (cityId > 0) selectedCityId.value = cityId;

      // ── Step 3: Sub-category ─────────────────────────────────────────────
      if (rawData['sub_category_id'] != null) {
        selectedSubCategoryId.value =
            int.tryParse(rawData['sub_category_id'].toString()) ?? 0;
      }

      // ── Step 4: Category → load facilities (bypass onCategoryChanged to
      //            avoid clearing anything) ──────────────────────────────────
      final categoryId = property.categoryId;
      if (categoryId > 0) {
        selectedCategoryId.value = categoryId;
        // Load facilities directly; DON'T call onCategoryChanged (it clears data)
        await fetchFacilitiesAndDocumentsByCategory(categoryId);

        // Map saved facility values by facility_id (most reliable key)
        for (final pf in property.facilities) {
          // pf.facilityId is the FK; match against Facility.id
          final facilityId = pf.facilityId;
          final savedValue = pf.value ?? '';
          if (savedValue.isNotEmpty) {
            facilityValues[facilityId] = savedValue;
            facilityControllers[facilityId]?.text = savedValue;
          }

          // Also match by name as fallback
          if (savedValue.isNotEmpty) {
            final pfName = (pf.name ?? pf.facilityName ?? '').toLowerCase();
            for (final f in facilities) {
              if (f.id == facilityId || f.name.toLowerCase() == pfName) {
                facilityValues[f.id] = savedValue;
                facilityControllers[f.id]?.text = savedValue;
                if (f.name.toLowerCase().contains('posted by')) userType.value = savedValue;
                break;
              }
            }
          }
        }
      }

      // ── Step 5: Amenities ────────────────────────────────────────────────
      // Use amenitiesall from the API response (already parsed into amenitiesAll)
      selectedAmenityIds.clear();
      if (property.amenitiesAll.isNotEmpty) {
        selectedAmenityIds.assignAll(property.amenitiesAll.map((a) => a.id).toList());
        print('✅ Amenities set: ${selectedAmenityIds.toList()}');
      }

      // ── Step 6: Gallery images ───────────────────────────────────────────
      galleryImageUrls.clear();
      for (final img in property.galleryImages) {
        if (img.isEmpty) continue;
        // gallery_images may be a JSON-encoded string in some entries
        if (img.startsWith('[')) {
          try {
            final list = (jsonDecode(img) as List).cast<String>();
            for (final u in list) {
              galleryImageUrls.add(_fullUrl(u));
            }
          } catch (_) { galleryImageUrls.add(_fullUrl(img)); }
        } else {
          galleryImageUrls.add(_fullUrl(img));
        }
      }

      // ── Step 7: 3D image ─────────────────────────────────────────────────
      if (property.threeDImage.isNotEmpty) {
        threeDImageUrl.value = _fullUrl(property.threeDImage);
      }

      // ── Step 8: Blueprint ────────────────────────────────────────────────
      final blueprint = rawData['blueprint']?.toString() ?? '';
      if (blueprint.isNotEmpty) blueprintUrl.value = _fullUrl(blueprint);

      // ── Step 9: Gallery videos ───────────────────────────────────────────
      galleryVideoUrls.clear();
      final rawVideos = rawData['gallery_videos'];
      if (rawVideos is List) {
        galleryVideoUrls.assignAll(rawVideos.map((v) => _fullUrl(v.toString())).toList());
      }

      // ── Step 10: Nearby places ───────────────────────────────────────────
      // Source: property.nearbyPlaces = [{"place_id":32,"distance":1234}, ...]
      // distance arrives as int OR double string ("1234.0") — handle both
      selectedNearbyPlaces.clear();
      if (property.nearbyPlaces != null && property.nearbyPlaces!.isNotEmpty) {
        for (final place in property.nearbyPlaces!) {
          final placeId = _asInt(place['place_id']) ?? _asInt(place['id']) ?? 0;
          final distance = _asInt(place['distance']) ?? 0;
          if (placeId <= 0) continue;
          selectedNearbyPlaces.add({'place_id': placeId, 'distance': distance});

          // Pre-fill the distance text controller
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (nearbyDistanceControllers.containsKey(placeId)) {
              nearbyDistanceControllers[placeId]!.text = distance.toString();
            }
          });
        }
        print('✅ Nearby places set: ${selectedNearbyPlaces.toList()}');
      }

      // ── Step 11: Documents ───────────────────────────────────────────────
      documentUrls.clear();
      final rawDocs = rawData['documents'];
      if (rawDocs is List) {
        for (final doc in rawDocs) {
          if (doc is Map<String, dynamic>) {
            final docId  = _asInt(doc['document_id']) ?? _asInt(doc['id']) ?? 0;
            final docUrl = doc['value']?.toString() ?? doc['url']?.toString() ?? '';
            if (docId > 0 && docUrl.isNotEmpty) documentUrls[docId] = docUrl;
          }
        }
      }

      completedSteps.assignAll([0, 1, 2, 3]);
      update();
      print('✅ loadPropertyForEditing complete for $propertyId');

    } catch (e, st) {
      print('❌ Error loading property: $e\n$st');
      SnackBarHelper.showError('Failed to load property details');
    } finally {
      isLoading(false);
    }
  }

  /// Normalise any value (int, double, String like "1234.0") to int
  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return double.tryParse(v)?.toInt();
    return null;
  }

  /// Ensure URL has base URL prefix
  String _fullUrl(String path) {
    if (path.isEmpty) return path;
    if (path.startsWith('http')) return path;
    final clean = path.startsWith('/') ? path.substring(1) : path;
    return '${ApiUrl.baseUrl}/$clean';
  }

  // ==================== NEARBY PLACES ====================

  Future<void> fetchNearbyPlaces() async {
    try {
      final response = await ApiService.getRequest('${ApiUrl.baseUrl}/api/v2/nearby_place');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true || data['status'] == 200) {
          final places = (data['data']['nearby_places'] as List)
              .map((item) => NearbyPlace.fromJson(item)).toList();
          nearbyPlacesList.assignAll(places);
          for (var place in places) {
            nearbyDistanceControllers.putIfAbsent(place.id, () => TextEditingController());
          }
        }
      }
    } catch (e) { print('❌ Error fetching nearby places: $e'); }
  }

  void toggleNearbyPlace(int placeId, String? distanceText) {
    final distance = int.tryParse(distanceText ?? '');
    if (distance == null || distance <= 0) {
      SnackBarHelper.showError('Enter a valid distance');
      return;
    }
    final idx = selectedNearbyPlaces.indexWhere((p) => p['place_id'] == placeId);
    if (idx >= 0) {
      selectedNearbyPlaces[idx] = {'place_id': placeId, 'distance': distance};
    } else {
      selectedNearbyPlaces.add({'place_id': placeId, 'distance': distance});
    }
    update();
  }

  void removeNearbyPlace(int placeId) {
    selectedNearbyPlaces.removeWhere((p) => p['place_id'] == placeId);
    nearbyDistanceControllers[placeId]?.clear();
    update();
  }

  bool isNearbyPlaceSelected(int placeId) => selectedNearbyPlaces.any((p) => p['place_id'] == placeId);
  int? getSelectedPlaceDistance(int placeId) {
    final place = selectedNearbyPlaces.firstWhereOrNull((p) => p['place_id'] == placeId);
    return place?['distance'] as int?;
  }

  // ==================== CATEGORIES ====================

  Future<void> fetchPropertyCategories() async {
    try {
      final response = await ApiService.getRequest('${ApiUrl.baseUrl}/api/v2/plot_category');
      print('📋 Categories raw response: ${response.statusCode} → ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = response.data as Map<String, dynamic>;
        final status = body['status'];
        if (status == true || status == 200 || status == 201 || status == 'true') {
          final raw = body['data'];
          final List<dynamic> dataList = raw is List ? raw : [];
          final parsed = dataList
              .whereType<Map<String, dynamic>>()
              .map((i) => PropertyCategory.fromJson(i))
              .toList();
          print('📋 Parsed categories: ${parsed.map((c) => '${c.id}:${c.categoryName}').toList()}');
          propertyCategories.assignAll(parsed);
        } else {
          print('⚠️ Categories status not success: $status');
        }
      }
    } catch (e, st) {
      print('❌ Error fetching categories: $e\n$st');
    }
  }

  void onCategoryChanged(int categoryId) {
    selectedCategoryId.value = categoryId;
    selectedSubCategoryId.value = 0;
    facilities.clear();
    facilityValues.clear();
    facilityControllers.forEach((_, c) => c.dispose());
    facilityControllers.clear();
    documents.clear();
    documentFiles.clear();
    documentUrls.clear();
    if (categoryId > 0) fetchFacilitiesAndDocumentsByCategory(categoryId);
    update();
  }

  void onSubCategoryChanged(int id) {
    selectedSubCategoryId.value = id;
    update();
  }

  // ==================== FACILITIES & DOCUMENTS ====================

  Future<void> fetchFacilitiesAndDocumentsByCategory(int categoryId) async {
    try {
      final response = await ApiService.getRequest('${ApiUrl.baseUrl}/api/v2/plot_facility/$categoryId');
      if (response.statusCode == 200 && (response.data['status'] == true || response.data['status'] == 200)) {
        final List<Facility> fList = [];
        final List<Document> dList = [];
        for (var item in response.data['data'] as List) {
          try {
            final type = (item['type'] as String? ?? '').toLowerCase();
            final hasFile = item['file'] != null && item['file'].toString().isNotEmpty;
            if (type == 'file' || type == 'document' || hasFile) {
              dList.add(Document(
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
              ));
            } else {
              fList.add(Facility.fromJson(item));
            }
          } catch (e) { print('⚠️ Error parsing item: $e'); }
        }
        facilities.assignAll(fList);
        documents.assignAll(dList);
        for (var f in facilities) {
          facilityControllers.putIfAbsent(f.id, () => TextEditingController());
        }
        update();
      }
    } catch (e) {
      print('❌ Error fetching facilities: $e');
      SnackBarHelper.showError('Failed to load facilities');
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
      final document = documents.firstWhereOrNull((d) => d.id == documentId);
      if (document == null) return;
      final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSizeKB = await file.length() / 1024;
        if (document.maxSize != null && fileSizeKB > document.maxSize!) {
          SnackBarHelper.showError('File too large (max ${document.maxSize}KB)');
          return;
        }
        documentFiles[documentId] = file;
        update();
        SnackBarHelper.showSuccess('${document.name} uploaded');
      }
    } catch (e) {
      SnackBarHelper.showError('Failed to pick document');
    }
  }

  void removeDocumentFile(int documentId) {
    documentFiles.remove(documentId);
    documentUrls.remove(documentId);
    update();
  }

  // ==================== AMENITIES ====================

  Future<void> fetchAvailableAmenities() async {
    try {
      final response = await ApiService.getRequest('${ApiUrl.baseUrl}/api/v2/amenities');
      if (response.statusCode == 200 && (response.data['status'] == true || response.data['status'] == 200)) {
        final list = (response.data['data']['amenities'] as List?)
            ?.map((i) => AmenityItem.fromJson(i as Map<String, dynamic>)).toList();
        if (list != null) availableAmenities.assignAll(list);
      }
    } catch (e) { print('❌ Error fetching amenities: $e'); }
  }

  void toggleAmenitySelection(int amenityId) {
    if (selectedAmenityIds.contains(amenityId)) selectedAmenityIds.remove(amenityId);
    else selectedAmenityIds.add(amenityId);
    update();
  }

  // ==================== LOCATION ====================

  Future<void> fetchStates() async {
    try {
      final response = await ApiService.getRequest('${ApiUrl.baseUrl}/api/v2/state');
      if (response.statusCode == 200 && (response.data['status'] == true || response.data['status'] == 200)) {
        statesList.assignAll((response.data['data'] as List).map((i) => StateList.fromJson(i)).toList());
      }
    } catch (e) { print('❌ Error fetching states: $e'); }
  }

  Future<void> fetchCitiesByState(int stateId) async {
    try {
      final response = await ApiService.getRequest('${ApiUrl.baseUrl}/api/v2/city/$stateId');
      if (response.statusCode == 200 && response.data['status'] == 200) {
        citiesList.assignAll((response.data['data'] as List).map((i) => CityModel.fromJson(i)).toList());
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
    if (stateId > 0) fetchCitiesByState(stateId);
    update();
  }

  void onCityChanged(int cityId) {
    selectedCityId.value = cityId;
    update();
  }

  // ==================== MAP & GEOLOCATION (Google Maps) ====================

  Future<void> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium)
          .timeout(const Duration(seconds: 10));

      currentPosition.value = LatLng(position.latitude, position.longitude);
      selectedLocation.value = currentPosition.value;
      latitude.value = position.latitude;
      longitude.value = position.longitude;
      await _reverseGeocode(position.latitude, position.longitude);
      update();
    } catch (e) {
      print('❌ Error getting location: $e');
      latitude.value = 28.6139;
      longitude.value = 77.2090;
      location.value = 'Delhi, India';
      update();
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = <String>[
          if (p.street?.isNotEmpty == true) p.street!,
          if (p.subLocality?.isNotEmpty == true) p.subLocality!,
          if (p.locality?.isNotEmpty == true) p.locality!,
          if (p.administrativeArea?.isNotEmpty == true) p.administrativeArea!,
          if (p.country?.isNotEmpty == true) p.country!,
        ];
        location.value = parts.join(', ');
        update();
      }
    } catch (e) { print('❌ Reverse geocode error: $e'); }
  }

  /// Called from the map view's onTap — accepts Google Maps LatLng
  void onMapTap(LatLng point) {
    selectedLocation.value = point;
    latitude.value = point.latitude;
    longitude.value = point.longitude;
    _reverseGeocode(point.latitude, point.longitude);
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
    } catch (e) { print('❌ Search error: $e'); }
    finally { isSearchingLocation(false); }
  }

  void selectSearchLocation(Place place) {
    selectedLocation.value = LatLng(place.coordinates.latitude, place.coordinates.longitude);
    latitude.value = place.coordinates.latitude;
    longitude.value = place.coordinates.longitude;
    location.value = place.address.isNotEmpty ? place.address : place.name;
    locationSearchResults.clear();
    update();
  }

  // ==================== IMAGE HANDLING ====================

  Future<void> pickGalleryImages() async {
    try {
      final pickedFiles = await _imagePicker.pickMultiImage(imageQuality: 85, maxWidth: 1200);
      if (pickedFiles != null) {
        for (var f in pickedFiles) {
          final total = galleryImages.length + galleryImageUrls.length + galleryVideos.length;
          if (total < 10) galleryImages.add(File(f.path));
          else { SnackBarHelper.showError('Maximum 10 media files allowed'); break; }
        }
        update();
      }
    } catch (e) {
      SnackBarHelper.showError('Failed to pick images');
    }
  }

  void removeGalleryImage(int index) {
    if (index >= 0 && index < galleryImages.length) {
      galleryImages.removeAt(index);
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
        for (var f in facilities) {
          if (f.isRequired == 1) {
            final v = facilityValues[f.id];
            if (v == null || v.toString().isEmpty) formErrors['facility_${f.id}'] = '${f.name} is required';
          }
        }
        for (var d in documents) {
          if (d.isRequired == 1 && !documentFiles.containsKey(d.id) && !documentUrls.containsKey(d.id)) {
            formErrors['document_${d.id}'] = '${d.name} is required';
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
        if (latitude.value == 0.0 || longitude.value == 0.0) formErrors['coordinates'] = 'Please select location on map';
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
      if (currentStep.value < 3) currentStep.value++;
    } else {
      final errors = validateCurrentStep();
      if (errors.isNotEmpty) SnackBarHelper.showError(errors.values.first);
    }
  }

  void previousStep() {
    if (currentStep.value > 0) currentStep.value--;
  }

  // ==================== SUBMIT PROPERTY ====================

  Future<void> submitProperty() async {
    try {
      bool allValid = true;
      Map<String, String> allErrors = {};
      for (int step = 0; step < 4; step++) {
        currentStep.value = step;
        final errs = validateCurrentStep();
        if (errs.isNotEmpty) { allValid = false; allErrors.addAll(errs); }
      }
      if (!allValid) {
        SnackBarHelper.showError(allErrors.values.first);
        return;
      }

      isSubmitting(true);
      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        SnackBarHelper.showError('Please login to continue');
        isSubmitting(false);
        return;
      }

      final String url = editingPropertyId.value > 0
          ? '${ApiUrl.baseUrl}/api/v2/plot_update'
          : '${ApiUrl.baseUrl}/api/v2/plot_store';

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (editingPropertyId.value > 0) request.fields['id'] = editingPropertyId.value.toString();

      // ── Core fields ──────────────────────────────────────────────────
      final coreFields = {
        'property_name': propertyName.value,
        'category_id': selectedCategoryId.value.toString(),
        'price': price.value,
        'price_per_sqft': pricePerSqft.value,
        'area_sqft': areaSqft.value,
        'plot_count': plotCount.value,
        'location': location.value,
        'lat': latitude.value.toString(),
        'lng': longitude.value.toString(),
        'about_property': aboutProperty.value,
        'user_type': userType.value.isNotEmpty ? userType.value : 'customer',
        if (selectedStateId.value > 0) 'state': selectedStateId.value.toString(),
        if (selectedCityId.value > 0) 'city': selectedCityId.value.toString(),
        if (selectedSubCategoryId.value > 0) 'sub_category_id': selectedSubCategoryId.value.toString(),
        if (selectedAmenityIds.isNotEmpty) 'amenities_data': selectedAmenityIds.map((id) => id.toString()).join(','),
        // amenities also sent as array below
      };
      coreFields.forEach((k, v) { if (v.isNotEmpty) request.fields[k] = v; });

      // ── Facilities ───────────────────────────────────────────────────
      final facilitiesData = <String, dynamic>{};
      for (var f in facilities) {
        if (f.type != 'file' && f.type != 'document') {
          final v = facilityValues[f.id];
          if (v != null && v.toString().isNotEmpty) facilitiesData[f.id.toString()] = v;
        }
      }
      if (facilitiesData.isNotEmpty) {
        facilitiesData.forEach((k, v) { request.fields['facilities[$k]'] = v.toString(); });
      }

      // ── Nearby places ────────────────────────────────────────────────
      if (selectedNearbyPlaces.isNotEmpty) {
        request.fields['nearby_places'] = jsonEncode(selectedNearbyPlaces.map((p) => {
          'place_id': p['place_id'],
          'distance': p['distance'],
        }).toList());
      }

      // ── Gallery images (new) ─────────────────────────────────────────
      for (int i = 0; i < galleryImages.length; i++) {
        final f = galleryImages[i];
        request.files.add(await http.MultipartFile.fromPath('gallery_images[]', f.path));
      }
      // existing image URLs
      for (var u in galleryImageUrls) {
        request.fields['gallery_images'] = u;
      }

      // ── Gallery videos (new) ─────────────────────────────────────────
      for (int i = 0; i < galleryVideos.length; i++) {
        final f = galleryVideos[i];
        request.files.add(await http.MultipartFile.fromPath('gallery_images[]', f.path));
      }
      for (var u in galleryVideoUrls) {
        request.fields['gallery_images'] = u;
      }

      // ── 3D image ─────────────────────────────────────────────────────
      if (threeDImageFile.value != null) {
        request.files.add(await http.MultipartFile.fromPath('three_d_image', threeDImageFile.value!.path));
      }
      if (editingPropertyId.value > 0 && threeDImageUrl.value.isNotEmpty) {
        request.fields['three_d_image_url'] = threeDImageUrl.value;
      }

      // ── Blueprint ─────────────────────────────────────────────────────
      if (blueprintFile.value != null) {
        request.files.add(await http.MultipartFile.fromPath('blueprint', blueprintFile.value!.path));
      }
      if (editingPropertyId.value > 0 && blueprintUrl.value.isNotEmpty) {
        request.fields['blueprint_url'] = blueprintUrl.value;
      }

      // ── Documents ─────────────────────────────────────────────────────
      for (var entry in documentFiles.entries) {
        if (entry.value != null) {
          request.files.add(await http.MultipartFile.fromPath('documents[${entry.key}]', entry.value!.path));
        }
      }
      if (editingPropertyId.value > 0) {
        documentUrls.forEach((docId, url) {
          if (url != null && url.isNotEmpty) request.fields['existing_documents[$docId]'] = url;
        });
      }

      // ── Send ──────────────────────────────────────────────────────────
      final streamedResponse = await request.send().timeout(const Duration(seconds: 90));
      final response = await http.Response.fromStream(streamedResponse);

      print('📥 Response: ${response.statusCode}\n${response.body}');

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['status'] == true || responseData['status'] == 200) {
          SnackBarHelper.showSuccess(responseData['message'] ?? 'Property saved successfully!');
          await Future.delayed(const Duration(seconds: 1));
          resetForm();
          if (Get.isSnackbarOpen) Get.back();
          Get.offNamed('/myResidential');
          final listController = Get.find<ResidentialPropertyFormController>();
          listController.fetchMyProperties();
        } else {
          SnackBarHelper.showError(responseData['message'] ?? 'Failed to save property');
        }
      } else if (response.statusCode == 422) {
        final errors = responseData['errors'] ?? {};
        String msg = 'Validation failed';
        if (errors is Map<String, dynamic> && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) msg = first.first.toString();
        }
        SnackBarHelper.showError(msg);
      } else {
        SnackBarHelper.showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Submit error: $e');
      SnackBarHelper.showError('Network error: ${e.toString()}');
    } finally {
      isSubmitting(false);
    }
  }

  // ==================== OTHER METHODS ====================

  Future<void> fetchMyProperties() async {
    try {
      isLoading(true);
      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) return;

      final response = await ApiService.getRequest(
        '${ApiUrl.baseUrl}/api/v2/my_residential_plots',
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true || data['status'] == 200) {
          List<Property> list = [];
          final d = data['data'];
          if (d is List) {
            list = d.map((i) => Property.fromJson(i)).toList();
          } else if (d is Map<String, dynamic>) {
            if (d.containsKey('plots') && d['plots'] is List) {
              list = (d['plots'] as List).map((i) => Property.fromJson(i)).toList();
            }
          }
          properties.assignAll(list);
          filteredProperties.assignAll(list);
        }
      }
    } catch (e) {
      print('❌ Error fetching properties: $e');
    } finally {
      isLoading(false);
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    if (filter == 'all') filteredProperties.assignAll(properties);
    else filteredProperties.assignAll(
        properties.where((p) => (p.status ?? '').toLowerCase() == filter.toLowerCase()).toList());
  }

  Future<void> fetchEnquiredProperties() async {
    try {
      isLoadingEnquiries(true);
      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) return;

      final response = await ApiService.getRequest(
        '${ApiUrl.baseUrl}/api/v2/plot_enquiry_list',
        headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if ((data['status'] == true || data['status'] == 200) &&
            data['data'] is Map<String, dynamic> &&
            data['data']['plot'] is List) {
          final list = (data['data']['plot'] as List).map((item) {
            try {
              if (item is Map<String, dynamic> && item['plot'] is Map<String, dynamic>) {
                final plotData = Map<String, dynamic>.from(item['plot']);
                if (item.containsKey('id')) plotData['enquiry_id'] = item['id'];
                return Property.fromJson(plotData);
              }
            } catch (e) { print('❌ Error parsing enquiry: $e'); }
            return Property.fromJson({});
          }).toList();
          enquiryProperties.assignAll(list);
        }
      }
    } catch (e) {
      print('❌ Error fetching enquiries: $e');
    } finally {
      isLoadingEnquiries(false);
    }
  }

  Future<void> deleteProperty(int propertyId, int index) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColor.primary))),
          barrierDismissible: false);
      await ApiService.deleteRequest('${ApiUrl.baseUrl}/api/v2/my_residential_plots/$propertyId');
      Get.back();
      if (index >= 0 && index < properties.length) {
        properties.removeAt(index);
        update();
      }
      SnackBarHelper.showSuccess('Property deleted successfully');
    } catch (e) {
      if (Get.isDialogOpen!) Get.back();
      SnackBarHelper.showError('Failed to delete property');
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
    facilityControllers.forEach((_, c) => c.dispose());
    nearbyDistanceControllers.forEach((_, c) => c.dispose());
    super.onClose();
  }
}