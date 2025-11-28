import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/api_constant.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/toster.dart';
import '../model/material_store.dart';

class MaterialStore extends GetxController {
  // Reactive variables
  var isLoading = false.obs;
  var isLoadMore = false.obs;
  var materials = <Material>[].obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalItems = 0.obs;
  var hasMoreData = true.obs;

  // Filter variables
  var searchQuery = ''.obs;
  var selectedCategory = ''.obs;
  var selectedStatus = ''.obs;

  // Detail variables
  var isLoadingDetail = false.obs;
  var materialDetail = Rxn<Material>();
  var errorMessage = ''.obs;

  // UI state variables
  var isExpanded = false.obs;
  var isDescriptionExpanded = false.obs;

  // Add protection against multiple calls
  var _isLoadingInProgress = false;
  var _lastRequestedPage = 0;

  @override
  void onInit() {
    super.onInit();
    fetchMaterials();
  }

  void toggleExpansion() => isExpanded.value = !isExpanded.value;
  void toggleDescription() => isDescriptionExpanded.value = !isDescriptionExpanded.value;

  // Fetch materials with pagination
  Future<void> fetchMaterials({bool loadMore = false}) async {
    try {
      // Prevent multiple simultaneous requests
      if (_isLoadingInProgress) {
        print('⏸️ Request already in progress, skipping...');
        return;
      }

      // Prevent loading same page multiple times
      final requestedPage = loadMore ? currentPage.value + 1 : 1;
      if (loadMore && _lastRequestedPage == requestedPage) {
        print('⏸️ Already requested page $requestedPage, skipping...');
        return;
      }

      _isLoadingInProgress = true;
      _lastRequestedPage = requestedPage;

      if (loadMore) {
        // Check if we're already at the last page
        if (!hasMoreData.value) {
          print('🛑 No more data to load');
          _isLoadingInProgress = false;
          return;
        }
        isLoadMore(true);
      } else {
        isLoading(true);
        currentPage.value = 1;
        hasMoreData.value = true;
      }

      final url = '${ApiUrl.marketList}?page=${loadMore ? currentPage.value + 1 : 1}${_buildQueryParams()}';
      print('🌐 Fetching Materials URL: $url');

      final response = await ApiService.getRequest(url);
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null &&
            responseData['data'] != null &&
            responseData['data']['material'] != null) {

          final materialsData = responseData['data']['material'];
          final paginationData = responseData['data']['pagination'];

          // Parse materials
          final List<Material> fetchedMaterials = _parseMaterials(materialsData);

          // API FIX: If API returns wrong pagination data, use manual calculation
          final apiCurrentPage = paginationData['current_page'] ?? 1;
          final apiTotalPages = paginationData['last_page'] ?? 1;
          final apiTotalItems = paginationData['total'] ?? 0;

          if (loadMore) {
            // Check if we're getting duplicate data
            final newMaterials = _filterDuplicates(fetchedMaterials);
            if (newMaterials.isEmpty) {
              print('⚠️ No new materials found, stopping pagination');
              hasMoreData.value = false;
            } else {
              materials.addAll(newMaterials);
              print('✅ Added ${newMaterials.length} new materials');
            }
          } else {
            materials.assignAll(fetchedMaterials);
          }

          // Manual pagination calculation since API returns wrong data
          if (loadMore) {
            currentPage.value = apiCurrentPage;
          } else {
            currentPage.value = 1;
          }

          // If API returns inconsistent data, use item count based logic
          final perPage = paginationData['per_page'] ?? 10;
          if (apiTotalItems > 0 && materials.length >= apiTotalItems) {
            hasMoreData.value = false;
            print('🛑 Reached total items limit: ${apiTotalItems}');
          } else if (fetchedMaterials.length < perPage) {
            hasMoreData.value = false;
            print('🛑 Last page detected: received ${fetchedMaterials.length} items (less than per_page: $perPage)');
          } else {
            hasMoreData.value = true;
          }

          totalPages.value = apiTotalPages;
          totalItems.value = materials.length; // Use actual count since API total is wrong

          print('✅ Total materials: ${materials.length}');
          print('📄 Current page: $currentPage, Total pages: $totalPages, Has more: $hasMoreData');

        } else {
          SnackBarHelper.showError("Invalid response format from server");
          print('❌ Invalid response format: $responseData');
        }
      } else if (response.statusCode == 404) {
        SnackBarHelper.showError("Materials not found");
        print('❌ 404 Error: ${response.data}');
      } else {
        final errorMessage = response.data?['message'] ?? 'Failed to fetch materials';
        SnackBarHelper.showError("Error $errorMessage");
        print('❌ API Error ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      SnackBarHelper.showError("Network error: $e");
      print('❌ Network error: $e');
    } finally {
      isLoading(false);
      isLoadMore(false);
      _isLoadingInProgress = false;
      refresh();
    }
  }

