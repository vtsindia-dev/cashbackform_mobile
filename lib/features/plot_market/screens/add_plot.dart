import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

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
  String? _existingPlotImageUrl;
  String? _existing3dImageUrl;
  bool _isSubmitting = false;
  bool _isLoadingData = true;

  LatLng? _selectedLocation;
  bool _isGettingLocation = false;

  // UI State
  bool _showAllAmenities = false;
  bool _showAllNearbyPlaces = false;

  // Map selection variables
  bool _showMap = false;
  LatLng? _temporarySelectedLocation;
  late MapController _mapController;

  // Search variables
  final TextEditingController _searchController = TextEditingController();
  List<MapSearchResult> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    controller.selectedFacilityIds = [];
    controller.update();
    try {
      setState(() {
        _isLoadingData = true;
      });

      print('🔄 Loading initial data...');

      // Load states
      if (controller.states.isEmpty) {
        await controller.fetchStates();
      }
      states = List.from(controller.states);
      print('✅ Loaded ${states.length} states');

      // Load property types
      if (controller.plotTypes.isEmpty) {
        await controller.fetchPropertyTypes();
      }
      propertyTypes = List.from(controller.plotTypes);
      print(
        '✅ Loaded ${propertyTypes.length} property types: ${propertyTypes.map((e) => '${e.id}: ${e.categoryName}').toList()}',
      );

      // Load amenities
      if (controller.amenities.isEmpty) {
        await controller.fetchAmenities();
      }
      amenities = List.from(controller.amenities);
      print('✅ Loaded ${amenities.length} amenities');

      // Load nearby places
      if (controller.nearbyPlaces.isEmpty) {
        await controller.fetchNearbyPlaces();
      }
      nearbyPlaces = List.from(controller.nearbyPlaces);
      print('✅ Loaded ${nearbyPlaces.length} nearby places');

      // Initialize nearby place controllers
      for (var place in nearbyPlaces) {
        final placeId = place['id'];
        if (placeId != null) {
          _nearbyPlaceControllers[placeId] = TextEditingController();
        }
      }

      // Prefill data for edit
      if (widget.plot != null) {
        await _prefillData();
      }

      setState(() {
        _isLoadingData = false;
      });

      print('✅ Form data loading complete');
    } catch (e) {
      print('❌ Error loading data: $e');
      SnackBarHelper.showError('Failed to load form data: ${e.toString()}');
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  Future<void> _prefillData() async {
    try {
      print('🔄 Prefilling form data...');

      if (widget.plot is MarketPlot) {
        final plot = widget.plot as MarketPlot;
        print('📋 Plot data received as MarketPlot object');
        print('📊 Plot ID: ${plot.id}, Name: ${plot.name}');

        // Basic fields
        _nameController.text = plot.name ?? '';
        _areaController.text = plot.area?.toString() ?? '';
        _priceController.text = plot.price?.toString() ?? '';
        _plotCountController.text = plot.plotCount?.toString() ?? '';
        _priceSqftController.text =
            plot.priceperSqft?.toString() ?? plot.price?.toString() ?? '';
        _latController.text = plot.lat?.toString() ?? '';
        _longController.text = plot.long?.toString() ?? '';
        _descriptionController.text = plot.description ?? '';
        _uldNoController.text = plot.uldNo?.toString() ?? '';
        _addressController.text = plot.address ?? '';
        _workController.text = plot.work ?? '';

        // Set location
        if (plot.lat?.isNotEmpty == true && plot.long?.isNotEmpty == true) {
          try {
            final lat = double.tryParse(plot.lat ?? '');
            final long = double.tryParse(plot.long ?? '');
            if (lat != null && long != null) {
              _selectedLocation = LatLng(lat, long);
              _temporarySelectedLocation = LatLng(lat, long);
              print('📍 Set location: $lat, $long');
            }
          } catch (e) {
            print('❌ Error parsing location: $e');
          }
        }

        // Set state
        if (plot.state?.id != null) {
          _selectedState = states.firstWhereOrNull(
            (state) => state.id == plot.state?.id,
          );
          if (_selectedState != null) {
            await controller.fetchCitiesForState(_selectedState!.id);
            cities = List.from(controller.cities);

            // Set city
            if (plot.city?.id != null) {
              _selectedCity = cities.firstWhereOrNull(
                (city) => city.id == plot.city?.id,
              );
            }
          }
        }

        // Set property type
        print('🔍 Setting property type...');
        print(
          '📊 Available property types: ${propertyTypes.map((e) => '${e.id}: ${e.categoryName}').toList()}',
        );

        int? propertyTypeId;

        if (plot.type != null) {
          propertyTypeId = plot.type;
          print('✅ Got property type ID from plot.type: $propertyTypeId');
        } else if (plot.propertyType != null) {
          if (plot.propertyType is int) {
            propertyTypeId = plot.propertyType as int;
            print(
              '✅ Got property type ID from plot.propertyType (int): $propertyTypeId',
            );
          } else if (plot.propertyType is PropertyType) {
            propertyTypeId = (plot.propertyType as PropertyType).id;
            print(
              '✅ Got property type ID from plot.propertyType (PropertyType object): $propertyTypeId',
            );
          }
        }

        if (propertyTypeId == null) {
          print(
            '⚠️ Could not get property type ID from model fields, trying other methods...',
          );

          try {
            if (plot is dynamic) {
              final dynamicPlot = plot as dynamic;
              if (dynamicPlot.typeId != null) {
                propertyTypeId = dynamicPlot.typeId as int?;
                print(
                  '✅ Got property type ID from dynamicPlot.typeId: $propertyTypeId',
                );
              } else if (dynamicPlot.property_type_id != null) {
                propertyTypeId = dynamicPlot.property_type_id as int?;
                print(
                  '✅ Got property type ID from dynamicPlot.property_type_id: $propertyTypeId',
                );
              }
            }
          } catch (e) {
            print('❌ Error trying to get type from dynamic fields: $e');
          }
        }

        if (propertyTypeId != null) {
          _selectedPropertyType = propertyTypes.firstWhereOrNull(
            (type) => type.id == propertyTypeId,
          );

          if (_selectedPropertyType != null) {
            print(
              '✅ Found and selected property type: ${_selectedPropertyType!.categoryName} (ID: ${_selectedPropertyType!.id})',
            );
          } else {
            print(
              '❌ Could not find property type with ID: $propertyTypeId in available types',
            );
            print(
              '   Available type IDs: ${propertyTypes.map((e) => e.id).toList()}',
            );
          }
        } else {
          print('⚠️ No property type ID found in plot data');
        }

        // Set amenities
        if (plot.amenities != null && plot.amenities!.isNotEmpty) {
          try {
            if (plot.amenities is String) {
              final amenityString = plot.amenities as String;
              _selectedAmenities = amenityString
                  .split(',')
                  .map((e) => int.tryParse(e.trim()) ?? 0)
                  .where((id) => id > 0)
                  .toList();
            } else if (plot.amenities is List) {
              _selectedAmenities = List<int>.from(plot.amenities!);
            }
            print('✅ Loaded ${_selectedAmenities.length} amenities');
          } catch (e) {
            print('❌ Error parsing amenities: $e');
          }
        }

        // Set nearby places
        if (plot.nearbyPlaces != null && plot.nearbyPlaces!.isNotEmpty) {
          for (var nearby in plot.nearbyPlaces!) {
            try {
              final placeId = nearby['place_id'] ?? nearby['place'];
              var distance = (nearby['distance'] ?? 0).toDouble();

              if (placeId != null &&
                  distance > 0 &&
                  _nearbyPlaceControllers.containsKey(placeId)) {
                _nearbyPlaceControllers[placeId]?.text = distance
                    .toStringAsFixed(2);

                _selectedNearbyPlaces.add({
                  'place': placeId,
                  'distance': distance,
                });
                print(
                  '📍 Set nearby place: $placeId - ${distance.toStringAsFixed(2)} km',
                );
              }
            } catch (e) {
              print('❌ Error parsing nearby place: $e');
            }
          }
        }

        // Set images
        if (plot.images != null) {
          try {
            if (plot.images is String && (plot.images as String).isNotEmpty) {
              final imageString = plot.images as String;
              if (imageString.contains(',')) {
                _existingImageUrls = imageString
                    .split(',')
                    .map((e) => e.trim())
                    .where((url) => url.isNotEmpty)
                    .toList();
              } else {
                _existingImageUrls = [imageString];
              }
            } else if (plot.images is List) {
              final imagesList = plot.images as List;
              _existingImageUrls = imagesList
                  .whereType<String>()
                  .where((url) => url.isNotEmpty)
                  .toList();
            }
            print('🖼️ Loaded ${_existingImageUrls.length} existing images');
          } catch (e) {
            print('❌ Error parsing images: $e');
            _existingImageUrls = [];
          }
        } else {
          _existingImageUrls = [];
        }

        if (plot.threeDImage != null && plot.threeDImage!.isNotEmpty) {
          setState(() {
            _existing3dImageUrl = plot.threeDImage;
          });
        }

        // Set plot image
        if (plot.plotImage != null && plot.plotImage!.isNotEmpty) {
          final plotImageUrl = plot.plotImage!;
          if (plotImageUrl.startsWith('uploads/')) {
            _existingPlotImageUrl =
                'https://admincashback.vrikshatech.in/public/$plotImageUrl';
          } else if (!plotImageUrl.startsWith('http')) {
            _existingPlotImageUrl =
                'https://admincashback.vrikshatech.in/public/$plotImageUrl';
          } else {
            _existingPlotImageUrl = plotImageUrl;
          }
          print('🖼️ Loaded plot image: $_existingPlotImageUrl');
        }
      } else if (widget.plot is Map) {
        final plotMap = widget.plot as Map<String, dynamic>;
        print('📋 Plot data received as Map');

        _nameController.text = plotMap['name']?.toString() ?? '';
        _areaController.text = plotMap['area']?.toString() ?? '';
        _priceController.text = plotMap['price']?.toString() ?? '';
        _latController.text = plotMap['lat']?.toString() ?? '';
        _longController.text = plotMap['long']?.toString() ?? '';
        _descriptionController.text = plotMap['description']?.toString() ?? '';
        _uldNoController.text = plotMap['uld_no']?.toString() ?? '';
        _addressController.text = plotMap['address']?.toString() ?? '';
        _workController.text = plotMap['work']?.toString() ?? '';

        final typeId = plotMap['type'];
        if (typeId != null) {
          print('🔍 Setting property type from map ID: $typeId');
          _selectedPropertyType = propertyTypes.firstWhereOrNull(
            (type) => type.id == typeId,
          );
          if (_selectedPropertyType != null) {
            print(
              '✅ Found property type: ${_selectedPropertyType!.categoryName}',
            );
          }
        }
      }

      print('✅ Prefill data complete');
    } catch (e) {
      print('❌ Error in _prefillData: $e');
      print('❌ Stack trace: ${e.toString()}');
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

    _nearbyPlaceControllers.values.forEach(
      (controller) => controller.dispose(),
    );
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

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
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latController.text = position.latitude.toStringAsFixed(6);
        _longController.text = position.longitude.toStringAsFixed(6);
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _temporarySelectedLocation = LatLng(
          position.latitude,
          position.longitude,
        );
      });

      await _getAddressFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting location: $e');
      SnackBarHelper.showError('Failed to get location');
    } finally {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  Future<void> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String address = [
          placemark.street,
          placemark.locality,
          placemark.subLocality,
          placemark.administrativeArea,
          placemark.postalCode,
          placemark.country,
        ].where((part) => part != null && part.isNotEmpty).join(', ');

        _addressController.text = address;
      }
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  // Add this search method
  Future<void> _searchPlaces(
    String query,
    StateSetter setState,
    Function(List<MapSearchResult>) onResults,
  ) async {
    if (query.length < 3) {
      onResults([]);
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&addressdetails=1&limit=5&countrycodes=in',
        ),
        headers: {'User-Agent': 'PropertyApp/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final results = data.map((item) {
          return MapSearchResult(
            name: item['name'] ?? '',
            displayName: item['display_name'] ?? '',
            location: LatLng(
              double.parse(item['lat']),
              double.parse(item['lon']),
            ),
          );
        }).toList();

        onResults(results);
      } else {
        onResults([]);
      }
    } catch (e) {
      print('Search error: $e');
      onResults([]);
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _showMapSelection() {
    // Set temporary location for map
    _temporarySelectedLocation =
        _selectedLocation ?? LatLng(13.018674, 80.206710);
    bool localShowMap = _showMap;
    List<MapSearchResult> localSearchResults = List.from(_searchResults);
    bool localIsSearching = _isSearching;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.9,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.r),
                topRight: Radius.circular(20.r),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Location',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                Divider(),

                // Search Bar
                Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  child: TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for places, addresses...',
                      prefixIcon: Icon(Icons.search, color: AppColor.primary),
                      suffixIcon: localIsSearching
                          ? SizedBox(
                              width: 20.w,
                              height: 20.h,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColor.primary,
                              ),
                            )
                          : _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  localSearchResults.clear();
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        borderSide: BorderSide(
                          color: AppColor.primary,
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length > 2) {
                        _searchPlaces(value, setState, (results) {
                          setState(() {
                            localSearchResults = results;
                            localIsSearching = false;
                          });
                        });
                      } else {
                        setState(() {
                          localSearchResults.clear();
                        });
                      }
                    },
                  ),
                ),

                // Search Results
                if (localSearchResults.isNotEmpty)
                  Container(
                    height: 150.h,
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.all(8.w),
                      itemCount: localSearchResults.length,
                      itemBuilder: (context, index) {
                        final result = localSearchResults[index];
                        return ListTile(
                          leading: Icon(
                            Icons.location_on,
                            size: 20.sp,
                            color: AppColor.primary,
                          ),
                          title: Text(
                            result.name.isNotEmpty
                                ? result.name
                                : result.displayName.split(',').first,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            result.displayName,
                            style: TextStyle(fontSize: 10.sp),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            setState(() {
                              _temporarySelectedLocation = result.location;
                              if (localShowMap) {
                                _mapController.move(result.location, 15);
                              }
                            });
                            _searchController.clear();
                            setState(() {
                              localSearchResults.clear();
                            });
                          },
                        );
                      },
                    ),
                  ),

                // Map Toggle
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Show on Map',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Switch(
                        value: localShowMap,
                        activeColor: AppColor.primary,
                        onChanged: (value) {
                          setState(() {
                            localShowMap = value;
                            if (value && _temporarySelectedLocation != null) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                _mapController.move(
                                  _temporarySelectedLocation!,
                                  15,
                                );
                              });
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                Expanded(
                  child: localShowMap
                      ? _buildInteractiveMap(setState)
                      : _buildSimpleMapPreview(),
                ),

                SizedBox(height: 16.h),

                // Coordinates Display
                _buildCoordinatesDisplay(),

                SizedBox(height: 16.h),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          setState(() {
                            localIsSearching = true;
                          });
                          await _getCurrentLocation();
                          setState(() {
                            localIsSearching = false;
                            if (_selectedLocation != null) {
                              _temporarySelectedLocation = _selectedLocation;
                              if (localShowMap) {
                                _mapController.move(
                                  _temporarySelectedLocation!,
                                  15,
                                );
                              }
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primary,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        icon: localIsSearching
                            ? SizedBox(
                                height: 16.h,
                                width: 16.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(Icons.my_location, size: 18.sp),
                        label: Text('Current Location'),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showManualCoordinateInput(setState),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColor.primary),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        icon: Icon(
                          Icons.edit_location_alt,
                          size: 18.sp,
                          color: AppColor.primary,
                        ),
                        label: Text('Enter Coordinates'),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                ElevatedButton(
                  onPressed: () {
                    if (_temporarySelectedLocation != null) {
                      // Update the parent widget's state
                      setState(() {
                        _selectedLocation = _temporarySelectedLocation;
                        _latController.text = _temporarySelectedLocation!
                            .latitude
                            .toStringAsFixed(6);
                        _longController.text = _temporarySelectedLocation!
                            .longitude
                            .toStringAsFixed(6);
                        _showMap =
                            localShowMap; // Update the parent's showMap state
                      });

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
                  child: Text(
                    'Confirm Location',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildInteractiveMap(StateSetter setState) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _temporarySelectedLocation!,
            initialZoom: 15,
            onTap: (tapPosition, point) {
              setState(() {
                _temporarySelectedLocation = point;
              });
              _mapController.move(point, 15);
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.property_app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: _temporarySelectedLocation!,
                  child: Icon(Icons.location_on, color: Colors.red, size: 40.w),
                ),
              ],
            ),
          ],
        ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Selected Coordinates',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Latitude',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _temporarySelectedLocation?.latitude.toStringAsFixed(6) ??
                          'Not set',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textMain,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Longitude',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _temporarySelectedLocation?.longitude.toStringAsFixed(
                            6,
                          ) ??
                          'Not set',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColor.textMain,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showManualCoordinateInput(StateSetter setState) {
    TextEditingController latController = TextEditingController(
      text: _temporarySelectedLocation?.latitude.toStringAsFixed(6) ?? '',
    );
    TextEditingController lngController = TextEditingController(
      text: _temporarySelectedLocation?.longitude.toStringAsFixed(6) ?? '',
    );

    Get.dialog(
      AlertDialog(
        title: Text('Enter Coordinates'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: latController,
                decoration: InputDecoration(
                  labelText: 'Latitude',
                  hintText: 'e.g., 13.018674',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: lngController,
                decoration: InputDecoration(
                  labelText: 'Longitude',
                  hintText: 'e.g., 80.206710',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final lat = double.tryParse(latController.text);
              final lng = double.tryParse(lngController.text);

              if (lat != null && lng != null) {
                setState(() {
                  _temporarySelectedLocation = LatLng(lat, lng);
                  if (_showMap) {
                    _mapController.move(LatLng(lat, lng), 15);
                  }
                });
                Get.back();
                SnackBarHelper.showSuccess('Coordinates updated');
              } else {
                SnackBarHelper.showError('Please enter valid coordinates');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: Colors.white,
            ),
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleMapPreview() {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.grey[200],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 60.sp, color: AppColor.primary),
          SizedBox(height: 16.h),
          Text(
            'Turn on "Show on Map" to select location',
            style: TextStyle(fontSize: 14.sp, color: AppColor.primary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              'You can also use current location or enter coordinates manually',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage();
      if (images != null && images.isNotEmpty) {
        if (_selectedImages.length + images.length > 10) {
          SnackBarHelper.showError('Maximum 10 images allowed');
          return;
        }
        setState(() {
          _selectedImages.addAll(images.map((e) => File(e.path)));
        });
      }
    } catch (e) {
      print('Error picking images: $e');
      SnackBarHelper.showError('Failed to pick images');
    }
  }

  Future<void> _pickPlotImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _plotImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking plot image: $e');
      SnackBarHelper.showError('Failed to pick image');
    }
  }

  Future<void> _pick3DImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _upload3dImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking plot image: $e');
      SnackBarHelper.showError('Failed to pick image');
    }
  }



  void _removeImage(int index) {
    setState(() {
      if (index < _existingImageUrls.length) {
        _existingImageUrls.removeAt(index);
      } else {
        final adjustedIndex = index - _existingImageUrls.length;
        if (adjustedIndex < _selectedImages.length) {
          _selectedImages.removeAt(adjustedIndex);
        }
      }
    });
  }

  Widget _buildDropdown<T>({
    required String label,
    required List<T> items,
    required T? value,
    required String Function(T) displayText,
    required void Function(T?) onChanged,
    bool isRequired = false,
    bool isEnabled = true,
  }) {
    final validItems = items.where((item) => item != null).toList();

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label${isRequired ? ' *' : ''}',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColor.textMain,
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonFormField<T>(
              value: value,
              items: [
                DropdownMenuItem<T>(
                  value: null,
                  child: Text(
                    'Select $label',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ...validItems.map((item) {
                  return DropdownMenuItem<T>(
                    value: item,
                    child: Text(
                      displayText(item) ?? 'Unknown',
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
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
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: AppColor.primary, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 12.h,
                ),
              ),
              style: TextStyle(
                fontSize: 14.sp,
                color: isEnabled ? Colors.black87 : Colors.grey[600],
              ),
              validator: isRequired
                  ? (value) => value == null ? 'Please select $label' : null
                  : null,
              isExpanded: true,
              icon: Icon(
                Icons.arrow_drop_down,
                color: isEnabled ? AppColor.primary : Colors.grey[400],
              ),
              dropdownColor: Colors.white,
              menuMaxHeight: 300.h,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
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
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColor.textMain,
              ),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
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
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(color: AppColor.primary, width: 2),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 14.w,
                  vertical: 12.h,
                ),
                suffixIcon: suffixIcon,
              ),
              style: TextStyle(
                fontSize: 14.sp,
                color: isEnabled ? Colors.black87 : Colors.grey[600],
              ),
              validator: isRequired
                  ? (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(child: Divider(thickness: 1, color: Colors.grey[300])),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColor.primary,
              ),
            ),
          ),
          Expanded(child: Divider(thickness: 1, color: Colors.grey[300])),
        ],
      ),
    );
  }

  Widget _selectedCommonFacilityWidget(){
    return GetBuilder<PlotMarketController>(
      builder: (controller) {
        return Column(
          children: [
            _buildSectionTitle('Common Facility'),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: controller.getCommonFacilityModel.map((facility) {

                final isSelected = controller.selectedFacilityIds.contains(facility.id);

                return GestureDetector(
                  onTap: () {
                    controller.toggleFacility(facility.id!);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.amber : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.amber : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      facility.title ?? "",
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );

              }).toList(),
            ),
          ],
        );
      },
    );
  }


  Widget _buildAmenitiesSection() {
    final showAmenities = _showAllAmenities ? amenities : amenities.take(6);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Amenities'),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: showAmenities.map((amenity) {
              final amenityId = amenity['id'];
              final isSelected = _selectedAmenities.contains(amenityId);
              return ChoiceChip(
                label: Text(
                  amenity['title'] ?? 'Unknown',
                  style: TextStyle(fontSize: 12.sp),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedAmenities.add(amenityId);
                    } else {
                      _selectedAmenities.remove(amenityId);
                    }
                  });
                },
                selectedColor: AppColor.primary,
                backgroundColor: Colors.grey[100],
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              );
            }).toList(),
          ),
          if (amenities.length > 6)
            Align(
              alignment: Alignment.center,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showAllAmenities = !_showAllAmenities;
                  });
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

  Widget _buildNearbyPlacesSection() {
    final showPlaces = _showAllNearbyPlaces
        ? nearbyPlaces
        : nearbyPlaces.take(4);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Nearby Places (Distance in KM)'),
          SizedBox(height: 12.h),
          Column(
            children: showPlaces.map((place) {
              final placeId = place['id'];
              final controller =
                  _nearbyPlaceControllers[placeId] ?? TextEditingController();

              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.place, size: 16.sp, color: AppColor.primary),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            place['title'] ?? 'Unknown Place',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller,
                            keyboardType: TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter distance in KM',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                                borderSide: BorderSide(
                                  color: Colors.grey[300]!,
                                ),
                              ),
                              suffixText: 'km',
                              suffixStyle: TextStyle(
                                color: AppColor.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onChanged: (value) {
                              if (value.trim().isNotEmpty) {
                                final distance = double.tryParse(value);
                                if (distance != null) {
                                  final existingIndex = _selectedNearbyPlaces
                                      .indexWhere((p) => p['place'] == placeId);

                                  if (existingIndex >= 0) {
                                    _selectedNearbyPlaces[existingIndex]['distance'] =
                                        distance;
                                  } else {
                                    _selectedNearbyPlaces.add({
                                      'place': placeId,
                                      'distance': distance,
                                    });
                                  }
                                }
                              } else {
                                _selectedNearbyPlaces.removeWhere(
                                  (p) => p['place'] == placeId,
                                );
                              }
                            },
                          ),
                        ),
                      ],
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
                  setState(() {
                    _showAllNearbyPlaces = !_showAllNearbyPlaces;
                  });
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

  Widget _buildLocationSection() {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Location Details'),
          SizedBox(height: 12.h),

          // Location Preview Card
          GestureDetector(
            onTap: _showMapSelection,
            child: Container(
              height: 150.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: Colors.grey[200],
                border: Border.all(color: AppColor.primary),
              ),
              child: _selectedLocation != null
                  ? Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 40.sp,
                                color: Colors.red,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Location Selected',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.primary,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 8.w,
                          right: 8.w,
                          child: Container(
                            padding: EdgeInsets.all(4.r),
                            decoration: BoxDecoration(
                              color: AppColor.primary,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              'Tap to change',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.map_outlined,
                            size: 40.sp,
                            color: AppColor.primary,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Tap to select location',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColor.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          SizedBox(height: 16.h),

          // Coordinates Display
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Latitude',
                  _latController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  isRequired: true,
                  suffixIcon: Icon(Icons.gps_fixed, size: 18.sp),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildTextField(
                  'Longitude',
                  _longController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  isRequired: true,
                  suffixIcon: Icon(Icons.gps_fixed, size: 18.sp),
                ),
              ),
            ],
          ),

          // Address
          _buildTextField(
            'Full Address',
            _addressController,
            maxLines: 3,
            isRequired: true,
          ),

          SizedBox(height: 16.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isGettingLocation ? null : _getCurrentLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  icon: _isGettingLocation
                      ? SizedBox(
                          height: 16.h,
                          width: 16.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(Icons.my_location, size: 18.sp),
                  label: Text('Current Location'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showMapSelection,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColor.primary),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  icon: Icon(Icons.map, size: 18.sp, color: AppColor.primary),
                  label: Text('Select on Map'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
          _buildSectionTitle('Land Images'),
          SizedBox(height: 12.h),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
              childAspectRatio: 1,
            ),
            itemCount: allImages.length + 1,
            itemBuilder: (context, index) {
              if (index == allImages.length) {
                return GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: AppColor.primary,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          color: AppColor.primary,
                          size: 24.sp,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Add Image',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColor.primary,
                          ),
                        ),
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
                            ? NetworkImage(image['value'] as String) as ImageProvider
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
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 12.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

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

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Update nearby places
      _selectedNearbyPlaces.clear();
      for (var entry in _nearbyPlaceControllers.entries) {
        final placeId = entry.key;
        final controller = entry.value;
        if (controller.text.trim().isNotEmpty) {
          double distance = double.tryParse(controller.text.trim()) ?? 0;

          if (distance > 0) {
            _selectedNearbyPlaces.add({'place': placeId, 'distance': distance});
          }
        }
      }

      // Prepare form data
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
        'plot_count' : _plotCountController.text.trim(),
      };


      // Add nearby places if any
      if (_selectedNearbyPlaces.isNotEmpty) {
        formData['nearby'] = _selectedNearbyPlaces;
      }

      // Add work if not empty
      if (_workController.text.trim().isNotEmpty) {
        formData['work'] = _workController.text.trim();
      }

      // Add plot ID for update
      if (widget.plot != null) {
        if (widget.plot is MarketPlot) {
          formData['id'] = (widget.plot as MarketPlot).id.toString();
        } else if (widget.plot is Map) {
          formData['id'] = widget.plot['id'].toString();
        }
      }

      print('📤 Submitting form data: $formData');

      final result = await controller.submitMarketPlot(
        formData: formData,
        images: _selectedImages,
        plotImage: _plotImage,
        bluePrint: null,
        threeDImage : _upload3dImage,
        selectedFacilityIds : controller.selectedFacilityIds,
        isUpdate: widget.plot != null,
      );

      print('📥 Submission result: $result');

      if (result['status'] == 200) {
        SnackBarHelper.showSuccess(
          result['message'] ??
              'Plot ${widget.plot != null ? 'updated' : 'added'} successfully',
        );
        controller.selectedFacilityIds = [];
        controller.update();
        await controller.fetchMyMarketPlots();
        Get.back(result: true);
      } else {
        SnackBarHelper.showError(
          result['message'] ??
              'Failed to ${widget.plot != null ? 'update' : 'add'} plot',
        );
      }
    } catch (e) {
      print('❌ Submission error: $e');
      SnackBarHelper.showError('Error: ${e.toString()}');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

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
              Text('Loading form...', style: TextStyle(fontSize: 14.sp)),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
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
              Text(
                'Basic Information',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primary,
                ),
              ),
              SizedBox(height: 16.h),

              _buildTextField('Plot Name', _nameController, isRequired: true),

              // Property Type Dropdown - FIXED
              _buildDropdown<PropertyType>(
                label: 'Property Type',
                items: propertyTypes,
                value: _selectedPropertyType,
                displayText: (type) => type.categoryName ?? 'Unknown Type',
                onChanged: (type) {
                  setState(() {
                    _selectedPropertyType = type;
                  });
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
                      displayText: (state) =>
                          state.stateName,
                      onChanged: (state) async {
                        setState(() {
                          _selectedState = state;
                          _selectedCity = null;
                          cities.clear();
                        });
                        if (state != null) {
                          await controller.fetchCitiesForState(state.id);
                          setState(() {
                            cities = List.from(controller.cities);
                          });
                        }
                      },
                      isRequired: true,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildDropdown<City>(
                      label: 'City',
                      items: cities,
                      value: _selectedCity,
                      displayText: (city) => city.cityName,
                      onChanged: (city) {
                        setState(() {
                          _selectedCity = city;
                        });
                      },
                      isRequired: true,
                      isEnabled: _selectedState != null,
                    ),
                  ),
                ],
              ),

              _buildLocationSection(),

              Text(
                'Property Details',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primary,
                ),
              ),
              SizedBox(height: 16.h),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Area (sq ft)',
                      _areaController,
                      keyboardType: TextInputType.number,
                      isRequired: true,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildTextField(
                      'Price (₹)',
                      _priceController,
                      keyboardType: TextInputType.number,
                      isRequired: true,
                    ),
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
                      isRequired: true,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildTextField(
                      'ULPIN Number',
                      _uldNoController,
                      keyboardType: TextInputType.text,
                    ),
                  ),
                ],
              ),
              _buildTextField(
                'Plot Count',
                _plotCountController,
                keyboardType: TextInputType.number,
                isRequired: true,
              ),
              Text(
                'Description',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primary,
                ),
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                'Description',
                _descriptionController,
                maxLines: 4,
                isRequired: true,
              ),
              _selectedCommonFacilityWidget(),
              _buildAmenitiesSection(),
              _buildNearbyPlacesSection(),
              _buildImageSection(),
              Text(
                'Blue Print Image',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primary,
                ),
              ),
              SizedBox(height: 16.h),
              GestureDetector(
                onTap: _pickPlotImage,
                child: Container(
                  width: double.infinity,
                  height: 150.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: Colors.grey[100],
                    border: Border.all(
                      color: AppColor.primary,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _plotImage != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.file(_plotImage!, fit: BoxFit.cover),
                  )
                      : _existingPlotImageUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.network(
                      _existingPlotImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 40.sp,
                                color: Colors.grey,
                              ),
                              Text(
                                'Load failed',
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                      : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 40.sp,
                          color: AppColor.primary,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Tap to add Blue Print Image',
                          style: TextStyle(color: AppColor.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                '3D Image',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColor.primary,
                ),
              ),
              SizedBox(height: 16.h),
              GestureDetector(
                onTap: _pick3DImage,
                child: Container(
                  width: double.infinity,
                  height: 150.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    color: Colors.grey[100],
                    border: Border.all(
                      color: AppColor.primary,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _upload3dImage != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.file(_upload3dImage!, fit: BoxFit.cover),
                  )
                      : _existing3dImageUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.network(
                      _existing3dImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 40.sp,
                                color: Colors.grey,
                              ),
                              Text(
                                'Load failed',
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                      : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          size: 40.sp,
                          color: AppColor.primary,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Tap to add 3D Image',
                          style: TextStyle(color: AppColor.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: _isSubmitting
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.plot != null ? 'Update Plot' : 'Add Plot',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 20.h),
              Text(
                '* indicates required field',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
