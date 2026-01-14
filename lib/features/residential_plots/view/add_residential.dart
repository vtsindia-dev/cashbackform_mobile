import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../common/api_constant.dart';
import '../../../common/colours.dart';
import '../controller/residential_add_controller.dart';
import '../model/residential_model.dart';

class AddEditPropertyScreen extends StatefulWidget {
  final int? propertyId;
  final bool isEditMode;

  const AddEditPropertyScreen({
    Key? key,
    this.propertyId,
    this.isEditMode = false,
  }) : super(key: key);

  @override
  State<AddEditPropertyScreen> createState() => _AddEditPropertyScreenState();
}

class _AddEditPropertyScreenState extends State<AddEditPropertyScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final ResidentialPropertyFormController _controller =
  Get.find<ResidentialPropertyFormController>();
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  // Form field controllers
  final _propertyNameController = TextEditingController();
  final _priceController = TextEditingController();
  final _pricePerSqftController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  // Animation controllers
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  // Dispose flags
  bool _isDisposed = false;
  bool _initialDataLoaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    _isDisposed = false;
    _initialDataLoaded = false;

    // Initialize animations
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _tabController = TabController(length: 4, vsync: this);

    _tabController.addListener(() {
      if (!_isDisposed) {
        _controller.currentStep.value = _tabController.index;
        _fadeAnimationController.forward(from: 0.0);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        _fadeAnimationController.forward();
        _initializeData();
      }
    });
  }

  void _initializeData() async {
    if (_initialDataLoaded) return;

    // Initialize data binding
    _initializeDataBinding();

    if (widget.propertyId != null) {
      print('🔄 Loading property for editing: ${widget.propertyId}');
      // Clear previous data before loading new property
      _controller.resetFormForEdit();
      await _controller.loadPropertyForEditing(widget.propertyId!);
      if (!_isDisposed) {
        Future.delayed(const Duration(milliseconds: 300), () {
          _prefetchImages();
        });
      }
    } else {
      // For add mode, reset form and clear fields
      _controller.resetForm();
      _clearFormFields();

      // Load initial data in parallel
      await _loadInitialData();
    }

    _initialDataLoaded = true;
  }

  Future<void> _loadInitialData() async {
    try {
      // Load categories if not loaded
      if (_controller.propertyCategories.isEmpty) {
        await _controller.fetchPropertyCategories();
      }

      // Load states if not loaded
      if (_controller.statesList.isEmpty) {
        await _controller.fetchStates();
      }

      // Load amenities if not loaded
      if (_controller.availableAmenities.isEmpty) {
        await _controller.fetchAvailableAmenities();
      }

      // Load nearby places if not loaded
      if (_controller.nearbyPlacesList.isEmpty) {
        await _controller.fetchNearbyPlaces();
      }

      // Get current location
      await _controller.getCurrentLocation();

    } catch (e) {
      print('❌ Error loading initial data: $e');
    }
  }

  void _initializeDataBinding() {
    // Use listeners instead of ever to avoid disposed controller errors
    void safeUpdateController(TextEditingController controller, String value) {
      if (!_isDisposed && controller.text != value) {
        controller.text = value;
      }
    }

    // Bind controllers to reactive values with safe checks
    _controller.propertyName.listen((value) {
      safeUpdateController(_propertyNameController, value);
    });

    _controller.price.listen((value) {
      safeUpdateController(_priceController, value);
    });

    _controller.pricePerSqft.listen((value) {
      safeUpdateController(_pricePerSqftController, value);
    });

    _controller.areaSqft.listen((value) {
      safeUpdateController(_areaController, value);
    });

    _controller.aboutProperty.listen((value) {
      safeUpdateController(_descriptionController, value);
    });

    _controller.location.listen((value) {
      safeUpdateController(_locationController, value);
    });

    // Set up text controllers to update reactive values
    _propertyNameController.addListener(() {
      if (!_isDisposed && _controller.propertyName.value != _propertyNameController.text) {
        _controller.propertyName.value = _propertyNameController.text;
      }
    });

    _priceController.addListener(() {
      if (!_isDisposed && _controller.price.value != _priceController.text) {
        _controller.price.value = _priceController.text;
      }
    });

    _pricePerSqftController.addListener(() {
      if (!_isDisposed && _controller.pricePerSqft.value != _pricePerSqftController.text) {
        _controller.pricePerSqft.value = _pricePerSqftController.text;
      }
    });

    _areaController.addListener(() {
      if (!_isDisposed && _controller.areaSqft.value != _areaController.text) {
        _controller.areaSqft.value = _areaController.text;
      }
    });

    _descriptionController.addListener(() {
      if (!_isDisposed && _controller.aboutProperty.value != _descriptionController.text) {
        _controller.aboutProperty.value = _descriptionController.text;
      }
    });

    _locationController.addListener(() {
      if (!_isDisposed && _controller.location.value != _locationController.text) {
        _controller.location.value = _locationController.text;
      }
    });
  }

  void _prefetchImages() {
    if (_controller.galleryImageUrls.isNotEmpty) {
      for (var imageUrl in _controller.galleryImageUrls) {
        final fullUrl = imageUrl.startsWith('http')
            ? imageUrl
            : '${ApiUrl.baseUrl}/${imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl}';

        precacheImage(
          CachedNetworkImageProvider(fullUrl),
          context,
          onError: (exception, stackTrace) {
            print('Failed to pre-cache image: $exception');
          },
        );
      }
    }
  }

  @override
  void didUpdateWidget(covariant AddEditPropertyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle when switching between edit and add modes
    if (oldWidget.propertyId != widget.propertyId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed) {
          _initialDataLoaded = false;
          if (widget.propertyId == null) {
            print('🔄 SWITCHED TO ADD MODE - Resetting form');
            _controller.resetForm();
            _clearFormFields();
            _loadInitialData();
          } else {
            print('🔄 SWITCHED TO EDIT MODE - Loading: ${widget.propertyId}');
            _controller.resetFormForEdit();
            _controller.loadPropertyForEditing(widget.propertyId!);
          }
        }
      });
    }
  }

  void _clearFormFields() {
    if (!_isDisposed) {
      _propertyNameController.clear();
      _priceController.clear();
      _pricePerSqftController.clear();
      _areaController.clear();
      _descriptionController.clear();
      _locationController.clear();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;

    _tabController.dispose();
    _scrollController.dispose();
    _fadeAnimationController.dispose();

    // Clear controllers
    _propertyNameController.dispose();
    _priceController.dispose();
    _pricePerSqftController.dispose();
    _areaController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();

    imageCache.clear();
    imageCache.clearLiveImages();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final hasChanges = await _checkForUnsavedChanges();
        if (hasChanges && mounted) {
          await _showExitConfirmationDialog();
        } else {
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: AppColor.backgroundLight,
        appBar: _buildAppBar(),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Obx(() {
            if (_controller.isLoading.value && widget.propertyId != null) {
              return _buildLoadingScreen();
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
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Future<bool> _checkForUnsavedChanges() async {
    if (widget.propertyId != null) {
      return _propertyNameController.text.isNotEmpty ||
          _priceController.text.isNotEmpty ||
          _pricePerSqftController.text.isNotEmpty ||
          _areaController.text.isNotEmpty ||
          _descriptionController.text.isNotEmpty ||
          _locationController.text.isNotEmpty ||
          _controller.galleryImages.isNotEmpty ||
          _controller.selectedAmenityIds.isNotEmpty ||
          _controller.selectedNearbyPlaces.isNotEmpty ||
          _controller.documentFiles.isNotEmpty;
    }

    return _propertyNameController.text.isNotEmpty ||
        _priceController.text.isNotEmpty ||
        _pricePerSqftController.text.isNotEmpty ||
        _areaController.text.isNotEmpty ||
        _controller.selectedAmenityIds.isNotEmpty ||
        _controller.selectedNearbyPlaces.isNotEmpty ||
        _controller.documentFiles.isNotEmpty;
  }

  Future<void> _showExitConfirmationDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(
          'Unsaved Changes',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.textMain,
          ),
        ),
        content: Text(
          'You have unsaved changes. Are you sure you want to leave?',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColor.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppColor.textSecondary,
                fontSize: 14.sp,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'Leave',
              style: TextStyle(
                color: AppColor.red,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (result == true) {
      Get.back();
    }
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CircularProgressIndicator(
                color: AppColor.primary,
                strokeWidth: 3.w,
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            widget.propertyId != null ? 'Loading Property...' : 'Loading Form...',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColor.textMain,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
          icon: Icon(
            Icons.arrow_back,
            color: AppColor.textMain,
          ),
          onPressed: () async {
            final hasChanges = await _checkForUnsavedChanges();
            if (hasChanges && mounted) {
              await _showExitConfirmationDialog();
            } else {
              Get.back();
            }
          },
        ),
        title: Text(
          widget.propertyId != null ? 'Edit Property' : 'Add New Property',
          style: TextStyle(
            color: AppColor.textMain,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
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
          gradient: LinearGradient(
            colors: [AppColor.primary, AppColor.primary.withOpacity(0.8)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
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

            // Price, Price per Sq. Ft., and Area Row
            Row(
              children: [
                Expanded(
                  child: _buildFormField(
                    label: 'Total Price *',
                    controller: _priceController,
                    hintText: 'Enter total price',
                    keyboardType: TextInputType.number,
                    prefix: Text('₹ ', style: TextStyle(color: AppColor.primary)),
                    onChanged: (value) => _controller.price.value = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Total price is required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Enter valid price';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildFormField(
                    label: 'Price/Sq. Ft.',
                    controller: _pricePerSqftController,
                    hintText: 'Price per sq. ft.',
                    keyboardType: TextInputType.number,
                    prefix: Text('₹ ', style: TextStyle(color: AppColor.primary)),
                    onChanged: (value) => _controller.pricePerSqft.value = value,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: _buildFormField(
                    label: 'Area (Sq. Ft.) *',
                    controller: _areaController,
                    hintText: 'Enter area',
                    keyboardType: TextInputType.number,
                    suffix: Text('Sq. Ft.', style: TextStyle(color: AppColor.textSecondary)),
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
        Obx(() {
          if (_controller.propertyCategories.isEmpty && !_controller.isLoading.value) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColor.lightGrey),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'No categories available',
                    style: TextStyle(color: AppColor.grey),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, size: 18.w),
                    onPressed: () => _controller.fetchPropertyCategories(),
                  ),
                ],
              ),
            );
          }

          if (_controller.isLoading.value && _controller.propertyCategories.isEmpty) {
            return _buildShimmerLoader(height: 48.h);
          }

          return Container(
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
                    'Select Category',
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
          );
        }),

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
                    'State *',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textMain,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Obx(() {
                    if (_controller.statesList.isEmpty && _controller.isLoading.value) {
                      return _buildShimmerLoader(height: 48.h);
                    }

                    if (_controller.statesList.isEmpty) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppColor.lightGrey),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'No states available',
                              style: TextStyle(color: AppColor.grey),
                            ),
                            IconButton(
                              icon: Icon(Icons.refresh, size: 18.w),
                              onPressed: () => _controller.fetchStates(),
                            ),
                          ],
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
                          value: _controller.selectedStateId.value > 0
                              ? _controller.selectedStateId.value
                              : null,
                          isExpanded: true,
                          hint: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.w),
                            child: Text(
                              'Select State',
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
                    );
                  }),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'City *',
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

                    if (_controller.citiesList.isEmpty && _controller.isLoading.value) {
                      return _buildShimmerLoader(height: 48.h);
                    }

                    if (_controller.citiesList.isEmpty) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppColor.lightGrey),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'No cities found',
                              style: TextStyle(color: AppColor.grey),
                            ),
                            IconButton(
                              icon: Icon(Icons.refresh, size: 18.w),
                              onPressed: () => _controller.fetchCitiesByState(_controller.selectedStateId.value),
                            ),
                          ],
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
                              'Select City',
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

  Widget _buildShimmerLoader({double height = 48}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }

  Widget _buildFacilitiesTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Obx(() {
        if (_controller.selectedCategoryId.value <= 0) {
          return _buildEmptyState(
            icon: Icons.category,
            message: 'Please select a category first',
          );
        }

        if (_controller.facilities.isEmpty && !_controller.isLoading.value) {
          return _buildEmptyState(
            icon: Icons.info_outline,
            message: 'No facilities found for this category',
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
              if (facility.type == 'file' || facility.type == 'document') {
                return const SizedBox();
              }
              return _buildDynamicFacilityField(facility);
            }).toList(),

            // Amenities Section
            SizedBox(height: 32.h),
            _buildAmenitiesSection(),

            // Documents Section
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

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: AppColor.backgroundLight,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40.w, color: AppColor.grey),
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(color: AppColor.grey, fontSize: 16.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyPlacesSection() {
    return Obx(() {
      // Show loading state
      if (_controller.isLoading.value) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: CircularProgressIndicator(color: AppColor.primary),
          ),
        );
      }

      return Column(
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

          if (_controller.nearbyPlacesList.isEmpty)
            _buildEmptyState(
              icon: Icons.location_on_outlined,
              message: 'No nearby places found',
            )
          else
            ..._controller.nearbyPlacesList.map((place) {
              final isSelected = _controller.isNearbyPlaceSelected(place.id);
              final distanceController = _controller.nearbyDistanceControllers[place.id] ?? TextEditingController();
              final savedDistance = _controller.getSelectedPlaceDistance(place.id);

              // Set initial value if exists
              if (savedDistance != null && distanceController.text.isEmpty && widget.propertyId != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!_isDisposed) {
                    distanceController.text = savedDistance.toString();
                  }
                });
              }

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
                    _buildPlaceImage(place),
                    SizedBox(width: 12.w),

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
                                child: Container(
                                  width: 40.w,
                                  height: 40.w,
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColor.primary : AppColor.backgroundLight,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: isSelected ? AppColor.primary : AppColor.lightGrey,
                                    ),
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
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      );
    });
  }

  Widget _buildPlaceImage(NearbyPlace place) {
    if (place.image.isEmpty) {
      return Container(
        width: 50.w,
        height: 50.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r),
          color: AppColor.backgroundLight,
        ),
        child: Icon(Icons.location_on, color: AppColor.primary, size: 24.w),
      );
    }

    final imageUrl = '${place.image}';

    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
        width: 50.w,
        height: 50.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r),
          image: DecorationImage(
            image: imageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
      placeholder: (context, url) => Container(
        width: 50.w,
        height: 50.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r),
          color: AppColor.backgroundLight,
        ),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.w,
            color: AppColor.primary,
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: 50.w,
        height: 50.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.r),
          color: AppColor.backgroundLight,
        ),
        child: Icon(Icons.broken_image, color: AppColor.grey, size: 24.w),
      ),
    );
  }

  Widget _buildDynamicFacilityField(Facility facility) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      child: Column(
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

          if (facility.type == 'dropdown' && facility.dropdownValues.isNotEmpty)
            _buildDropdownFacility(facility)
          else if (facility.type == 'radio' && facility.dropdownValues.isNotEmpty)
            _buildRadioFacility(facility)
          else
            _buildTextFacility(facility),
        ],
      ),
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
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColor.primary.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected ? AppColor.primary : AppColor.lightGrey,
                width: isSelected ? 1.5 : 1,
              ),
            ),
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
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextFacility(Facility facility) {
    if (!_controller.facilityControllers.containsKey(facility.id)) {
      _controller.facilityControllers[facility.id] = TextEditingController();
    }

    final controller = _controller.facilityControllers[facility.id]!;

    // Set value from existing data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        final currentValue = _controller.facilityValues[facility.id];
        if (currentValue != null && controller.text != currentValue.toString()) {
          controller.text = currentValue.toString();
        }
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
      keyboardType: _isNumericField(facility.name) ? TextInputType.number : TextInputType.text,
      onChanged: (value) => _controller.updateFacilityValue(facility.id, value),
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

        Obx(() {
          if (_controller.availableAmenities.isEmpty && !_controller.isLoading.value) {
            return Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColor.backgroundLight,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'No amenities available',
                    style: TextStyle(color: AppColor.grey),
                  ),
                  IconButton(
                    icon: Icon(Icons.refresh, size: 18.w),
                    onPressed: () => _controller.fetchAvailableAmenities(),
                  ),
                ],
              ),
            );
          }

          return Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: _controller.availableAmenities.map((amenity) {
              final isSelected = _controller.selectedAmenityIds.contains(amenity.id);
              return AnimatedChoiceChip(
                label: amenity.title,
                selected: isSelected,
                onSelected: (selected) => _controller.toggleAmenitySelection(amenity.id),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildDocumentsSection() {
    return Obx(() {
      if (_controller.documents.isEmpty && _controller.selectedCategoryId.value > 0) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColor.backgroundLight,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
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
                'No documents required for this category',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColor.textSecondary,
                ),
              ),
            ],
          ),
        );
      }

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

          ..._controller.documents.map((document) => _buildDocumentUploadCard(document)).toList(),
        ],
      );
    });
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
                    icon: Icon(Iconsax.eye, size: 20.w, color: AppColor.primary),
                    onPressed: () {
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
                label: const Text('Upload'),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Document Preview'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.document, size: 60.w, color: AppColor.primary),
            SizedBox(height: 16.h),
            Text(
              'File: ${file.path.split('/').last}',
              style: TextStyle(fontSize: 14.sp),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showUrlPreview(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.link, size: 60.w, color: AppColor.primary),
            SizedBox(height: 16.h),
            const Text('Document is already uploaded'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
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
                        final imageUrl = _controller.galleryImageUrls[index];
                        final fullUrl = imageUrl.startsWith('http')
                            ? imageUrl
                            : '${ApiUrl.baseUrl}/${imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl}';

                        return _buildExistingImageItem(fullUrl, index);
                      },
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              );
            }
            return const SizedBox();
          }),

          // 3D Image Upload Section
          _build3DImageSection(),
          SizedBox(height: 24.h),

          // Upload New Images
          Obx(() {
            final totalImages = _controller.galleryImages.length + _controller.galleryImageUrls.length;
            final remainingImages = 10 - totalImages;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.h,
                childAspectRatio: 1,
              ),
              itemCount: totalImages + (remainingImages > 0 ? 1 : 0),
              itemBuilder: (context, index) {
                // Add Image Button
                if (index == totalImages && remainingImages > 0) {
                  return _buildAddImageButton(remainingImages);
                }

                // Existing URL Images
                if (index < _controller.galleryImageUrls.length) {
                  final imageUrl = _controller.galleryImageUrls[index];
                  final fullUrl = imageUrl.startsWith('http')
                      ? imageUrl
                      : '${ApiUrl.baseUrl}/${imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl}';

                  return _buildExistingImageGridItem(fullUrl, index);
                }

                // New File Images
                final fileIndex = index - _controller.galleryImageUrls.length;
                return _buildNewImageGridItem(fileIndex);
              },
            );
          }),

          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  Widget _build3DImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '3D Image/Tour',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.textMain,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Upload a 3D image or virtual tour file (Optional)',
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColor.textSecondary,
          ),
        ),
        SizedBox(height: 12.h),

        Obx(() {
          final has3DFile = _controller.threeDImageFile.value != null;
          final has3DUrl = _controller.threeDImageUrl.value.isNotEmpty;

          return Container(
            decoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColor.lightGrey),
            ),
            child: Column(
              children: [
                // 3D Image Preview
                if (has3DFile || has3DUrl)
                  Container(
                    height: 150.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.r),
                        topRight: Radius.circular(8.r),
                      ),
                      color: AppColor.backgroundLight,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.view_in_ar,
                        size: 50.w,
                        color: AppColor.primary,
                      ),
                    ),
                  ),

                // Upload/Remove Button
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '3D Image/Tour',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColor.textMain,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            if (has3DFile)
                              Text(
                                'File: ${_controller.threeDImageFile.value!.path.split('/').last}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColor.primary,
                                ),
                              ),
                            if (has3DUrl)
                              Text(
                                '3D Image uploaded',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColor.success,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (has3DFile || has3DUrl)
                        IconButton(
                          icon: Icon(Iconsax.trash, size: 20.w, color: AppColor.red),
                          onPressed: () => _controller.remove3DImage(),
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: () => _controller.pick3DImage(),
                          icon: Icon(Iconsax.document_upload, size: 16.w),
                          label: const Text('Upload 3D'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primary,
                            foregroundColor: AppColor.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildExistingImageItem(String imageUrl, int index) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 100.w,
              height: 100.h,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 100.w,
                height: 100.h,
                color: AppColor.backgroundLight,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.w,
                    color: AppColor.primary,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 100.w,
                height: 100.h,
                color: AppColor.backgroundLight,
                child: Icon(Icons.broken_image, color: AppColor.grey),
              ),
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
                padding: EdgeInsets.all(4.w),
                child: Icon(
                  Icons.close,
                  size: 12.w,
                  color: AppColor.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingImageGridItem(String imageUrl, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: AppColor.backgroundLight,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  color: AppColor.primary,
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColor.backgroundLight,
              child: Icon(Icons.broken_image, color: AppColor.grey),
            ),
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
              padding: EdgeInsets.all(4.w),
              child: Icon(
                Icons.close,
                size: 12.w,
                color: AppColor.red,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewImageGridItem(int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: Image.file(
            _controller.galleryImages[index],
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColor.backgroundLight,
              child: Icon(Icons.broken_image, color: AppColor.grey),
            ),
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
              padding: EdgeInsets.all(4.w),
              child: Icon(
                Icons.close,
                size: 12.w,
                color: AppColor.red,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddImageButton(int remainingImages) {
    return GestureDetector(
      onTap: () {
        if (remainingImages > 0) {
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
                color: remainingImages > 0 ? AppColor.primary : AppColor.grey,
                size: 24.w,
              ),
              SizedBox(height: 8.h),
              Text(
                'Add Image',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: remainingImages > 0 ? AppColor.primary : AppColor.grey,
                ),
              ),
            ],
          ),
        ),
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
              const Spacer(),
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
            label: const Text('Use Current Location'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: AppColor.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              minimumSize: const Size(double.infinity, 0),
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
                  label: const Text('Previous'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
            if (_tabController.index > 0) SizedBox(width: 12.w),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: isLoading
                    ? null
                    : () {
                  final totalTabs = _tabController.length;

                  if (isLastTab) {
                    bool allValid = true;
                    for (int i = 0; i < totalTabs; i++) {
                      _controller.currentStep.value = i;
                      if (!_controller.isStepValid()) {
                        allValid = false;
                        final errors = _controller.validateCurrentStep();
                        if (errors.isNotEmpty) {
                          Get.snackbar(
                            'Validation Error',
                            errors.values.first,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                        if (i >= 0 && i < totalTabs) {
                          _tabController.animateTo(i);
                        }
                        _controller.currentStep.value = i;
                        break;
                      }
                    }
                    if (allValid) {
                      _controller.submitProperty();
                    }
                  } else {
                    _controller.currentStep.value = _tabController.index;
                    if (_controller.isStepValid()) {
                      _controller.nextStep();
                      final nextIndex = _tabController.index + 1;
                      if (nextIndex >= 0 && nextIndex < totalTabs) {
                        _tabController.animateTo(nextIndex);
                      }
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
                    ? const Text('Processing...')
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
    Widget? suffix,
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
            suffix: suffix,
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
}

class AnimatedChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const AnimatedChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppColor.primary.withOpacity(0.2),
      backgroundColor: AppColor.backgroundLight,
      labelStyle: TextStyle(
        color: selected ? AppColor.primary : AppColor.textMain,
        fontSize: 12.sp,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: BorderSide(
          color: selected ? AppColor.primary : AppColor.lightGrey,
        ),
      ),
      onSelected: onSelected,
    );
  }
}