  // Filter out duplicate materials
  List<Material> _filterDuplicates(List<Material> newMaterials) {
    final existingIds = materials.map((m) => m.id).toSet();
    return newMaterials.where((material) => !existingIds.contains(material.id)).toList();
  }

  // Load more materials with better protection
  Future<void> loadMoreMaterials() async {
    if (!hasMoreData.value || isLoadMore.value || isLoading.value || _isLoadingInProgress) {
      print('⏸️ Cannot load more: hasMoreData=$hasMoreData, isLoadMore=$isLoadMore, isLoading=$isLoading, inProgress=$_isLoadingInProgress');
      return;
    }

    print('🔄 Loading more materials...');
    await fetchMaterials(loadMore: true);
  }

  // ... REST OF YOUR EXISTING METHODS REMAIN THE SAME ...
  // Fetch Material Detail
  Future<void> fetchMaterialDetail(int id) async {
    try {
      _clearDetailData();
      isLoadingDetail(true);
      errorMessage('');

      final url = '${ApiUrl.marketDetails}/$id';
      print('🌐 Fetching Material Detail URL: $url');

      final response = await ApiService.getRequest(url);
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          materialDetail.value = Material.fromJson(responseData['data']);
          print('✅ Fetched Material detail: ${materialDetail.value?.materialName}');
          _logMaterialDetailInfo();
        } else {
          errorMessage('Invalid response format from server');
          SnackBarHelper.showError("Invalid response format");
          print('❌ Invalid response format: $responseData');
        }
      } else if (response.statusCode == 404) {
        errorMessage('Material details not found');
        SnackBarHelper.showError("Material details not found");
        print('❌ 404 Error: ${response.data}');
      } else {
        final errorMsg = response.data?['message'] ?? 'Failed to fetch material details';
        errorMessage(errorMsg);
        SnackBarHelper.showError("Error: $errorMsg");
        print('❌ API Error ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      errorMessage('Network error: $e');
      SnackBarHelper.showError("Network error: $e");
      print('❌ Network error: $e');
    } finally {
      isLoadingDetail(false);
    }
  }

