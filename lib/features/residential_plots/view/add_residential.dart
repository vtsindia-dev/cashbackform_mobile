import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
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
  final _plotCountController = TextEditingController();
  final _pricePerSqftController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final TextEditingController _youtubeLinkController = TextEditingController();

  // Animation controllers
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Google Maps
  GoogleMapController? _googleMapController;

  bool _isDisposed = false;
  bool _initialDataLoaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _isDisposed = false;
    _initialDataLoaded = false;

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_isDisposed) {
        _controller.currentStep.value = _tabController.index;
        _fadeAnimationController.forward(from: 0.0);
        _slideAnimationController.forward(from: 0.0);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        _fadeAnimationController.forward();
        _slideAnimationController.forward();
        _initializeData();
      }
    });
  }

  void _initializeData() async {
    if (_initialDataLoaded) return;
    _initializeDataBinding();
    if (widget.propertyId != null) {
      _controller.resetFormForEdit();
      final result =
      await _controller.loadPropertyForEditing(widget.propertyId!);

      setState(() {
        _youtubeLinkController.text = result??'';
      });

      if (!_isDisposed) {
        Future.delayed(const Duration(milliseconds: 300), _prefetchImages);
      }
    } else {
      _controller.resetForm();
      _clearFormFields();
      await _loadInitialData();
    }
    _initialDataLoaded = true;
  }

  Future<void> _loadInitialData() async {
    try {
      if (_controller.propertyCategories.isEmpty) await _controller.fetchPropertyCategories();
      if (_controller.statesList.isEmpty) await _controller.fetchStates();
      if (_controller.availableAmenities.isEmpty) await _controller.fetchAvailableAmenities();
      if (_controller.nearbyPlacesList.isEmpty) await _controller.fetchNearbyPlaces();
      await _controller.getCurrentLocation();
    } catch (e) {
      print('❌ Error loading initial data: $e');
    }
  }

  void _initializeDataBinding() {
    void safeUpdate(TextEditingController c, String v) {
      if (!_isDisposed && c.text != v) c.text = v;
    }
    _controller.propertyName.listen((v) => safeUpdate(_propertyNameController, v));
    _controller.price.listen((v) => safeUpdate(_priceController, v));
    _controller.plotCount.listen((v) => safeUpdate(_plotCountController, v));
    _controller.pricePerSqft.listen((v) => safeUpdate(_pricePerSqftController, v));
    _controller.areaSqft.listen((v) => safeUpdate(_areaController, v));
    _controller.aboutProperty.listen((v) => safeUpdate(_descriptionController, v));
    _controller.location.listen((v) => safeUpdate(_locationController, v));
    _controller.yotubeLink.listen((v) => safeUpdate(_youtubeLinkController, v));

    _propertyNameController.addListener(() {
      if (!_isDisposed && _controller.propertyName.value != _propertyNameController.text)
        _controller.propertyName.value = _propertyNameController.text;
    });
    _priceController.addListener(() {
      if (!_isDisposed && _controller.price.value != _priceController.text)
        _controller.price.value = _priceController.text;
    });
    _plotCountController.addListener(() {
      if (!_isDisposed && _controller.plotCount.value != _plotCountController.text)
        _controller.plotCount.value = _plotCountController.text;
    });
    _pricePerSqftController.addListener(() {
      if (!_isDisposed && _controller.pricePerSqft.value != _pricePerSqftController.text)
        _controller.pricePerSqft.value = _pricePerSqftController.text;
    });
    _areaController.addListener(() {
      if (!_isDisposed && _controller.areaSqft.value != _areaController.text)
        _controller.areaSqft.value = _areaController.text;
    });
    _descriptionController.addListener(() {
      if (!_isDisposed && _controller.aboutProperty.value != _descriptionController.text)
        _controller.aboutProperty.value = _descriptionController.text;
    });
    _youtubeLinkController.addListener(() {
      if (!_isDisposed && _controller.yotubeLink.value != _youtubeLinkController.text)
        _controller.yotubeLink.value = _youtubeLinkController.text;
    });
    _locationController.addListener(() {
      if (!_isDisposed && _controller.location.value != _locationController.text)
        _controller.location.value = _locationController.text;
    });
  }

  void _prefetchImages() {
    for (var imageUrl in _controller.galleryImageUrls) {
      final fullUrl = imageUrl.startsWith('http')
          ? imageUrl
          : '${ApiUrl.baseUrl}/${imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl}';
      precacheImage(CachedNetworkImageProvider(fullUrl), context,
          onError: (e, s) {});
    }
  }

  @override
  void didUpdateWidget(covariant AddEditPropertyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.propertyId != widget.propertyId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_isDisposed) {
          _initialDataLoaded = false;
          if (widget.propertyId == null) {
            _controller.resetForm();
            _clearFormFields();
            _loadInitialData();
          } else {
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
      _plotCountController.clear();
      _pricePerSqftController.clear();
      _areaController.clear();
      _descriptionController.clear();
      _locationController.clear();
      _youtubeLinkController.clear();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _tabController.dispose();
    _scrollController.dispose();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    _propertyNameController.dispose();
    _priceController.dispose();
    _plotCountController.dispose();
    _pricePerSqftController.dispose();
    _areaController.dispose();
    _descriptionController.dispose();
    _youtubeLinkController.dispose();
    _locationController.dispose();
    _googleMapController?.dispose();
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
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: _buildAppBar(),
        body: Obx(() {
          if (_controller.isLoading.value && widget.propertyId != null) {
            return _buildLoadingScreen();
          }
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
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
              ),
            ),
          );
        }),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Future<bool> _checkForUnsavedChanges() async {
    return _propertyNameController.text.isNotEmpty ||
        _priceController.text.isNotEmpty ||
        _areaController.text.isNotEmpty ||
        _controller.galleryImages.isNotEmpty ||
        _controller.galleryVideos.isNotEmpty ||
        _controller.selectedAmenityIds.isNotEmpty ||
        _controller.selectedNearbyPlaces.isNotEmpty ||
        _controller.blueprintFile.value != null;
  }

  Future<void> _showExitConfirmationDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        backgroundColor: Colors.white,
        title: Text('Unsaved Changes',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1A1D2E))),
        content: Text('You have unsaved changes. Are you sure you want to leave?',
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF6B7280))),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel', style: TextStyle(color: const Color(0xFF6B7280), fontSize: 14.sp)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: Text('Leave', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (result == true) Get.back();
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w, height: 80.w,
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CircularProgressIndicator(color: AppColor.primary, strokeWidth: 3.w),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            widget.propertyId != null ? 'Loading Property...' : 'Loading Form...',
            style: TextStyle(fontSize: 16.sp, color: const Color(0xFF1A1D2E), fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text('Please wait a moment',
              style: TextStyle(fontSize: 13.sp, color: const Color(0xFF6B7280))),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(64.h),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  color: const Color(0xFF1A1D2E),
                  onPressed: () async {
                    final hasChanges = await _checkForUnsavedChanges();
                    if (hasChanges && mounted) await _showExitConfirmationDialog();
                    else Get.back();
                  },
                ),
                Expanded(
                  child: Text(
                    widget.propertyId != null ? 'Edit Property' : 'Add New Property',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF1A1D2E),
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                SizedBox(width: 48.w),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 3)),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColor.primary,
          borderRadius: BorderRadius.circular(11.r),
          boxShadow: [
            BoxShadow(color: AppColor.primary.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF9CA3AF),
        labelStyle: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w700, letterSpacing: 0.2),
        unselectedLabelStyle: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w500),
        tabs: const [
          Tab(text: 'Basic'),
          Tab(text: 'Facilities'),
          Tab(text: 'Media'),
          Tab(text: 'Location'),
        ],
      ),
    );
  }

  // ==================== BASIC INFO TAB ====================
  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: 'Property Details',
              icon: Iconsax.building,
              children: [
                _buildFormField(
                  label: 'Property Name',
                  required: true,
                  controller: _propertyNameController,
                  hintText: 'e.g. Sunrise Villa, Green Park Apartment',
                  onChanged: (v) => _controller.propertyName.value = v,
                  validator: (v) => v == null || v.isEmpty ? 'Property name is required' : null,
                ),
                SizedBox(height: 14.h),
                _buildCategorySection(),
                SizedBox(height: 14.h),
                Row(children: [
                  Expanded(
                    child: _buildFormField(
                      label: 'Total Price',
                      required: true,
                      controller: _priceController,
                      hintText: '0',
                      keyboardType: TextInputType.number,
                      prefix: Text('₹', style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.w600, fontSize: 15.sp)),
                      onChanged: (v) => _controller.price.value = v,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _buildFormField(
                      label: 'Price/Sq.Ft.',
                      controller: _pricePerSqftController,
                      hintText: '0',
                      keyboardType: TextInputType.number,
                      prefix: Text('₹', style: TextStyle(color: AppColor.primary, fontWeight: FontWeight.w600, fontSize: 15.sp)),
                      onChanged: (v) => _controller.pricePerSqft.value = v,
                    ),
                  ),
                ]),
                SizedBox(height: 14.h),
                Row(children: [
                  Expanded(
                    child: _buildFormField(
                      label: 'Plot Count',
                      required: true,
                      controller: _plotCountController,
                      hintText: '0',
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _controller.plotCount.value = v,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (int.tryParse(v) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _buildFormField(
                      label: 'Total Area',
                      required: true,
                      controller: _areaController,
                      hintText: '0',
                      keyboardType: TextInputType.number,
                      suffix: Text('Sq.Ft.', style: TextStyle(color: const Color(0xFF9CA3AF), fontSize: 12.sp)),
                      onChanged: (v) => _controller.areaSqft.value = v,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Area is required';
                        if (int.tryParse(v) == null) return 'Enter valid area';
                        return null;
                      },
                    ),
                  ),
                ]),
              ],
            ),
            SizedBox(height: 14.h),
            _buildSectionCard(
              title: 'Location',
              icon: Iconsax.location,
              children: [_buildLocationSelection()],
            ),
            SizedBox(height: 14.h),
            _buildSectionCard(
              title: 'Description',
              icon: Iconsax.document_text,
              children: [
                _buildFormField(
                  label: 'About Property',
                  controller: _descriptionController,
                  hintText: 'Describe key highlights, surroundings, and unique features...',
                  maxLines: 5,
                  onChanged: (v) => _controller.aboutProperty.value = v,
                ),
              ],
            ),
            SizedBox(height: 10,),
            _buildFormField(
              label: 'Youtube Link',
              required: false,
              controller: _youtubeLinkController,
              hintText: 'Enter youtube link',
              keyboardType: TextInputType.url,
              suffix: Text('', style: TextStyle(color: const Color(0xFF9CA3AF), fontSize: 12.sp)),
              onChanged: (v) => _controller.yotubeLink.value = v,
            ),
            SizedBox(height: 100.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
            child: Row(
              children: [
                Container(
                  width: 32.w, height: 32.w,
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(icon, size: 16.w, color: AppColor.primary),
                ),
                SizedBox(width: 10.w),
                Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: const Color(0xFF1A1D2E))),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('Category', required: true),
        SizedBox(height: 6.h),
        Obx(() {
          if (_controller.isLoading.value && _controller.propertyCategories.isEmpty) {
            return _buildShimmerLoader(height: 50.h);
          }
          if (_controller.propertyCategories.isEmpty) {
            return _buildRetryField('No categories available', () => _controller.fetchPropertyCategories());
          }
          return _buildStyledDropdown<int>(
            value: _controller.selectedCategoryId.value > 0 ? _controller.selectedCategoryId.value : null,
            hint: 'Select category',
            items: _controller.propertyCategories.map((c) =>
                DropdownMenuItem(value: c.id, child: Padding(padding: EdgeInsets.symmetric(horizontal: 12.w), child: Text(c.categoryName)))).toList(),
            onChanged: (v) { if (v != null) _controller.onCategoryChanged(v); },
          );
        }),
        Obx(() {
          if (_controller.selectedCategoryId.value == 0) return const SizedBox();
          final cat = _controller.propertyCategories.firstWhereOrNull((c) => c.id == _controller.selectedCategoryId.value);
          if (cat?.subCategories == null || cat!.subCategories!.isEmpty) return const SizedBox();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 12.h),
              _buildLabel('Sub Category'),
              SizedBox(height: 6.h),
              _buildStyledDropdown<int>(
                value: _controller.selectedSubCategoryId.value > 0 ? _controller.selectedSubCategoryId.value : null,
                hint: 'Select sub category',
                items: cat.subCategories!.map((s) =>
                    DropdownMenuItem(value: s.id, child: Padding(padding: EdgeInsets.symmetric(horizontal: 12.w), child: Text(s.name)))).toList(),
                onChanged: (v) { if (v != null) _controller.onSubCategoryChanged(v); },
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildLocationSelection() {
    return Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildLabel('State', required: true),
          SizedBox(height: 6.h),
          Obx(() {
            if (_controller.isLoading.value && _controller.statesList.isEmpty) return _buildShimmerLoader(height: 50.h);
            if (_controller.statesList.isEmpty) return _buildRetryField('No states', () => _controller.fetchStates());
            return _buildStyledDropdown<int>(
              value: _controller.selectedStateId.value > 0 ? _controller.selectedStateId.value : null,
              hint: 'Select state',
              items: _controller.statesList.map((s) => DropdownMenuItem(value: s.id, child: Padding(padding: EdgeInsets.symmetric(horizontal: 12.w), child: Text(s.stateName)))).toList(),
              onChanged: (v) { if (v != null) _controller.onStateChanged(v); },
            );
          }),
        ]),
      ),
      SizedBox(width: 10.w),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildLabel('City', required: true),
          SizedBox(height: 6.h),
          Obx(() {
            if (_controller.selectedStateId.value == 0) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text('Select state first', style: TextStyle(color: const Color(0xFF9CA3AF), fontSize: 13.sp)),
              );
            }
            if (_controller.isLoading.value && _controller.citiesList.isEmpty) return _buildShimmerLoader(height: 50.h);
            if (_controller.citiesList.isEmpty) return _buildRetryField('No cities', () => _controller.fetchCitiesByState(_controller.selectedStateId.value));
            return _buildStyledDropdown<int>(
              value: _controller.selectedCityId.value > 0 ? _controller.selectedCityId.value : null,
              hint: 'Select city',
              items: _controller.citiesList.map((c) => DropdownMenuItem(value: c.id, child: Padding(padding: EdgeInsets.symmetric(horizontal: 12.w), child: Text(c.name)))).toList(),
              onChanged: (v) { if (v != null) _controller.onCityChanged(v); },
            );
          }),
        ]),
      ),
    ]);
  }

  Widget _buildStyledDropdown<T>({
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF9CA3AF)),
          hint: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(hint, style: TextStyle(color: const Color(0xFF9CA3AF), fontSize: 13.sp)),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildRetryField(String message, VoidCallback onRetry) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(message, style: TextStyle(color: const Color(0xFF9CA3AF), fontSize: 13.sp)),
          GestureDetector(
            onTap: onRetry,
            child: Icon(Icons.refresh_rounded, size: 18.w, color: AppColor.primary),
          ),
        ],
      ),
    );
  }

  // ==================== FACILITIES TAB ====================
  Widget _buildFacilitiesTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Obx(() {
        if (_controller.selectedCategoryId.value <= 0) {
          return _buildEmptyStateCard(icon: Iconsax.category, message: 'Please select a category first\nfrom the Basic tab');
        }
        if (_controller.facilities.isEmpty && !_controller.isLoading.value) {
          return _buildEmptyStateCard(icon: Icons.info_outline, message: 'No facilities found\nfor this category');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionCard(
              title: 'Property Facilities',
              icon: Iconsax.home_trend_up,
              children: [
                ..._controller.facilities.map((f) {
                  if (f.type == 'file' || f.type == 'document') return const SizedBox();
                  return _buildDynamicFacilityField(f);
                }).toList(),
              ],
            ),
            if (_controller.documents.isNotEmpty) ...[
              SizedBox(height: 14.h),
              _buildDocumentsSection(),
            ],
            SizedBox(height: 14.h),
            _buildAmenitiesSection(),
            SizedBox(height: 14.h),
            _buildNearbyPlacesSection(),
            SizedBox(height: 100.h),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyStateCard({required dynamic icon, required String message}) {
    return Container(
      margin: EdgeInsets.only(top: 60.h),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 72.w, height: 72.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(18.r),
              ),
              child: Icon(icon, size: 32.w, color: const Color(0xFF9CA3AF)),
            ),
            SizedBox(height: 16.h),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: const Color(0xFF6B7280), fontSize: 14.sp, height: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsSection() {
    return _buildSectionCard(
      title: 'Required Documents',
      icon: Iconsax.document_upload,
      children: _controller.documents.map(_buildDocumentUploadCard).toList(),
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
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: (hasFile || hasUrl) ? AppColor.primary.withOpacity(0.04) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: (hasFile || hasUrl) ? AppColor.primary.withOpacity(0.3) : const Color(0xFFE5E7EB),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text(document.name, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1A1D2E))),
              if (document.isRequired == 1) ...[
                SizedBox(width: 4.w),
                Text('*', style: TextStyle(color: const Color(0xFFEF4444), fontSize: 14.sp)),
              ],
            ]),
            SizedBox(height: 10.h),
            if (hasFile || hasUrl)
              Row(children: [
                Container(
                  width: 36.w, height: 36.w,
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Iconsax.document, color: AppColor.primary, size: 18.w),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(hasFile ? file!.path.split('/').last : 'Document uploaded',
                        style: TextStyle(fontSize: 12.sp, color: const Color(0xFF1A1D2E), fontWeight: FontWeight.w500),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(hasFile ? 'New file selected' : 'Existing file',
                        style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9CA3AF))),
                  ]),
                ),
                if (hasUrl && url != null)
                  GestureDetector(
                    onTap: () async {
                      final uri = Uri.parse(url);
                      if (await canLaunchUrl(uri)) await launchUrl(uri);
                    },
                    child: Container(
                      width: 32.w, height: 32.w,
                      decoration: BoxDecoration(
                        color: AppColor.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(Iconsax.eye, size: 16.w, color: AppColor.primary),
                    ),
                  ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => _controller.removeDocumentFile(document.id),
                  child: Container(
                    width: 32.w, height: 32.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Iconsax.trash, size: 16.w, color: const Color(0xFFEF4444)),
                  ),
                ),
              ])
            else
              GestureDetector(
                onTap: () => _controller.pickDocumentFile(document.id),
                child: Container(
                  height: 80.h, width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColor.primary.withOpacity(0.3), style: BorderStyle.solid),
                    color: AppColor.primary.withOpacity(0.03),
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Iconsax.document_upload, size: 24.w, color: AppColor.primary),
                    SizedBox(height: 6.h),
                    Text('Tap to upload', style: TextStyle(fontSize: 12.sp, color: AppColor.primary, fontWeight: FontWeight.w500)),
                    if (document.allowedFormats != null)
                      Text('${document.allowedFormats!.join(', ')} • Max ${document.maxSize}KB',
                          style: TextStyle(fontSize: 10.sp, color: const Color(0xFF9CA3AF))),
                  ]),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildDynamicFacilityField(Facility facility) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(facility.name,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600,
                    color: facility.isRequired == 1 ? const Color(0xFF1A1D2E) : const Color(0xFF6B7280))),
            if (facility.isRequired == 1) ...[
              SizedBox(width: 4.w),
              Text('*', style: TextStyle(color: const Color(0xFFEF4444), fontSize: 14.sp)),
            ],
          ]),
          SizedBox(height: 6.h),
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
    final currentValue = _controller.facilityValues[facility.id]?.toString() ?? '';
    return _buildStyledDropdown<String>(
      value: currentValue.isEmpty ? null : currentValue,
      hint: 'Select ${facility.name}',
      items: facility.dropdownValues.map((o) => DropdownMenuItem(value: o, child: Padding(padding: EdgeInsets.symmetric(horizontal: 12.w), child: Text(o)))).toList(),
      onChanged: (v) => _controller.updateFacilityValue(facility.id, v),
    );
  }

  Widget _buildRadioFacility(Facility facility) {
    final currentValue = _controller.facilityValues[facility.id]?.toString() ?? '';
    return Wrap(
      spacing: 10.w,
      runSpacing: 8.h,
      children: facility.dropdownValues.map((option) {
        final isSelected = currentValue == option;
        return GestureDetector(
          onTap: () => _controller.updateFacilityValue(facility.id, option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColor.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: isSelected ? AppColor.primary : const Color(0xFFE5E7EB), width: isSelected ? 1.5 : 1),
            ),
            child: Text(option,
                style: TextStyle(fontSize: 13.sp, color: isSelected ? Colors.white : const Color(0xFF4B5563),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed) {
        final cv = _controller.facilityValues[facility.id];
        if (cv != null && controller.text != cv.toString()) controller.text = cv.toString();
      }
    });
    return TextFormField(
      controller: controller,
      style: TextStyle(fontSize: 14.sp, color: const Color(0xFF1A1D2E)),
      decoration: InputDecoration(
        hintText: 'Enter ${facility.name}',
        hintStyle: TextStyle(color: const Color(0xFF9CA3AF), fontSize: 13.sp),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: const Color(0xFFE5E7EB))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: AppColor.primary, width: 1.5)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      ),
      keyboardType: _isNumericField(facility.name) ? TextInputType.number : TextInputType.text,
      onChanged: (v) => _controller.updateFacilityValue(facility.id, v),
    );
  }

  bool _isNumericField(String name) {
    return ['age', 'floor', 'length', 'breadth', 'width', 'number', 'count'].any((f) => name.toLowerCase().contains(f));
  }

  Widget _buildAmenitiesSection() {
    return _buildSectionCard(
      title: 'Amenities',
      icon: Iconsax.star,
      children: [
        Text('Select all available amenities for this property',
            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
        SizedBox(height: 12.h),
        Obx(() {
          if (_controller.availableAmenities.isEmpty && !_controller.isLoading.value) {
            return _buildRetryField('No amenities available', () => _controller.fetchAvailableAmenities());
          }
          return Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _controller.availableAmenities.map((amenity) {
              final isSelected = _controller.selectedAmenityIds.contains(amenity.id);
              return GestureDetector(
                onTap: () => _controller.toggleAmenitySelection(amenity.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColor.primary : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: isSelected ? AppColor.primary : const Color(0xFFE5E7EB)),
                  ),
                  child: Text(amenity.title,
                      style: TextStyle(fontSize: 12.sp,
                          color: isSelected ? Colors.white : const Color(0xFF4B5563),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildNearbyPlacesSection() {
    return _buildSectionCard(
      title: 'Nearby Places',
      icon: Iconsax.location_tick,
      children: [
        Text('Add places and distances in km',
            style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
        SizedBox(height: 12.h),
        Obx(() {
          if (_controller.isLoading.value) {
            return Center(child: CircularProgressIndicator(color: AppColor.primary));
          }
          if (_controller.nearbyPlacesList.isEmpty) {
            return _buildEmptyStateCard(icon: Iconsax.location, message: 'No nearby places found');
          }
          return Column(
            children: _controller.nearbyPlacesList.map((place) {
              final isSelected = _controller.isNearbyPlaceSelected(place.id);
              final distCtrl = _controller.nearbyDistanceControllers[place.id] ?? TextEditingController();
              final savedDist = _controller.getSelectedPlaceDistance(place.id);
              if (savedDist != null && distCtrl.text.isEmpty && widget.propertyId != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!_isDisposed) distCtrl.text = savedDist.toString();
                });
              }
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(bottom: 10.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isSelected ? AppColor.primary.withOpacity(0.04) : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: isSelected ? AppColor.primary.withOpacity(0.4) : const Color(0xFFE5E7EB),
                      width: isSelected ? 1.5 : 1),
                ),
                child: Row(children: [
                  _buildPlaceImage(place),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(place.title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1A1D2E))),
                      SizedBox(height: 8.h),
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: distCtrl,
                            style: TextStyle(fontSize: 13.sp, color: const Color(0xFF1A1D2E)),
                            decoration: InputDecoration(
                              hintText: 'Distance',
                              hintStyle: TextStyle(color: const Color(0xFF9CA3AF), fontSize: 12.sp),
                              filled: true, fillColor: Colors.white,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                              contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                              suffixText: 'km',
                              suffixStyle: TextStyle(fontSize: 11.sp, color: const Color(0xFF9CA3AF)),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              if (v.isNotEmpty && (int.tryParse(v) ?? 0) > 0) {
                                _controller.toggleNearbyPlace(place.id, v);
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 10.w),
                        GestureDetector(
                          onTap: () {
                            final d = distCtrl.text;
                            if (isSelected) {
                              _controller.removeNearbyPlace(place.id);
                            } else if (d.isNotEmpty && (int.tryParse(d) ?? 0) > 0) {
                              _controller.toggleNearbyPlace(place.id, d);
                            } else {
                              Get.snackbar('Distance Required', 'Enter distance for ${place.title}', snackPosition: SnackPosition.BOTTOM);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 38.w, height: 38.w,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColor.primary : Colors.white,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: isSelected ? AppColor.primary : const Color(0xFFE5E7EB)),
                            ),
                            child: Icon(isSelected ? Icons.check_rounded : Icons.add_rounded,
                                size: 18.w, color: isSelected ? Colors.white : const Color(0xFF9CA3AF)),
                          ),
                        ),
                      ]),
                    ]),
                  ),
                ]),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildPlaceImage(NearbyPlace place) {
    if (place.image.isEmpty) {
      return Container(
        width: 44.w, height: 44.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: AppColor.primary.withOpacity(0.1),
        ),
        child: Icon(Iconsax.location, color: AppColor.primary, size: 20.w),
      );
    }
    return CachedNetworkImage(
      imageUrl: place.image,
      imageBuilder: (ctx, img) => Container(
        width: 44.w, height: 44.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          image: DecorationImage(image: img, fit: BoxFit.cover),
        ),
      ),
      placeholder: (_, __) => Container(
        width: 44.w, height: 44.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: const Color(0xFFF3F4F6),
        ),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2.w, color: AppColor.primary)),
      ),
      errorWidget: (_, __, ___) => Container(
        width: 44.w, height: 44.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: const Color(0xFFF3F4F6),
        ),
        child: Icon(Icons.location_on_outlined, color: const Color(0xFF9CA3AF), size: 20.w),
      ),
    );
  }

  // ==================== MEDIA TAB ====================
  Widget _buildMediaTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gallery Images + Videos
          _buildSectionCard(
            title: 'Gallery',
            icon: Iconsax.gallery,
            children: [
              Text('Add photos and videos (Max 10 total)',
                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
              SizedBox(height: 14.h),
              Obx(() {
                final totalMedia = _controller.galleryImages.length +
                    _controller.galleryImageUrls.length +
                    _controller.galleryVideos.length;
                final remaining = 10 - totalMedia;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.w,
                    mainAxisSpacing: 8.h,
                    childAspectRatio: 1,
                  ),
                  itemCount: totalMedia + (remaining > 0 ? 2 : 0),
                  itemBuilder: (context, index) {
                    // Add buttons at end
                    if (index == totalMedia && remaining > 0) return _buildAddImageButton(remaining);
                    if (index == totalMedia + 1 && remaining > 0) return _buildAddVideoButton(remaining);

                    // Existing URL images
                    if (index < _controller.galleryImageUrls.length) {
                      final imageUrl = _controller.galleryImageUrls[index];
                      final fullUrl = imageUrl.startsWith('http')
                          ? imageUrl
                          : '${ApiUrl.baseUrl}/${imageUrl.startsWith('/') ? imageUrl.substring(1) : imageUrl}';
                      return _buildExistingImageGridItem(fullUrl, index);
                    }

                    // New video files
                    final afterUrls = index - _controller.galleryImageUrls.length;
                    if (afterUrls < _controller.galleryVideos.length) {
                      return _buildVideoGridItem(afterUrls);
                    }

                    // New image files
                    final fileIndex = afterUrls - _controller.galleryVideos.length;
                    return _buildNewImageGridItem(fileIndex);
                  },
                );
              }),
            ],
          ),
          SizedBox(height: 14.h),

          // 3D Image Section
          _buildSectionCard(
            title: '3D Tour / Virtual View',
            icon: Icons.view_in_ar_rounded,
            children: [
              Text('Upload a 3D image or virtual tour file (Optional)',
                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
              SizedBox(height: 12.h),
              Obx(() {
                final has3DFile = _controller.threeDImageFile.value != null;
                final has3DUrl = _controller.threeDImageUrl.value.isNotEmpty;
                if (has3DFile || has3DUrl) {
                  return _buildUploadedFileRow(
                    icon: Icons.view_in_ar_rounded,
                    label: has3DFile
                        ? _controller.threeDImageFile.value!.path.split('/').last
                        : '3D image uploaded',
                    sublabel: has3DFile ? 'New file selected' : 'Existing 3D tour',
                    onRemove: () => _controller.remove3DImage(),
                    iconColor: const Color(0xFF6366F1),
                    iconBg: const Color(0xFFEEF2FF),
                  );
                }
                return _buildUploadDropzone(
                  icon: Icons.view_in_ar_rounded,
                  label: 'Upload 3D Image / Tour',
                  sublabel: 'JPG, PNG, GLB, GLTF • Max 10MB',
                  onTap: () => _controller.pick3DImage(),
                  accentColor: const Color(0xFF6366F1),
                );
              }),
            ],
          ),
          SizedBox(height: 14.h),

          // Layout Sketch Section
          _buildSectionCard(
            title: 'Layout Sketch / Floor Plan',
            icon: Iconsax.document,
            children: [
              Text('Upload the property layout sketch or floor plan (Optional)',
                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
              SizedBox(height: 12.h),
              Obx(() {
                final hasFile = _controller.blueprintFile.value != null;
                final hasUrl = _controller.blueprintUrl.value.isNotEmpty;
                if (hasFile || hasUrl) {
                  return _buildUploadedFileRow(
                    icon: Iconsax.document_code,
                    label: hasFile
                        ? _controller.blueprintFile.value!.path.split('/').last
                        : 'Layout Sketch uploaded',
                    sublabel: hasFile ? 'New Layout Sketch selected' : 'Existing Layout Sketch',
                    onRemove: () => _controller.removeBlueprint(),
                    iconColor: const Color(0xFF0EA5E9),
                    iconBg: const Color(0xFFE0F2FE),
                    previewUrl: hasUrl ? _controller.blueprintUrl.value : null,
                  );
                }
                return _buildUploadDropzone(
                  icon: Iconsax.document,
                  label: 'Upload Layout Sketch / Floor Plan',
                  sublabel: 'PDF, PNG, JPG • Max 10MB',
                  onTap: () => _controller.pickBlueprint(),
                  accentColor: const Color(0xFF0EA5E9),
                );
              }),
            ],
          ),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  Widget _buildUploadDropzone({
    required IconData icon,
    required String label,
    required String sublabel,
    required VoidCallback onTap,
    required Color accentColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 24.h),
        decoration: BoxDecoration(
          color: accentColor.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: accentColor.withOpacity(0.3), style: BorderStyle.solid),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 48.w, height: 48.w,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: accentColor, size: 22.w),
          ),
          SizedBox(height: 10.h),
          Text(label, style: TextStyle(fontSize: 13.sp, color: accentColor, fontWeight: FontWeight.w600)),
          SizedBox(height: 4.h),
          Text(sublabel, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9CA3AF))),
        ]),
      ),
    );
  }

  Widget _buildUploadedFileRow({
    required IconData icon,
    required String label,
    required String sublabel,
    required VoidCallback onRemove,
    required Color iconColor,
    required Color iconBg,
    String? previewUrl,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: iconBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: iconColor.withOpacity(0.2)),
      ),
      child: Row(children: [
        Container(
          width: 40.w, height: 40.w,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10.r)),
          child: Icon(icon, color: iconColor, size: 20.w),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF1A1D2E), fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(sublabel, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6B7280))),
          ]),
        ),
        if (previewUrl != null)
          GestureDetector(
            onTap: () async {
              final uri = Uri.parse(previewUrl);
              if (await canLaunchUrl(uri)) await launchUrl(uri);
            },
            child: Container(
              width: 34.w, height: 34.w,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8.r)),
              child: Icon(Iconsax.eye, size: 16.w, color: iconColor),
            ),
          ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: onRemove,
          child: Container(
            width: 34.w, height: 34.w,
            decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(8.r)),
            child: Icon(Iconsax.trash, size: 16.w, color: const Color(0xFFEF4444)),
          ),
        ),
      ]),
    );
  }

  Widget _buildAddImageButton(int remainingMedia) {
    return GestureDetector(
      onTap: () {
        if (remainingMedia > 0) _controller.pickGalleryImages();
        else Get.snackbar('Limit Reached', 'Maximum 10 media files allowed', snackPosition: SnackPosition.BOTTOM);
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: remainingMedia > 0 ? AppColor.primary.withOpacity(0.3) : const Color(0xFFE5E7EB)),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Iconsax.gallery_add, color: remainingMedia > 0 ? AppColor.primary : const Color(0xFF9CA3AF), size: 22.w),
          SizedBox(height: 6.h),
          Text('Photos', style: TextStyle(fontSize: 10.sp, color: remainingMedia > 0 ? AppColor.primary : const Color(0xFF9CA3AF), fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  Widget _buildAddVideoButton(int remainingMedia) {
    return GestureDetector(
      onTap: () {
        if (remainingMedia > 0) _controller.pickGalleryVideo();
        else Get.snackbar('Limit Reached', 'Maximum 10 media files allowed', snackPosition: SnackPosition.BOTTOM);
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.3)),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Iconsax.video_add, color: const Color(0xFF22C55E), size: 22.w),
          SizedBox(height: 6.h),
          Text('Video', style: TextStyle(fontSize: 10.sp, color: const Color(0xFF22C55E), fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  Widget _buildVideoGridItem(int index) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1D2E),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Iconsax.video, color: Colors.white, size: 24.w),
              SizedBox(height: 4.h),
              Text('Video', style: TextStyle(fontSize: 9.sp, color: Colors.white70)),
            ]),
          ),
        ),
        Positioned(
          top: 4.w, right: 4.w,
          child: GestureDetector(
            onTap: () => _controller.removeGalleryVideo(index),
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              padding: EdgeInsets.all(3.w),
              child: Icon(Icons.close, size: 11.w, color: const Color(0xFFEF4444)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExistingImageGridItem(String imageUrl, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.r),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            width: double.infinity, height: double.infinity,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(color: const Color(0xFFF3F4F6),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2.w, color: AppColor.primary))),
            errorWidget: (_, __, ___) => Container(color: const Color(0xFFF3F4F6),
                child: Icon(Icons.broken_image, color: const Color(0xFF9CA3AF))),
          ),
        ),
        Positioned(
          top: 4.w, right: 4.w,
          child: GestureDetector(
            onTap: () => _controller.removeGalleryImageUrl(index),
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              padding: EdgeInsets.all(3.w),
              child: Icon(Icons.close, size: 11.w, color: const Color(0xFFEF4444)),
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
          borderRadius: BorderRadius.circular(10.r),
          child: Image.file(
            _controller.galleryImages[index],
            width: double.infinity, height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: const Color(0xFFF3F4F6),
                child: Icon(Icons.broken_image, color: const Color(0xFF9CA3AF))),
          ),
        ),
        Positioned(
          top: 4.w, right: 4.w,
          child: GestureDetector(
            onTap: () => _controller.removeGalleryImage(index),
            child: Container(
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              padding: EdgeInsets.all(3.w),
              child: Icon(Icons.close, size: 11.w, color: const Color(0xFFEF4444)),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== LOCATION TAB (Google Maps) ====================
  Widget _buildLocationTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            title: 'Property Location',
            icon: Iconsax.location,
            children: [
              Text('Search or pin the exact location on the map',
                  style: TextStyle(fontSize: 12.sp, color: const Color(0xFF6B7280))),
              SizedBox(height: 14.h),

              // Search bar
              _buildFormField(
                label: 'Search Address',
                required: true,
                controller: _locationController,
                hintText: 'Search location...',
                onChanged: (v) {
                  _controller.location.value = v;
                  if (v.length > 3) _controller.searchLocation(v);
                },
                suffixIcon: Obx(() => _controller.isSearchingLocation.value
                    ? SizedBox(width: 18.w, height: 18.w, child: CircularProgressIndicator(strokeWidth: 2.w, color: AppColor.primary))
                    : Icon(Iconsax.search_normal, size: 18.w, color: const Color(0xFF9CA3AF))),
                validator: (v) => v == null || v.isEmpty ? 'Location is required' : null,
              ),

              // Search results
              Obx(() {
                if (_controller.locationSearchResults.isNotEmpty) {
                  return Container(
                    margin: EdgeInsets.only(top: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      children: _controller.locationSearchResults.map((place) => InkWell(
                        onTap: () {
                          _controller.selectSearchLocation(place);
                          _locationController.text = place.address.isNotEmpty ? place.address : place.name;
                          // Move Google Map
                          _googleMapController?.animateCamera(
                            CameraUpdate.newLatLngZoom(
                              LatLng(_controller.latitude.value, _controller.longitude.value), 15,
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                          child: Row(children: [
                            Icon(Iconsax.location, size: 16.w, color: AppColor.primary),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(place.name, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: const Color(0xFF1A1D2E))),
                                if (place.address.isNotEmpty)
                                  Text(place.address, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF6B7280)), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ]),
                            ),
                          ]),
                        ),
                      )).toList(),
                    ),
                  );
                }
                return const SizedBox();
              }),

              SizedBox(height: 16.h),

              // Google Map
              ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: SizedBox(
                  height: 260.h,
                  child: Obx(() => GoogleMap(
                    onMapCreated: (ctrl) {
                      _googleMapController = ctrl;
                    },
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_controller.latitude.value, _controller.longitude.value),
                      zoom: 15,
                    ),
                    onTap: (point) {
                      _controller.onMapTap(point);
                      _googleMapController?.animateCamera(CameraUpdate.newLatLng(point));
                      _locationController.text = _controller.location.value;
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('selected'),
                        position: LatLng(
                          _controller.latitude.value,
                          _controller.longitude.value,
                        ),
                        infoWindow: InfoWindow(title: _controller.location.value.isNotEmpty ? _controller.location.value : 'Selected Location'),
                      ),
                    },
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    mapToolbarEnabled: false,
                  )),
                ),
              ),

              SizedBox(height: 16.h),

              // Coordinates row
              Row(children: [
                Expanded(child: _buildCoordCard('Latitude', _controller.latitude)),
                SizedBox(width: 10.w),
                Expanded(child: _buildCoordCard('Longitude', _controller.longitude)),
              ]),

              SizedBox(height: 14.h),

              // Selected location chip
              Obx(() {
                if (_controller.location.value.isEmpty) return const SizedBox();
                return Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColor.primary.withOpacity(0.2)),
                  ),
                  child: Row(children: [
                    Icon(Iconsax.location_tick, color: AppColor.primary, size: 18.w),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(_controller.location.value,
                          style: TextStyle(fontSize: 13.sp, color: const Color(0xFF1A1D2E)), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                );
              }),

              SizedBox(height: 14.h),

              // Use current location button
              GestureDetector(
                onTap: () async {
                  await _controller.getCurrentLocation();
                  _locationController.text = _controller.location.value;
                  _googleMapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(_controller.latitude.value, _controller.longitude.value), 15,
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Iconsax.gps, size: 18.w, color: Colors.white),
                    SizedBox(width: 8.w),
                    Text('Use Current Location', style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ],
          ),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  Widget _buildCoordCard(String label, RxDouble value) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 11.sp, color: const Color(0xFF9CA3AF))),
        SizedBox(height: 4.h),
        Obx(() => Text(value.value.toStringAsFixed(6),
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1A1D2E)))),
      ]),
    );
  }

  // ==================== BOTTOM BAR ====================
  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFF0F0F0))),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: ListenableBuilder(
        listenable: _tabController,
        builder: (context, _) {
          return Obx(() {
            final currentIndex = _tabController.index;
            final isLastTab = currentIndex == _tabController.length - 1;
            final isLoading = _controller.isSubmitting.value;
            return Row(children: [
              if (currentIndex > 0) ...[
                GestureDetector(
                  onTap: isLoading ? null : () {
                    _controller.currentStep.value = currentIndex;
                    _controller.previousStep();
                    _tabController.animateTo(currentIndex - 1);
                  },
                  child: Container(
                    height: 50.h,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.arrow_back_ios_new_rounded, size: 16.w, color: const Color(0xFF4B5563)),
                      SizedBox(width: 4.w),
                      Text('Back', style: TextStyle(fontSize: 14.sp, color: const Color(0xFF4B5563), fontWeight: FontWeight.w500)),
                    ]),
                  ),
                ),
                SizedBox(width: 10.w),
              ],
              Expanded(
                child: GestureDetector(
                  onTap: isLoading ? null : () {
                    _controller.currentStep.value = currentIndex;
                    if (isLastTab) {
                      _controller.submitProperty();
                    } else {
                      if (_controller.isStepValid()) {
                        _controller.nextStep();
                        _tabController.animateTo(currentIndex + 1);
                      } else {
                        final errors = _controller.validateCurrentStep();
                        if (errors.isNotEmpty) {
                          Get.snackbar('Validation Error', errors.values.first, snackPosition: SnackPosition.BOTTOM);
                        }
                      }
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: isLoading ? AppColor.primary.withOpacity(0.7) : AppColor.primary,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [BoxShadow(color: AppColor.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                    ),
                    child: Center(
                      child: isLoading
                          ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        SizedBox(width: 18.w, height: 18.w, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                        SizedBox(width: 10.w),
                        Text('Processing...', style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                      ])
                          : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(isLastTab ? Iconsax.tick_circle : Icons.arrow_forward_ios_rounded,
                            size: 16.w, color: Colors.white),
                        SizedBox(width: 8.w),
                        Text(isLastTab ? 'Submit Property' : 'Continue',
                            style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ),
                ),
              ),
            ]);
          });
        },
      ),
    );
  }

  // ==================== SHARED HELPERS ====================
  Widget _buildLabel(String label, {bool required = false}) {
    return Row(children: [
      Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
      if (required) ...[
        SizedBox(width: 3.w),
        Text(' *', style: TextStyle(color: const Color(0xFFEF4444), fontSize: 13.sp)),
      ],
    ]);
  }

  Widget _buildFormField({
    required String label,
    bool required = false,
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildLabel(label, required: required),
      SizedBox(height: 6.h),
      TextFormField(
        controller: controller,
        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF1A1D2E)),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: const Color(0xFF9CA3AF), fontSize: 13.sp),
          filled: true, fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: BorderSide(color: AppColor.primary, width: 1.5)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          prefixIcon: prefix != null ? Padding(padding: EdgeInsets.only(left: 12.w, right: 6.w), child: prefix) : null,
          prefixIconConstraints: prefix != null ? const BoxConstraints(minWidth: 0, minHeight: 0) : null,
          suffix: suffix,
          suffixIcon: suffixIcon != null ? Padding(padding: EdgeInsets.only(right: 12.w), child: suffixIcon) : null,
          suffixIconConstraints: suffixIcon != null ? const BoxConstraints(minWidth: 0, minHeight: 0) : null,
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        onChanged: onChanged,
      ),
    ]);
  }

  Widget _buildShimmerLoader({double height = 48}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      child: Container(height: height, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10.r))),
    );
  }
}