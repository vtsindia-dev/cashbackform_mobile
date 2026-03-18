import 'package:cashback_farms/features/service/model/categories_model.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/api_constant.dart';
import '../../../common/model/logger_model.dart' show Loggers;
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
  var vendors = <Vendor>[].obs;
  var materialEnquiries = <MaterialEnquiry>[].obs;
  var serviceEnquiries = <ServiceEnquiry>[].obs;
  var errorMessage = ''.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalItems = 0.obs;
  var hasMoreData = true.obs;
  var searchQuery = ''.obs;
  var selectedCategory = ''.obs;
  var selectedStatus = ''.obs;
  var isExpanded = false.obs;
  var isDescriptionExpanded = false.obs;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final quoteController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  var nameError = RxString('');
  var phoneError = RxString('');
  var quoteError = RxString('');
  var dateError = RxString('');
  var timeError = RxString('');
  var materialId = 0.obs;
  var serviceId = 0.obs;
  var vendorId = 0.obs;

  void toggleExpansion() => isExpanded.value = !isExpanded.value;
  void toggleDescription() => isDescriptionExpanded.value = !isDescriptionExpanded.value;


  bool isCategoriesServiceLoading = false;
  int categoriesServiceCurrentPage = 1;
  int categoriesServiceTotalPages = 1;
  bool isFetchingMoreCategoriesService = false;
  List<CategoriesServiceModel> categoriesServiceList = [];


  Future<void> resetCategoriesService() async {
    categoriesServiceList.clear();
    categoriesServiceCurrentPage = 1;
    categoriesServiceTotalPages = 1;
    isFetchingMoreCategoriesService = false;
    isCategoriesServiceLoading = true;
    update();
    await getCategoriesServiceList(isInitialLoad: true);
  }

  Future<void> getCategoriesServiceList({bool isInitialLoad = true}) async {
    if (isInitialLoad) {
      categoriesServiceList.clear();
      categoriesServiceCurrentPage = 1;
      categoriesServiceTotalPages = 1;
      isCategoriesServiceLoading = true;
    } else {
      isFetchingMoreCategoriesService = true;
    }
    update();

    try {
      final url = "${ApiUrl.servicesList}?page_no=$categoriesServiceCurrentPage";
      final response = await ApiService.getRequest(url);
      if (response.data != null) {
        final data = response.data['data'];
        if (data == null) {
          return;
        }
        categoriesServiceTotalPages = data['pagination']?['last_page'] ?? 1;
        List list = data['services'] ?? [];
        List<CategoriesServiceModel> tempList = list.map((e) => CategoriesServiceModel.fromJson(e)).toList();
        if (isInitialLoad) {
          categoriesServiceList = tempList;
        } else {
          categoriesServiceList.addAll(tempList);
        }
      }
    } catch (e) {
      Loggers.error('Error :: $e');
    }
    isCategoriesServiceLoading = false;
    isFetchingMoreCategoriesService = false;
    update();
  }

  void loadMoreCategoriesService() {
    if (categoriesServiceCurrentPage < categoriesServiceTotalPages &&
        !isFetchingMoreCategoriesService) {
      categoriesServiceCurrentPage++;
      getCategoriesServiceList(isInitialLoad: false);
    }
  }


  bool isVendorLoading = false;
  int vendorCurrentPage = 1;
  int vendorTotalPages = 1;
  bool isFetchingMoreVendors = false;
  List<Vendor> vendorList = [];

  Future<void> resetVendors(int? categoryId , {required String selectedCategoryId}) async {
    vendorList.clear();
    vendorCurrentPage = 1;
    vendorTotalPages = 1;
    isFetchingMoreVendors = false;
    isVendorLoading = true;
    update();

    await fetchVendors(isInitialLoad: true, selectedCategoryId: selectedCategoryId);
  }

  Future<void> fetchVendors({bool isInitialLoad = true, required String selectedCategoryId}) async {
    if (isInitialLoad) {
      vendorList.clear();
      vendorCurrentPage = 1;
      vendorTotalPages = 1;
      isVendorLoading = true;
    } else {
      isFetchingMoreVendors = true;
    }
    update();
    try {
      final url = "${ApiUrl.vendorList}?page_no=$vendorCurrentPage""${"&service_id=$selectedCategoryId"}";
      final response = await ApiService.getRequest(url);
      if (response.data != null) {
        List list = response.data['data'] ?? [];
        vendorTotalPages =
            response.data['pagination']?['last_page'] ?? 1;

        List<Vendor> tempList =
        list.map((e) => Vendor.fromJson(e)).toList();

        if (isInitialLoad) {
          vendorList = tempList;
        } else {
          final newItems = tempList.where((newItem) =>
          !vendorList.any((old) => old.id == newItem.id)).toList();
          vendorList.addAll(newItems);
        }
      }
    } catch (e) {
      Loggers.error('Vendor Error :: $e');
    }
    isVendorLoading = false;
    isFetchingMoreVendors = false;
    update();
  }

  void loadMoreVendors({required String selectedCategoryId}) {
    if (vendorCurrentPage < vendorTotalPages &&
        !isFetchingMoreVendors) {
      vendorCurrentPage++;
      fetchVendors(isInitialLoad: false, selectedCategoryId: selectedCategoryId);
    }
  }


  Vendor? vendorDetail;
  bool isVendorDetailLoading = false;

  Future<void> fetchVendorDetail({required String id}) async {
    try {
      isVendorDetailLoading = true;
      update();

      final url = "${ApiUrl.vendorDetails}/$id";
      final response = await ApiService.getRequest(url);

      if (response.data != null && response.data['status'] == true) {
        vendorDetail = Vendor.fromJson(response.data['data']);
        print('vendorDetail ==> ${vendorDetail?.address}');
      } else {
        vendorDetail = null;
      }

    } catch (e) {
      Loggers.error('Vendor Details Error :: $e');
    } finally {
      isVendorDetailLoading = false;
      update();
    }
  }




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
    } else if (phoneController.text.trim().length != 10) {
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
    } else if (phoneController.text.trim().length != 10) {
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



  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    quoteController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.onClose();
  }
}