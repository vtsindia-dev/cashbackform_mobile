import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';
import '../model/material_store.dart';

class MaterialController extends GetxController {

  var isLoading = false.obs;
  var materials = <MaterialModel>[].obs;
  var currentPage = 1.obs;
  var hasMore = true.obs;
  var isLoadingVendors = false.obs;
  var vendors = <Vendor>[].obs;
  var isLoadingVendorDetail = false.obs;
  var vendorDetail = Rxn<Vendor>();
  var isSubmittingEnquiry = false.obs;
  var enquirySuccess = false.obs;
  var enquiryError = ''.obs;
  var isSubmittingReview = false.obs;
  var reviewSuccess = false.obs;
  var reviewError = ''.obs;
  var pageErrorMessage = ''.obs;
  var showSearchBar = false.obs;
  var searchQuery = ''.obs;
  var selectedImage = ''.obs;
  final SessionManager _sessionHandler = SessionManager();
  @override
  void onInit() {
    super.onInit();
    fetchMaterials();
  }

  String _buildUrlWithParams(String baseUrl, Map<String, dynamic> params) {
    if (params.isEmpty) return baseUrl;

    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    return '$baseUrl?$queryString';
  }

  Future<void> fetchMaterials({bool loadMore = false}) async {
    try {
      if (!loadMore) {
        isLoading(true);
        currentPage.value = 1;
        hasMore.value = true;
        materials.clear();
        pageErrorMessage.value = '';
      } else {
        if (!hasMore.value) return;
        currentPage.value++;
      }

      // Build URL with query parameters manually
      final url = _buildUrlWithParams(
          'https://admincashback.vrikshatech.in/public/api/v2/material_list',
          {'page': currentPage.value}
      );

      print('🌐 Fetching materials: $url');

      final response = await ApiService.getRequest(url);

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        print('📦 Response data type: ${data.runtimeType}');

        if (data != null && data is Map) {
          // FIXED: Proper status check
          if (data['status'] == 200 || data['status'] == true) {
            if (data['data'] != null && data['data']['material'] != null) {
              final materialsData = data['data']['material'] as List;
              final pagination = data['data']['pagination'] ?? {};

              print('📊 Found ${materialsData.length} materials');

              final newMaterials = materialsData
                  .map((json) => MaterialModel.fromJson(json))
                  .toList();

              if (loadMore) {
                materials.addAll(newMaterials);
              } else {
                materials.value = newMaterials;
              }

              // Update pagination
              final totalPages = pagination['last_page'] ?? 1;
              final currentPageNum = pagination['current_page'] ?? 1;
              hasMore.value = currentPageNum < totalPages;

              print('✅ Total materials: ${materials.length}, Has more: ${hasMore.value}');
              print('📄 Current page: $currentPageNum, Total pages: $totalPages');

              pageErrorMessage.value = '';

            } else {
              if (!loadMore) {
                pageErrorMessage.value = 'No materials available';
                print('⚠️ No materials data found in response');
                materials.clear();
              }
            }
          } else {
            final errorMsg = data['message'] ?? 'Failed to fetch materials';
            if (!loadMore) {
              pageErrorMessage.value = errorMsg;
              print('❌ API returned error status: ${errorMsg}');
              materials.clear();
            }
          }
        } else {
          if (!loadMore) {
            pageErrorMessage.value = 'Invalid response format';
            print('❌ Invalid response format');
            materials.clear();
          }
        }
      } else {
        if (!loadMore) {
          pageErrorMessage.value = 'Failed to fetch materials';
          print('❌ Failed to fetch materials. Status: ${response.statusCode}');
          materials.clear();
        }
      }
    } catch (e, stackTrace) {
      if (!loadMore) {
        final errorMsg = 'Network error: ${e.toString().split('\n').first}';
        pageErrorMessage.value = errorMsg;
        print('❌ Error fetching materials: $e');
        print('❌ Stack trace: $stackTrace');
        materials.clear();
      }
    } finally {
      isLoading(false);
    }
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

