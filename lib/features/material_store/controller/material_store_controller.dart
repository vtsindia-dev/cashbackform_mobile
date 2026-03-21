import 'package:cashback_farms/common/api_constant.dart';
import 'package:cashback_farms/common/model/logger_model.dart';
import 'package:cashback_farms/features/material_store/model/material_home_list_model.dart';
import 'package:cashback_farms/features/service/model/material_unit_model.dart';
import '../model/material_model.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';
import 'package:cashback_farms/features/auth/models/location_model.dart';


class MaterialController extends GetxController {

  var isLoading = false.obs;
  var currentPage = 1.obs;
  var hasMore = true.obs;
  var isLoadingVendors = false.obs;
  var vendors = <Vendor>[].obs;
  var isLoadingVendorDetail = false.obs;
  var enquirySuccess = false.obs;
  var enquiryError = ''.obs;
  var reviewSuccess = false.obs;
  var reviewError = ''.obs;
  var pageErrorMessage = ''.obs;
  var showSearchBar = false.obs;
  var searchQuery = ''.obs;
  var selectedImage = ''.obs;
  final SessionManager _sessionHandler = SessionManager();
////////////////////////////////////////////////////////////////////////////////////


  @override
  void onInit() {
    getCategories();
    fetchMaterialUnits();
    super.onInit();
  }


  bool isStateLoading = false;
  bool isCityLoading = false;
  List<StateModel> stateList = [];
  List<CityModel> cityList = [];
  String? selectedStateId;
  String? selectedCityId;


  Future<void> fetchStates() async {
    isStateLoading = true;
    update();
    final stateResponse =
    await ApiService.getRequest(ApiUrl.stateUrl);
    if (stateResponse.statusCode == 200) {
      StateResponse response = StateResponse.fromJson(stateResponse.data);
      stateList = response.data;
    } else {
      stateList = [];
    }
    isStateLoading = false;
    update();
  }

  Future<void> fetchCity(int cityId) async {
    isCityLoading = true;
    cityList = [];
    selectedCityId = null;
    update();
    final cityResponse = await ApiService.getRequest("${ApiUrl.cityUrl}$cityId");
    if (cityResponse.statusCode == 200) {
      CityResponse response = CityResponse.fromJson(cityResponse.data);
      cityList = response.data;
    } else {
      cityList = [];
    }
    isCityLoading = false;
    update();
  }




  TextEditingController searchController = TextEditingController();
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedSubSubCategory;
  String searchText = "";
  List<String> selectedBrandIds = [];
  List<String> selectedBrandNames = [];

  List<Category> categoryList = [];
  List<SubCategoriesList> subCategoryList = [];
  List<SubSubCategoriesList> subSubCategoryList = [];
  List<BrandList> brandList = [];


  bool isCategoryLoading = false;
  bool isSubCategoryLoading = false;
  bool isSubSubCategoryLoading = false;


