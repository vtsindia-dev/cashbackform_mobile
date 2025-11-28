
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/api_constant.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/toster.dart';
import '../model/service_model.dart' show Service;

class ServiceController extends GetxController {
  var isLoading = false.obs;
  var isLoadMore = false.obs;
  var services = <Service>[].obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var totalItems = 0.obs;
  var hasMoreData = true.obs;
  var searchQuery = ''.obs;
  var selectedCategory = ''.obs;
  var selectedStatus = ''.obs;
  var isLoadingDetail = false.obs;
  var serviceDetail = Rxn<Service>();
  var errorMessage = ''.obs;
  var isExpanded = false.obs;
  var isDescriptionExpanded = false.obs;
  var _isLoadingMore = false; // Private variable to track load more state

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }
  void toggleExpansion() => isExpanded.value = !isExpanded.value;
  void toggleDescription() => isDescriptionExpanded.value = !isDescriptionExpanded.value;
  Future<void> fetchServices({bool loadMore = false}) async {
    try {
      // Prevent multiple simultaneous requests
      if ((isLoading.value && !loadMore) || (isLoadMore.value && loadMore)) {
        return;
      }

      if (loadMore) {
        // Check if we're already at the last page
        if (!hasMoreData.value) return;
        isLoadMore(true);
      } else {
        isLoading(true);
        currentPage.value = 1;
        hasMoreData.value = true;
      }

      final url = '${ApiUrl.serviceList}?page=${currentPage.value}${_buildQueryParams()}';
      print('🌐 Fetching Services URL: $url');

      final response = await ApiService.getRequest(url);
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null &&
            responseData['data'] != null &&
            responseData['data']['services'] != null) {

          final servicesData = responseData['data']['services'];
          final paginationData = responseData['data']['pagination'];
          final List<Service> fetchedServices = _parseServices(servicesData);

          if (loadMore) {
            // Check for duplicates before adding
            final newServices = fetchedServices.where((newService) =>
            !services.any((existingService) => existingService.id == newService.id)
            ).toList();

            services.addAll(newServices);
          } else {
            services.assignAll(fetchedServices);
          }

          currentPage.value = paginationData['current_page'] ?? 1;
          totalPages.value = paginationData['last_page'] ?? 1;
          totalItems.value = paginationData['total'] ?? 0;
          hasMoreData.value = currentPage.value < totalPages.value;

          print('✅ Fetched ${services.length} services');
          print('📄 Current page: $currentPage, Total pages: $totalPages, Total items: $totalItems');

        } else {
          SnackBarHelper.showError("Invalid response format from server");
          print('❌ Invalid response format: $responseData');
        }
      } else if (response.statusCode == 404) {
        SnackBarHelper.showError("Services not found");
        print('❌ 404 Error: ${response.data}');
      } else {
        final errorMessage = response.data?['message'] ?? 'Failed to fetch services';
        SnackBarHelper.showError("Error $errorMessage");
        print('❌ API Error ${response.statusCode}: ${response.data}');
      }
    } catch (e) {
      SnackBarHelper.showError("Network error: $e");
      print('❌ Network error: $e');
    } finally {
      isLoading(false);
      isLoadMore(false);
      refresh();
    }
  }

  Future<void> loadMoreServices() async {
    if (_isLoadingMore || !hasMoreData.value || isLoadMore.value || isLoading.value) {
      return;
    }

    _isLoadingMore = true;
    currentPage.value++;
    await fetchServices(loadMore: true);
    _isLoadingMore = false;
  }

  Future<void> fetchServiceDetail(int id) async {
    try {
      _clearDetailData();
      isLoadingDetail(true);
      errorMessage('');
      final url = '${ApiUrl.syndicateDetails}/$id';
      print('🌐 Fetching Service Detail URL: $url');
      final response = await ApiService.getRequest(url);
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null && responseData['data'] != null) {
          serviceDetail.value = Service.fromJson(responseData['data']);
          print('✅ Fetched Service detail: ${serviceDetail.value?.serviceName}');
          _logServiceDetailInfo();
        } else {
          errorMessage('Invalid response format from server');
          SnackBarHelper.showError("Invalid response format");
          print('❌ Invalid response format: $responseData');
        }
      } else if (response.statusCode == 404) {
        errorMessage('Service details not found');
        SnackBarHelper.showError("Service details not found");
        print('❌ 404 Error: ${response.data}');
      } else {
        final errorMsg = response.data?['message'] ?? 'Failed to fetch service details';
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
  Future<void> viewServiceImage(String imageUrl) async {
    try {
      if (imageUrl.isNotEmpty) {
        print("Viewing Service image: $imageUrl");
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
    serviceDetail.value = null;
    errorMessage('');
  }

  void _logServiceDetailInfo() {
    final detail = serviceDetail.value;
    if (detail != null) {
      print('🛠️ Service Name: ${detail.serviceName}');
      print('📝 Description: ${detail.description}');
      print('🏷️ Category: ${detail.category?.categoryName}');
      print('🖼️ Image: ${detail.image}');
      print('📊 Status: ${detail.status == 1 ? 'Active' : 'Inactive'}');
      print('📅 Created: ${detail.createdAt}');
      print('🔄 Updated: ${detail.updatedAt}');
    }
  }
  String getFormattedCategory() {
    final service = serviceDetail.value;
    return service?.category?.categoryName ?? 'No Category';
  }
  String getFormattedStatus() {
    final service = serviceDetail.value;
    return service?.status == 1 ? 'Active' : 'Inactive';
  }
  String getServiceImage() {
    final service = serviceDetail.value;
    if (service?.image != null && service!.image.isNotEmpty) {
      return service.image;
    }
    return 'assets/images/placeholder_service.png';
  }

  Future<void> refreshServices() async {
    await fetchServices(loadMore: false);
  }
  Future<void> searchServices(String query) async {
    searchQuery.value = query;
    await fetchServices();
  }

  Future<void> filterByCategory(String category) async {
    selectedCategory.value = category;
    await fetchServices();
  }
  Future<void> filterByStatus(String status) async {
    selectedStatus.value = status;
    await fetchServices();
  }

  // Clear all filters
  Future<void> clearFilters() async {
    searchQuery.value = '';
    selectedCategory.value = '';
    selectedStatus.value = '';
    await fetchServices();
  }

  // Get available categories
  List<String> getAvailableCategories() {
    return services
        .map((service) => service.category?.categoryName ?? '')
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

  // Parse services from JSON
  List<Service> _parseServices(List<dynamic> servicesData) {
    return servicesData.map((serviceJson) {
      return Service.fromJson(serviceJson);
    }).toList();
  }

  // Get service by ID
  Service? getServiceById(int id) {
    try {
      return services.firstWhere((service) => service.id == id);
    } catch (e) {
      return null;
    }
  }

  // Check if service is favorite
  bool isServiceFavorite(int serviceId) {
    return false;
  }

  // Toggle favorite
  void toggleFavorite(int serviceId) {
    print('Toggled favorite for service $serviceId');
  }

  // Get services by category
  List<Service> getServicesByCategory(String categoryName) {
    return services.where((service) =>
    service.category?.categoryName == categoryName
    ).toList();
  }

  // Get active services only
  List<Service> getActiveServices() {
    return services.where((service) => service.status == 1).toList();
  }

  // Get services with images
  List<Service> getServicesWithImages() {
    return services.where((service) =>
    service.image != null && service.image.isNotEmpty
    ).toList();
  }

  // Search services by name or description
  List<Service> searchServicesLocal(String query) {
    if (query.isEmpty) return services.toList();

    final lowercaseQuery = query.toLowerCase();
    return services.where((service) =>
    service.serviceName.toLowerCase().contains(lowercaseQuery) ||
        (service.description != null && service.description!.toLowerCase().contains(lowercaseQuery))
    ).toList();
  }

  // Get services with descriptions
  List<Service> getServicesWithDescriptions() {
    return services.where((service) =>
    service.description != null && service.description!.isNotEmpty
    ).toList();
  }

  @override
  void onClose() {
    _clearDetailData();
    super.onClose();
  }
}