import 'package:cashback_farms/features/service/model/categories_model.dart';
import 'package:cashback_farms/features/service/model/material_unit_model.dart';
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
  var selectedStatus = ''.obs;
  var isExpanded = false.obs;
  var isDescriptionExpanded = false.obs;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
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


  @override
  void onInit() {
    fetchMaterialUnits();
    super.onInit();
  }
  TextEditingController searchController = TextEditingController();
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedSubSubCategory;
  String searchText = "";

  List<Category> categoryList = [];
  List<SubCategoriesList> subCategoryList = [];
  List<SubSubCategoriesList> subSubCategoryList = [];
  bool isSubCategoryLoading = false;
  bool isSubSubCategoryLoading = false;

  Future<void> getSubCategories(String? categoryId) async {
    if (categoryId == null) return;

    try {
      isSubCategoryLoading = true;
      subCategoryList.clear();
      selectedSubCategory = null;
      selectedSubSubCategory = null;
      subSubCategoryList.clear();
      update();

      final url = '${ApiUrl.servicesSubCategory}/$categoryId';

      final response = await ApiService.getRequest(url);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        if (data['status'] == 200) {
          List list = data['data']?['categories_list'] ?? [];
          subCategoryList = list
              .map((e) => SubCategoriesList.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      Loggers.error("SubCategory Error: $e");
    } finally {
      isSubCategoryLoading = false;
      update();
    }
  }

  Future<void> getSubSubCategories(String? subCategoryId) async {
    if (subCategoryId == null) return;

    try {
      isSubSubCategoryLoading = true;
      subSubCategoryList.clear();
      selectedSubSubCategory = null;
      update();

      final url = "${ApiUrl.servicesSubSubCategory}/$subCategoryId";

      final response = await ApiService.getRequest(url);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        if (data['status'] == 200) {
          List list = data['data']?['categories_list'] ?? [];

          subSubCategoryList = list
              .map((e) => SubSubCategoriesList.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      Loggers.error("SubSubCategory Error: $e");
    } finally {
      isSubSubCategoryLoading = false;
      update();
    }
  }

  void applyFilter({
    String? search,
    String? category,
    String? subCategory,
    String? subSubCategory,
  }) {
    searchText = search ?? "";
    selectedCategory = category;
    selectedSubCategory = subCategory;
    selectedSubSubCategory = subSubCategory;

    getCategoriesServiceList(isInitialLoad: true);
  }

  void clearFilter() {
    searchText = "";
    selectedCategory = null;
    selectedSubCategory = null;
    selectedSubSubCategory = null;

    getCategoriesServiceList(isInitialLoad: true);
  }


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
      String url = "${ApiUrl.servicesList}?page_no=$categoriesServiceCurrentPage";

      if (searchText.isNotEmpty) {
        url += "&search=$searchText";
      }
      if (selectedCategory != null) {
        url += "&category=$selectedCategory";
      }
      if (selectedSubCategory != null) {
        url += "&sub_category=$selectedSubCategory";
      }
      if (selectedSubSubCategory != null) {
        url += "&sub_sub_category=$selectedSubSubCategory";
      }

      final response = await ApiService.getRequest(url);
      if (response.data != null) {
        final data = response.data['data'];
        if (data == null) {
          return;
        }
        categoriesServiceTotalPages = data['pagination']?['last_page'] ?? 1;
        List list = data['services'] ?? [];
        List categoriesList = data['categories_list'] ?? [];
        categoryList = categoriesList.map((e) => Category.fromJson(e)).toList();
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
  List<Brand>? brandList;

  bool isVendorDetailLoading = false;

  Future<void> fetchVendorDetail({required String id}) async {
    try {
      isVendorDetailLoading = true;
      update();

      final url = "${ApiUrl.vendorDetails}/$id";
      final response = await ApiService.getRequest(url);

      if (response.data != null && response.data['status'] == true) {
        vendorDetail = Vendor.fromJson(response.data['data']);

        if (response.data['brands'] != null) {
          brandList = (response.data['brands'] as List)
              .map((e) => Brand.fromJson(e))
              .toList();
        } else {
          brandList = [];
        }
      } else {
        vendorDetail = null;
      }
      update();
    } catch (e) {
      Loggers.error('Vendor Details Error :: $e');
    } finally {
      isVendorDetailLoading = false;
      update();
    }
  }

  double selectedRating = 0;
  TextEditingController reviewController = TextEditingController();
  bool isSubmittingReview = false;

  Future<void> submitReview({
    required String vendorId,
  }) async {
    if (selectedRating == 0) {
      SnackBarHelper.showInfo('Please select rating');
      return;
    }
    if (reviewController.text.trim().isEmpty) {
      SnackBarHelper.showInfo('Please write review');
      return;
    }
    try {
      isSubmittingReview = true;
      update();
      final String? token = await SessionManager.getToken();

      Map<String, dynamic> data = {
        "vendor_id": vendorId,
        "rating": selectedRating,
        "review": reviewController.text,
      };
      final response = await ApiService.postRequestWithToken(ApiUrl.submitReview, data: data, token: token??'',);
      if(response.statusCode == 200 || response.statusCode == 201){
        final data = response.data;
        if(data !=null){
          if(data['status'] == true){
            SnackBarHelper.showSuccess('Review submitted Successfully');
            selectedRating = 0;
            reviewController.clear();
            await fetchVendorDetail(id: vendorId);
          }
        }
      }else{
        SnackBarHelper.showError('Something went wrong');
      }
    } catch (e) {
      SnackBarHelper.showError('Something went wrong');
    } finally {
      isSubmittingReview = false;
      update();
    }
  }

  TextEditingController quoteController = TextEditingController();
  String? selectedDate;
  String? selectedTime;
  bool isSubmittingEnquiry = false;

  Future<void> submitEnquiry({
    required String serviceId,
  }) async {
    if (quoteController.text.trim().isEmpty) {
      SnackBarHelper.showInfo('Please enter your requirement');
      return;
    }

    if (selectedDate == null) {
      SnackBarHelper.showInfo('Please select date');
      return;
    }

    if (selectedTime == null) {
      SnackBarHelper.showInfo('Please select time');
      return;
    }

    try {
      isSubmittingEnquiry = true;
      update();

      final String? token = await SessionManager.getToken();
      final userId = await SessionManager.getUserId();

      Map<String, dynamic> data = {
        "service_id": serviceId,
        "quote": quoteController.text,
        "date_preference": selectedDate,
        "time_preference": selectedTime,
        "user_id": userId,
      };

      final response = await ApiService.postRequestWithToken(
        ApiUrl.submitServiceEnquiry,
        data: data,
        token: token ?? '',
      );

      final resData = response.data;

      if (response.statusCode == 200) {
        if (resData != null && resData['status'] == true) {
          Get.back();
          Future.delayed(const Duration(milliseconds: 200), () {
            SnackBarHelper.showSuccess(
              resData['message'] ?? 'Enquiry submitted successfully',
            );
          });
          quoteController.clear();
          selectedDate = null;
          selectedTime = null;
        } else {
          SnackBarHelper.showError(
            resData?['message'] ?? 'Failed',
          );
        }

      } else if (response.statusCode == 409) {
        SnackBarHelper.showError(
          resData?['message'] ?? 'Already submitted',
        );
      } else {
        SnackBarHelper.showError('Something went wrong');
      }

    } catch (e) {
      SnackBarHelper.showError('Something went wrong');
    } finally {
      isSubmittingEnquiry = false;
      update();
    }
  }

  List<MaterialUnitModel> materialUnits = [];
  bool isUnitLoading = false;

  Future<void> fetchMaterialUnits() async {
    try {
      isUnitLoading = true;
      update();

      final response = await ApiService.getRequest(
        ApiUrl.materialUnit,
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null && data['status'] == true) {
          materialUnits = (data['data'] as List)
              .map((e) => MaterialUnitModel.fromJson(e))
              .toList();
        }
      } else {
        SnackBarHelper.showError('Failed to load units');
      }
    } catch (e) {
      SnackBarHelper.showError('Something went wrong');
    } finally {
      isUnitLoading = false;
      update();
    }
  }

  TextEditingController productQuoteController = TextEditingController();
  TextEditingController quantityController = TextEditingController(text: "1");
  int quantity = 1;
  String? selectedUnit;


  Future<void> submitProductEnquiry({
    required String materialId,
  }) async {

    if (productQuoteController.text.trim().isEmpty) {
      SnackBarHelper.showInfo('Please enter your requirement');
      return;
    }

    if (selectedUnit == null) {
      SnackBarHelper.showInfo('Please select unit');
      return;
    }

    try {
      isSubmittingEnquiry = true;
      update();

      final String? token = await SessionManager.getToken();
      final userId = await SessionManager.getUserId();

      Map<String, dynamic> data = {
        "material_id": materialId,
        "requirement": productQuoteController.text,
        "unit_id": selectedUnit,
        "quantity": quantity,
        "user_id": userId,
      };

      final response = await ApiService.postRequestWithToken(
        ApiUrl.submitMaterialEnquiry,
        data: data,
        token: token ?? '',
      );

      final resData = response.data;

      if(response.statusCode == 200 || response.statusCode == 201){
        if (resData != null && resData['status'] == true) {
          Get.back();

          Future.delayed(const Duration(milliseconds: 200), () {
            SnackBarHelper.showSuccess(
              resData['message'] ?? 'Enquiry sent successfully',
            );
          });

          productQuoteController.clear();
          quantity = 1;
          quantityController.text = "1";
          selectedUnit = null;
        } else {
          SnackBarHelper.showError(resData?['message'] ?? 'Failed');
        }
      }else if (response.statusCode == 409) {
        SnackBarHelper.showError(
          resData?['message'] ?? 'Already submitted',
        );
      } else {
        SnackBarHelper.showError('Something went wrong');
      }
    } catch (e) {
      SnackBarHelper.showError('Something went wrong');
    } finally {
      isSubmittingEnquiry = false;
      update();
    }
  }














  //////////////////////////////////////////////////////////////////////////////////////////////////


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