// lib/app/modules/vendor_store/controllers/vendor_store_controller.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../common/api_constant.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';
import '../model/comapany_profile.dart';

class VendorStoreController extends GetxController {
  var isLoading = false.obs;
  var isCreating = false.obs;
  var isFetching = false.obs;
  var store = Rxn<VendorStoreModel>();
  var errorMessage = ''.obs;

  // Existing controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final postalCodeController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final websiteController = TextEditingController();
  final latController = TextEditingController();
  final langController = TextEditingController();
  final addressController = TextEditingController();
  final searchAddressController = TextEditingController();
  final instagramController = TextEditingController();
  final facebookController = TextEditingController();
  final xController = TextEditingController();
  final youtubeController = TextEditingController();

  final faxController = TextEditingController();
  final taxController = TextEditingController();
  final gstController = TextEditingController();
  final establishedYearController = TextEditingController();

  var addressText = ''.obs;
  var latText = ''.obs;
  var langText = ''.obs;

  var faxText = ''.obs;
  var taxText = ''.obs;
  var gstText = ''.obs;
  var establishedYearText = ''.obs;


  final userId = 0.obs;
  final ImagePicker _picker = ImagePicker();
  var storeImages = <File>[].obs;
  var thumbnailImage = Rxn<File>();
  var storeImageUrls = <String>[].obs;
  var thumbnailUrl = ''.obs;
  var countries = <CountryModel>[].obs;
  var states = <StateModel>[].obs;
  var cities = <CityModel>[].obs;
  var selectedCountry = Rxn<CountryModel>();
  var selectedState = Rxn<StateModel>();
  var selectedCity = Rxn<CityModel>();
  var isCountryLoading = false.obs;
  var isStateLoading = false.obs;
  var isCityLoading = false.obs;
  GoogleMapController? mapController;
  var selectedLocation = Rxn<LatLng>();
  var isMapLoading = false.obs;
  var isLocatingUser = false.obs;
  var mapMarkers = <Marker>{}.obs;
  var searchResults = <Map<String, dynamic>>[].obs;
  var isSearching = false.obs;


  @override
  void onInit() {
    super.onInit();
    loadUserId();
    fetchCountries();
    checkLocationPermission();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    cityController.dispose();
    stateController.dispose();
    postalCodeController.dispose();
    phoneController.dispose();
    emailController.dispose();
    websiteController.dispose();
    latController.dispose();
    langController.dispose();
    addressController.dispose();
    searchAddressController.dispose();
    instagramController.dispose();
    facebookController.dispose();
    xController.dispose();
    youtubeController.dispose();

    faxController.dispose();
    taxController.dispose();
    gstController.dispose();
    establishedYearController.dispose();

    mapController?.dispose();
    super.onClose();
  }


