// lib/features/service/controllers/service_controller.dart
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/api_constant.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';
import '../model/service_model.dart';

import 'package:flutter/material.dart';

class ServiceController extends GetxController {
  var isLoading = false.obs;
  var isLoadMore = false.obs;
  var isLoadingDetail = false.obs;
  var isSubmitting = false.obs;
  var _isLoadingMore = false;
  var _isLoadingInProgress = false;

  var vendors = <Vendor>[].obs; // For service providers/vendors
  var materialEnquiries = <MaterialEnquiry>[].obs;
  var serviceEnquiries = <ServiceEnquiry>[].obs;

  // Detail data
  var vendorDetail = Rxn<Vendor>();
  var errorMessage = ''.obs;

  // Pagination
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalItems = 0.obs;
  var hasMoreData = true.obs;

  // Filters
  var searchQuery = ''.obs;
  var selectedCategory = ''.obs;
  var selectedStatus = ''.obs;

  // UI states
  var isExpanded = false.obs;
  var isDescriptionExpanded = false.obs;

  // Form controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final quoteController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();

  // Form errors
  var nameError = RxString('');
  var phoneError = RxString('');
  var quoteError = RxString('');
  var dateError = RxString('');
  var timeError = RxString('');

  // Selected IDs
  var materialId = 0.obs;
  var serviceId = 0.obs;
  var vendorId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Uncomment as needed
    // fetchVendors();
    // fetchMaterialEnquiries();
    // fetchServiceEnquiries();
  }

  // ==================== UI Helper Methods ====================
  void toggleExpansion() => isExpanded.value = !isExpanded.value;
  void toggleDescription() => isDescriptionExpanded.value = !isDescriptionExpanded.value;

  // ==================== Vendor/Service Provider Methods ====================
  Future<void> fetchVendors({bool loadMore = false}) async {
    try {
      if ((isLoading.value && !loadMore) || (isLoadMore.value && loadMore)) {
        return;
      }

      if (loadMore) {
        if (!hasMoreData.value) return;
        isLoadMore(true);
      } else {
        isLoading(true);
        currentPage.value = 1;
        hasMoreData.value = true;
      }

      final url = '${ApiUrl.vendorList}?page=${currentPage.value}${_buildQueryParams()}';
      print('🌐 Fetching Vendors URL: $url');

      final response = await ApiService.getRequest(url);

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData != null &&
            responseData['data'] != null) {

          final vendorsData = responseData['data'];
          final paginationData = responseData['pagination'] ?? {};

          final List<Vendor> fetchedVendors = _parseVendors(vendorsData);

          if (loadMore) {
            final newVendors = fetchedVendors.where((newVendor) =>
            !vendors.any((existingVendor) => existingVendor.id == newVendor.id)
            ).toList();
            vendors.addAll(newVendors);
          } else {
            vendors.assignAll(fetchedVendors);
          }

          currentPage.value = paginationData['current_page'] ?? 1;
          totalPages.value = paginationData['last_page'] ?? 1;
          totalItems.value = paginationData['total'] ?? 0;
          hasMoreData.value = currentPage.value < totalPages.value;

          print('✅ Fetched ${vendors.length} vendors');
          print('📄 Current page: $currentPage, Total pages: $totalPages');
        } else {
          SnackBarHelper.showError("Invalid response format from server");
        }
      } else {
        final errorMsg = response.data?['message'] ?? 'Failed to fetch vendors';
        SnackBarHelper.showError("Error: $errorMsg");
      }
    } catch (e) {
      SnackBarHelper.showError("Network error: $e");
      print('❌ Network error: $e');
    } finally {
      isLoading(false);
      isLoadMore(false);
    }
  }

  Future<void> loadMoreVendors() async {
    if (_isLoadingMore || !hasMoreData.value || isLoadMore.value || isLoading.value) {
      return;
    }
    _isLoadingMore = true;
    currentPage.value++;
    await fetchVendors(loadMore: true);
    _isLoadingMore = false;
  }

  Future<void> fetchVendorDetail(int id) async {
    try {
      _clearDetailData();
      isLoadingDetail(true);
      errorMessage('');

      final url = '${ApiUrl.vendorDetails}/$id';
      print('🌐 Fetching Vendor Detail URL: $url');

      final response = await ApiService.getRequest(url);

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          vendorDetail.value = Vendor.fromJson(responseData['data']);
          print('✅ Fetched Vendor detail: ${vendorDetail.value?.name}');
        } else {
          errorMessage('Invalid response format from server');
          SnackBarHelper.showError("Invalid response format");
        }
      } else if (response.statusCode == 404) {
        errorMessage('Vendor details not found');
        SnackBarHelper.showError("Vendor details not found");
      } else {
        final errorMsg = response.data?['message'] ?? 'Failed to fetch vendor details';
        errorMessage(errorMsg);
        SnackBarHelper.showError("Error: $errorMsg");
      }
    } catch (e) {
      errorMessage('Network error: $e');
      SnackBarHelper.showError("Network error: $e");
      print('❌ Network error: $e');
    } finally {
      isLoadingDetail(false);
    }
  }

  // ==================== Material Enquiry Methods ====================
  Future<void> fetchMaterialEnquiries({bool loadMore = false}) async {
    try {
      if ((isLoading.value && !loadMore) || (isLoadMore.value && loadMore)) {
        return;
      }

      if (loadMore) {
        if (!hasMoreData.value) return;
        isLoadMore(true);
      } else {
        isLoading(true);
        currentPage.value = 1;
        hasMoreData.value = true;
        materialEnquiries.clear();
      }

      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        SnackBarHelper.showError('Please login to view enquiries');
        return;
      }

      final url = '${ApiUrl.materialEnquiryList}?page=${currentPage.value}';
      print('🌐 Fetching Material Enquiries URL: $url');

      final response = await ApiService.getAuthenticatedRequest(url, token);

      if (response.statusCode == 200 && response.data != null) {
        final result = MaterialEnquiryResponse.fromJson(response.data);

        if (loadMore) {
          materialEnquiries.addAll(result.data.materialEnquiry);
        } else {
          materialEnquiries.assignAll(result.data.materialEnquiry);
        }

        currentPage.value = result.data.pagination.currentPage;
        totalPages.value = result.data.pagination.lastPage;
        totalItems.value = result.data.pagination.total;
        hasMoreData.value = currentPage.value < totalPages.value;

        print('✅ Fetched ${materialEnquiries.length} material enquiries');
      } else {
        SnackBarHelper.showError('Failed to load enquiries');
      }
    } catch (e) {
      SnackBarHelper.showError('Failed to load enquiries: $e');
      print('❌ fetchMaterialEnquiries error: $e');
    } finally {
      isLoading(false);
      isLoadMore(false);
    }
  }

  Future<Map<String, dynamic>> submitMaterialEnquiry(MaterialEnquiryPayload payload) async {
    if (!_validateMaterialEnquiryForm()) {
      return {
        'success': false,
        'message': 'Please fix all errors',
        'status': 400
      };
    }

    try {
      isSubmitting(true);
      errorMessage('');

      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        SnackBarHelper.showError('Please login to submit enquiry');
        return {
          'success': false,
          'message': 'Authentication required',
          'status': 401
        };
      }

      final response = await ApiService.postRequest(
        ApiUrl.submitMaterialEnquiry,
        payload.toJson(),
        // token: token,
      );

      print('📤 Material Enquiry Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        final success = responseData['success'] ?? true;
        final message = responseData['message'] ?? 'Enquiry submitted successfully';

        if (success) {
          SnackBarHelper.showSuccess(message);
          _clearMaterialEnquiryForm();
          return {
            'success': true,
            'message': message,
            'status': response.statusCode,
            'data': responseData
          };
        } else {
          errorMessage.value = message;
          SnackBarHelper.showError(message);
          return {
            'success': false,
            'message': message,
            'status': response.statusCode ?? 400,
          };
        }
      } else {
        final errorMsg = response.data?['message'] ?? 'Failed to submit enquiry';
        errorMessage.value = errorMsg;
        SnackBarHelper.showError(errorMsg);
        return {
          'success': false,
          'message': errorMsg,
          'status': response.statusCode ?? 500,
        };
      }
    } catch (e) {
      print('❌ Material Enquiry Error: $e');
      final errorMsg = 'Network error: ${e.toString()}';
      errorMessage.value = errorMsg;
      SnackBarHelper.showError('Failed to submit enquiry');
      return {
        'success': false,
        'message': errorMsg,
        'status': 500,
      };
    } finally {
      isSubmitting(false);
    }
  }

  // ==================== Service Enquiry Methods ====================
  Future<void> fetchServiceEnquiries({bool loadMore = false}) async {
    try {
      if ((isLoading.value && !loadMore) || (isLoadMore.value && loadMore)) {
        return;
      }

      if (loadMore) {
        if (!hasMoreData.value) return;
        isLoadMore(true);
      } else {
        isLoading(true);
        currentPage.value = 1;
        hasMoreData.value = true;
        serviceEnquiries.clear();
      }

      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        SnackBarHelper.showError('Please login to view enquiries');
        return;
      }

      final url = '${ApiUrl.serviceEnquiryList}?page=${currentPage.value}';
      print('🌐 Fetching Service Enquiries URL: $url');

      final response = await ApiService.getAuthenticatedRequest(url, token);

      if (response.statusCode == 200 && response.data != null) {
        final result = ServiceEnquiryResponse.fromJson(response.data);

        if (loadMore) {
          serviceEnquiries.addAll(result.data.serviceEnquiry);
        } else {
          serviceEnquiries.assignAll(result.data.serviceEnquiry);
        }

        currentPage.value = result.data.pagination.currentPage;
        totalPages.value = result.data.pagination.lastPage;
        totalItems.value = result.data.pagination.total;
        hasMoreData.value = currentPage.value < totalPages.value;

        print('✅ Fetched ${serviceEnquiries.length} service enquiries');
      } else {
        SnackBarHelper.showError('Failed to load enquiries');
      }
    } catch (e) {
      SnackBarHelper.showError('Failed to load enquiries: $e');
      print('❌ fetchServiceEnquiries error: $e');
    } finally {
      isLoading(false);
      isLoadMore(false);
    }
  }

  Future<Map<String, dynamic>> submitServiceEnquiry(ServiceEnquiryPayload payload) async {
    if (!_validateServiceEnquiryForm()) {
      return {
        'success': false,
        'message': 'Please fix all errors',
        'status': 400
      };
    }

    try {
      isSubmitting(true);
      errorMessage('');

      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        SnackBarHelper.showError('Please login to submit enquiry');
        return {
          'success': false,
          'message': 'Authentication required',
          'status': 401
        };
      }

      final response = await ApiService.postRequest(
        ApiUrl.submitServiceEnquiry,
        payload.toJson(),
        // token: token,
      );

      print('📤 Service Enquiry Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        final success = responseData['success'] ?? true;
        final message = responseData['message'] ?? 'Enquiry submitted successfully';

        if (success) {
          SnackBarHelper.showSuccess(message);
          _clearServiceEnquiryForm();
          return {
            'success': true,
            'message': message,
            'status': response.statusCode,
            'data': responseData
          };
        } else {
          errorMessage.value = message;
          SnackBarHelper.showError(message);
          return {
            'success': false,
            'message': message,
            'status': response.statusCode ?? 400,
          };
        }
      } else {
        final errorMsg = response.data?['message'] ?? 'Failed to submit enquiry';
        errorMessage.value = errorMsg;
        SnackBarHelper.showError(errorMsg);
        return {
          'success': false,
          'message': errorMsg,
          'status': response.statusCode ?? 500,
        };
      }
    } catch (e) {
      print('❌ Service Enquiry Error: $e');
      final errorMsg = 'Network error: ${e.toString()}';
      errorMessage.value = errorMsg;
      SnackBarHelper.showError('Failed to submit enquiry');
      return {
        'success': false,
        'message': errorMsg,
        'status': 500,
      };
    } finally {
      isSubmitting(false);
    }
  }

  // ==================== Review Methods ====================
  Future<Map<String, dynamic>> submitReview(ReviewPayload payload) async {
    try {
      isSubmitting(true);
      errorMessage('');

      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        SnackBarHelper.showError('Please login to submit review');
        return {
          'success': false,
          'message': 'Authentication required',
          'status': 401
        };
      }

      final response = await ApiService.postRequest(
        ApiUrl.submitReview,
        payload.toJson(),
        // token: token,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        final success = responseData['success'] ?? true;
        final message = responseData['message'] ?? 'Review submitted successfully';

        if (success) {
          SnackBarHelper.showSuccess(message);
          // Refresh vendor detail to show new review
          if (vendorDetail.value != null) {
            await fetchVendorDetail(vendorDetail.value!.id);
          }
          return {
            'success': true,
            'message': message,
            'status': response.statusCode,
          };
        } else {
          errorMessage.value = message;
          SnackBarHelper.showError(message);
          return {
            'success': false,
            'message': message,
            'status': response.statusCode ?? 400,
          };
        }
      } else {
        final errorMsg = response.data?['message'] ?? 'Failed to submit review';
        errorMessage.value = errorMsg;
        SnackBarHelper.showError(errorMsg);
        return {
          'success': false,
          'message': errorMsg,
          'status': response.statusCode ?? 500,
        };
      }
    } catch (e) {
      print('❌ Review Error: $e');
      errorMessage.value = 'Network error: ${e.toString()}';
      SnackBarHelper.showError('Failed to submit review');
      return {
        'success': false,
        'message': e.toString(),
        'status': 500,
      };
    } finally {
      isSubmitting(false);
    }
  }

  // ==================== Image/URL Launcher Methods ====================
  Future<void> viewImage(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty) {
        print("Viewing image: $imageUrl");
        await _launchUrl(imageUrl);
      }
    } catch (e) {
      print("Image not found: $imageUrl");
      SnackBarHelper.showError("Image not found");
    }
  }

  Future<void> _launchUrl(String url) async {
    try {
      String formattedUrl = url;
      if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
        formattedUrl = 'http://$formattedUrl';
      }
      final Uri uri = Uri.parse(formattedUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        print('Cannot launch URL: $uri');
        SnackBarHelper.showError("Cannot open the link. Please check your connection.");
      }
    } catch (e) {
      print('Error launching URL: $e');
      SnackBarHelper.showError("Failed to open link");
    }
  }

  // ==================== Form Methods ====================
  void setMaterialId(int id) {
    materialId.value = id;
    _clearMaterialEnquiryForm();
  }

  void setServiceId(int id) {
    serviceId.value = id;
    _clearServiceEnquiryForm();
  }

  void setVendorId(int id) {
    vendorId.value = id;
  }

  void _clearMaterialEnquiryForm() {
    nameController.clear();
    phoneController.clear();
    quoteController.clear();
    _clearErrors();
  }

  void _clearServiceEnquiryForm() {
    nameController.clear();
    phoneController.clear();
    quoteController.clear();
    dateController.clear();
    timeController.clear();
    _clearErrors();
  }

  void _clearErrors() {
    nameError.value = '';
    phoneError.value = '';
    quoteError.value = '';
    dateError.value = '';
    timeError.value = '';
    errorMessage.value = '';
  }

  bool _validateMaterialEnquiryForm() {
    _clearErrors();
    bool isValid = true;

    if (nameController.text.trim().isEmpty) {
      nameError.value = 'Name is required';
      isValid = false;
    } else if (nameController.text.trim().length < 2) {
      nameError.value = 'Name must be at least 2 characters';
      isValid = false;
    }

    if (phoneController.text.trim().isEmpty) {
      phoneError.value = 'Phone number is required';
      isValid = false;
    } else if (!_isValidPhoneNumber(phoneController.text.trim())) {
      phoneError.value = 'Enter a valid 10-digit phone number';
      isValid = false;
    }

    if (quoteController.text.trim().isEmpty) {
      quoteError.value = 'Enquiry message is required';
      isValid = false;
    } else if (quoteController.text.trim().length < 10) {
      quoteError.value = 'Message must be at least 10 characters';
      isValid = false;
    }

    if (materialId.value == 0) {
      errorMessage.value = 'Invalid material selection';
      isValid = false;
    }

    return isValid;
  }

  bool _validateServiceEnquiryForm() {
    _clearErrors();
    bool isValid = true;

    if (nameController.text.trim().isEmpty) {
      nameError.value = 'Name is required';
      isValid = false;
    } else if (nameController.text.trim().length < 2) {
      nameError.value = 'Name must be at least 2 characters';
      isValid = false;
    }

    if (phoneController.text.trim().isEmpty) {
      phoneError.value = 'Phone number is required';
      isValid = false;
    } else if (!_isValidPhoneNumber(phoneController.text.trim())) {
      phoneError.value = 'Enter a valid 10-digit phone number';
      isValid = false;
    }

    if (quoteController.text.trim().isEmpty) {
      quoteError.value = 'Enquiry message is required';
      isValid = false;
    } else if (quoteController.text.trim().length < 10) {
      quoteError.value = 'Message must be at least 10 characters';
      isValid = false;
    }

    if (dateController.text.trim().isEmpty) {
      dateError.value = 'Preferred date is required';
      isValid = false;
    }

    if (timeController.text.trim().isEmpty) {
      timeError.value = 'Preferred time is required';
      isValid = false;
    }

    if (serviceId.value == 0) {
      errorMessage.value = 'Invalid service selection';
      isValid = false;
    }

    return isValid;
  }

  bool _isValidPhoneNumber(String phone) {
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    return phoneRegex.hasMatch(phone);
  }

  // ==================== Filter Methods ====================
  Future<void> searchVendors(String query) async {
    searchQuery.value = query;
    await fetchVendors();
  }

  Future<void> filterByCategory(String category) async {
    selectedCategory.value = category;
    await fetchVendors();
  }

  Future<void> filterByStatus(String status) async {
    selectedStatus.value = status;
    await fetchVendors();
  }

  Future<void> clearFilters() async {
    searchQuery.value = '';
    selectedCategory.value = '';
    selectedStatus.value = '';
    await fetchVendors();
  }

  List<String> getAvailableCategories() {
    return vendors
        .map((vendor) => vendor.city?.cityName ?? '')
        .where((city) => city.isNotEmpty)
        .toSet()
        .toList();
  }

  List<String> getAvailableStatuses() {
    return ['Active', 'Inactive'];
  }

  // ==================== Helper Methods ====================
  String _buildQueryParams() {
    final params = <String>[];

    if (searchQuery.value.isNotEmpty) {
      params.add('search=${Uri.encodeComponent(searchQuery.value)}');
    }
    if (selectedCategory.value.isNotEmpty) {
      params.add('city=${Uri.encodeComponent(selectedCategory.value)}');
    }
    if (selectedStatus.value.isNotEmpty) {
      final statusValue = selectedStatus.value == 'Active' ? '1' : '0';
      params.add('status=$statusValue');
    }

    return params.isEmpty ? '' : '&${params.join('&')}';
  }

  List<Vendor> _parseVendors(dynamic vendorsData) {
    if (vendorsData is List) {
      return vendorsData.map((json) => Vendor.fromJson(json)).toList();
    }
    return [];
  }

  void _clearDetailData() {
    vendorDetail.value = null;
    errorMessage('');
  }

  // ==================== Refresh Methods ====================
  Future<void> refreshVendors() async {
    await fetchVendors(loadMore: false);
  }

  Future<void> refreshMaterialEnquiries() async {
    await fetchMaterialEnquiries(loadMore: false);
  }

  Future<void> refreshServiceEnquiries() async {
    await fetchServiceEnquiries(loadMore: false);
  }

  // ==================== Getter Methods ====================
  String getFormattedVendorName() {
    return vendorDetail.value?.name ?? 'No Name';
  }

  String getFormattedDescription() {
    return vendorDetail.value?.description ?? 'No Description';
  }

  String getFormattedStatus() {
    return vendorDetail.value?.status == 1 ? 'Active' : 'Inactive';
  }

  String getVendorImage() {
    if (vendorDetail.value?.image.isNotEmpty ?? false) {
      return vendorDetail.value!.image.first;
    }
    return 'assets/images/placeholder_vendor.png';
  }

  double getAverageRating() {
    final rating = vendorDetail.value?.reviewsAvgRating;
    if (rating != null && rating.isNotEmpty) {
      return double.tryParse(rating) ?? 0.0;
    }
    return 0.0;
  }

  int getReviewCount() {
    return vendorDetail.value?.reviewsCount ?? 0;
  }

  List<Review> getVendorReviews() {
    return vendorDetail.value?.reviews ?? [];
  }

  List<VendorMaterial> getVendorMaterials() {
    return vendorDetail.value?.vendorMaterials ?? [];
  }

  List<VendorService> getVendorServices() {
    return vendorDetail.value?.vendorServices ?? [];
  }

  // ==================== Lifecycle Methods ====================
  @override
  void onClose() {
    _clearDetailData();
    nameController.dispose();
    phoneController.dispose();
    quoteController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.onClose();
  }
}