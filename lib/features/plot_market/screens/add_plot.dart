import 'dart:convert';
import 'dart:io';
import 'package:cashback_farms/common/api_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../common/colours.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/toster.dart';
import '../controller/plot_market_controller.dart';
import '../model/plot_market.dart';

class MapSearchResult {
  final String name;
  final String displayName;
  final LatLng location;

  MapSearchResult({
    required this.name,
    required this.displayName,
    required this.location,
  });
}

class MarketPlotForm extends StatefulWidget {
  final dynamic plot;

  const MarketPlotForm({super.key, this.plot});

  @override
  State<MarketPlotForm> createState() => _MarketPlotFormState();
}

class _MarketPlotFormState extends State<MarketPlotForm> {
  final PlotMarketController controller = Get.find<PlotMarketController>();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _priceSqftController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _uldNoController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _workController = TextEditingController();
  final TextEditingController _plotCountController = TextEditingController();
  final TextEditingController _youtubeLinkController = TextEditingController();

  List<AppState> states = [];
  List<City> cities = [];
  List<PropertyType> propertyTypes = [];
  List<dynamic> nearbyPlaces = [];
  List<dynamic> amenities = [];

  AppState? _selectedState;
  City? _selectedCity;
  PropertyType? _selectedPropertyType;
  List<int> _selectedAmenities = [];
  Map<int, TextEditingController> _nearbyPlaceControllers = {};
  List<Map<String, dynamic>> _selectedNearbyPlaces = [];

  List<File> _selectedImages = [];
  List<String> _existingImageUrls = [];
  File? _plotImage;
  File? _upload3dImage;

  File? _selectedVideo;
  String? _existingVideoUrl;

  String? _existingPlotImageUrl;
  String? _existing3dImageUrl;
  bool _isSubmitting = false;
  bool _isLoadingData = true;

  LatLng? _selectedLocation;
  bool _isGettingLocation = false;

  bool _showAllAmenities = false;
  bool _showAllNearbyPlaces = false;
  bool _showAllFacilities = false;
  static const int _facilityPreviewCount = 6;

  bool _showMap = false;
  LatLng? _temporarySelectedLocation;
  GoogleMapController? _googleMapController;
  final TextEditingController _searchController = TextEditingController();
  List<MapSearchResult> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    // Reset facilities before loading
    controller.selectedFacilityIds = [];
    controller.update();