  // View Material Document/Image
  Future<void> viewMaterialImage(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty) {
        print("Viewing Material image: $imageUrl");
        await _launchUrl(imageUrl);
        return;
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

      print('Launching URL: $uri');

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        print('Cannot launch URL: $uri');
        SnackBarHelper.showError("Cannot open the image. Please check your connection.");
      }
    } catch (e) {
      print('Error launching URL: $e');
      SnackBarHelper.showError("Failed to open image");
    }
  }

  void _clearDetailData() {
    materialDetail.value = null;
    errorMessage('');
  }

  void _logMaterialDetailInfo() {
    final detail = materialDetail.value;
    if (detail != null) {
      print('📦 Material Name: ${detail.materialName}');
      print('📝 Description: ${detail.description}');
      print('🏷️ Category: ${detail.category?.categoryName}');
      print('🖼️ Image: ${detail.image}');
      print('📊 Status: ${detail.status == 1 ? 'Active' : 'Inactive'}');
      print('📅 Created: ${detail.createdAt}');
      print('🔄 Updated: ${detail.updatedAt}');
    }
  }

  // Get formatted category name
  String getFormattedCategory() {
    final material = materialDetail.value;
    return material?.category?.categoryName ?? 'No Category';
  }

  // Get formatted status
  String getFormattedStatus() {
    final material = materialDetail.value;
    return material?.status == 1 ? 'Active' : 'Inactive';
  }

  // Get material image or placeholder
  String getMaterialImage() {
    final material = materialDetail.value;
    if (material?.image != null && material!.image.isNotEmpty) {
      return material.image;
    }
    return 'assets/images/placeholder_material.png';
  }

  // Refresh materials
  Future<void> refreshMaterials() async {
    await fetchMaterials(loadMore: false);
  }

  // Search materials
  Future<void> searchMaterials(String query) async {
    searchQuery.value = query;
    await fetchMaterials();
  }

  // Filter by category
  Future<void> filterByCategory(String category) async {
    selectedCategory.value = category;
    await fetchMaterials();
  }

  // Filter by status
  Future<void> filterByStatus(String status) async {
    selectedStatus.value = status;
    await fetchMaterials();
  }

  // Clear all filters
  Future<void> clearFilters() async {
    searchQuery.value = '';
    selectedCategory.value = '';
    selectedStatus.value = '';
    await fetchMaterials();
  }

  // Get available categories
  List<String> getAvailableCategories() {
    return materials
        .map((material) => material.category?.categoryName ?? '')
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();
  }

  // Get available statuses
  List<String> getAvailableStatuses() {
    return ['Active', 'Inactive'];
  }

  // Build query parameters
  String _buildQueryParams() {
    final params = <String>[];

    if (searchQuery.value.isNotEmpty) {
      params.add('search=${Uri.encodeComponent(searchQuery.value)}');
    }
    if (selectedCategory.value.isNotEmpty) {
      params.add('category=${Uri.encodeComponent(selectedCategory.value)}');
    }
    if (selectedStatus.value.isNotEmpty) {
      final statusValue = selectedStatus.value == 'Active' ? '1' : '0';
      params.add('status=${Uri.encodeComponent(statusValue)}');
    }

    return params.isEmpty ? '' : '&${params.join('&')}';
  }

  // Parse materials from JSON
  List<Material> _parseMaterials(List<dynamic> materialsData) {
    return materialsData.map((materialJson) {
      return Material.fromJson(materialJson);
    }).toList();
  }

  // Get material by ID
  Material? getMaterialById(int id) {
    try {
      return materials.firstWhere((material) => material.id == id);
    } catch (e) {
      return null;
    }
  }

  // Check if material is favorite
  bool isMaterialFavorite(int materialId) {
    return false;
  }

  // Toggle favorite
  void toggleFavorite(int materialId) {
    print('Toggled favorite for material $materialId');
  }

  // Get materials by category
  List<Material> getMaterialsByCategory(String categoryName) {
    return materials.where((material) =>
    material.category?.categoryName == categoryName
    ).toList();
  }

  // Get active materials only
  List<Material> getActiveMaterials() {
    return materials.where((material) => material.status == 1).toList();
  }

  // Get materials with images
  List<Material> getMaterialsWithImages() {
    return materials.where((material) =>
    material.image != null && material.image.isNotEmpty
    ).toList();
  }

  // Search materials by name or description
  List<Material> searchMaterialsLocal(String query) {
    if (query.isEmpty) return materials.toList();

    final lowercaseQuery = query.toLowerCase();
    return materials.where((material) =>
    material.materialName.toLowerCase().contains(lowercaseQuery) ||
        material.description.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  @override
  void onClose() {
    _clearDetailData();
    super.onClose();
  }
}