  Future<void> getCategories() async {
    try {
      isCategoryLoading = true;
      categoryList.clear();
      subCategoryList.clear();
      subSubCategoryList.clear();
      selectedCategory = null;
      selectedSubCategory = null;
      selectedSubSubCategory = null;
      update();

      final url = ApiUrl.materialCategory;

      final response = await ApiService.getRequest(url);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        if (data['status'] == 200) {
          List list = data['data']?['data'] ?? [];
          categoryList = list
              .map((e) => Category.fromJson(e))
              .toList();
        }
      }
    } catch (e) {
      Loggers.error("Category Error: $e");
    } finally {
      isCategoryLoading = false;
      update();
    }
  }



  Future<void> getSubCategories(String? categoryId) async {
    if (categoryId == null) return;

    try {
      isSubCategoryLoading = true;
      subCategoryList.clear();
      selectedSubCategory = null;
      selectedSubSubCategory = null;
      subSubCategoryList.clear();
      update();

      final url = '${ApiUrl.materialSubCategory}/$categoryId';

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

      final url = "${ApiUrl.materialSubSubCategory}/$subCategoryId";

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
    required List<String> brandIds
  }) {
    searchText = search ?? "";
    selectedCategory = category;
    selectedSubCategory = subCategory;
    selectedSubSubCategory = subSubCategory;
    selectedBrandIds = brandIds;

    getMaterialServiceList(isInitialLoad: true);
  }

  void clearFilter() {
    searchText = "";
    searchController.text = "";
    selectedCategory = null;
    selectedSubCategory = null;
    selectedSubSubCategory = null;
    selectedBrandIds = [];
    selectedBrandNames = [];

    getMaterialServiceList(isInitialLoad: true);
  }

  bool isMaterialServiceLoading = false;
  int materialServiceCurrentPage = 1;
  int materialServiceTotalPages = 1;
  bool isFetchingMoreMaterialService = false;

  List<MaterialHomeListModel> materialServiceList = [];

  Future<void> resetMaterialService() async {
    materialServiceList.clear();
    materialServiceCurrentPage = 1;
    materialServiceTotalPages = 1;
    isFetchingMoreMaterialService = false;
    isMaterialServiceLoading = true;
    update();

    await getMaterialServiceList(isInitialLoad: true);
  }

  Future<void> getMaterialServiceList({bool isInitialLoad = true}) async {
    if (isInitialLoad) {
      materialServiceList.clear();
      materialServiceCurrentPage = 1;
      materialServiceTotalPages = 1;
      isMaterialServiceLoading = true;
    } else {
      isFetchingMoreMaterialService = true;
    }
    update();

    try {
      final queryParams = {
        "page_no": materialServiceCurrentPage.toString(),
        if (searchText.isNotEmpty) "material_name": searchText,
        if (selectedCategory != null) "category": selectedCategory!,
        if (selectedSubCategory != null) "sub_category": selectedSubCategory!,
        if (selectedSubSubCategory != null) "sub_sub_category": selectedSubSubCategory!,
      };

      for (var id in selectedBrandIds) {
        queryParams.putIfAbsent("brand_id[]", () => id);
      }

      final uri = Uri.parse(ApiUrl.marketList).replace(queryParameters: queryParams);

      final response = await ApiService.getRequest(uri.toString());

      if (response.data != null) {
        final data = response.data['data'];
        if (data == null) return;

        materialServiceTotalPages = data['pagination']?['last_page'] ?? 1;

        List list = data['material'] ?? [];
        List<MaterialHomeListModel> tempList = list.map((e) => MaterialHomeListModel.fromJson(e)).toList();
        List brand = data['brand_list'] ?? [];
        brandList = brand.map((e) => BrandList.fromJson(e)).toList();
        if (isInitialLoad) {
          materialServiceList = tempList;
        } else {
          materialServiceList.addAll(tempList);
        }
      }
    } catch (e) {
      Loggers.error('Error :: $e');
    }

    isMaterialServiceLoading = false;
    isFetchingMoreMaterialService = false;
    update();
  }

  void loadMoreMaterialService() {
    if (materialServiceCurrentPage < materialServiceTotalPages &&
        !isFetchingMoreMaterialService) {
      materialServiceCurrentPage++;
      getMaterialServiceList(isInitialLoad: false);
    }
  }

  void applyLocationFilter({
    String? stateId,
    String? cityId,
    required String selectedCategoryId
  }) {
    selectedStateId = stateId;
    selectedCityId = cityId;

    resetVendors(
      selectedCategoryId: selectedCategoryId,
    );
  }

  void clearLocationFilter({required String selectedCategoryId}) {
    selectedStateId = null;
    selectedCityId = null;

    resetVendors(
      selectedCategoryId: selectedCategoryId,
    );
  }

  bool isVendorLoading = false;
  int vendorCurrentPage = 1;
  int vendorTotalPages = 1;
  bool isFetchingMoreVendors = false;
  List<Vendor> vendorList = [];

  Future<void> resetVendors({required String selectedCategoryId}) async {
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
      String url = "${ApiUrl.vendorApi}?page_no=$vendorCurrentPage";

      if (selectedCategoryId.isNotEmpty) {
        url += "&product_id=$selectedCategoryId";
      }
      if (selectedStateId != null && selectedStateId!.isNotEmpty) {
        url += "&state=$selectedStateId";
      }
      if (selectedCityId != null && selectedCityId!.isNotEmpty) {
        url += "&city=$selectedCityId";
      }

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
  List<Brand>? brandDetailList;

  bool isVendorDetailLoading = false;

  Future<void> fetchVendorDetail({required String id}) async {
    try {
      isVendorDetailLoading = true;
      update();

      final url = "${ApiUrl.vendorApi}/$id";
      final response = await ApiService.getRequest(url);

      if (response.data != null && response.data['status'] == true) {
        vendorDetail = Vendor.fromJson(response.data['data']);

        if (response.data['brands'] != null) {
          brandDetailList = (response.data['brands'] as List)
              .map((e) => Brand.fromJson(e))
              .toList();
        } else {
          brandDetailList = [];
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























  /////////////////////////////////////////////



  String _buildUrlWithParams(String baseUrl, Map<String, dynamic> params) {
    if (params.isEmpty) return baseUrl;

    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    return '$baseUrl?$queryString';
  }

  Future<void> fetchMaterials({bool loadMore = false}) async {
    // try {
    //   if (!loadMore) {
    //     isLoading(true);
    //     currentPage.value = 1;
    //     hasMore.value = true;
    //
    //     pageErrorMessage.value = '';
    //   } else {
    //     if (!hasMore.value) return;
    //     currentPage.value++;
    //   }
    //
    //   // Build URL with query parameters manually
    //   final url = _buildUrlWithParams(
    //       'https://admincashback.vrikshatech.in/public/api/v2/material_list',
    //       {'page': currentPage.value}
    //   );
    //
    //   print('🌐 Fetching materials: $url');
    //
    //   final response = await ApiService.getRequest(url);
    //
    //   print('📥 Response status: ${response.statusCode}');
    //
    //   if (response.statusCode == 200) {
    //     final data = response.data;
    //     print('📦 Response data type: ${data.runtimeType}');
    //
    //     if (data != null && data is Map) {
    //       // FIXED: Proper status check
    //       if (data['status'] == 200 || data['status'] == true) {
    //         if (data['data'] != null && data['data']['material'] != null) {
    //           final materialsData = data['data']['material'] as List;
    //           final pagination = data['data']['pagination'] ?? {};
    //
    //           print('📊 Found ${materialsData.length} materials');
    //
    //           final newMaterials = materialsData
    //               .map((json) => MaterialModel.fromJson(json))
    //               .toList();
    //
    //           if (loadMore) {
    //             materials.addAll(newMaterials);
    //           } else {
    //             materials.value = newMaterials;
    //           }
    //
    //           // Update pagination
    //           final totalPages = pagination['last_page'] ?? 1;
    //           final currentPageNum = pagination['current_page'] ?? 1;
    //           hasMore.value = currentPageNum < totalPages;
    //
    //           print('✅ Total materials: ${materials.length}, Has more: ${hasMore.value}');
    //           print('📄 Current page: $currentPageNum, Total pages: $totalPages');
    //
    //           pageErrorMessage.value = '';
    //
    //         } else {
    //           if (!loadMore) {
    //             pageErrorMessage.value = 'No materials available';
    //             print('⚠️ No materials data found in response');
    //             materials.clear();
    //           }
    //         }
    //       } else {
    //         final errorMsg = data['message'] ?? 'Failed to fetch materials';
    //         if (!loadMore) {
    //           pageErrorMessage.value = errorMsg;
    //           print('❌ API returned error status: ${errorMsg}');
    //           materials.clear();
    //         }
    //       }
    //     } else {
    //       if (!loadMore) {
    //         pageErrorMessage.value = 'Invalid response format';
    //         print('❌ Invalid response format');
    //         materials.clear();
    //       }
    //     }
    //   } else {
    //     if (!loadMore) {
    //       pageErrorMessage.value = 'Failed to fetch materials';
    //       print('❌ Failed to fetch materials. Status: ${response.statusCode}');
    //       materials.clear();
    //     }
    //   }
    // } catch (e, stackTrace) {
    //   if (!loadMore) {
    //     final errorMsg = 'Network error: ${e.toString().split('\n').first}';
    //     pageErrorMessage.value = errorMsg;
    //     print('❌ Error fetching materials: $e');
    //     print('❌ Stack trace: $stackTrace');
    //     materials.clear();
    //   }
    // } finally {
    //   isLoading(false);
    // }
  }

  Future<void> fetchVendorsForMaterial(int materialId) async {
    try {
      isLoadingVendors(true);
      vendors.clear();
      pageErrorMessage.value = '';
      final url ='https://admincashback.vrikshatech.in/public/api/v2/vendor?product_id=$materialId';
      print('🌐 Fetching vendors: $url');
      final response = await ApiService.getRequest(url);
      print('📥 Vendor response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data != null && data is Map) {
          if (data['status'] == true) {
            if (data['data'] != null && data['data'] is List) {
              final vendorsData = data['data'] as List;
              vendors.value = vendorsData
                  .map((json) => Vendor.fromJson(json))
                  .toList();
              print('✅ Fetched ${vendors.length} vendors');
            } else {
              print('⚠️ No vendor data found in response');
              vendors.clear();
            }
          } else {
            final errorMsg = data['message'] ?? 'Failed to fetch sellers';
            print('❌ API returned error: $errorMsg');
            vendors.clear();
          }
        } else {
          print('❌ Invalid response format');
          vendors.clear();
        }
      } else {
        print('❌ Failed to fetch     . Status: ${response.statusCode}');
        vendors.clear();
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching vendors: $e');
      print('❌ Stack trace: $stackTrace');
      vendors.clear();
    } finally {
      isLoadingVendors(false);
    }
  }




  // Search materials
  Future<void> searchMaterials(String query) async {
    // try {
    //   searchQuery.value = query;
    //
    //   if (query.isEmpty) {
    //     await fetchMaterials();
    //     return;
    //   }
    //
    //   isLoading(true);
    //   materials.clear();
    //   pageErrorMessage.value = '';
    //
    //   final url = _buildUrlWithParams(
    //       'https://admincashback.vrikshatech.in/public/api/v2/material_list',
    //       {
    //         'page': 1,
    //         'search': query,
    //       }
    //   );
    //
    //   print('🔍 Searching materials: $url');
    //
    //   final response = await ApiService.getRequest(url);
    //
    //   if (response.statusCode == 200) {
    //     final data = response.data;
    //
    //     if (data != null && data is Map &&
    //         (data['status'] == 200 || data['status'] == true)) {
    //       if (data['data'] != null && data['data']['material'] != null) {
    //         final materialsData = data['data']['material'] as List;
    //         materials.value = materialsData
    //             .map((json) => MaterialModel.fromJson(json))
    //             .toList();
    //
    //         if (materials.isEmpty) {
    //           pageErrorMessage.value = 'No materials found for "$query"';
    //         }
    //       } else {
    //         pageErrorMessage.value = 'No materials found for "$query"';
    //         materials.clear();
    //       }
    //     } else {
    //       pageErrorMessage.value = 'Search failed';
    //       materials.clear();
    //     }
    //   } else {
    //     pageErrorMessage.value = 'Search failed';
    //     materials.clear();
    //   }
    // } catch (e) {
    //   print('❌ Error searching materials: $e');
    //   pageErrorMessage.value = 'Search error';
    //   materials.clear();
    // } finally {
    //   isLoading(false);
    // }
  }

  // Clear search
  Future<void> clearSearch() async {
    searchQuery.value = '';
    showSearchBar.value = false;
    await fetchMaterials();
  }

  // Toggle search bar
  void toggleSearchBar() {
    showSearchBar.value = !showSearchBar.value;
    if (!showSearchBar.value) {
      searchQuery.value = '';
    }
  }


  // Refresh all data
  Future<void> refreshData() async {
    await fetchMaterials();
    vendors.clear();
  }

  // Load more materials
  Future<void> loadMoreMaterials() async {
    if (hasMore.value && !isLoading.value) {
      await fetchMaterials(loadMore: true);
    }
  }


  // Clear all data
  void clearAllData() {
    vendors.clear();
    currentPage.value = 1;
    hasMore.value = true;
    enquirySuccess.value = false;
    enquiryError.value = '';
    reviewSuccess.value = false;
    reviewError.value = '';
    pageErrorMessage.value = '';
    searchQuery.value = '';
    selectedImage.value = '';
  }

  @override
  void onClose() {
    clearAllData();
    super.onClose();
  }
}