  Future<void> checkLocationPermission() async {
    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> searchLocation(String query) async {
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }
    try {
      isSearching.value = true;
      final url = 'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=${ApiUrl.googleApiKey}&components=country:in';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          searchResults.value =
          List<Map<String, dynamic>>.from(data['predictions']);
        } else {
          searchResults.clear();
        }
      }
    } catch (e) {
      print('❌ Search error: $e');
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> selectSearchResult(Map<String, dynamic> result) async {
    try {
      isMapLoading.value = true;
      final placeId = result['place_id'];
      final url = 'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=$placeId'
          '&key=${ApiUrl.googleApiKey}';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          final lat = location['lat'];
          final lng = location['lng'];
          final latLng = LatLng(lat, lng);
          selectedLocation.value = latLng;

          final marker = Marker(
            markerId: const MarkerId('selected_location'),
            position: latLng,
            infoWindow: InfoWindow(
              title: result['description'] ?? 'Selected Location',
            ),
          );
          mapMarkers.value = {marker};

          mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(latLng, 16),
          );

          await updateAddressFromLatLng(latLng);
          final desc = result['description'] ?? '';
          addressController.text = desc;
          searchAddressController.text = desc;
          addressText.value = desc;
        }
      }
    } catch (e) {
      print('❌ Select search result error: $e');
      SnackBarHelper.showError('Failed to get location details');
    } finally {
      isMapLoading.value = false;
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      isLocatingUser.value = true;
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        SnackBarHelper.showError('Please enable location services');
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          SnackBarHelper.showError('Location permissions are denied');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        SnackBarHelper.showError('Location permissions are permanently denied');
        return;
      }
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final latLng = LatLng(position.latitude, position.longitude);
      selectedLocation.value = latLng;

      final marker = Marker(
        markerId: const MarkerId('current_location'),
        position: latLng,
        infoWindow: const InfoWindow(title: 'Current Location'),
      );
      mapMarkers.value = {marker};

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(latLng, 16),
      );
      await updateAddressFromLatLng(latLng);
    } catch (e) {
      print('❌ Get current location error: $e');
      SnackBarHelper.showError('Failed to get current location');
    } finally {
      isLocatingUser.value = false;
    }
  }

  Future<void> onMapTap(LatLng latLng) async {
    try {
      isMapLoading.value = true;
      selectedLocation.value = latLng;

      final marker = Marker(
        markerId: const MarkerId('tapped_location'),
        position: latLng,
        infoWindow: const InfoWindow(title: 'Selected Location'),
      );
      mapMarkers.value = {marker};

      await updateAddressFromLatLng(latLng);
    } catch (e) {
      print('❌ Map tap error: $e');
    } finally {
      isMapLoading.value = false;
    }
  }

  Future<void> updateAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        final latStr = latLng.latitude.toString();
        final lngStr = latLng.longitude.toString();
        latController.text = latStr;
        langController.text = lngStr;
        latText.value = latStr;
        langText.value = lngStr;

        List<String> addressParts = [];
        if (place.street?.isNotEmpty == true) addressParts.add(place.street!);
        if (place.subLocality?.isNotEmpty == true) addressParts.add(place.subLocality!);
        if (place.locality?.isNotEmpty == true) addressParts.add(place.locality!);
        if (place.administrativeArea?.isNotEmpty == true) addressParts.add(place.administrativeArea!);
        if (place.country?.isNotEmpty == true) addressParts.add(place.country!);

        final fullAddress = addressParts.join(', ');
        addressController.text = fullAddress;
        searchAddressController.text = fullAddress;
        addressText.value = fullAddress;

        if (place.postalCode?.isNotEmpty == true) {
          postalCodeController.text = place.postalCode!;
        }

        await matchLocationWithDatabase(place);
      }
    } catch (e) {
      print('❌ Update address error: $e');
    }
  }
  Future<void> matchLocationWithDatabase(Placemark place) async {
    if (countries.isEmpty) await fetchCountries();
    if (place.country != null) {
      final matchedCountry = countries.firstWhereOrNull(
              (c) => c.countryName.toLowerCase().contains(place.country!.toLowerCase()));
      if (matchedCountry != null) {
        selectedCountry.value = matchedCountry;
        await fetchStates(matchedCountry.id);
        if (place.administrativeArea != null) {
          final matchedState = states.firstWhereOrNull(
                  (s) => s.stateName.toLowerCase().contains(place.administrativeArea!.toLowerCase()));
          if (matchedState != null) {
            selectedState.value = matchedState;
            await fetchCities(matchedState.id);
            if (place.locality != null) {
              final matchedCity = cities.firstWhereOrNull(
                      (c) => c.cityName.toLowerCase().contains(place.locality!.toLowerCase()));
              if (matchedCity != null) {
                selectedCity.value = matchedCity;
                cityController.text = matchedCity.cityName;
              }
            }
          }
        }
      }
    }
  }


  Future<void> fetchCountries() async {
    try {
      isCountryLoading.value = true;
      countries.clear();
      final response = await ApiService.getRequest(ApiUrl.countryUrl);
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['data'] != null && responseData['data'] is List) {
          countries.value = (responseData['data'] as List)
              .map((item) => CountryModel.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      print('❌ Error fetching countries: $e');
    } finally {
      isCountryLoading.value = false;
    }
  }

  void onCountryChanged(CountryModel? country) {
    selectedCountry.value = country;
    selectedState.value = null;
    selectedCity.value = null;
    states.clear();
    cities.clear();
    stateController.clear();
    cityController.clear();
    if (country != null) fetchStates(country.id);
  }


  Future<void> fetchStates(int countryId) async {
    try {
      isStateLoading.value = true;
      states.clear();
      final url = '${ApiUrl.stateUrl}?country_id=$countryId&search=';
      final response = await ApiService.getRequest(url);
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['data'] != null && responseData['data'] is List) {
          states.value = (responseData['data'] as List)
              .map((item) => StateModel.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      print('❌ Error fetching states: $e');
    } finally {
      isStateLoading.value = false;
    }
  }

  void onStateChanged(StateModel? state) {
    selectedState.value = state;
    selectedCity.value = null;
    cities.clear();
    cityController.clear();
    if (state != null) {
      stateController.text = state.stateName;
      fetchCities(state.id);
    }
  }


  Future<void> fetchCities(int stateId) async {
    try {
      isCityLoading.value = true;
      cities.clear();
      final url = '${ApiUrl.cityUrl}?state_id=$stateId&search=';
      final response = await ApiService.getRequest(url);
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['data'] != null && responseData['data'] is List) {
          cities.value = (responseData['data'] as List)
              .map((item) => CityModel.fromJson(item))
              .toList();
        }
      }
    } catch (e) {
      print('❌ Error fetching cities: $e');
    } finally {
      isCityLoading.value = false;
    }
  }

  void onCityChanged(CityModel? city) {
    selectedCity.value = city;
    if (city != null) cityController.text = city.cityName;
  }


  Future<void> pickStoreImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (images != null && images.isNotEmpty) {
        if (storeImages.length + images.length > 5) {
          SnackBarHelper.showError('Maximum 5 images allowed');
          return;
        }
        for (var image in images) {
          storeImages.add(File(image.path));
        }
      }
    } catch (e) {
      print('❌ Image pick error: $e');
      SnackBarHelper.showError('Failed to pick images');
    }
  }

  Future<void> pickThumbnailImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (image != null) thumbnailImage.value = File(image.path);
    } catch (e) {
      print('❌ Thumbnail pick error: $e');
      SnackBarHelper.showError('Failed to pick thumbnail');
    }
  }

  Future<void> takeThumbnailPhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );
      if (image != null) thumbnailImage.value = File(image.path);
    } catch (e) {
      print('❌ Camera error: $e');
      SnackBarHelper.showError('Failed to take photo');
    }
  }

  void removeStoreImage(int index) {
    if (index >= 0 && index < storeImages.length) {
      storeImages.removeAt(index);
    }
  }

  void clearThumbnail() {
    thumbnailImage.value = null;
  }


  Future<void> loadUserId() async {
    final id = await SessionManager.getUserId();
    if (id != null) userId.value = int.parse(id);
  }


  bool _validateForm() {
    if (nameController.text.trim().isEmpty) {
      SnackBarHelper.showError('Please enter store name');
      return false;
    }
    if (descriptionController.text.trim().isEmpty) {
      SnackBarHelper.showError('Please enter store description');
      return false;
    }
    if (selectedCountry.value == null) {
      SnackBarHelper.showError('Please select country');
      return false;
    }
    if (selectedState.value == null) {
      SnackBarHelper.showError('Please select state');
      return false;
    }
    if (selectedCity.value == null) {
      SnackBarHelper.showError('Please select city');
      return false;
    }
    if (postalCodeController.text.trim().isEmpty) {
      SnackBarHelper.showError('Please enter postal code');
      return false;
    }
    if (phoneController.text.trim().isEmpty) {
      SnackBarHelper.showError('Please enter phone number');
      return false;
    }
    if (emailController.text.trim().isEmpty) {
      SnackBarHelper.showError('Please enter email');
      return false;
    }
    if (!GetUtils.isEmail(emailController.text.trim())) {
      SnackBarHelper.showError('Please enter a valid email');
      return false;
    }

    if (websiteController.text.trim().isNotEmpty) {
      final websiteUrl = websiteController.text.trim();
      if (!_isValidWebsiteUrl(websiteUrl)) {
        SnackBarHelper.showError(
            'Please enter a valid website URL'
        );
        return false;
      }
    }

    if (addressController.text.trim().isEmpty) {
      SnackBarHelper.showError('Please select address from map');
      return false;
    }
    if (latController.text.trim().isEmpty || langController.text.trim().isEmpty) {
      SnackBarHelper.showError('Please select location on map');
      return false;
    }
    if (thumbnailImage.value == null && thumbnailUrl.value.isEmpty) {
      SnackBarHelper.showError('Please select a thumbnail image');
      return false;
    }

    if (storeImages.isEmpty && storeImageUrls.isEmpty) {
      SnackBarHelper.showError('Please select at least one store image');
      return false;
    }

    if (gstController.text.trim().isEmpty) {
      SnackBarHelper.showError('Please enter GST number');
      return false;
    }

    if (establishedYearController.text.trim().isNotEmpty) {
      final year = int.tryParse(establishedYearController.text.trim());
      final currentYear = DateTime.now().year;
      if (year == null || year < 1900 || year > currentYear) {
        SnackBarHelper.showError('Please enter a valid established year (1900-$currentYear)');
        return false;
      }
    }

    final socialFields = {
      'Instagram': instagramController.text.trim(),
      'Facebook': facebookController.text.trim(),
      'X (Twitter)': xController.text.trim(),
      'YouTube': youtubeController.text.trim(),
    };
    for (final entry in socialFields.entries) {
      final val = entry.value;
      if (val.isNotEmpty && !_isValidWebsiteUrl(val)) {
        SnackBarHelper.showError('Please enter a valid ${entry.key} URL');
        return false;
      }
    }

    return true;
  }

  bool _isValidWebsiteUrl(String url) {
    url = url.trim();
    if (url.isEmpty) return false;
    final urlPattern = r'^(https?:\/\/)?'
        r'((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|'
        r'((\d{1,3}\.){3}\d{1,3}))'
        r'(:\d+)?(\/[-a-z\d%_.~+]*)*'
        r'(\?[;&a-z\d%_.~+=-]*)?'
        r'(\#[-a-z\d_]*)?$';
    final regex = RegExp(urlPattern, caseSensitive: false);
    if (!regex.hasMatch(url)) {
      return false;
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      final parts = url.split('.');
      if (parts.length < 2) return false;
      final tld = parts.last;
      const validTlds = [
        'com', 'org', 'net', 'edu', 'gov', 'io', 'co', 'in', 'uk', 'us',
        'au', 'ca', 'de', 'fr', 'jp', 'br', 'mx', 'it', 'es', 'nl',
        'ru', 'za', 'com.au', 'co.uk', 'co.in', 'app', 'dev', 'tech'
      ];
      return true;
    }

    return true;
  }

  Future<Map<String, dynamic>> createStore() async {
    try {
      isCreating(true);
      errorMessage('');

      if (!_validateForm()) {
        isCreating(false);
        return {'status': 400, 'message': 'Please fill all required fields'};
      }

      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        isCreating(false);
        return {'status': 401, 'message': 'Please login to create store'};
      }

      final formData = dio.FormData.fromMap({
        'user_id': userId.value,
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'country': selectedCountry.value?.id,
        'state': selectedState.value?.id,
        'city': selectedCity.value?.id,
        'postal_code': postalCodeController.text.trim(),
        'phone': phoneController.text.trim(),
        'email': emailController.text.trim(),
        'website': websiteController.text.trim(),
        'lat': latController.text.trim(),
        'lang': langController.text.trim(),
        'address': addressController.text.trim(),
        'instagram': instagramController.text.trim(),
        'facebook': facebookController.text.trim(),
        'x': xController.text.trim(),
        'youtube': youtubeController.text.trim(),
        'fax': faxController.text.trim(),
        'tax_number': taxController.text.trim(),
        'gst': gstController.text.trim(),
        'estimate_date': establishedYearController.text.trim(),
      });


      for (var i = 0; i < storeImages.length; i++) {
        final file = storeImages[i];
        if (await file.exists()) {
          formData.files.add(MapEntry(
            'image[]',
            await dio.MultipartFile.fromFile(
              file.path,
              filename: 'store_image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
            ),
          ));
        }
      }
      if (thumbnailImage.value != null && await thumbnailImage.value!.exists()) {
        formData.files.add(MapEntry(
          'thumbnail',
          await dio.MultipartFile.fromFile(
            thumbnailImage.value!.path,
            filename: 'thumbnail_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        ));
      }
      final response = await ApiService.postMultipart(ApiUrl.vendorStoreUrl, formData);
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        final responseData = response.data;

        if (responseData == null) {
          const errorMsg = 'Invalid response from server';
          SnackBarHelper.showError(errorMsg);
          return {'status': 500, 'message': errorMsg};
        }
        if (responseData['status'] == true) {
          final message = responseData['message'] ?? 'Store created successfully';
          SnackBarHelper.showSuccess(message);
          await fetchStore();
          return {
            'status': 200,
            'message': message,
            'data': responseData['data']
          };
        } else {
          final errorMsg = responseData['message'] ?? 'Failed to create store';
          SnackBarHelper.showError(errorMsg);
          return {'status': 400, 'message': errorMsg};
        }
      } else {
        final errorMsg = response.data?['message'] ??
            'Failed to create store (Status: ${response.statusCode})';
        SnackBarHelper.showError(errorMsg);
        return {'status': response.statusCode ?? 500, 'message': errorMsg};
      }
    } catch (e) {
      print('❌ Create store error: $e');
      SnackBarHelper.showError('Network error: ${e.toString()}');
      return {'status': 500, 'message': 'Network error: $e'};
    } finally {
      isCreating(false);
    }
  }

  Future<void> fetchStore() async {
    try {
      isFetching(true);
      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        isFetching(false);
        return;
      }
      final response = await ApiService.getAuthenticatedRequest(
        '${ApiUrl.vendorStoreUrl}/${userId.value}',
        token,
      );
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          store.value = VendorStoreModel.fromJson(responseData['data']);
          clearForm();
          await prefillFormData();
        }
      }
    } catch (e) {
      print('❌ Fetch store error: $e');
    } finally {
      isFetching(false);
    }
  }


  Future<void> prefillFormData() async {
    if (store.value == null) return;
    final s = store.value!;

    nameController.text = s.name??'';
    descriptionController.text = s.description??'';
    postalCodeController.text = s.postalCode??'';
    phoneController.text = s.phone??'';
    emailController.text = s.email??'';
    websiteController.text = s.website ?? '';
    instagramController.text = s.instagram ?? '';
    facebookController.text = s.facebook ?? '';
    xController.text = s.x ?? '';
    youtubeController.text = s.youtube ?? '';
    faxController.text = s.fax ?? '';
    taxController.text = s.tax ?? '';
    gstController.text = s.gst ?? '';
    establishedYearController.text = s.establishedYear != null ? s.establishedYear.toString() : '';
    final address = s.address;
    addressController.text = address??'';
    searchAddressController.text = address??'';
    addressText.value = address??'';
    final latStr = s.lat?.toString()??'';
    final lngStr = s.lang?.toString()??'';
    latController.text = latStr;
    langController.text = lngStr;
    latText.value = latStr;
    langText.value = lngStr;

    if (s.lat != 0 && s.lang != 0) {
      final latLng = LatLng(s.lat??0, s.lang??0);
      selectedLocation.value = latLng;
      final marker = Marker(
        markerId: const MarkerId('stored_location'),
        position: latLng,
        infoWindow: InfoWindow(title: s.name),
      );
      mapMarkers.assignAll({marker});
    }

    if (s.images != null && s.images!.isNotEmpty) {
      storeImageUrls.value = s.images!;
    }
    if (s.thumbnail != null) {
      thumbnailUrl.value = s.thumbnail!;
    }

    if (s.state?.countryId != null) {
      await fetchCountries();

      final country = countries.firstWhereOrNull((c) => c.id == s.state?.countryId);

      if (country != null) {
        selectedCountry.value = country;

        if (s.state?.id != null) {
          await fetchStates(s.state?.countryId ?? 0);

          final state =
          states.firstWhereOrNull((st) => st.id == s.state?.id);

          if (state != null) {
            selectedState.value = state;
            stateController.text = state.stateName;

            if (s.city?.id != null) {
              await fetchCities(s.state?.id ?? 0);

              final city =
              cities.firstWhereOrNull((ci) => ci.id == s.city?.id);

              if (city != null) {
                selectedCity.value = city;
                cityController.text = city.cityName;
              }
            }
          }
        }
      }
    }
  }


  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    cityController.clear();
    stateController.clear();
    postalCodeController.clear();
    phoneController.clear();
    emailController.clear();
    websiteController.clear();
    latController.clear();
    langController.clear();
    addressController.clear();
    searchAddressController.clear();
    instagramController.clear();
    facebookController.clear();
    xController.clear();
    youtubeController.clear();
    faxController.clear();
    taxController.clear();
    gstController.clear();
    establishedYearController.clear();
    addressText.value = '';
    latText.value = '';
    langText.value = '';
    faxText.value = '';
    taxText.value = '';
    gstText.value = '';
    establishedYearText.value = '';
    selectedCountry.value = null;
    selectedState.value = null;
    selectedCity.value = null;

    countries.clear();
    states.clear();
    cities.clear();

    storeImages.clear();
    thumbnailImage.value = null;
    storeImageUrls.clear();
    thumbnailUrl.value = '';
    mapMarkers.value = {};
    selectedLocation.value = null;
    searchResults.clear();

    fetchCountries();
  }


  String get displayThumbnail {
    if (thumbnailImage.value != null) return thumbnailImage.value!.path;
    if (thumbnailUrl.value.isNotEmpty) return thumbnailUrl.value;
    return '';
  }

  List<String> get displayImages {
    return [
      ...storeImages.map((f) => f.path),
      ...storeImageUrls,
    ];
  }

  bool get isFormValid {
    return nameController.text.isNotEmpty &&
        descriptionController.text.isNotEmpty &&
        selectedCountry.value != null &&
        selectedState.value != null &&
        selectedCity.value != null &&
        postalCodeController.text.isNotEmpty &&
        phoneController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        GetUtils.isEmail(emailController.text) &&
        addressController.text.isNotEmpty &&
        latController.text.isNotEmpty &&
        langController.text.isNotEmpty &&
        thumbnailImage.value != null &&
        storeImages.isNotEmpty &&
        gstController.text.isNotEmpty;
  }

  CameraPosition get initialCameraPosition {
    if (selectedLocation.value != null) {
      return CameraPosition(target: selectedLocation.value!, zoom: 16);
    }
    return const CameraPosition(
      target: LatLng(20.5937, 78.9629),
      zoom: 5,
    );
  }
}