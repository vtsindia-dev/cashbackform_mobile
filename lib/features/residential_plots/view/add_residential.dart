import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import '../../../common/api_constant.dart';
import '../../../common/colours.dart';
import '../controller/residential_add_controller.dart';
import '../controller/residential_controller.dart';
import '../model/residential_model.dart';

class AddEditPropertyScreen extends StatefulWidget {
  final int? propertyId;

  const AddEditPropertyScreen({Key? key, this.propertyId}) : super(key: key);

  @override
  State<AddEditPropertyScreen> createState() => _AddEditPropertyScreenState();
}

class _AddEditPropertyScreenState extends State<AddEditPropertyScreen>
    with SingleTickerProviderStateMixin {
  final ResidentialPropertyFormController _controller =
  Get.put(ResidentialPropertyFormController());
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  // Form field controllers
  final _propertyNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Initialize controllers with reactive values
    _controller.propertyName.listen((value) {
      if (_propertyNameController.text != value) {
        _propertyNameController.text = value;
      }
    });

    _controller.price.listen((value) {
      if (_priceController.text != value) {
        _priceController.text = value;
      }
    });

    _controller.areaSqft.listen((value) {
      if (_areaController.text != value) {
        _areaController.text = value;
      }
    });

    _controller.aboutProperty.listen((value) {
      if (_descriptionController.text != value) {
        _descriptionController.text = value;
      }
    });

    _controller.location.listen((value) {
      if (_locationController.text != value) {
        _locationController.text = value;
      }
    });

    // Listen to tab changes to update step
    _tabController.addListener(() {
      _controller.currentStep.value = _tabController.index;
    });

    // Load property for editing if ID is provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.propertyId != null) {
        _controller.loadPropertyForEditing(widget.propertyId!);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _propertyNameController.dispose();
    _priceController.dispose();
    _areaController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColor.primary),
          );
        }

        return Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildBasicInfoTab(),
                  _buildFacilitiesTab(),
                  _buildMediaTab(),
                  _buildLocationTab(),
                ],
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(70.h),
      child: AppBar(
        backgroundColor: AppColor.backgroundLight,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColor.textMain),
          onPressed: () => Get.back(),
        ),
        title: Text(
          widget.propertyId != null ? 'Edit Property' : 'Add New Property',
          style: TextStyle(
            color: AppColor.textMain,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Iconsax.info_circle, color: AppColor.primary),
            onPressed: _showInfoDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColor.primary,
          borderRadius: BorderRadius.circular(10.r),
        ),
        labelColor: AppColor.white,
        unselectedLabelColor: AppColor.textSecondary,
        labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12.sp),
        tabs: const [
          Tab(text: 'Basic Info'),
          Tab(text: 'Facilities'),
          Tab(text: 'Media'),
          Tab(text: 'Location'),
        ],
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property Name
            _buildFormField(
              label: 'Property Name *',
              controller: _propertyNameController,
              hintText: 'Enter property name',
              onChanged: (value) => _controller.propertyName.value = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Property name is required';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // Category Selection
            _buildCategorySection(),
            SizedBox(height: 16.h),

            // Price and Area Row
            Row(
              children: [
                Expanded(
                  child: _buildFormField(
                    label: 'Price *',
                    controller: _priceController,
                    hintText: 'Enter price',
                    keyboardType: TextInputType.number,
                    prefix: Text('₹ ', style: TextStyle(color: AppColor.primary)),
                    onChanged: (value) => _controller.price.value = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Price is required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Enter valid price';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildFormField(
                    label: 'Area (Sq. Ft.) *',
                    controller: _areaController,
                    hintText: 'Enter area',
                    keyboardType: TextInputType.number,
                    onChanged: (value) => _controller.areaSqft.value = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Area is required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Enter valid area';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // State and City Selection
            _buildLocationSelection(),
            SizedBox(height: 16.h),

            // Description
            _buildFormField(
              label: 'Description',
              controller: _descriptionController,
              hintText: 'Describe your property...',
              maxLines: 4,
              onChanged: (value) => _controller.aboutProperty.value = value,
            ),

            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category *',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.textMain,
          ),
        ),
        SizedBox(height: 8.h),

        // Main Category
        Obx(() => Container(
          decoration: BoxDecoration(
            color: AppColor.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColor.lightGrey),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _controller.selectedCategoryId.value > 0
                  ? _controller.selectedCategoryId.value
                  : null,
              isExpanded: true,
              hint: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text(
                  _controller.propertyCategories.isEmpty
                      ? 'Loading categories...'
                      : 'Select Category',
                  style: TextStyle(color: AppColor.grey),
                ),
              ),
              items: _controller.propertyCategories.map((category) {
                return DropdownMenuItem<int>(
                  value: category.id,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Text(category.categoryName),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _controller.onCategoryChanged(value);
                }
              },
            ),
          ),
        )),

        // Sub Category if available
        SizedBox(height: 12.h),
        Obx(() {
          if (_controller.selectedCategoryId.value == 0) {
            return const SizedBox();
          }

          final category = _controller.propertyCategories.firstWhereOrNull(
                (c) => c.id == _controller.selectedCategoryId.value,
          );

          if (category?.subCategories != null && category!.subCategories!.isNotEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sub Category',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textMain,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  decoration: BoxDecoration(
                    color: AppColor.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColor.lightGrey),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _controller.selectedSubCategoryId.value > 0
                          ? _controller.selectedSubCategoryId.value
                          : null,
                      isExpanded: true,
                      hint: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        child: Text('Select Sub Category', style: TextStyle(color: AppColor.grey)),
                      ),
                      items: category.subCategories!.map((subCategory) {
                        return DropdownMenuItem<int>(
                          value: subCategory.id,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Text(subCategory.name),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _controller.onSubCategoryChanged(value);
                        }
                      },
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        }),
      ],
    );
  }

  Widget _buildLocationSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'State',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textMain,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Obx(() => Container(
                    decoration: BoxDecoration(
                      color: AppColor.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColor.lightGrey),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _controller.selectedStateId.value > 0
                            ? _controller.selectedStateId.value
                            : null,
                        isExpanded: true,
                        hint: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Text(
                            _controller.statesList.isEmpty
                                ? 'Loading states...'
                                : 'Select State',
                            style: TextStyle(color: AppColor.grey),
                          ),
                        ),
                        items: _controller.statesList.map((state) {
                          return DropdownMenuItem<int>(
                            value: state.id,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Text(state.stateName),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _controller.onStateChanged(value);
                          }
                        },
                      ),
                    ),
                  )),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'City',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textMain,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Obx(() {
                    if (_controller.selectedStateId.value == 0) {
                      return Container(
                        decoration: BoxDecoration(
                          color: AppColor.backgroundLight,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppColor.lightGrey),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                        child: Text(
                          'Select state first',
                          style: TextStyle(color: AppColor.grey),
                        ),
                      );
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: AppColor.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: AppColor.lightGrey),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _controller.selectedCityId.value > 0
                              ? _controller.selectedCityId.value
                              : null,
                          isExpanded: true,
                          hint: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Text(
                              _controller.citiesList.isEmpty
                                  ? 'No cities found'
                                  : 'Select City',
                              style: TextStyle(color: AppColor.grey),
                            ),
                          ),
                          items: _controller.citiesList.map((city) {
                            return DropdownMenuItem<int>(
                              value: city.id,
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12.w),
                                child: Text(city.name),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              _controller.onCityChanged(value);
                            }
                          },
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFacilitiesTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Obx(() {
        if (_controller.selectedCategoryId.value <= 0) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.category, size: 60.w, color: AppColor.grey),
                SizedBox(height: 16.h),
                Text(
                  'Please select a category first',
                  style: TextStyle(color: AppColor.grey, fontSize: 16.sp),
                ),
              ],
            ),
          );
        }

        if (_controller.facilities.isEmpty && !_controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 60.w, color: AppColor.grey),
                SizedBox(height: 16.h),
                Text(
                  'No facilities found for this category',
                  style: TextStyle(color: AppColor.grey, fontSize: 16.sp),
                ),
              ],
            ),
          );
        }

        if (_controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColor.primary),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Property Details',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColor.textMain,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Fill in the property details as required',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColor.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),

            // Dynamic Facilities from API
            ..._controller.facilities.map((facility) {
              // Skip if facility type is 'file' (these are handled in documents)
              if (facility.type == 'file' || facility.type == 'document') {
                return const SizedBox();
              }
              return _buildDynamicFacilityField(facility);
            }).toList(),

            // Amenities Section
            SizedBox(height: 32.h),
            _buildAmenitiesSection(),

            // Documents Section (File upload facilities)
            SizedBox(height: 32.h),
            if (_controller.documents.isNotEmpty) ...[
              _buildDocumentsSection(),
            ],

            // Nearby Places Section
            SizedBox(height: 32.h),
            _buildNearbyPlacesSection(),

            SizedBox(height: 100.h),
          ],
        );
      }),
    );
  }

  Widget _buildNearbyPlacesSection() {
    return Obx(() => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nearby Places',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColor.textMain,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Select nearby places and enter distance in meters',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColor.textSecondary,
          ),
        ),
        SizedBox(height: 16.h),

        if (_controller.nearbyPlacesList.isEmpty && !_controller.isLoading.value)
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColor.backgroundLight,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColor.lightGrey),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.location_on_outlined, size: 40.w, color: AppColor.grey),
                  SizedBox(height: 8.h),
                  Text(
                    'No nearby places found',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColor.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (_controller.isLoading.value)
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: CircularProgressIndicator(color: AppColor.primary),
            ),
          )
        else
          ..._controller.nearbyPlacesList.map((place) {
            final isSelected = _controller.isNearbyPlaceSelected(place.id);
            final distanceController = _controller.nearbyDistanceControllers[place.id] ?? TextEditingController();
            final savedDistance = _controller.getSelectedPlaceDistance(place.id);

            // Set initial value if exists
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (savedDistance != null && distanceController.text.isEmpty) {
                distanceController.text = savedDistance.toString();
              }
            });

            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isSelected ? AppColor.primary : AppColor.lightGrey,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  // Place Image
                  Container(
                    width: 50.w,
                    height: 50.w,
                    margin: EdgeInsets.only(right: 12.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.r),
                      color: AppColor.backgroundLight,
                      image: place.image.isNotEmpty ? DecorationImage(
                        image: NetworkImage('${ApiUrl.baseUrl}/${place.image}'),
                        fit: BoxFit.cover,
                      ) : null,
                    ),
                    child: place.image.isEmpty
                        ? Icon(Icons.location_on, color: AppColor.primary, size: 24.w)
                        : null,
                  ),

                  // Place Info and Distance Input
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColor.textMain,
                          ),
                        ),
                        SizedBox(height: 8.h),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: distanceController,
                                decoration: InputDecoration(
                                  hintText: 'Distance in meters',
                                  filled: true,
                                  fillColor: AppColor.backgroundLight,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6.r),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                                  suffixText: 'm',
                                  suffixStyle: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColor.textSecondary,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  // Update immediately as user types
                                  if (value.isNotEmpty) {
                                    final distance = int.tryParse(value);
                                    if (distance != null && distance > 0) {
                                      _controller.toggleNearbyPlace(place.id, value);
                                    }
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 12.w),

                            // Selection Toggle Button
                            GestureDetector(
                              onTap: () {
                                final distance = distanceController.text;
                                if (isSelected) {
                                  _controller.removeNearbyPlace(place.id);
                                } else {
                                  if (distance.isNotEmpty) {
                                    final distValue = int.tryParse(distance);
                                    if (distValue != null && distValue > 0) {
                                      _controller.toggleNearbyPlace(place.id, distance);
                                    } else {
                                      Get.snackbar(
                                        'Invalid Distance',
                                        'Please enter a valid distance in meters',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: AppColor.red,
                                        colorText: AppColor.white,
                                      );
                                    }
                                  } else {
                                    Get.snackbar(
                                      'Distance Required',
                                      'Please enter distance for ${place.title}',
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                  }
                                }
                              },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColor.primary : AppColor.backgroundLight,
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(
                                    color: isSelected ? AppColor.primary : AppColor.lightGrey,
                                  ),
                                  boxShadow: isSelected ? [
                                    BoxShadow(
                                      color: AppColor.primary.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ] : [],
                                ),
                                child: Center(
                                  child: Icon(
                                    isSelected ? Icons.check : Icons.add,
                                    size: 20.w,
                                    color: isSelected ? AppColor.white : AppColor.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (isSelected)
                          Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Text(
                              'Selected • ${savedDistance ?? 0}m',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColor.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),

        SizedBox(height: 8.h),

        // Selected places summary
        if (_controller.selectedNearbyPlaces.isNotEmpty)
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColor.primary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 16.w, color: AppColor.primary),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Selected ${_controller.selectedNearbyPlaces.length} nearby place${_controller.selectedNearbyPlaces.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColor.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (_controller.selectedNearbyPlaces.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      // Show selected places details
                      _showSelectedNearbyPlacesDialog();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'View',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColor.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    ));
  }
  void _showSelectedNearbyPlacesDialog() {
    final selectedPlaces = _controller.selectedNearbyPlaces;
    final nearbyPlacesList = _controller.nearbyPlacesList;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Selected Nearby Places',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: selectedPlaces.length,
            itemBuilder: (context, index) {
              final placeData = selectedPlaces[index];
              final placeId = placeData['place_id'] as int? ?? 0;
              final distance = placeData['distance'] as int? ?? 0;

              // Find place details
              final place = nearbyPlacesList.firstWhereOrNull((p) => p.id == placeId);

              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColor.backgroundLight,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place?.title ?? 'Place ID: $placeId',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColor.textMain,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Distance: ${distance}m',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColor.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 18.w, color: AppColor.red),
                      onPressed: () {
                        _controller.removeNearbyPlace(placeId);
                        Navigator.pop(context);
                        if (selectedPlaces.length == 1) {
                          // If this was the last one, close dialog
                          Navigator.pop(context);
                        } else {
                          // Otherwise, refresh dialog
                          _showSelectedNearbyPlacesDialog();
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: AppColor.primary),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildDynamicFacilityField(Facility facility) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              facility.name,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: facility.isRequired == 1 ? AppColor.textMain : AppColor.textSecondary,
              ),
            ),
            if (facility.isRequired == 1) ...[
              SizedBox(width: 4.w),
              Text(
                '*',
                style: TextStyle(color: AppColor.red, fontSize: 14.sp),
              ),
            ],
          ],
        ),
        SizedBox(height: 8.h),

        // Render different input types based on facility.type
        if (facility.type == 'dropdown' && facility.dropdownValues.isNotEmpty)
          _buildDropdownFacility(facility)
        else if (facility.type == 'radio' && facility.dropdownValues.isNotEmpty)
          _buildRadioFacility(facility)
        else if (facility.type == 'text' || facility.type == 'number')
            _buildTextFacility(facility)
          else
            _buildTextFacility(facility),

        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildDropdownFacility(Facility facility) {
    final options = facility.dropdownValues;
    final currentValue = _controller.facilityValues[facility.id]?.toString() ?? '';

    return Container(
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColor.lightGrey),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentValue.isEmpty ? null : currentValue,
          isExpanded: true,
          hint: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text('Select ${facility.name}', style: TextStyle(color: AppColor.grey)),
          ),
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text(option),
              ),
            );
          }).toList(),
          onChanged: (value) {
            _controller.updateFacilityValue(facility.id, value);
          },
        ),
      ),
    );
  }

  Widget _buildRadioFacility(Facility facility) {
    final options = facility.dropdownValues;
    final currentValue = _controller.facilityValues[facility.id]?.toString() ?? '';

    return Wrap(
      spacing: 16.w,
      runSpacing: 12.h,
      children: options.map((option) {
        final isSelected = currentValue == option;
        return GestureDetector(
          onTap: () => _controller.updateFacilityValue(facility.id, option),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColor.primary : AppColor.grey,
                    width: 2.w,
                  ),
                  color: isSelected ? AppColor.primary : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(Icons.check, size: 14.w, color: AppColor.white)
                    : null,
              ),
              SizedBox(width: 8.w),
              Text(
                option,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isSelected ? AppColor.primary : AppColor.textMain,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextFacility(Facility facility) {
    // Get or create controller
    if (!_controller.facilityControllers.containsKey(facility.id)) {
      _controller.facilityControllers[facility.id] = TextEditingController();
    }

    final controller = _controller.facilityControllers[facility.id]!;

    // Set initial value if exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentValue = _controller.facilityValues[facility.id];
      if (currentValue != null && controller.text != currentValue.toString()) {
        controller.text = currentValue.toString();
      }
    });

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Enter ${facility.name}',
        filled: true,
        fillColor: AppColor.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColor.lightGrey),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      ),
      keyboardType: facility.type == 'number' || _isNumericField(facility.name)
          ? TextInputType.number
          : TextInputType.text,
      onChanged: (value) {
        _controller.updateFacilityValue(facility.id, value);
      },
    );
  }

  bool _isNumericField(String name) {
    final numericFields = ['age', 'floor', 'length', 'breadth', 'width', 'number', 'count'];
    return numericFields.any((field) => name.toLowerCase().contains(field));
  }

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amenities',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColor.textMain,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Select available amenities',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColor.textSecondary,
          ),
        ),
        SizedBox(height: 16.h),

        Obx(() => Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: _controller.availableAmenities.map((amenity) {
            final isSelected = _controller.selectedAmenityIds.contains(amenity.id);
            return ChoiceChip(
              label: Text(amenity.title),
              selected: isSelected,
              selectedColor: AppColor.primary.withOpacity(0.2),
              backgroundColor: AppColor.backgroundLight,
              labelStyle: TextStyle(
                color: isSelected ? AppColor.primary : AppColor.textMain,
                fontSize: 12.sp,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
                side: BorderSide(
                  color: isSelected ? AppColor.primary : AppColor.lightGrey,
                ),
              ),
              onSelected: (selected) {
                _controller.toggleAmenitySelection(amenity.id);
              },
            );
          }).toList(),
        )),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documents',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColor.textMain,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Upload required documents',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColor.textSecondary,
          ),
        ),
        SizedBox(height: 16.h),

        ..._controller.documents.map((document) {
          return _buildDocumentUploadCard(document);
        }).toList(),
      ],
    );
  }

  Widget _buildDocumentUploadCard(Document document) {
    return Obx(() {
      final hasFile = _controller.documentFiles.containsKey(document.id);
      final hasUrl = _controller.documentUrls.containsKey(document.id);
      final file = hasFile ? _controller.documentFiles[document.id] : null;
      final url = hasUrl ? _controller.documentUrls[document.id] : null;

      return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColor.lightGrey),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        document.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.textMain,
                        ),
                      ),
                      if (document.isRequired == 1) ...[
                        SizedBox(width: 4.w),
                        Text(
                          '*',
                          style: TextStyle(color: AppColor.red, fontSize: 14.sp),
                        ),
                      ],
                    ],
                  ),
                  if (document.description != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      document.description!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColor.textSecondary,
                      ),
                    ),
                  ],
                  if (document.allowedFormats != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      'Formats: ${document.allowedFormats?.join(', ')}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColor.grey,
                      ),
                    ),
                  ],
                  if (hasFile && file != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      'File: ${file.path.split('/').last}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColor.primary,
                      ),
                    ),
                  ],
                  if (hasUrl && url != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      'Uploaded: ✓',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColor.success,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 12.w),
            if (hasFile || hasUrl)
              Row(
                children: [
                  IconButton(
                    icon: Icon(Iconsax.eye, size: 20.w),
                    onPressed: () {
                      // Show document preview
                      if (hasFile && file != null) {
                        _showDocumentPreview(file);
                      } else if (hasUrl && url != null) {
                        _showUrlPreview(url);
                      }
                    },
                  ),
                  IconButton(
                    icon: Icon(Iconsax.trash, size: 20.w, color: AppColor.red),
                    onPressed: () => _controller.removeDocumentFile(document.id),
                  ),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: () => _controller.pickDocumentFile(document.id),
                icon: Icon(Iconsax.document_upload, size: 16.w),
                label: Text('Upload'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: AppColor.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                ),
              ),
          ],
        ),
      );
    });
  }

  void _showDocumentPreview(File file) {
    // Implement document preview logic
    Get.snackbar(
      'Document Preview',
      'File: ${file.path.split('/').last}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showUrlPreview(String url) {
    // Implement URL preview logic
    Get.defaultDialog(
      title: 'Document',
      content: Column(
        children: [
          Text('Document is uploaded'),
          SizedBox(height: 10.h),
          ElevatedButton(
            onPressed: () {
              // Open URL
            },
            child: Text('View Document'),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gallery Images',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.textMain,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add property images (Max 10)',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColor.textSecondary,
            ),
          ),
          SizedBox(height: 24.h),

          // Existing Images for Edit Mode
          Obx(() {
            if (_controller.galleryImageUrls.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Existing Images',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textMain,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 100.h,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _controller.galleryImageUrls.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(right: 8.w),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.r),
                                child: Image.network(
                                  _controller.galleryImageUrls[index],
                                  width: 100.w,
                                  height: 100.h,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 100.w,
                                      height: 100.h,
                                      color: AppColor.backgroundLight,
                                      child: Icon(Icons.broken_image, color: AppColor.grey),
                                    );
                                  },
                                ),
                              ),
                              Positioned(
                                top: 4.w,
                                right: 4.w,
                                child: GestureDetector(
                                  onTap: () {
                                    _controller.galleryImageUrls.removeAt(index);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColor.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    padding: EdgeInsets.all(2.w),
                                    child: Icon(
                                      Icons.close,
                                      size: 14.w,
                                      color: AppColor.red,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              );
            }
            return const SizedBox();
          }),

          // Upload New Images
          Obx(() => GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
              childAspectRatio: 1,
            ),
            itemCount: _controller.galleryImages.length + 1,
            itemBuilder: (context, index) {
              if (index == _controller.galleryImages.length) {
                return GestureDetector(
                  onTap: () {
                    if (_controller.galleryImages.length < 10) {
                      _controller.pickGalleryImages();
                    } else {
                      Get.snackbar(
                        'Limit Reached',
                        'Maximum 10 images allowed',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColor.backgroundLight,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColor.lightGrey, style: BorderStyle.solid),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.gallery_add,
                            color: _controller.galleryImages.length < 10
                                ? AppColor.primary
                                : AppColor.grey,
                            size: 24.w,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            'Add Image',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: _controller.galleryImages.length < 10
                                  ? AppColor.primary
                                  : AppColor.grey,
                            ),
                          ),
                          Text(
                            '${_controller.galleryImages.length}/10',
                            style: TextStyle(
                              fontSize: 8.sp,
                              color: AppColor.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.file(
                      _controller.galleryImages[index],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 4.w,
                    right: 4.w,
                    child: GestureDetector(
                      onTap: () => _controller.removeGalleryImage(index),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        padding: EdgeInsets.all(2.w),
                        child: Icon(
                          Icons.close,
                          size: 14.w,
                          color: AppColor.red,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          )),

          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  Widget _buildLocationTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Property Location',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColor.textMain,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Set the exact location of your property',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColor.textSecondary,
            ),
          ),
          SizedBox(height: 24.h),

          // Location Search
          _buildFormField(
            label: 'Location *',
            controller: _locationController,
            hintText: 'Search or enter location',
            onChanged: (value) {
              _controller.location.value = value;
              if (value.length > 3) {
                _controller.searchLocation(value);
              }
            },
            suffixIcon: Obx(() {
              if (_controller.isSearchingLocation.value) {
                return SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: CircularProgressIndicator(strokeWidth: 2.w),
                );
              }
              return Icon(Iconsax.search_normal, size: 20.w);
            }),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Location is required';
              }
              return null;
            },
          ),

          // Location Search Results
          Obx(() {
            if (_controller.locationSearchResults.isNotEmpty) {
              return Container(
                margin: EdgeInsets.only(top: 8.h),
                decoration: BoxDecoration(
                  color: AppColor.white,
                  borderRadius: BorderRadius.circular(8.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: _controller.locationSearchResults.map((place) {
                    return ListTile(
                      leading: Icon(Iconsax.location, size: 20.w),
                      title: Text(place.name),
                      subtitle: place.address.isNotEmpty ? Text(place.address) : null,
                      onTap: () {
                        _controller.selectSearchLocation(place);
                        _locationController.text = place.address.isNotEmpty
                            ? place.address
                            : place.name;
                      },
                    );
                  }).toList(),
                ),
              );
            }
            return const SizedBox();
          }),

          SizedBox(height: 20.h),

          // Map View Toggle
          Row(
            children: [
              Text(
                'Show on Map',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textMain,
                ),
              ),
              Spacer(),
              Obx(() => Switch(
                value: _controller.showMap.value,
                activeColor: AppColor.primary,
                onChanged: (value) {
                  _controller.showMap.value = value;
                  if (value) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _controller.mapController.move(
                        _controller.selectedLocation.value,
                        15,
                      );
                    });
                  }
                },
              )),
            ],
          ),

          // Map View
          SizedBox(height: 20.h),
          Obx(() {
            if (_controller.showMap.value) {
              return Container(
                height: 300.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColor.lightGrey),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: FlutterMap(
                    mapController: _controller.mapController,
                    options: MapOptions(
                      initialCenter: _controller.selectedLocation.value,
                      initialZoom: 15,
                      onTap: (tapPosition, point) {
                        _controller.onMapTap(point);
                        _locationController.text = _controller.location.value;
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
                            point: _controller.selectedLocation.value,
                            child: Icon(
                              Icons.location_on,
                              color: AppColor.red,
                              size: 40.w,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox();
          }),

          // Coordinates Display
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColor.backgroundLight,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Latitude',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColor.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Obx(() => Text(
                        _controller.latitude.value.toStringAsFixed(6),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.textMain,
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColor.backgroundLight,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Longitude',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColor.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Obx(() => Text(
                        _controller.longitude.value.toStringAsFixed(6),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.textMain,
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Current Address
          SizedBox(height: 20.h),
          Obx(() {
            if (_controller.location.value.isNotEmpty) {
              return Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColor.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.location, color: AppColor.primary, size: 20.w),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selected Location',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColor.primary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            _controller.location.value,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColor.textMain,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          }),

          // Use Current Location Button
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            onPressed: () async {
              Get.snackbar(
                'Getting Location',
                'Fetching your current location...',
                snackPosition: SnackPosition.BOTTOM,
              );
              await _controller.getCurrentLocation();
              _locationController.text = _controller.location.value;
            },
            icon: Icon(Iconsax.gps, size: 16.w),
            label: Text('Use Current Location'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: AppColor.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              minimumSize: Size(double.infinity, 0),
            ),
          ),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        border: Border(top: BorderSide(color: AppColor.lightGrey)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Obx(() {
        bool isLastTab = _tabController.index == 3;
        bool isLoading = _controller.isSubmitting.value;

        return Row(
          children: [
            // Previous Button
            if (_tabController.index > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () {
                    _controller.previousStep();
                    _tabController.animateTo(_tabController.index - 1);
                  },
                  icon: Icon(Iconsax.arrow_left, size: 18.w),
                  label: Text('Previous'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
            if (_tabController.index > 0) SizedBox(width: 12.w),

            // Next/Submit Button
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: isLoading
                    ? null
                    : () {
                  if (isLastTab) {
                    // Validate all steps before submit
                    bool allValid = true;
                    for (int i = 0; i <= 3; i++) {
                      _controller.currentStep.value = i;
                      if (!_controller.isStepValid()) {
                        allValid = false;
                        // Show error for the first invalid step
                        final errors = _controller.validateCurrentStep();
                        if (errors.isNotEmpty) {
                          Get.snackbar(
                            'Validation Error',
                            errors.values.first,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                        // Navigate to the invalid step
                        _tabController.animateTo(i);
                        _controller.currentStep.value = i;
                        break;
                      }
                    }

                    if (allValid) {
                      _controller.nextStep();
                    }
                  } else {
                    // Validate current step
                    _controller.currentStep.value = _tabController.index;
                    if (_controller.isStepValid()) {
                      _controller.nextStep();
                      _tabController.animateTo(_tabController.index + 1);
                    } else {
                      final errors = _controller.validateCurrentStep();
                      if (errors.isNotEmpty) {
                        Get.snackbar(
                          'Validation Error',
                          errors.values.first,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    }
                  }
                },
                icon: isLoading
                    ? SizedBox(
                  width: 16.w,
                  height: 16.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    color: AppColor.white,
                  ),
                )
                    : Icon(
                  isLastTab ? Iconsax.tick_circle : Iconsax.arrow_right,
                  size: 18.w,
                ),
                label: isLoading
                    ? Text('Processing...')
                    : Text(isLastTab ? 'Submit Property' : 'Continue'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  foregroundColor: AppColor.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    Widget? prefix,
    Widget? suffixIcon,
    FormFieldValidator<String>? validator,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.textMain,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: AppColor.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColor.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColor.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColor.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColor.red, width: 1.5),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            prefixIcon: prefix != null
                ? Padding(
              padding: EdgeInsets.only(left: 12.w, right: 8.w),
              child: prefix,
            )
                : null,
            prefixIconConstraints: prefix != null
                ? BoxConstraints(minWidth: 0, minHeight: 0)
                : null,
            suffixIcon: suffixIcon,
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          onChanged: onChanged,
        ),
      ],
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Property Submission Guide',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoItem('1. Basic Info', 'Fill all required fields marked with *'),
              _buildInfoItem('2. Facilities', 'Provide accurate property details'),
              _buildInfoItem('3. Media', 'Upload clear property images'),
              _buildInfoItem('4. Location', 'Pin exact location on map'),
              SizedBox(height: 16.h),
              Text(
                'Note: You can save as draft and complete later.',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColor.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: TextStyle(color: AppColor.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 10.r,
            backgroundColor: AppColor.primary,
            child: Text(
              title.split('.')[0],
              style: TextStyle(color: AppColor.white, fontSize: 10.sp),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textMain,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColor.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}