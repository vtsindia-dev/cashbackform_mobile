import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../common/colours.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/toster.dart';
import '../controller/plot_market_controller.dart';
import '../model/plot_market.dart';

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
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _unitSplitController = TextEditingController();
  final TextEditingController _uldNoController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _workController = TextEditingController();
  final TextEditingController _amenitiesController = TextEditingController();

  List<File> _selectedImages = [];
  List<String> _existingImageUrls = [];
  File? _plotImage;
  File? _bluePrint;
  String? _existingPlotImageUrl;
  String? _existingBluePrintUrl;
  List<String> _amenitiesList = [];
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _prefillData();
  }

  void _prefillData() {
    if (widget.plot != null) {
      _nameController.text = widget.plot?.name?.toString() ?? '';
      _typeController.text = widget.plot?.type?.toString() ?? '';
      _stateController.text = widget.plot?.state?.stateName ?? '';
      _cityController.text = widget.plot?.city?.cityName ?? '';
      _areaController.text = widget.plot?.area?.toString() ?? '';
      _priceController.text = widget.plot?.price?.toString() ?? '';
      _latController.text = widget.plot?.lat?.toString() ?? '';
      _longController.text = widget.plot?.long?.toString() ?? '';
      _descriptionController.text = widget.plot?.description ?? '';
      _unitSplitController.text = widget.plot?.unitSplit?.toString() ?? '';
      _addressController.text = widget.plot?.address ?? '';
      _workController.text = widget.plot?.work ?? '';
      _uldNoController.text = widget.plot?.area?.toString() ?? '';

      if (widget.plot is MarketPlotDetail) {
        final detail = widget.plot as MarketPlotDetail;
        _amenitiesList = detail.aminities.isNotEmpty
            ? detail.aminities.split(',').map((e) => e.trim()).toList()
            : [];
        _existingImageUrls = detail.images ?? [];
        _existingPlotImageUrl = detail.plotImage;
        _existingBluePrintUrl = detail.plotImage;
      }
    }
    _amenitiesController.text = _amenitiesList.join(', ');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _areaController.dispose();
    _priceController.dispose();
    _latController.dispose();
    _longController.dispose();
    _descriptionController.dispose();
    _unitSplitController.dispose();
    _uldNoController.dispose();
    _addressController.dispose();
    _workController.dispose();
    _amenitiesController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((e) => File(e.path)));
      });
    }
  }

  Future<void> _pickPlotImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _plotImage = File(image.path);
      });
    }
  }

  Future<void> _pickBluePrint() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _bluePrint = File(image.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      SnackBarHelper.showError('Please fill all required fields');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Prepare form data
      Map<String, dynamic> formData = {
        'name': _nameController.text.trim(),
        'type': _typeController.text.trim(),
        'state': _stateController.text.trim(),
        'city': _cityController.text.trim(),
        'area': _areaController.text.trim(),
        'price': _priceController.text.trim(),
        'lat': _latController.text.trim(),
        'long': _longController.text.trim(),
        'description': _descriptionController.text.trim(),
        'unit_split': _unitSplitController.text.trim(),
        'address': _addressController.text.trim(),
        'work': _workController.text.trim(),
        'uld_no': _uldNoController.text.trim(),
        'amenities': _amenitiesList.join(', '),
        'images[]': _existingImageUrls,
      };

      // Add plot ID for update
      if (widget.plot != null) {
        formData['id'] = widget.plot.id.toString();
      }

      // Call controller submit method
      final result = await controller.submitMarketPlot(
        formData: formData,
        images: _selectedImages,
        plotImage: _plotImage,
        bluePrint: _bluePrint,
        isUpdate: widget.plot != null,
      );

      if (result['status'] == 200) {
        SnackBarHelper.showSuccess(
            result['message'] ??
                (widget.plot != null ? 'Plot updated successfully' : 'Plot added successfully')
        );
        Get.back(result: true);
      } else {
        SnackBarHelper.showError(
            result['message'] ??
                'Failed to ${widget.plot != null ? 'update' : 'add'} plot'
        );
      }
    } catch (e) {
      SnackBarHelper.showError('Error submitting form: $e');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        TextInputType keyboardType = TextInputType.text,
        bool isRequired = false,
        int maxLines = 1,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (isRequired ? ' *' : ''),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColor.textMain,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColor.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: AppColor.primarylite),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: AppColor.primarylite),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(color: AppColor.primary, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
            ),
            validator: (value) {
              if (isRequired && (value == null || value.trim().isEmpty)) {
                return 'This field is required';
              }
              return null;
            },
          ),
        ),
      ].animate().fade(duration: 300.ms).scale(begin: const Offset(0.95, 0.95)),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: AppColor.primary,
      ),
    ).animate().fade(duration: 400.ms).slide(begin: const Offset(0, 0.05));
  }

  Widget _buildAmenitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Amenities'),
        SizedBox(height: 8.h),
        if (_amenitiesList.isNotEmpty)
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _amenitiesList.map((amenity) {
              return Chip(
                label: Text(
                  amenity,
                  style: TextStyle(fontSize: 12.sp),
                ),
                deleteIcon: Icon(Icons.close, size: 16.sp),
                onDeleted: () => setState(() => _amenitiesList.remove(amenity)),
                backgroundColor: AppColor.primarylite.withOpacity(0.2),
              );
            }).toList(),
          ),
        if (_amenitiesList.isNotEmpty) SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _amenitiesController,
                decoration: InputDecoration(
                  hintText: 'Add an amenity',
                  filled: true,
                  fillColor: AppColor.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: AppColor.primarylite),
                  ),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    setState(() {
                      _amenitiesList.add(value.trim());
                      _amenitiesController.clear();
                    });
                  }
                },
              ),
            ),
            SizedBox(width: 8.w),
            ElevatedButton(
              onPressed: () {
                if (_amenitiesController.text.trim().isNotEmpty) {
                  setState(() {
                    _amenitiesList.add(_amenitiesController.text.trim());
                    _amenitiesController.clear();
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
              child: Icon(Icons.add, size: 20.sp, color: AppColor.white),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePickerSection({
    required String title,
    required File? imageFile,
    required String? existingImageUrl,
    required VoidCallback onPickImage,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(title),
        SizedBox(height: 12.h),
        GestureDetector(
          onTap: onPickImage,
          child: Container(
            width: double.infinity,
            height: 150.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: AppColor.white,
              border: Border.all(color: AppColor.primarylite, width: 2),
            ),
            child: imageFile != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.file(imageFile, fit: BoxFit.cover),
            )
                : existingImageUrl != null && existingImageUrl.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(existingImageUrl, fit: BoxFit.cover),
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_photo_alternate,
                    size: 40.sp, color: AppColor.primary),
                SizedBox(height: 8.h),
                Text(
                  hintText ?? 'Tap to add image',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColor.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if ((imageFile != null || existingImageUrl != null) && existingImageUrl != null)
          TextButton(
            onPressed: () {
              setState(() {
                if (title == 'Plot Image') {
                  _plotImage = null;
                } else if (title == 'Blueprint') {
                  _bluePrint = null;
                }
              });
            },
            child: Text(
              'Remove Image',
              style: TextStyle(
                color: AppColor.orangeAccent,
                fontSize: 12.sp,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMultiImagePickerSection() {
    List<Widget> existingImages = _existingImageUrls.map((url) {
      return _buildImageCard(
        imageFile: null,
        imageUrl: url,
        onDelete: () {
          setState(() {
            _existingImageUrls.remove(url);
          });
        },
      );
    }).toList();

    List<Widget> selectedImages = _selectedImages.map((file) {
      return _buildImageCard(
        imageFile: file,
        imageUrl: null,
        onDelete: () {
          setState(() {
            _selectedImages.remove(file);
          });
        },
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Additional Images'),
        SizedBox(height: 12.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [...existingImages, ...selectedImages],
          ),
        ),
        SizedBox(height: 12.h),
        ElevatedButton.icon(
          onPressed: _pickImages,
          icon: Icon(Icons.photo_library, size: 18.sp),
          label: Text('Select Images'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primarylite,
            foregroundColor: AppColor.white,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
        ),
      ],
    );
  }

  Widget _buildImageCard(
      {File? imageFile, String? imageUrl, required VoidCallback onDelete}) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: Stack(
        children: [
          Container(
            width: 90.w,
            height: 90.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              color: AppColor.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: imageFile != null
                  ? Image.file(imageFile, fit: BoxFit.cover)
                  : (imageUrl != null
                  ? Image.network(imageUrl, fit: BoxFit.cover)
                  : Container()),
            ),
          ),
          Positioned(
            top: 4.w,
            right: 4.w,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: EdgeInsets.all(4.r),
                decoration: const BoxDecoration(
                  color: AppColor.orange,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, size: 14.sp, color: AppColor.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: DynamicAppBar(
        title: widget.plot != null ? 'Edit Plot' : 'Add Plot',
        showBackButton: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Basic Information'),
              SizedBox(height: 12.h),
              _buildTextField('Plot Name', _nameController, isRequired: true),
              SizedBox(height: 12.h),
              _buildTextField('Type', _typeController, isRequired: true),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('State', _stateController, isRequired: true),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildTextField('City', _cityController, isRequired: true),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _buildTextField('Full Address', _addressController,
                  maxLines: 2, isRequired: true),
              SizedBox(height: 12.h),
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
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Latitude',
                      _latController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildTextField(
                      'Longitude',
                      _longController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              _buildSectionTitle('Description'),
              SizedBox(height: 12.h),
              _buildTextField('Description', _descriptionController,
                  maxLines: 4, isRequired: true),
              SizedBox(height: 20.h),
              _buildSectionTitle('Additional Details'),
              SizedBox(height: 12.h),
              _buildTextField('Work Status', _workController),
              SizedBox(height: 12.h),
              _buildTextField('Unit Split', _unitSplitController),
              SizedBox(height: 12.h),
              _buildTextField('ULD Number', _uldNoController),
              SizedBox(height: 20.h),
              _buildAmenitiesSection(),
              SizedBox(height: 20.h),
              _buildImagePickerSection(
                title: 'Plot Image',
                imageFile: _plotImage,
                existingImageUrl: _existingPlotImageUrl,
                onPickImage: _pickPlotImage,
                hintText: 'Tap to add plot image',
              ),
              SizedBox(height: 20.h),
              _buildImagePickerSection(
                title: 'Blueprint',
                imageFile: _bluePrint,
                existingImageUrl: _existingBluePrintUrl,
                onPickImage: _pickBluePrint,
                hintText: 'Tap to add blueprint',
              ),
              SizedBox(height: 20.h),
              _buildMultiImagePickerSection(),
              SizedBox(height: 30.h),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  minimumSize: Size(double.infinity, 50.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: _isSubmitting
                    ? SizedBox(
                  height: 20.h,
                  width: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColor.white,
                  ),
                )
                    : Text(
                  widget.plot != null ? 'Update Plot' : 'Add Plot',
                  style: TextStyle(
                    color: AppColor.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ).animate().fade(duration: 400.ms).slide(begin: const Offset(0, 0.05)),
        ),
      ),
    );
  }
}