    try {
      if (mounted) setState(() => _isLoadingData = true);

      if (controller.states.isEmpty) await controller.fetchStates();
      states = List.from(controller.states);

      if (controller.plotTypes.isEmpty) await controller.fetchPropertyTypes();
      propertyTypes = List.from(controller.plotTypes);

      if (controller.amenities.isEmpty) await controller.fetchAmenities();
      amenities = List.from(controller.amenities);

      if (controller.nearbyPlaces.isEmpty) await controller.fetchNearbyPlaces();
      nearbyPlaces = List.from(controller.nearbyPlaces);

      for (var place in nearbyPlaces) {
        final placeId = place['id'];
        if (placeId != null) {
          _nearbyPlaceControllers[placeId] = TextEditingController();
        }
      }

      if (widget.plot != null) await _prefillData();

      if (mounted) setState(() => _isLoadingData = false);
    } catch (e) {
      SnackBarHelper.showError('Failed to load form data: ${e.toString()}');
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  Future<void> _prefillData() async {
    try {
      if (widget.plot is MarketPlot) {
        final plot = widget.plot as MarketPlot;

        _nameController.text = plot.name;
        _areaController.text = plot.area;
        _priceController.text = plot.price;
        _plotCountController.text = plot.plotCount?.toString() ?? '';
        _priceSqftController.text = plot.priceperSqft ?? plot.price;
        _latController.text = plot.lat;
        _longController.text = plot.long;
        _descriptionController.text = plot.description;
        _uldNoController.text = plot.uldNo ?? '';
        _addressController.text = plot.address;
        _workController.text = plot.work ?? '';
        _youtubeLinkController.text = plot.youtubeLink ?? '';

        // Location
        final lat = double.tryParse(plot.lat);
        final lng = double.tryParse(plot.long);
        if (lat != null && lng != null) {
          _selectedLocation = LatLng(lat, lng);
          _temporarySelectedLocation = LatLng(lat, lng);
        }

        // State & City
        if (plot.state?.id != null) {
          _selectedState =
              states.firstWhereOrNull((s) => s.id == plot.state!.id);
          if (_selectedState != null) {
            await controller.fetchCitiesForState(_selectedState!.id);
            cities = List.from(controller.cities);
            if (plot.city?.id != null) {
              _selectedCity =
                  cities.firstWhereOrNull((c) => c.id == plot.city!.id);
            }
          }
        }

        // Property type
        if (plot.type != null) {
          _selectedPropertyType =
              propertyTypes.firstWhereOrNull((t) => t.id == plot.type);
        }

        // Amenities
        if (plot.amenities != null) {
          _selectedAmenities = List<int>.from(plot.amenities!);
        }

        // Nearby places
        if (plot.nearbyPlaces != null) {
          for (var nearby in plot.nearbyPlaces!) {
            try {
              final placeId =
                  nearby['place_id'] ?? nearby['place'];
              final distance =
              (nearby['distance'] ?? 0.0).toDouble();
              if (placeId != null &&
                  distance > 0 &&
                  _nearbyPlaceControllers.containsKey(placeId)) {
                _nearbyPlaceControllers[placeId]?.text =
                    distance.toStringAsFixed(2);
                _selectedNearbyPlaces.add({
                  'place': placeId,
                  'distance': distance,
                });
              }
            } catch (_) {}
          }
        }

        // Gallery images
        if (plot.images.isNotEmpty) {
          _existingImageUrls = List<String>.from(plot.images);
        }

        // 3D image
        if (plot.threeDImage != null && plot.threeDImage!.isNotEmpty) {
          _existing3dImageUrl = plot.threeDImage;
        }

        // ── FIX: Blueprint prefill ──────────────────────────────────────
        if (plot.bluePrint != null && plot.bluePrint!.isNotEmpty) {
          final bp = plot.bluePrint!;
          _existingPlotImageUrl = bp.startsWith('http')
              ? bp
              : '${ApiUrl.baseUrl}/$bp';
        } else if (plot.plotImage != null && plot.plotImage!.isNotEmpty) {
          final pi = plot.plotImage!;
          _existingPlotImageUrl = pi.startsWith('http')
              ? pi
              : '${ApiUrl.baseUrl}/$pi';
        }

        // ── FIX: Common facility prefill ────────────────────────────────
        // commonFacilityIds comes as List<String> e.g. ["17","16","15"]
        if (plot.commonFacilityIds.isNotEmpty) {
          final ids = plot.commonFacilityIds
              .map((e) => int.tryParse(e))
              .whereType<int>()
              .toList();
          controller.selectedFacilityIds = ids;
          controller.update();
        }
      }
    } catch (e) {
      debugPrint('❌ _prefillData error: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _areaController.dispose();
    _priceController.dispose();
    _priceSqftController.dispose();
    _latController.dispose();
    _longController.dispose();
    _descriptionController.dispose();
    _uldNoController.dispose();
    _addressController.dispose();
    _workController.dispose();
    _searchController.dispose();
    _plotCountController.dispose();
    _nearbyPlaceControllers.values.forEach((c) => c.dispose());
    _googleMapController?.dispose();
    _youtubeLinkController.dispose();
    super.dispose();
  }

  // ── Location ──────────────────────────────────────────────────────────────

  Future<void> _getCurrentLocation() async {
    if (mounted) setState(() => _isGettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        SnackBarHelper.showError('Location services are disabled');
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
          desiredAccuracy: LocationAccuracy.high);
      if (mounted) {
        setState(() {
          _latController.text = position.latitude.toStringAsFixed(6);
          _longController.text = position.longitude.toStringAsFixed(6);
          _selectedLocation = LatLng(position.latitude, position.longitude);
          _temporarySelectedLocation =
              LatLng(position.latitude, position.longitude);
        });
      }
      await _getAddressFromCoordinates(
          position.latitude, position.longitude);
    } catch (e) {
      SnackBarHelper.showError('Failed to get location');
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks =
      await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty && mounted) {
        Placemark p = placemarks.first;
        String address = [
          p.street,
          p.locality,
          p.subLocality,
          p.administrativeArea,
          p.postalCode,
          p.country,
        ].where((x) => x != null && x.isNotEmpty).join(', ');
        _addressController.text = address;
      }
    } catch (_) {}
  }

  Future<void> _searchPlaces(
      String query,
      StateSetter setS,
      Function(List<MapSearchResult>) onResults,
      ) async {
    if (query.length < 3) {
      onResults([]);
      return;
    }
    setS(() => _isSearching = true);
    try {
      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5&countrycodes=in'),
        headers: {'User-Agent': 'PropertyApp/1.0'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final results = data
            .map((item) => MapSearchResult(
          name: item['name'] ?? '',
          displayName: item['display_name'] ?? '',
          location: LatLng(
            double.tryParse(item['lat']?.toString() ?? '') ?? 0.0,
            double.tryParse(item['lon']?.toString() ?? '') ?? 0.0,
          ),
        ))
            .toList();
        onResults(results);
      } else {
        onResults([]);
      }
    } catch (_) {
      onResults([]);
    } finally {
      setS(() => _isSearching = false);
    }
  }

  // ── Map bottom sheet ──────────────────────────────────────────────────────

  void _showMapSelection() {
    _temporarySelectedLocation =
        _selectedLocation ?? const LatLng(13.018674, 80.206710);
    List<MapSearchResult> localSearchResults = [];
    bool localIsSearching = false;

    Get.bottomSheet(
      StatefulBuilder(builder: (ctx, setS) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.9,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Select Location',
                      style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold)),
                  IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back()),
                ],
              ),
              Divider(color: Colors.grey[300]),
              Container(
                margin: EdgeInsets.only(bottom: 8.h),
                child: TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for places, addresses...',
                    prefixIcon:
                    Icon(Icons.search, color: AppColor.primary),
                    suffixIcon: localIsSearching
                        ? Padding(
                      padding: EdgeInsets.all(12.w),
                      child: SizedBox(
                        width: 18.w,
                        height: 18.h,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColor.primary),
                      ),
                    )
                        : _searchController.text.isNotEmpty
                        ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setS(() => localSearchResults.clear());
                        })
                        : null,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide:
                        BorderSide(color: Colors.grey[300]!)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(
                            color: AppColor.primary, width: 2)),
                  ),
                  onChanged: (value) {
                    if (value.length > 2) {
                      _searchPlaces(value, setS, (results) {
                        setS(() {
                          localSearchResults = results;
                          localIsSearching = false;
                        });
                      });
                    } else {
                      setS(() => localSearchResults.clear());
                    }
                  },
                ),
              ),
              if (localSearchResults.isNotEmpty)
                Container(
                  height: 150.h,
                  margin: EdgeInsets.only(bottom: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: ListView.builder(
                    padding: EdgeInsets.all(8.w),
                    itemCount: localSearchResults.length,
                    itemBuilder: (_, i) {
                      final result = localSearchResults[i];
                      return ListTile(
                        leading: Icon(Icons.location_on,
                            size: 20.sp, color: AppColor.primary),
                        title: Text(
                          result.name.isNotEmpty
                              ? result.name
                              : result.displayName.split(',').first,
                          style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(result.displayName,
                            style: TextStyle(fontSize: 10.sp),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        onTap: () {
                          setS(() {
                            _temporarySelectedLocation =
                                result.location;
                            _googleMapController?.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                    result.location, 15));
                          });
                          _searchController.clear();
                          setS(() => localSearchResults.clear());
                        },
                      );
                    },
                  ),
                ),
              Expanded(child: _buildGoogleMap(setS)),
              SizedBox(height: 12.h),
              _buildCoordinatesDisplay(),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        setS(() => localIsSearching = true);
                        await _getCurrentLocation();
                        setS(() {
                          localIsSearching = false;
                          if (_selectedLocation != null) {
                            _temporarySelectedLocation =
                                _selectedLocation;
                            _googleMapController?.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                    _temporarySelectedLocation!,
                                    15));
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        padding:
                        EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      icon: localIsSearching
                          ? SizedBox(
                          height: 16.h,
                          width: 16.h,
                          child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white))
                          : Icon(Icons.my_location,
                          size: 18.sp, color: Colors.white),
                      label: const Text('Current Location',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _showManualCoordinateInput(setS),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColor.primary),
                        padding:
                        EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      icon: Icon(Icons.edit_location_alt,
                          size: 18.sp, color: AppColor.primary),
                      label: const Text('Enter Coordinates'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              ElevatedButton(
                onPressed: () {
                  if (_temporarySelectedLocation != null) {
                    if (mounted) {
                      setState(() {
                        _selectedLocation =
                            _temporarySelectedLocation;
                        _latController.text =
                            _temporarySelectedLocation!.latitude
                                .toStringAsFixed(6);
                        _longController.text =
                            _temporarySelectedLocation!.longitude
                                .toStringAsFixed(6);
                      });
                    }
                    _getAddressFromCoordinates(
                      _temporarySelectedLocation!.latitude,
                      _temporarySelectedLocation!.longitude,
                    );
                    Get.back();
                    SnackBarHelper.showSuccess('Location updated');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  minimumSize: Size(double.infinity, 50.h),
                ),
                child: Text('Confirm Location',
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ],
          ),
        );
      }),
      isScrollControlled: true,
    );
  }

  Widget _buildGoogleMap(StateSetter setS) {
    final initialPosition = CameraPosition(
      target: _temporarySelectedLocation ??
          const LatLng(13.018674, 80.206710),
      zoom: 15,
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: initialPosition,
              onMapCreated: (c) => _googleMapController = c,
              markers: _temporarySelectedLocation != null
                  ? {
                Marker(
                  markerId:
                  const MarkerId('selected_location'),
                  position: _temporarySelectedLocation!,
                  draggable: true,
                  onDragEnd: (pos) =>
                      setS(() => _temporarySelectedLocation = pos),
                )
              }
                  : {},
              onTap: (point) {
                setS(() => _temporarySelectedLocation = point);
                _googleMapController
                    ?.animateCamera(CameraUpdate.newLatLng(point));
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapType: MapType.normal,
              compassEnabled: true,
            ),
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: Text('📍 Tap on map to set location',
                      style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.primary)),
                ),
              ),
            ),
            Positioned(
              right: 10,
              bottom: 60,
              child: Column(
                children: [
                  _mapZoomButton(Icons.add_rounded,
                          () => _googleMapController?.animateCamera(CameraUpdate.zoomIn())),
                  SizedBox(height: 4.h),
                  _mapZoomButton(Icons.remove_rounded,
                          () => _googleMapController?.animateCamera(CameraUpdate.zoomOut())),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapZoomButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Icon(icon, size: 20.sp, color: AppColor.primary),
      ),
    );
  }

  Widget _buildCoordinatesDisplay() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Latitude',
                    style: TextStyle(
                        fontSize: 11.sp, color: Colors.grey[600])),
                SizedBox(height: 4.h),
                Text(
                  _temporarySelectedLocation?.latitude
                      .toStringAsFixed(6) ??
                      'Not set',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textMain),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Longitude',
                    style: TextStyle(
                        fontSize: 11.sp, color: Colors.grey[600])),
                SizedBox(height: 4.h),
                Text(
                  _temporarySelectedLocation?.longitude
                      .toStringAsFixed(6) ??
                      'Not set',
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textMain),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showManualCoordinateInput(StateSetter setS) {
    TextEditingController latCtrl = TextEditingController(
        text: _temporarySelectedLocation?.latitude.toStringAsFixed(6) ?? '');
    TextEditingController lngCtrl = TextEditingController(
        text: _temporarySelectedLocation?.longitude.toStringAsFixed(6) ?? '');
    Get.dialog(AlertDialog(
      title: const Text('Enter Coordinates'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: latCtrl,
            decoration: const InputDecoration(
                labelText: 'Latitude',
                hintText: 'e.g., 13.018674',
                border: OutlineInputBorder()),
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: lngCtrl,
            decoration: const InputDecoration(
                labelText: 'Longitude',
                hintText: 'e.g., 80.206710',
                border: OutlineInputBorder()),
            keyboardType:
            const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            final lat = double.tryParse(latCtrl.text);
            final lng = double.tryParse(lngCtrl.text);
            if (lat != null && lng != null) {
              setS(() {
                _temporarySelectedLocation = LatLng(lat, lng);
                _googleMapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(LatLng(lat, lng), 15));
              });
              Get.back();
              SnackBarHelper.showSuccess('Coordinates updated');
            } else {
              SnackBarHelper.showError('Please enter valid coordinates');
            }
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: Colors.white),
          child: const Text('Update'),
        ),
      ],
    ));
  }

  // ── Image / Video pickers ─────────────────────────────────────────────────

  Future<void> _pickImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null && images.isNotEmpty) {
        if (_selectedImages.length + images.length > 10) {
          SnackBarHelper.showError('Maximum 10 images allowed');
          return;
        }
        if (mounted) {
          setState(() =>
              _selectedImages.addAll(images.map((e) => File(e.path))));
        }
      }
    } catch (_) {
      SnackBarHelper.showError('Failed to pick images');
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
          source: ImageSource.gallery,
          maxDuration: const Duration(minutes: 5));
      if (video != null) {
        final file = File(video.path);
        final sizeInMB = await file.length() / (1024 * 1024);
        if (sizeInMB > 50) {
          SnackBarHelper.showError('Video size must be less than 50 MB');
          return;
        }
        if (mounted) setState(() => _selectedVideo = file);
        SnackBarHelper.showSuccess('Video selected successfully');
      }
    } catch (_) {
      SnackBarHelper.showError('Failed to pick video');
    }
  }

  Future<void> _pickPlotImage() async {
    try {
      final XFile? image =
      await _picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() => _plotImage = File(image.path));
      }
    } catch (_) {
      SnackBarHelper.showError('Failed to pick image');
    }
  }

  Future<void> _pick3DImage() async {
    try {
      final XFile? image =
      await _picker.pickImage(source: ImageSource.gallery);
      if (image != null && mounted) {
        setState(() => _upload3dImage = File(image.path));
      }
    } catch (_) {
      SnackBarHelper.showError('Failed to pick image');
    }
  }

  void _removeImage(int index) {
    if (!mounted) return;
    setState(() {
      if (index < _existingImageUrls.length) {
        _existingImageUrls.removeAt(index);
      } else {
        final adj = index - _existingImageUrls.length;
        if (adj < _selectedImages.length) _selectedImages.removeAt(adj);
      }
    });
  }

  // ── UI helpers ────────────────────────────────────────────────────────────

  Widget _buildDropdown<T>({
    required String label,
    required List<T> items,
    required T? value,
    required String Function(T) displayText,
    required void Function(T?) onChanged,
    bool isRequired = false,
    bool isEnabled = true,
    bool isLoading = false, // ✅ Add this parameter
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: label,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700]),
              children: [
                if (isRequired)
                  const TextSpan(
                      text: ' *', style: TextStyle(color: Colors.red))
              ],
            ),
          ),
          SizedBox(height: 6.h),

          // ✅ Show loading indicator instead of dropdown when loading
          if (isLoading)
            Container(
              height: 50.h,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  SizedBox(width: 14.w),
                  SizedBox(
                    width: 16.w,
                    height: 16.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColor.primary,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Loading $label...',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          else
            DropdownButtonFormField<T>(
              value: value,
              items: [
                DropdownMenuItem<T>(
                  value: null,
                  child: Text('Select $label',
                      style: TextStyle(color: Colors.grey[500])),
                ),
                ...items.map((item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(displayText(item),
                      overflow: TextOverflow.ellipsis),
                )),
              ],
              onChanged: isEnabled ? onChanged : null,
              decoration: InputDecoration(
                filled: true,
                fillColor: isEnabled ? Colors.white : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide:
                  BorderSide(color: AppColor.primary, width: 1.5),
                ),
                contentPadding: EdgeInsets.symmetric(
                    horizontal: 14.w, vertical: 12.h),
              ),
              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
              validator: isRequired
                  ? (v) => v == null ? 'Please select $label' : null
                  : null,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColor.primary),
              dropdownColor: Colors.white,
              menuMaxHeight: 300.h,
            ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      String label,
      TextEditingController ctrl, {
        TextInputType keyboardType = TextInputType.text,
        bool isRequired = false,
        int maxLines = 1,
        Widget? suffixIcon,
        bool isEnabled = true,
      }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: label,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700]),
              children: [
                if (isRequired)
                  const TextSpan(
                      text: ' *', style: TextStyle(color: Colors.red))
              ],
            ),
          ),
          SizedBox(height: 6.h),
          TextFormField(
            controller: ctrl,
            keyboardType: keyboardType,
            maxLines: maxLines,
            enabled: isEnabled,
            decoration: InputDecoration(
              filled: true,
              fillColor: isEnabled ? Colors.white : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide:
                BorderSide(color: AppColor.primary, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w, vertical: 12.h),
              suffixIcon: suffixIcon,
            ),
            style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            validator: isRequired
                ? (v) {
              if (v == null || v.trim().isEmpty) {
                return 'This field is required';
              }
              return null;
            }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h, top: 8.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColor.primary,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  // ── IMPROVED Common Facility Section ─────────────────────────────────────
  Widget _selectedCommonFacilityWidget() {
    return GetBuilder<PlotMarketController>(
      builder: (ctrl) {
        final allFacilities = ctrl.getCommonFacilityModel;
        final showFacilities = _showAllFacilities
            ? allFacilities
            : allFacilities.take(_facilityPreviewCount).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Common Facilities'),
            if (allFacilities.isEmpty)
              Container(
                padding: EdgeInsets.symmetric(
                    vertical: 20.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Center(
                  child: Text('Loading facilities...',
                      style: TextStyle(
                          fontSize: 13.sp, color: Colors.grey[500])),
                ),
              )
            else ...[
              // Selected count badge
              if (ctrl.selectedFacilityIds.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.symmetric(
                      horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                        color: AppColor.primary.withOpacity(0.3)),
                  ),
                  child: Text(
                    '${ctrl.selectedFacilityIds.length} facilit${ctrl.selectedFacilityIds.length == 1 ? 'y' : 'ies'} selected',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.primary,
                    ),
                  ),
                ),

              // Grid of facility chips with icons
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.w,
                  mainAxisSpacing: 10.h,
                  childAspectRatio: 3.2,
                ),
                itemCount: showFacilities.length,
                itemBuilder: (_, index) {
                  final facility = showFacilities[index];
                  final isSelected =
                  ctrl.selectedFacilityIds.contains(facility.id);
                  return GestureDetector(
                    onTap: () => ctrl.toggleFacility(facility.id!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                          horizontal: 10.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColor.primary
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: isSelected
                              ? AppColor.primary
                              : Colors.grey[200]!,
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [
                          BoxShadow(
                            color: AppColor.primary
                                .withOpacity(0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                            : [
                          BoxShadow(
                            color:
                            Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          // Facility icon from URL or fallback
                          Container(
                            width: 28.w,
                            height: 28.w,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.2)
                                  : AppColor.primary.withOpacity(0.08),
                              borderRadius:
                              BorderRadius.circular(6.r),
                            ),
                            child: facility.image != null &&
                                facility.image!.isNotEmpty
                                ? ClipRRect(
                              borderRadius:
                              BorderRadius.circular(6.r),
                              child: Image.network(
                                facility.image!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 16.sp,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColor.primary,
                                    ),
                              ),
                            )
                                : Icon(
                              Icons.check_circle_outline,
                              size: 16.sp,
                              color: isSelected
                                  ? Colors.white
                                  : AppColor.primary,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              facility.title ?? '',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[800],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            Icon(Icons.check_circle,
                                size: 14.sp, color: Colors.white),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Show more / less
              if (allFacilities.length > _facilityPreviewCount)
                Align(
                  alignment: Alignment.center,
                  child: TextButton.icon(
                    onPressed: () {
                      if (mounted) {
                        setState(() =>
                        _showAllFacilities = !_showAllFacilities);
                      }
                    },
                    icon: Icon(
                      _showAllFacilities
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColor.primary,
                      size: 18.sp,
                    ),
                    label: Text(
                      _showAllFacilities
                          ? 'Show Less'
                          : 'Show ${allFacilities.length - _facilityPreviewCount} More',
                      style: TextStyle(
                          color: AppColor.primary, fontSize: 13.sp),
                    ),
                  ),
                ),
            ],
            SizedBox(height: 8.h),
          ],
        );
      },
    );
  }

  // ── Amenities ─────────────────────────────────────────────────────────────

  Widget _buildAmenitiesSection() {
    final showAmenities =
    _showAllAmenities ? amenities : amenities.take(6).toList();
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Amenities'),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: showAmenities.map((amenity) {
              final amenityId = amenity['id'];
              final isSelected = _selectedAmenities.contains(amenityId);
              return GestureDetector(
                onTap: () {
                  if (mounted) {
                    setState(() {
                      if (isSelected) {
                        _selectedAmenities.remove(amenityId);
                      } else {
                        _selectedAmenities.add(amenityId);
                      }
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(
                      horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color:
                    isSelected ? AppColor.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColor.primary
                          : Colors.grey[300]!,
                    ),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color:
                        AppColor.primary.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      )
                    ]
                        : [],
                  ),
                  child: Text(
                    amenity['title'] ?? 'Unknown',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? Colors.white
                          : Colors.grey[700],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (amenities.length > 6)
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  if (mounted) {
                    setState(
                            () => _showAllAmenities = !_showAllAmenities);
                  }
                },
                child: Text(
                  _showAllAmenities ? 'Show Less' : 'Show More',
                  style: TextStyle(color: AppColor.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Nearby places ─────────────────────────────────────────────────────────

  Widget _buildNearbyPlacesSection() {
    final showPlaces = _showAllNearbyPlaces
        ? nearbyPlaces
        : nearbyPlaces.take(4).toList();
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Nearby Places (Distance in KM)'),
          Column(
            children: showPlaces.map((place) {
              final placeId = place['id'];
              final ctrl = _nearbyPlaceControllers[placeId] ??
                  TextEditingController();
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: AppColor.primary.withOpacity(0.1),
                            borderRadius:
                            BorderRadius.circular(8.r),
                          ),
                          child: Icon(Icons.place,
                              size: 16.sp, color: AppColor.primary),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            place['title'] ?? 'Unknown Place',
                            style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800]),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    TextFormField(
                      controller: ctrl,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: InputDecoration(
                        hintText: 'Enter distance in KM',
                        filled: true,
                        fillColor: Colors.grey[50],
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 10.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide:
                          BorderSide(color: Colors.grey[200]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide:
                          BorderSide(color: Colors.grey[200]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                              color: AppColor.primary, width: 1.5),
                        ),
                        suffixText: 'km',
                        suffixStyle: TextStyle(
                            color: AppColor.primary,
                            fontWeight: FontWeight.bold),
                      ),
                      onChanged: (value) {
                        if (value.trim().isNotEmpty) {
                          final distance = double.tryParse(value);
                          if (distance != null) {
                            final idx = _selectedNearbyPlaces
                                .indexWhere(
                                    (p) => p['place'] == placeId);
                            if (idx >= 0) {
                              _selectedNearbyPlaces[idx]
                              ['distance'] = distance;
                            } else {
                              _selectedNearbyPlaces.add({
                                'place': placeId,
                                'distance': distance,
                              });
                            }
                          }
                        } else {
                          _selectedNearbyPlaces.removeWhere(
                                  (p) => p['place'] == placeId);
                        }
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          if (nearbyPlaces.length > 4)
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  if (mounted) {
                    setState(() =>
                    _showAllNearbyPlaces = !_showAllNearbyPlaces);
                  }
                },
                child: Text(
                  _showAllNearbyPlaces
                      ? 'Show Less Places'
                      : 'Show More Places',
                  style: TextStyle(color: AppColor.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Location section ──────────────────────────────────────────────────────

  Widget _buildLocationSection() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Location Details'),
          GestureDetector(
            onTap: _showMapSelection,
            child: Container(
              height: 140.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: AppColor.primary.withOpacity(0.04),
                border: Border.all(color: AppColor.primary.withOpacity(0.4)),
              ),
              child: _selectedLocation != null
                  ? Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on,
                            size: 36.sp, color: Colors.red),
                        SizedBox(height: 6.h),
                        Text('Location Selected',
                            style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColor.primary)),
                        SizedBox(height: 4.h),
                        Text(
                          '${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8.w,
                    right: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColor.primary,
                        borderRadius:
                        BorderRadius.circular(6.r),
                      ),
                      child: Text('Tap to change',
                          style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.white)),
                    ),
                  ),
                ],
              )
                  : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined,
                        size: 36.sp, color: AppColor.primary),
                    SizedBox(height: 8.h),
                    Text('Tap to select location',
                        style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColor.primary)),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildTextField('Latitude', _latController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    isRequired: true,
                    suffixIcon:
                    Icon(Icons.gps_fixed, size: 18.sp)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildTextField('Longitude', _longController,
                    keyboardType: const TextInputType.numberWithOptions(
                        decimal: true),
                    isRequired: true,
                    suffixIcon:
                    Icon(Icons.gps_fixed, size: 18.sp)),
              ),
            ],
          ),
          _buildTextField('Full Address', _addressController,
              maxLines: 3, isRequired: true),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isGettingLocation
                      ? null
                      : _getCurrentLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    padding:
                    EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  icon: _isGettingLocation
                      ? SizedBox(
                      height: 16.h,
                      width: 16.h,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white))
                      : Icon(Icons.my_location,
                      size: 18.sp, color: Colors.white),
                  label: const Text('Current Location',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showMapSelection,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColor.primary),
                    padding:
                    EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  icon: Icon(Icons.map,
                      size: 18.sp, color: AppColor.primary),
                  label: const Text('Select on Map'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Images & Video ────────────────────────────────────────────────────────

  Widget _buildImageSection() {
    final allImages = [
      ..._existingImageUrls.map((url) => {'type': 'url', 'value': url}),
      ..._selectedImages.map((file) => {'type': 'file', 'value': file}),
    ];
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Land Images & Video'),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
              childAspectRatio: 1,
            ),
            itemCount: allImages.length + 1,
            itemBuilder: (_, index) {
              if (index == allImages.length) {
                return GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                          color: AppColor.primary.withOpacity(0.4),
                          style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate,
                            color: AppColor.primary, size: 24.sp),
                        SizedBox(height: 4.h),
                        Text('Add Image',
                            style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColor.primary)),
                      ],
                    ),
                  ),
                );
              }
              final image = allImages[index];
              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      image: DecorationImage(
                        image: image['type'] == 'url'
                            ? NetworkImage(image['value'] as String)
                        as ImageProvider
                            : FileImage(image['value'] as File),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4.w,
                    right: 4.w,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle),
                        child: Icon(Icons.close,
                            size: 12.sp, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 16.h),

          // Video
          Text('Property Video',
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700])),
          SizedBox(height: 6.h),
          GestureDetector(
            onTap: _pickVideo,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  vertical: 18.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: _selectedVideo != null
                    ? AppColor.primary.withOpacity(0.06)
                    : Colors.grey[50],
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: _selectedVideo != null
                      ? AppColor.primary
                      : Colors.grey[200]!,
                ),
              ),
              child: _selectedVideo != null
                  ? Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: AppColor.primary.withOpacity(0.15),
                      borderRadius:
                      BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.videocam,
                        color: AppColor.primary, size: 26.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text('Video Selected',
                            style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColor.primary)),
                        SizedBox(height: 2.h),
                        Text(
                          _selectedVideo!.path
                              .split('/')
                              .last,
                          style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[500]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (mounted) {
                        setState(() => _selectedVideo = null);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle),
                      child: Icon(Icons.close,
                          size: 14.sp, color: Colors.white),
                    ),
                  ),
                ],
              )
                  : _existingVideoUrl != null
                  ? Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color:
                      AppColor.primary.withOpacity(0.15),
                      borderRadius:
                      BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.play_circle_filled,
                        color: AppColor.primary, size: 26.sp),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text('Existing Video',
                          style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColor.primary)),
                      Text('Tap to replace',
                          style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[500])),
                    ],
                  ),
                ],
              )
                  : Column(
                children: [
                  Icon(Icons.video_library_outlined,
                      size: 34.sp, color: AppColor.primary),
                  SizedBox(height: 8.h),
                  Text('Tap to add Property Video',
                      style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColor.primary,
                          fontWeight: FontWeight.w500)),
                  SizedBox(height: 4.h),
                  Text('MP4, MOV • Max 50 MB',
                      style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey[400])),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Image picker card (Blueprint / 3D) ────────────────────────────────────

  Widget _buildImagePickerCard({
    required String title,
    required VoidCallback onTap,
    required File? newFile,
    required String? existingUrl,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 160.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          color: Colors.grey[50],
          border: Border.all(
            color: (newFile != null || existingUrl != null)
                ? AppColor.primary
                : Colors.grey[200]!,
          ),
        ),
        child: newFile != null
            ? Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.file(newFile,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity),
            ),
            Positioned(
              top: 8.w,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text('Tap to change',
                    style: TextStyle(
                        fontSize: 10.sp, color: Colors.white)),
              ),
            ),
          ],
        )
            : existingUrl != null
            ? Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                existingUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (_, __, ___) => Center(
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image,
                          size: 36.sp, color: Colors.grey),
                      Text('Image failed to load',
                          style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey[500])),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8.w,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text('Tap to change',
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.white)),
              ),
            ),
          ],
        )
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color:
                  AppColor.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_a_photo,
                    size: 30.sp, color: AppColor.primary),
              ),
              SizedBox(height: 10.h),
              Text('Tap to add $title',
                  style: TextStyle(
                      color: AppColor.primary,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500)),
              SizedBox(height: 4.h),
              Text('JPG, PNG supported',
                  style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey[400])),
            ],
          ),
        ),
      ),
    );
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      SnackBarHelper.showError('Please fill all required fields');
      return;
    }
    if (_selectedState == null) {
      SnackBarHelper.showError('Please select state');
      return;
    }
    if (_selectedCity == null) {
      SnackBarHelper.showError('Please select city');
      return;
    }
    if (_selectedPropertyType == null) {
      SnackBarHelper.showError('Please select property type');
      return;
    }
    if (controller.selectedFacilityIds.isEmpty) {
      SnackBarHelper.showError('Please select minimum one common facility');
      return;
    }
    final youtubeLink = _youtubeLinkController.text.trim();

    if (youtubeLink.isNotEmpty) {
      final uri = Uri.tryParse(youtubeLink);

      final isValidYoutube =
          uri != null &&
              uri.hasAbsolutePath &&
              (uri.host.contains('youtube.com') ||
                  uri.host.contains('youtu.be'));

      if (!isValidYoutube) {
        SnackBarHelper.showError('Please enter a valid YouTube link');
        return;
      }
    }
    if (mounted) setState(() => _isSubmitting = true);

    try {
      // Rebuild nearby places from controllers
      _selectedNearbyPlaces.clear();
      for (var entry in _nearbyPlaceControllers.entries) {
        final placeId = entry.key;
        final ctrl = entry.value;
        if (ctrl.text.trim().isNotEmpty) {
          double distance = double.tryParse(ctrl.text.trim()) ?? 0;
          if (distance > 0) {
            _selectedNearbyPlaces
                .add({'place': placeId, 'distance': distance});
          }
        }
      }


      Map<String, dynamic> formData = {
        'name': _nameController.text.trim(),
        'type': _selectedPropertyType!.id.toString(),
        'state': _selectedState!.id.toString(),
        'city': _selectedCity!.id.toString(),
        'address': _addressController.text.trim(),
        'area': _areaController.text.trim(),
        'price': _priceController.text.trim(),
        'price_sqft': _priceSqftController.text.trim(),
        'lat': _latController.text.trim(),
        'long': _longController.text.trim(),
        'description': _descriptionController.text.trim(),
        'uld_no': _uldNoController.text.trim(),
        'amenities': _selectedAmenities.join(','),
        'status': '0',
        'plot_count': _plotCountController.text.trim(),
        'youtube_link' : _youtubeLinkController.text.trim(),
      };

      if (_selectedNearbyPlaces.isNotEmpty) {
        formData['nearby'] = _selectedNearbyPlaces;
      }
      if (_workController.text.trim().isNotEmpty) {
        formData['work'] = _workController.text.trim();
      }
      if (widget.plot != null) {
        if (widget.plot is MarketPlot) {
          formData['id'] = (widget.plot as MarketPlot).id.toString();
        } else if (widget.plot is Map) {
          formData['id'] = widget.plot['id'].toString();
        }
      }

      final result = await controller.submitMarketPlot(
        formData: formData,
        images: _selectedImages,
        bluePrint: _plotImage,
        threeDImage: _upload3dImage,
        video: _selectedVideo,
        selectedFacilityIds: controller.selectedFacilityIds,
        isUpdate: widget.plot != null,
      );

      if (result['status'] == 200) {
        SnackBarHelper.showSuccess(
          result['message'] ??
              'Plot ${widget.plot != null ? 'updated' : 'added'} successfully',
        );
        controller.selectedFacilityIds = [];
        controller.update();
        await controller.fetchMyMarketPlots();
      } else {
        SnackBarHelper.showError(
          result['message'] ??
              'Failed to ${widget.plot != null ? 'update' : 'add'} plot',
        );
      }
    } catch (e) {
      SnackBarHelper.showError('Error: ${e.toString()}');
    } finally {
      // ── FIX: guard setState with mounted check ──────────────────────
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: DynamicAppBar(
          title: widget.plot != null ? 'Edit Land' : 'Add Land',
          showBackButton: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColor.primary),
              SizedBox(height: 20.h),
              Text('Loading form...',
                  style: TextStyle(fontSize: 14.sp)),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: DynamicAppBar(
        title: widget.plot != null ? 'Edit Land' : 'Add Land',
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Basic Information'),
                    _buildTextField('Plot Name', _nameController,
                        isRequired: true),
                    _buildDropdown<PropertyType>(
                      label: 'Property Type',
                      items: propertyTypes,
                      value: _selectedPropertyType,
                      displayText: (t) => t.categoryName,
                      onChanged: (t) {
                        if (mounted) {
                          setState(() => _selectedPropertyType = t);
                        }
                      },
                      isRequired: true,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown<AppState>(
                            label: 'State',
                            items: states,
                            value: _selectedState,
                            displayText: (s) => s.stateName,
                            isLoading: _isLoadingData && states.isEmpty,
                            onChanged: (s) async {
                              if (mounted) {
                                setState(() {
                                  _selectedState = s;
                                  _selectedCity = null;
                                  cities.clear();
                                });
                              }
                              if (s != null) {
                                await controller.fetchCitiesForState(s.id);
                                if (mounted) {
                                  setState(() => cities = List.from(controller.cities));
                                }
                              }
                            },
                            isRequired: true,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Obx(() => _buildDropdown<City>(
                            label: 'City',
                            items: cities,
                            value: _selectedCity,
                            displayText: (c) => c.cityName,
                            isLoading: controller.isCityLoading.value,
                            onChanged: (c) {
                              if (mounted) {
                                setState(() => _selectedCity = c);
                              }
                            },
                            isRequired: true,
                            isEnabled: _selectedState != null && !controller.isCityLoading.value,
                          )),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              _buildCard(child: _buildLocationSection()),
              SizedBox(height: 12.h),
              _buildCard( child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Property Details'),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField('Area (sq ft)',
                              _areaController,
                              keyboardType:
                              TextInputType.number,
                              isRequired: true),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildTextField(
                              'Price (₹)', _priceController,
                              keyboardType:
                              TextInputType.number,
                              isRequired: true),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                              'Price per Sqft (₹)',
                              _priceSqftController,
                              keyboardType: TextInputType.number,
                              isRequired: true),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildTextField(
                              'ULPIN Number', _uldNoController),
                        ),
                      ],
                    ),
                    _buildTextField('Plot Count', _plotCountController,
                        keyboardType: TextInputType.number,
                        isRequired: true),
                    _buildTextField('Description',
                        _descriptionController,
                        maxLines: 4, isRequired: true),
                    _buildTextField('YouTube Link', _youtubeLinkController,
                        keyboardType: TextInputType.emailAddress,
                        isRequired: false),
                  ],
                ),),
              SizedBox(height: 12.h),
              _buildCard(child: _selectedCommonFacilityWidget()),
              SizedBox(height: 12.h),
              _buildCard(child: _buildAmenitiesSection()),
              SizedBox(height: 12.h),
              _buildCard(child: _buildNearbyPlacesSection()),
              SizedBox(height: 12.h),
              _buildCard(child: _buildImageSection()),
              SizedBox(height: 12.h),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Layout Sketch Image'),
                    _buildImagePickerCard(
                      title: 'Layout Sketch Image',
                      onTap: _pickPlotImage,
                      newFile: _plotImage,
                      existingUrl: _existingPlotImageUrl,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('3D Image'),
                    _buildImagePickerCard(
                      title: '3D Image',
                      onTap: _pick3DImage,
                      newFile: _upload3dImage,
                      existingUrl: _existing3dImageUrl,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    disabledBackgroundColor:
                    AppColor.primary.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r)),
                    elevation: 4,
                    shadowColor: AppColor.primary.withOpacity(0.3),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                      height: 22.h,
                      width: 22.h,
                      child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white))
                      : Text(
                      widget.plot != null
                          ? 'Update Plot'
                          : 'Add Plot',
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
              SizedBox(height: 8.h),
              Center(
                child: Text('* indicates required field',
                    style: TextStyle(
                        fontSize: 12.sp, color: Colors.grey[400])),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}