import 'dart:convert';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../../../common/api_constant.dart';
import '../../../common/colours.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';
import '../../auth/models/location_model.dart' show CountryModel;
import '../../legal_and_policies/screen.dart';
import '../../menu/controller/dashboard_menu_controller.dart';
import '../../payment/controller/razorpay_controller.dart';
import '../model/residential_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

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
  var pricePerSqft = ''.obs;
  var aboutProperty = ''.obs;
  var areaSqft = ''.obs;
  var plotCount = ''.obs;
  var userType = ''.obs;
  var yotubeLink = ''.obs;
  var propertyCategories = <PropertyCategory>[].obs;
  var selectedCategoryId = 0.obs;
  var selectedSubCategoryId = 0.obs;
  var selectedStateId = 0.obs;
  var selectedCityId = 0.obs;
  var selectedCountryId = 0.obs;
  var countriesList = <CountryModel>[].obs;
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
  var selectedNearbyPlaces = <Map<String, dynamic>>[].obs;
  var nearbyDistanceControllers = <int, TextEditingController>{};
  var showMap = false.obs;
  var currentPosition = const LatLng(28.6139, 77.2090).obs;
  var selectedLocation = const LatLng(28.6139, 77.2090).obs;
  var isSearchingLocation = false.obs;
  var locationSearchResults = <Place>[].obs;
  var galleryImages = <File>[].obs;
  var galleryImageUrls = <String>[].obs;
  var galleryVideos = <File>[].obs;
  var galleryVideoUrls = <String>[].obs;
  var blueprintFile = Rxn<File>();
  var blueprintUrl = ''.obs;
  var threeDImageFile = Rxn<File>();
  var threeDImageUrl = ''.obs;
  final ImagePicker _imagePicker = ImagePicker();
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
        fetchCountries(),
     //   getCurrentLocation(),
        fetchNearbyPlaces(),
      ]);
    } catch (e) {
      print('❌ Error initializing data: $e');
    } finally {
      isLoading(false);
    }
  }

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
    selectedCountryId.value = 0;
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
    countriesList.clear();
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
  var isCityLoading = false.obs;
  var isStateLoading = false.obs;
  Future<String?> loadPropertyForEditing(int propertyId) async {
    try {
      isLoading(true);
      editingPropertyId.value = propertyId;
      await Future.wait([
        if (propertyCategories.isEmpty) fetchPropertyCategories(),
        if (countriesList.isEmpty) fetchCountries(),
        if (availableAmenities.isEmpty) fetchAvailableAmenities(),
        if (nearbyPlacesList.isEmpty) fetchNearbyPlaces(),
      ]);

      final url = '${ApiUrl.baseUrl}/api/v2/plot_details/$propertyId';
      final response = await ApiService.getRequest(url);
      print('📥 loadPropertyForEditing $propertyId → ${response.statusCode}');

      if (response.statusCode != 200 ||
          (response.data['status'] != true && response.data['status'] != 200)) {
        SnackBarHelper.showError('Failed to load property details');
        return null;
      }
      final rawData = response.data['data'] as Map<String, dynamic>;
      final property = Property.fromJson(rawData);
      _originalProperty.value = property;
      propertyName.value = property.propertyName;
      price.value        = property.price > 0 ? property.price.toStringAsFixed(0) : '';
      areaSqft.value     = property.areaSqft > 0 ? property.areaSqft.toString() : '';
      plotCount.value    = (rawData['plot_count'] ?? 0).toString();
      aboutProperty.value = property.aboutProperty;
      location.value     = property.location;
      userType.value     = property.userType;
      yotubeLink.value   = property.youtubeLink??'';

      if (property.price > 0 && property.areaSqft > 0) {
        pricePerSqft.value = (property.price / property.areaSqft).toStringAsFixed(2);
      }

      latitude.value  = double.tryParse(property.lat ?? '0') ?? 0.0;
      longitude.value = double.tryParse(property.lng ?? '0') ?? 0.0;
      selectedLocation.value = LatLng(latitude.value, longitude.value);
      final countryId = property.country ?? 0;
      final stateId   = property.state ?? 0;
      final cityId    = property.city  ?? 0;
      if (countryId > 0) {
        selectedCountryId.value = countryId;
        await fetchStatesByCountry(countryId);
      } else if (stateId > 0) {
        await fetchStates();
      }
      if (stateId > 0) {
        selectedStateId.value = stateId;
        await fetchCitiesByState(stateId);
      }
      if (cityId > 0) selectedCityId.value = cityId;
      if (rawData['sub_category_id'] != null) {
        selectedSubCategoryId.value =
            int.tryParse(rawData['sub_category_id'].toString()) ?? 0;
      }

      final categoryId = property.categoryId;
      if (categoryId > 0) {
        selectedCategoryId.value = categoryId;
        await fetchFacilitiesAndDocumentsByCategory(categoryId);
        for (final pf in property.facilities) {
          final facilityId = pf.facilityId;
          final savedValue = pf.value ?? '';
          if (savedValue.isNotEmpty) {
            facilityValues[facilityId] = savedValue;
            facilityControllers[facilityId]?.text = savedValue;
          }

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

      selectedAmenityIds.clear();
      if (property.amenitiesAll.isNotEmpty) {
        selectedAmenityIds.assignAll(property.amenitiesAll.map((a) => a.id).toList());
        print('✅ Amenities set: ${selectedAmenityIds.toList()}');
      }

      galleryImageUrls.clear();
      for (final img in property.galleryImages) {
        if (img.isEmpty) continue;
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
      if (property.threeDImage.isNotEmpty) {
        threeDImageUrl.value = _fullUrl(property.threeDImage);
      }
      final blueprint = rawData['blueprint']?.toString() ?? '';
      if (blueprint.isNotEmpty) blueprintUrl.value = _fullUrl(blueprint);
      galleryVideoUrls.clear();
      final rawVideos = rawData['gallery_videos'];
      if (rawVideos is List) {
        galleryVideoUrls.assignAll(rawVideos.map((v) => _fullUrl(v.toString())).toList());
      }
      selectedNearbyPlaces.clear();
      if (property.nearbyPlaces != null && property.nearbyPlaces!.isNotEmpty) {
        for (final place in property.nearbyPlaces!) {
          final placeId = _asInt(place['place_id']) ?? _asInt(place['id']) ?? 0;
          final distance = _asInt(place['distance']) ?? 0;
          if (placeId <= 0) continue;
          selectedNearbyPlaces.add({'place_id': placeId, 'distance': distance});
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (nearbyDistanceControllers.containsKey(placeId)) {
              nearbyDistanceControllers[placeId]!.text = distance.toString();
            }
          });
        }
        print('✅ Nearby places set: ${selectedNearbyPlaces.toList()}');
      }
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
      return  property.youtubeLink;
    } catch (e, st) {
      print('❌ Error loading property: $e\n$st');
      SnackBarHelper.showError('Failed to load property details');
      return  null;
    } finally {
      isLoading(false);
    }
  }
  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return double.tryParse(v)?.toInt();
    return null;
  }

  String _fullUrl(String path) {
    if (path.isEmpty) return path;
    if (path.startsWith('http')) return path;
    final clean = path.startsWith('/') ? path.substring(1) : path;
    return '${ApiUrl.baseUrl}/$clean';
  }

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

  Future<void> fetchCountries() async {
    try {
      final response = await ApiService.getRequest(ApiUrl.countryUrl);
      if (response.statusCode == 200 && (response.data['status'] == true || response.data['status'] == 200)) {
        countriesList.assignAll(
          (response.data['data'] as List).map((i) => CountryModel.fromJson(i)).toList(),
        );
      }
    } catch (e) { print('❌ Error fetching countries: $e'); }
  }

  void onCountryChanged(int countryId) {
    selectedCountryId.value = countryId;
    selectedStateId.value = 0;
    selectedCityId.value = 0;
    statesList.clear();
    citiesList.clear();
    if (countryId > 0) {
      isStateLoading.value = true;
      fetchStatesByCountry(countryId);
    }
    update();
  }

  Future<void> fetchStatesByCountry(int countryId) async {
    try {
      isStateLoading.value = true;
      statesList.clear();
      final response = await ApiService.getRequest('${ApiUrl.baseUrl}/api/v2/state?country_id=$countryId');
      if (response.statusCode == 200 && (response.data['status'] == true || response.data['status'] == 200)) {
        statesList.assignAll((response.data['data'] as List).map((i) => StateList.fromJson(i)).toList());
      }
    } catch (e) {
      print('❌ Error fetching states by country: $e');
    } finally {
      isStateLoading.value = false;
    }
  }

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
      isCityLoading(true);
      citiesList.clear();
      final response = await ApiService.getRequest('${ApiUrl.baseUrl}/api/v2/city/$stateId');
      if (response.statusCode == 200 && response.data['status'] == 200) {
        citiesList.assignAll(
          (response.data['data'] as List).map((i) => CityModel.fromJson(i)).toList(),
        );
      } else {
        citiesList.clear();
      }
    } catch (e) {
      print('❌ Error fetching cities: $e');
      citiesList.clear();
    } finally {
      isCityLoading(false);
    }
  }

  void onStateChanged(int stateId) {
    selectedStateId.value = stateId;
    selectedCityId.value = 0;
    citiesList.clear();
    if (stateId > 0) {
      isCityLoading.value = true;
      fetchCitiesByState(stateId);
    }
    update();
  }

  void onCityChanged(int cityId) {
    selectedCityId.value = cityId;
    update();
  }

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

  Map<String, String> validateCurrentStep() {
    formErrors.clear();
    switch (currentStep.value) {
      case 0:
        if (propertyName.value.isEmpty) formErrors['property_name'] = 'Property name is required';
        if (selectedCategoryId.value <= 0) formErrors['category_id'] = 'Please select a category';
        if (price.value.isEmpty) formErrors['price'] = 'Total price is required';
        if (areaSqft.value.isEmpty) formErrors['area_sqft'] = 'Area is required';
        if (selectedCountryId.value <= 0) formErrors['country'] = 'Please select a country';
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
      final youtubeLink = yotubeLink.value.trim();
      if (youtubeLink.isNotEmpty) {
        final uri = Uri.tryParse(youtubeLink);
        final isValidYoutube =
            uri != null &&
                uri.hasAbsolutePath &&
                (uri.host.contains('youtube.com') || uri.host.contains('youtu.be'));

        if (!isValidYoutube) {
          SnackBarHelper.showError('Please enter a valid YouTube link');
          return;
        }
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
      final coreFields = {
        'property_name': propertyName.value,
        'category_id': selectedCategoryId.value.toString(),
        'price': price.value,
        'area_sqft_price': pricePerSqft.value,
        'area_sqft': areaSqft.value,
        'plot_count': plotCount.value,
        'location': location.value,
        'lat': latitude.value.toString(),
        'lng': longitude.value.toString(),
        'about_property': aboutProperty.value,
        'user_type': userType.value.isNotEmpty ? userType.value : 'customer',
        if (yotubeLink.value.trim().isNotEmpty) 'youtube_link': yotubeLink.value.trim(),
        if (selectedStateId.value > 0) 'state': selectedStateId.value.toString(),
        if (selectedCityId.value > 0) 'city': selectedCityId.value.toString(),
        if (selectedCountryId.value > 0) 'country': selectedCountryId.value.toString(),

        if (selectedSubCategoryId.value > 0) 'sub_category_id': selectedSubCategoryId.value.toString(),
        if (selectedAmenityIds.isNotEmpty) 'amenities_data': selectedAmenityIds.map((id) => id.toString()).join(','),
      };
      coreFields.forEach((k, v) { if (v.isNotEmpty) request.fields[k] = v; });
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

      if (selectedNearbyPlaces.isNotEmpty) {
        request.fields['nearby_places'] = jsonEncode(selectedNearbyPlaces.map((p) => {
          'place_id': p['place_id'],
          'distance': p['distance'],
        }).toList());
      }
      for (int i = 0; i < galleryImages.length; i++) {
        final f = galleryImages[i];
        request.files.add(await http.MultipartFile.fromPath('gallery_images[]', f.path));
      }
      for (var u in galleryImageUrls) {
        request.fields['gallery_images'] = u;
      }
      for (int i = 0; i < galleryVideos.length; i++) {
        final f = galleryVideos[i];
        request.files.add(await http.MultipartFile.fromPath('gallery_images[]', f.path));
      }
      for (var u in galleryVideoUrls) {
        request.fields['gallery_images'] = u;
      }
      if (threeDImageFile.value != null) {
        request.files.add(await http.MultipartFile.fromPath('three_d_image', threeDImageFile.value!.path));
      }
      if (editingPropertyId.value > 0 && threeDImageUrl.value.isNotEmpty) {
        request.fields['three_d_image_url'] = threeDImageUrl.value;
      }
      if (blueprintFile.value != null) {
        request.files.add(await http.MultipartFile.fromPath('blueprint', blueprintFile.value!.path));
      }
      if (editingPropertyId.value > 0 && blueprintUrl.value.isNotEmpty) {
        request.fields['blueprint_url'] = blueprintUrl.value;
      }
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
    else {
      filteredProperties.assignAll(
        properties.where((p) => (p.status ?? '').toLowerCase() == filter.toLowerCase()).toList());
    }
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
                if (item.containsKey('created_at')) plotData['created_at'] = item['created_at'];
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

  Future<void> renewProperty(int propertyId) async {
    try {
      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        SnackBarHelper.showError('Session expired. Please login again.');
        return;
      }
      final response = await ApiService.getAuthenticatedRequest(
        '${ApiUrl.baseUrl}/api/v2/renew/$propertyId',
         token,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        SnackBarHelper.showSuccess('Property renewed successfully!');
        fetchMyProperties();
      } else {
        final msg = response.data?['message'] ?? 'Renewal failed. Please try again.';
        SnackBarHelper.showError(msg.toString());
      }
    } catch (e) {
      SnackBarHelper.showError('Failed to renew property');
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

      final dashboardController = Get.put(DashboardController());
      double baseAmount = 499.0;

      if (dashboardController.businessSettings.value?.residentialDocumentAmount != null && dashboardController.businessSettings.value!.residentialDocumentAmount! > 0) {
        baseAmount = dashboardController.businessSettings.value!.residentialDocumentAmount!;
      }

      final double residentialIgst = (dashboardController.businessSettings.value?.residentialIgst ?? 0).toDouble();

      final double residentialServiceCharge = (dashboardController.businessSettings.value?.residentialServiceCharge ?? 0).toDouble();

      final double serviceChargeAmount = (baseAmount * residentialServiceCharge) / 100;

      final double igstAmount = (baseAmount * residentialIgst) / 100;

      final double totalAmount = baseAmount + serviceChargeAmount + igstAmount;

      return totalAmount;
    } catch (e) {
      print('❌ Error getting verification amount: $e');
      return 499.0;
    }
  }

  Future<void> initiateVerificationPayment(Property property) async {
    try {
      final razorpayController = Get.put(RazorpayController());
      final dashboardController = Get.put(DashboardController());
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

      double baseAmount = 499.0;

      if (dashboardController
          .businessSettings.value?.residentialDocumentAmount !=
          null &&
          dashboardController
              .businessSettings.value!.residentialDocumentAmount! >
              0) {
        baseAmount = dashboardController
            .businessSettings.value!.residentialDocumentAmount!;
      }
      final double residentialIgst =
      (dashboardController.businessSettings.value?.residentialIgst ??
          0)
          .toDouble();

      final double residentialServiceCharge =
      (dashboardController
          .businessSettings.value?.residentialServiceCharge ??
          0)
          .toDouble();
      final double serviceChargeAmount = (baseAmount * residentialServiceCharge) / 100;

      final double igstAmount = (baseAmount * residentialIgst) / 100;
      final double amountToCharge =
          baseAmount + serviceChargeAmount + igstAmount;


      razorpayController.setupResidentialVerificationPayment(
        residentialPlotId: property.id,
        amount: amountToCharge,
        propertyName: property.propertyName,
      );

      Get.dialog(
        AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          titlePadding: EdgeInsets.zero,
          title: Container(
            padding: EdgeInsets.symmetric(
              vertical: 20.h,
              horizontal: 24.w,
            ),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24.r),
                topRight: Radius.circular(24.r),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.home_work_rounded,
                    color: Colors.white,
                    size: 22.sp,
                  ),
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
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  "Secure your listing and reach more buyers with our verified badge.",
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),

                SizedBox(height: 16.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColor.primary.withOpacity(0.15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.propertyName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColor.black,
                        ),
                      ),

                      SizedBox(height: 4.h),

                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12.sp,
                            color: Colors.grey[400],
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              property.location,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),
                _buildBenefitItem(
                  "Priority search ranking for residential listings",
                ),
                _buildBenefitItem(
                  "Trusted Seller badge added to profile",
                ),
                _buildBenefitItem(
                  "Document validation for buyer confidence",
                ),
                SizedBox(height: 20.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColor.primary.withOpacity(0.05),
                        AppColor.primary.withOpacity(0.1),
                      ],
                    ),
                    borderRadius:
                    BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      _buildAmountRow(
                        "Verification Fee",
                        "₹${baseAmount.toStringAsFixed(2)}",
                      ),

                      SizedBox(height: 10.h),
                      _buildAmountRow(
                        "Service Charge (${residentialServiceCharge.toStringAsFixed(0)}%)",
                        "₹${serviceChargeAmount.toStringAsFixed(2)}",
                      ),
                      SizedBox(height: 10.h),
                      _buildAmountRow(
                        "IGST (${residentialIgst.toStringAsFixed(0)}%)",
                        "₹${igstAmount.toStringAsFixed(2)}",
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 12.h,
                        ),
                        child: Divider(),
                      ),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Amount",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "₹${amountToCharge.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColor.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 14.h),
                Obx(
                      () => Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 40.w,
                        child: Checkbox(
                          value: razorpayController
                              .isTermsAccepted.value,
                          onChanged: (_) =>
                              razorpayController
                                  .toggleTerms(),
                          activeColor: AppColor.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(4.r),
                          ),
                        ),
                      ),

                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 5.h),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 12.sp,
                                color:
                                Colors.grey.shade700,
                                height: 1.4,
                              ),
                              children: [
                                const TextSpan(
                                  text:
                                  "I agree to the ",
                                ),
                                TextSpan(
                                  text:
                                  "Terms & Conditions",
                                  style: TextStyle(
                                    color:
                                    AppColor.primary,
                                    fontWeight:
                                    FontWeight.bold,
                                    decoration:
                                    TextDecoration
                                        .underline,
                                  ),
                                  recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () {
                                      Get.to(
                                            () =>
                                            LegalPageScreen(
                                              slug:
                                              "flatsvillas_payment_verification_terms_and_condition",
                                              title:
                                              "Terms & Conditions",
                                            ),
                                      );
                                    },
                                ),
                                const TextSpan(
                                  text: ".",
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actionsPadding:
          EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),

          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      if (Get.isSnackbarOpen) {
                        Get.closeCurrentSnackbar();
                      }
                      Get.back();
                    },
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!razorpayController
                          .isTermsAccepted.value) {
                        Get.snackbar(
                          "Action Required",
                          "Please accept the terms to proceed.",
                          backgroundColor:
                          Colors.redAccent,
                          colorText: Colors.white,
                          snackPosition:
                          SnackPosition.BOTTOM,
                        );
                        return;
                      }

                      if (Get.isSnackbarOpen) {
                        Get.closeCurrentSnackbar();
                      }

                      Get.back();
                      razorpayController.initiatePayment();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      padding: EdgeInsets.symmetric(
                        vertical: 12.h,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "Proceed to Pay",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      print('❌ Error initiating verification payment: $e');

      SnackBarHelper.showError(
        'Failed to initiate payment',
      );
    }
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: AppColor.primary,
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(
      String title,
      String amount,
      ) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.grey[700],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }




  @override
  void onClose() {
    facilityControllers.forEach((_, c) => c.dispose());
    nearbyDistanceControllers.forEach((_, c) => c.dispose());
    super.onClose();
  }
}