  Future<void> fetchVendorDetail(int vendorId) async {
    try {
      isLoadingVendorDetail(true);
      pageErrorMessage.value = '';

      final url = 'https://admincashback.vrikshatech.in/public/api/v2/vendor/$vendorId';
      print('🌐 Fetching vendor detail: $url');

      final response = await ApiService.getRequest(url);

      print('📥 Vendor detail response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null && data is Map) {
          if (data['status'] == true) {
            if (data['data'] != null) {
              vendorDetail.value = Vendor.fromJson(data['data']);
              print('✅ Fetched vendor details: ${vendorDetail.value?.name}');
            } else {
              print('⚠️ No vendor detail data found');
              vendorDetail.value = null;
            }
          } else {
            final errorMsg = data['message'] ?? 'Failed to fetch seller details';
            print('❌ API returned error: $errorMsg');
            vendorDetail.value = null;
          }
        } else {
          print('❌ Invalid response format');
          vendorDetail.value = null;
        }
      } else {
        print('❌ Failed to fetch vendor details. Status: ${response.statusCode}');
        vendorDetail.value = null;
      }
    } catch (e, stackTrace) {
      print('❌ Error fetching vendor detail: $e');
      print('❌ Stack trace: $stackTrace');
      vendorDetail.value = null;
    } finally {
      isLoadingVendorDetail(false);
    }
  }

  // 4. Submit material enquiry
  Future<bool> submitMaterialEnquiry({
    required int materialId,
    required String requirement,
    required int unitId,
    required double quantity,
    required int userId,
  }) async {
    try {
      isSubmittingEnquiry(true);
      enquiryError.value = '';
      enquirySuccess.value = false;

      print('📤 Submitting material enquiry:');
      print('   Material ID: $materialId');
      print('   Requirement: $requirement');
      print('   Unit ID: $unitId');
      print('   Quantity: $quantity');
      print('   User ID: $userId');

      // Create proper payload for material enquiry
      final payload = {
        'material_id': materialId,
        'requirement': requirement,
        'unit_id': unitId,
        'quantity': quantity,
        'user_id': userId,
      };

      final response = await ApiService.postRequest(
        'https://admincashback.vrikshatech.in/public/api/v2/material/enquiry',
        payload,
      );

      print('📥 Enquiry Response Status: ${response.statusCode}');
      print('📥 Enquiry Response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data != null) {
          if ((data['status'] == true || data['status'] == 200 || data['status'] == 201)) {
            enquirySuccess.value = true;
            enquiryError.value = '';
            print('✅ Enquiry submitted successfully');
            return true;
          } else {
            enquiryError.value = data['message'] ?? 'Failed to submit enquiry';
            print('❌ Enquiry submission failed: ${enquiryError.value}');
          }
        } else {
          enquiryError.value = 'Invalid response from server';
        }
      } else {
        enquiryError.value = 'Server error: ${response.statusCode}';
        print('❌ Server error: ${enquiryError.value}');
      }
      return false;
    } catch (e, stackTrace) {
      enquiryError.value = 'Network error: ${e.toString()}';
      print('❌ Network error: $e');
      print('❌ Stack trace: $stackTrace');
      return false;
    } finally {
      isSubmittingEnquiry(false);
    }
  }

  // 5. Submit shop review
  Future<bool> submitShopReview({
    required int vendorId,
    required int userId,
    required double rating,
    required String review,
  }) async {
    try {
      isSubmittingReview(true);
      reviewError.value = '';
      reviewSuccess.value = false;

      final payload = {
        'vendor_id': vendorId,
        'user_id': userId,
        'rating': rating,
        'review': review,
      };

      print('📤 Submitting shop review: $payload');

      final response = await ApiService.postRequest(
        'https://admincashback.vrikshatech.in/public/api/v2/shop/review',
        payload,
      );

      print('📥 Review Response Status: ${response.statusCode}');
      print('📥 Review Response: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data != null) {
          if (data['status'] == true || data['status'] == 200 || data['status'] == 201) {
            reviewSuccess.value = true;
            reviewError.value = '';

            // Refresh vendor details to get updated reviews
            if (vendorDetail.value != null) {
              await fetchVendorDetail(vendorDetail.value!.userId);
            }

            print('✅ Review submitted successfully');
            return true;
          } else {
            reviewError.value = data['message'] ?? 'Failed to submit review';
            print('❌ Review submission failed: ${reviewError.value}');
          }
        } else {
          reviewError.value = 'Invalid response from server';
        }
      } else {
        reviewError.value = 'Server error: ${response.statusCode}';
        print('❌ Server error: ${reviewError.value}');
      }
      return false;
    } catch (e, stackTrace) {
      reviewError.value = 'Network error: ${e.toString()}';
      print('❌ Network error: $e');
      print('❌ Stack trace: $stackTrace');
      return false;
    } finally {
      isSubmittingReview(false);
    }
  }

  // Search materials
  Future<void> searchMaterials(String query) async {
    try {
      searchQuery.value = query;

      if (query.isEmpty) {
        await fetchMaterials();
        return;
      }

      isLoading(true);
      materials.clear();
      pageErrorMessage.value = '';

      final url = _buildUrlWithParams(
          'https://admincashback.vrikshatech.in/public/api/v2/material_list',
          {
            'page': 1,
            'search': query,
          }
      );

      print('🔍 Searching materials: $url');

      final response = await ApiService.getRequest(url);

      if (response.statusCode == 200) {
        final data = response.data;

        if (data != null && data is Map &&
            (data['status'] == 200 || data['status'] == true)) {
          if (data['data'] != null && data['data']['material'] != null) {
            final materialsData = data['data']['material'] as List;
            materials.value = materialsData
                .map((json) => MaterialModel.fromJson(json))
                .toList();

            if (materials.isEmpty) {
              pageErrorMessage.value = 'No materials found for "$query"';
            }
          } else {
            pageErrorMessage.value = 'No materials found for "$query"';
            materials.clear();
          }
        } else {
          pageErrorMessage.value = 'Search failed';
          materials.clear();
        }
      } else {
        pageErrorMessage.value = 'Search failed';
        materials.clear();
      }
    } catch (e) {
      print('❌ Error searching materials: $e');
      pageErrorMessage.value = 'Search error';
      materials.clear();
    } finally {
      isLoading(false);
    }
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
    vendorDetail.value = null;
  }

  // Load more materials
  Future<void> loadMoreMaterials() async {
    if (hasMore.value && !isLoading.value) {
      await fetchMaterials(loadMore: true);
    }
  }


  // Clear all data
  void clearAllData() {
    materials.clear();
    vendors.clear();
    vendorDetail.value = null;
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