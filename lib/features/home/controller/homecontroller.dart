import 'package:cashback_farms/common/model/logger_model.dart';
import 'package:cashback_farms/features/home/model/feature_gio_rental_model.dart';
import 'package:cashback_farms/features/home/model/featured_plot_model.dart';
import 'package:cashback_farms/features/home/model/home_category_model.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../common/api_constant.dart';
import '../../../common/widget/api_service.dart';
import '../model/home_model.dart';

class HomeController extends GetxController {
  // ========== LOCATION VARIABLES ==========
  var isLoadingLocation = true.obs;
  var currentLocation = "Fetching location...".obs;
  var areaName = "".obs;
  var fullAddress = "".obs;

  // ========== LOADING STATES ==========
  var isLoadingFeaturedData = false.obs;
  var isLoadingServices = false.obs;
  var isLoadingMaterials = false.obs;
  var isLoadingBanners = false.obs;
  var isLoadingSyndicates = false.obs;
  var isLoadingMarket = false.obs;
  var isLoadingGioo = false.obs;

  // Load more states
  var isLoadingMoreSyndicates = false.obs;
  var isLoadingMoreMarket = false.obs;
  var isLoadingMoreGioo = false.obs;

  // ========== DATA OBSERVABLES ==========
  var services = <Map<String, dynamic>>[].obs;
  var materials = <Map<String, dynamic>>[].obs;
  var featuredBanners = <FeaturedBanner>[].obs;
  var featuredSyndicates = <FeaturedSyndicate>[].obs;
  var featuredMarketProperties = <FeaturedMarketProperty>[].obs;
  var featuredGiooPlots = <GiooPlot>[].obs;

  // ========== PAGINATION VARIABLES ==========
  // Syndicate pagination
  var syndicateCurrentPage = 1.obs;
  var syndicateTotalPages = 1.obs;
  var syndicateHasMore = true.obs;
  var syndicatePagination = Rxn<FeaturedPagination>();

  // Market pagination
  var marketCurrentPage = 1.obs;
  var marketTotalPages = 1.obs;
  var marketHasMore = true.obs;
  var marketPagination = Rxn<FeaturedPagination>();

  // GIOO pagination
  var giooCurrentPage = 1.obs;
  var giooTotalPages = 1.obs;
  var giooHasMore = true.obs;
  var giooPagination = Rxn<FeaturedPagination>();

  // ========== ERROR STATES ==========
  var locationError = ''.obs;
  var serviceError = ''.obs;
  var materialError = ''.obs;
  var bannerError = ''.obs;
  var syndicateError = ''.obs;
  var marketError = ''.obs;
  var giooError = ''.obs;

  // ========== UI STATES ==========
  var isBannerExpanded = false.obs;
  var isSyndicateExpanded = false.obs;
  var isMarketExpanded = false.obs;
  var isGiooExpanded = false.obs;

  // ========== PROTECTION AGAINST MULTIPLE CALLS ==========
  var _isFetchingLocation = false;
  var _isFetchingServices = false;
  var _isFetchingMaterials = false;
  var _isFetchingBanners = false;
  var _isFetchingSyndicates = false;
  var _isFetchingMarket = false;
  var _isFetchingGioo = false;

  @override
  void onInit() {
    super.onInit();
    // Load initial data
    _initializeData();
  }


  bool isHomeCategoryLoading = false;
   void isUpdateLoading(bool value) {
      isHomeCategoryLoading = value;
      update();
    }

  List<HomeCategoryModelList> homeCategoryList = [];

  Future<void> getHomeCategories() async {
    try {
      isUpdateLoading(true);
      final url = ApiUrl.homeCategoryApi;
      final response = await ApiService.getRequest(url);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == 200) {
          List list = data['data']?['categories'] ?? [];
          homeCategoryList = list
              .map((e) => HomeCategoryModelList.fromJson(e))
              .toList();
          update();
        }
      }
    } catch (e) {
      Loggers.error("SubSubCategory Error: $e");
    } finally {
      isUpdateLoading(false);
    }
  }





  void _initializeData() async {
    await getUserLocation();
    await fetchAllHomeData();
  }

  // ========== TOGGLE UI EXPANSION ==========
  void toggleBannerExpansion() => isBannerExpanded.value = !isBannerExpanded.value;
  void toggleSyndicateExpansion() => isSyndicateExpanded.value = !isSyndicateExpanded.value;
  void toggleMarketExpansion() => isMarketExpanded.value = !isMarketExpanded.value;
  void toggleGiooExpansion() => isGiooExpanded.value = !isGiooExpanded.value  ;

  // ========== REFRESH ALL DATA ==========
  Future<void> refreshAllData() async {
    print('🔄 ');

    // Clear all data
    services.clear();
    materials.clear();
    featuredBanners.clear();
    featuredSyndicates.clear();
    featuredMarketProperties.clear();
    featuredGiooPlots.clear();

    // Reset pagination
    syndicateCurrentPage.value = 1;
    marketCurrentPage.value = 1;
    giooCurrentPage.value = 1;
    syndicateHasMore.value = true;
    marketHasMore.value = true;
    giooHasMore.value = true;

    // Clear errors
    clearErrors();

    // Fetch all data
    await fetchAllHomeData();

    print('✅ All home data refreshed successfully');
  }

  // ========== FETCH ALL HOME DATA ==========
  Future<void> fetchAllHomeData() async {
    try {
      isLoadingFeaturedData(true);

      await Future.wait([
        fetchServices(),
        fetchMaterials(),
        fetchBanners(),
        fetchFeaturedSyndicates(),
        fetchFeaturedPlots(),
        fetchFeaturedRental(),
        fetchFeaturedMarket(),
        fetchFeaturedGioo(),
        getHomeCategories(),
      ]);

      print('✅ All home data loaded successfully');
    } catch (e) {
      print('❌ Error fetching home data: $e');
    } finally {
      isLoadingFeaturedData(false);
    }
  }

  // ========== LOCATION METHODS ==========
  Future<void> getUserLocation() async {
    try {
      if (_isFetchingLocation) {
        print('⏸️ Location fetch already in progress');
        return;
      }

      _isFetchingLocation = true;
      isLoadingLocation(true);
      locationError('');

      updateLocationText("Fetching location...");

      PermissionStatus status = await Permission.location.status;

      if (status.isDenied || status.isRestricted) {
        status = await Permission.location.request();
      }

      if (status.isPermanentlyDenied) {
        updateLocationText("Enable location in Settings");
        locationError('Location permission permanently denied');
        openAppSettings();
        return;
      }

      if (status.isGranted) {
        await fetchLocationFromDevice();
      } else {
        updateLocationText("Location permission denied");
        locationError('Location permission denied by user');
      }
    } catch (e) {
      updateLocationText("Unable to fetch location");
      locationError('Location fetch error: $e');
      print('❌ Location Error: $e');
    } finally {
      isLoadingLocation(false);
      _isFetchingLocation = false;
    }
  }

  Future<void> fetchLocationFromDevice() async {
    try {
      updateLocationText("Getting current position...");

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        String locality = place.locality ?? "";
        String subLocality = place.subLocality ?? "";
        String administrativeArea = place.administrativeArea ?? "";
        String postalCode = place.postalCode ?? "";
        String street = place.street ?? "";
        String name = place.name ?? "";

        // Set area name
        areaName.value = subLocality.isNotEmpty ? subLocality : (locality.isNotEmpty ? locality : name);

        // Build full address
        List<String> addressParts = [];
        if (street.isNotEmpty) addressParts.add(street);
        if (locality.isNotEmpty && locality != areaName.value) addressParts.add(locality);
        if (administrativeArea.isNotEmpty) addressParts.add(administrativeArea);
        if (postalCode.isNotEmpty) addressParts.add(postalCode);

        fullAddress.value = addressParts.join(', ');

        // Set current location display
        if (areaName.value.isNotEmpty && fullAddress.value.isNotEmpty) {
          currentLocation.value = "${areaName.value}, ${fullAddress.value}";
        } else if (areaName.value.isNotEmpty) {
          currentLocation.value = areaName.value;
        } else {
          currentLocation.value = fullAddress.value;
        }

        print("📍 Location Details:");
        print("Latitude: ${position.latitude}, Longitude: ${position.longitude}");
        print("Area Name: ${areaName.value}");
        print("Full Address: ${fullAddress.value}");
        print("Locality: $locality");
        print("SubLocality: $subLocality");
        print("Street: $street");
        print("Postal Code: $postalCode");
      } else {
        updateLocationText("No address found for coordinates");
        locationError('No placemarks found for coordinates');
      }
    } on Exception catch (e) {
      updateLocationText("Location service error");
      locationError('Geolocation error: $e');
      print('❌ Geolocation Error: $e');
    }
  }

  void updateLocationText(String text) {
    currentLocation.value = text;   // Obx will auto refresh
  }


  void refreshLocation() {
    locationError('');
    getUserLocation();
  }

  Future<void> fetchServices() async {
    try {
      if (_isFetchingServices) {
        print('⏸️ Services already in progress');
        return;
      }

      _isFetchingServices = true;
      isLoadingServices(true);
      serviceError('');

      print('🌐 Fetching services from: ${ApiUrl.serviceList}');
      final response = await ApiService.getRequest(ApiUrl.serviceList);
      if (response.statusCode == 200) {
        final responseData = response.data;
        print('📦 Services API Response: $responseData');

        if (responseData != null &&
            responseData['status'] == 200 &&
            responseData['data'] != null) {

          if (responseData['data'] is List) {
            final List<dynamic> servicesData = responseData['data'];
            services.assignAll(servicesData.map((service) {
              return {
                'id': service['id'] ?? 0,
                'title': service['service_name'] ?? service['name'] ?? 'Service',
                'image': service['image'] ?? service['service_image'] ?? '',
                'description': service['description'] ?? '',
                'status': service['status'] ?? 1,
                'created_at': service['created_at'],
                'updated_at': service['updated_at'],
              };
            }).toList());
          } else if (responseData['data'] is Map &&
              responseData['data']['services'] is List) {
            final List<dynamic> servicesData = responseData['data']['services'];
            services.assignAll(servicesData.map((service) {
              return {
                'id': service['id'] ?? 0,
                'title': service['service_name'] ?? service['name'] ?? 'Service',
                'image': service['image'] ?? service['service_image'] ?? '',
                'description': service['description'] ?? '',
                'status': service['status'] ?? 1,
                'created_at': service['created_at'],
                'updated_at': service['updated_at'],
              };
            }).toList());
          }

          print('✅ Loaded ${services.length} services');
        } else {
          serviceError('Invalid services response format');
          print('❌ Invalid services response format');
        }
      } else {
        serviceError('Failed to load services: ${response.statusCode}');
        print('❌ Services API Error: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      serviceError('Services error: $e');
      print('❌ Error fetching services: $e');
    } finally {
      isLoadingServices(false);
      _isFetchingServices = false;
    }
  }

  // FETCH MATERIALS
  Future<void> fetchMaterials() async {
    try {
      if (_isFetchingMaterials) {
        print('⏸️ Materials fetch already in progress');
        return;
      }

      _isFetchingMaterials = true;
      isLoadingMaterials(true);
      materialError('');

      print('🌐 Fetching materials from: ${ApiUrl.marketList}');

      final response =
      await ApiService.getRequest(ApiUrl.marketList);

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('📦 Materials API Response: $responseData');

        if (responseData != null &&
            responseData['status'] == 200 &&
            responseData['data'] != null &&
            responseData['data'] is Map) {

          final data = responseData['data'];

          if (data['material'] is List) {
            final List<dynamic> materialsData = data['material'];

            materials.assignAll(
              materialsData.map((material) {
                return {
                  'id': material['id'] ?? 0,
                  'title': material['material_name'] ??
                      material['name'] ??
                      'Material',
                  'image': material['image'] ??
                      material['material_image'] ??
                      '',
                  'description': material['description'] ?? '',
                  'category': material['category'] != null
                      ? {
                    'id':
                    material['category']['id'] ?? 0,
                    'name': material['category']
                    ['category_name'] ??
                        'Uncategorized',
                  }
                      : null,
                  'status': material['status'] ?? 1,
                  'created_at': material['created_at'],
                  'updated_at': material['updated_at'],
                };
              }).toList(),
            );

            print(
                '✅ Loaded ${materials.length} materials');
          } else {
            materialError('Material list missing in response');
            print('❌ material key not found or invalid');
          }
        } else {
          materialError('Invalid materials response format');
          print('❌ Invalid materials response format');
        }
      } else {
        materialError(
            'Failed to load materials: ${response.statusCode}');
        print(
            '❌ Materials API Error: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      materialError('Materials error: $e');
      print('❌ Error fetching materials: $e');
    } finally {
      isLoadingMaterials(false);
      _isFetchingMaterials = false;
    }
  }

  // FETCH BANNERS
  Future<void> fetchBanners() async {
    try {
      if (_isFetchingBanners) {
        print('⏸️ Banners fetch already in progress');
        return;
      }

      _isFetchingBanners = true;
      isLoadingBanners(true);
      bannerError('');

      final bannerUrl = '${ApiUrl.baseUrl}/api/v2/carousel_banner';
      print('🌐 Fetching banners from: $bannerUrl');

      final response = await ApiService.getRequest(bannerUrl);

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('📦 Banners API Response: $responseData');

        if (responseData != null &&
            responseData['status'] == 200 &&
            responseData['data'] is List) {

          final List<dynamic> bannersData = responseData['data'];
          final List<FeaturedBanner> banners = bannersData
              .map((banner) => FeaturedBanner.fromJson(banner))
              .toList();

          featuredBanners.assignAll(banners);
          print('✅ Loaded ${featuredBanners.length} banners');
        } else {
          bannerError('Invalid banners response format');
          print('❌ Invalid banners response format');
        }
      } else {
        bannerError('Failed to load banners: ${response.statusCode}');
        print('❌ Banners API Error: ${response.statusCode} - ${response.data}');
      }
    } catch (e) {
      bannerError('Banners error: $e');
      print('❌ Error fetching banners: $e');
    } finally {
      isLoadingBanners(false);
      _isFetchingBanners = false;
    }
  }

  bool isLoadingRental = false;
  bool isLoadingMoreRental = false;
  bool rentalHasMore = true;

  int rentalCurrentPage = 1;
  int rentalTotalPages = 1;

  List<FeaturedRentalProperty> rentalList = [];
  FeaturedPagination? rentalPagination;

  String rentalError = '';

  Future<void> fetchFeaturedRental({bool loadMore = false}) async {
    try {
      if (loadMore && !rentalHasMore) return;

      if (loadMore) {
        isLoadingMoreRental = true;
      } else {
        isLoadingRental = true;
        rentalCurrentPage = 1;
        rentalList.clear();
      }

      update();

      final page = loadMore ? rentalCurrentPage + 1 : 1;

      final url = "${ApiUrl.featuredRental}?page=$page";

      final response = await ApiService.getRequest(url);

      if (response.statusCode == 200) {
        final data = response.data;

        final parsed = FeaturedRentalResponse.fromJson(data['data']);

        if (loadMore) {
          rentalList.addAll(parsed.rentalProperties);
        } else {
          rentalList = parsed.rentalProperties;
        }

        rentalPagination = parsed.pagination;
        rentalCurrentPage = parsed.pagination.currentPage;
        rentalTotalPages = parsed.pagination.lastPage;
        rentalHasMore = parsed.pagination.hasMorePages;
      }
    } catch (e) {
      rentalError = "$e";
    }

    isLoadingRental = false;
    isLoadingMoreRental = false;
    update();
  }
  void loadMoreRentalPlots() {
    if (rentalCurrentPage < rentalTotalPages &&
        !isLoadingMoreRental) {

      print('📥 Loading more rental plots...');

      fetchFeaturedRental(loadMore: true);
    } else {
      print('🛑 No more rental plots OR already loading');
    }
  }



  // FETCH FEATURED SYNDICATES (WITH PAGINATION)
  Future<void> fetchFeaturedSyndicates({bool loadMore = false}) async {
    try {
      if (_isFetchingSyndicates && !loadMore) {
        print('⏸️ Syndicates fetch already in progress');
        return;
      }

      if (loadMore && !syndicateHasMore.value) {
        print('🛑 No more syndicates to load');
        return;
      }

      _isFetchingSyndicates = true;

      if (loadMore) {
        isLoadingMoreSyndicates(true);
      } else {
        isLoadingSyndicates(true);
        syndicateError('');
      }

      final page =
      loadMore ? syndicateCurrentPage.value + 1 : 1;
      final url =
          '${ApiUrl.featuredSyndicates}?page=$page';

      print('🌐 Fetching featured syndicates from: $url');

      final response = await ApiService.getRequest(url);

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('📦 Featured Syndicates API Response: $responseData');

        if (responseData != null &&
            responseData['status'] == 200 &&
            responseData['data'] != null) {

          final syndicateResponse =
          FeaturedSyndicateResponse.fromJson(
              responseData['data']);

          if (loadMore) {
            featuredSyndicates
                .addAll(syndicateResponse.syndicates);
          } else {
            featuredSyndicates
                .assignAll(syndicateResponse.syndicates);
          }

          syndicatePagination.value =
              syndicateResponse.pagination;
          syndicateCurrentPage.value =
              syndicateResponse.pagination.currentPage;
          syndicateTotalPages.value =
              syndicateResponse.pagination.lastPage;
          syndicateHasMore.value =
              syndicateResponse.pagination.hasMorePages;

          print(
              '✅ Loaded ${featuredSyndicates.length} featured syndicates');
          print(
              '📊 Pagination: ${syndicateCurrentPage.value}/${syndicateTotalPages.value}');
        } else {
          syndicateError('Invalid syndicates response format');
        }
      } else {
        syndicateError(
            'Failed to load syndicates: ${response.statusCode}');
      }
    } catch (e) {
      syndicateError('Syndicates error: $e');
      print('❌ Error fetching featured syndicates: $e');
    } finally {
      isLoadingSyndicates(false);
      isLoadingMoreSyndicates(false);
      _isFetchingSyndicates = false;
    }
  }

  // LOAD MORE SYNDICATES
  Future<void> loadMoreFeaturedSyndicates() async {
    if (!syndicateHasMore.value || isLoadingMoreSyndicates.value) {
      return;
    }

    await fetchFeaturedSyndicates(loadMore: true);
  }

  var plotCurrentPage = 1.obs;
  var plotTotalPages = 1.obs;
  var plotHasMore = true.obs;

  var plotPagination = Rxn<Pagination>();

  var featuredPlots = <Syndicate>[].obs;

  var plotError = ''.obs;

  var _isFetchingPlots = false;

  var isLoadingPlots = false.obs;
  var isLoadingMorePlots = false.obs;

  Future<void> fetchFeaturedPlots({
    bool loadMore = false,
  }) async {
    try {
      if (_isFetchingPlots) {
        print('⏸️ Plots fetch already in progress');
        return;
      }

      if (loadMore && !plotHasMore.value) {
        print('🛑 No more plots to load');
        return;
      }

      _isFetchingPlots = true;

      if (loadMore) {
        isLoadingMorePlots(true);
      } else {
        isLoadingPlots(true);
        plotError('');
      }

      final page =
      loadMore ? plotCurrentPage.value + 1 : 1;

      final url =
          '${ApiUrl.featuredPlot}?page=$page';

      print('🌐 Fetching featured plots from: $url');

      final response = await ApiService.getRequest(url);

      print('📦 Response: ${response.data}');

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData != null &&
            responseData is Map<String, dynamic>) {

          final plotResponse =
          FeaturedPlotProperty.fromJson(
            responseData,
          );

          final plots =
              plotResponse.data?.syndicate ?? [];

          final pagination =
              plotResponse.data?.pagination;

          if (loadMore) {
            featuredPlots.addAll(plots);
          } else {
            featuredPlots.assignAll(plots);
          }


          plotPagination.value = pagination;

          plotCurrentPage.value =
              pagination?.currentPage ?? 1;

          plotTotalPages.value =
              pagination?.lastPage ?? 1;

          plotHasMore.value =
              plotCurrentPage.value <
                  plotTotalPages.value;

          print(
            '✅ Loaded ${featuredPlots.length} featured plots',
          );

          print(
            '📄 Current Page: ${plotCurrentPage.value}',
          );

          print(
            '📄 Total Pages: ${plotTotalPages.value}',
          );

          print(
            '📄 Has More: ${plotHasMore.value}',
          );
        } else {
          plotError(
            'Invalid plots response format',
          );

          print(
            '❌ Invalid plots response format',
          );
        }
      } else {
        plotError(
          'Failed to load plots: ${response.statusCode}',
        );

        print(
          '❌ API Error: ${response.statusCode}',
        );
      }
    } catch (e, stackTrace) {
      plotError('Plots error: $e');

      print(
        '❌ Error fetching featured plots: $e',
      );

      print(stackTrace);
    } finally {
      isLoadingPlots(false);
      isLoadingMorePlots(false);

      _isFetchingPlots = false;
    }
  }
  Future<void> loadMoreFeaturedPlots() async {
    if (!plotHasMore.value || isLoadingMorePlots.value) return;
    await fetchFeaturedPlots(loadMore: true);
  }



  // FETCH FEATURED MARKET PROPERTIES (WITH PAGINATION)
  Future<void> fetchFeaturedMarket({bool loadMore = false}) async {
    try {
      if (_isFetchingMarket && !loadMore) {
        print('⏸️ Market fetch already in progress');
        return;
      }

      if (loadMore && !marketHasMore.value) {
        print('🛑 No more market properties to load');
        return;
      }

      _isFetchingMarket = true;

      if (loadMore) {
        isLoadingMoreMarket(true);
      } else {
        isLoadingMarket(true);
        marketError('');
      }

      final page = loadMore ? marketCurrentPage.value + 1 : 1;
      final url = '${ApiUrl.featuredMarket}?page=$page';

      print('🌐 Fetching featured market from: $url');

      final response = await ApiService.getRequest(url);

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('📦 Featured Market API Response: $responseData');

        if (responseData != null &&
            responseData['status'] == 200 &&
            responseData['data'] != null) {

          final marketResponse =
          FeaturedMarketResponse.fromJson(responseData['data']);

          if (loadMore) {
            featuredMarketProperties
                .addAll(marketResponse.marketProperties);
          } else {
            featuredMarketProperties
                .assignAll(marketResponse.marketProperties);
          }

          marketPagination.value = marketResponse.pagination;
          marketCurrentPage.value =
              marketResponse.pagination.currentPage;
          marketTotalPages.value =
              marketResponse.pagination.lastPage;
          marketHasMore.value =
              marketResponse.pagination.hasMorePages;

          print(
              '✅ Loaded ${featuredMarketProperties.length} featured market properties');
          print(
              '📊 Pagination: ${marketCurrentPage.value}/${marketTotalPages.value}');
        } else {
          marketError('Invalid market response format');
        }
      } else {
        marketError('Failed to load market: ${response.statusCode}');
      }
    } catch (e) {
      marketError('Market error: $e');
      print('❌ Error fetching featured market: $e');
    } finally {
      isLoadingMarket(false);
      isLoadingMoreMarket(false);
      _isFetchingMarket = false;
    }
  }

  // LOAD MORE MARKET PROPERTIES
  Future<void> loadMoreFeaturedMarket() async {
    if (!marketHasMore.value || isLoadingMoreMarket.value) {
      return;
    }

    await fetchFeaturedMarket(loadMore: true);
  }

  // FETCH FEATURED GIOO PLOTS (WITH PAGINATION)
  Future<void> fetchFeaturedGioo({bool loadMore = false}) async {
    try {
      if (_isFetchingGioo && !loadMore) {
        print('⏸️ GIOO fetch already in progress');
        return;
      }

      if (loadMore && !giooHasMore.value) {
        print('🛑 No more GIOO plots to load');
        return;
      }

      _isFetchingGioo = true;

      if (loadMore) {
        isLoadingMoreGioo(true);
      } else {
        isLoadingGioo(true);
        giooError('');
      }

      final page = loadMore ? giooCurrentPage.value + 1 : 1;
      final url = '${ApiUrl.featuredGioo}?page=$page';

      print('🌐 Fetching featured GIOO from: $url');

      final response = await ApiService.getRequest(url);

      if (response.statusCode == 200) {
        final responseData = response.data;
        print('📦 Featured GIOO API Response: $responseData');

        if (responseData != null &&
            responseData['status'] == 200 &&
            responseData['data'] != null) {

          final giooResponse =
          GiooResponse.fromJson(responseData['data']);

          if (loadMore) {
            featuredGiooPlots.addAll(giooResponse.giooPlots);
          } else {
            featuredGiooPlots.assignAll(giooResponse.giooPlots);
          }

          giooPagination.value = giooResponse.pagination;
          giooCurrentPage.value = giooResponse.pagination.currentPage;
          giooTotalPages.value = giooResponse.pagination.lastPage;
          giooHasMore.value = giooResponse.pagination.hasMorePages;

          print('✅ Loaded ${featuredGiooPlots.length} featured GIOO plots');
        } else {
          giooError('Invalid GIOO response format');
        }
      } else {
        giooError('Failed to load GIOO: ${response.statusCode}');
      }
    } catch (e) {
      giooError('GIOO error: $e');
    } finally {
      isLoadingGioo(false);
      isLoadingMoreGioo(false);
      _isFetchingGioo = false;
    }
  }

  // LOAD MORE GIOO PLOTS
  Future<void> loadMoreFeaturedGioo() async {
    if (!giooHasMore.value || isLoadingMoreGioo.value) {
      return;
    }

    await fetchFeaturedGioo(loadMore: true);
  }

  // ========== GETTER METHODS FOR UI ==========
  bool get isLoading => isLoadingLocation.value || isLoadingFeaturedData.value;

  List<FeaturedBanner> get activeBanners {
    return featuredBanners.where((banner) => banner.image.isNotEmpty).toList();
  }

  List<FeaturedSyndicate> get topSyndicates {
    return featuredSyndicates.take(3).toList();
  }

  List<FeaturedMarketProperty> get topMarketProperties {
    return featuredMarketProperties.where((property) => property.isVerified).take(3).toList();
  }

  List<FeaturedMarketProperty> get verifiedProperties {
    return featuredMarketProperties.where((property) => property.isVerified).toList();
  }

  List<GiooPlot> get topGiooPlots {
    return featuredGiooPlots.take(3).toList();
  }

  // ========== SEARCH METHODS ==========
  List<FeaturedSyndicate> searchSyndicates(String query) {
    if (query.isEmpty) return featuredSyndicates;

    return featuredSyndicates.where((syndicate) =>
    syndicate.name.toLowerCase().contains(query.toLowerCase()) ||
        syndicate.address.toLowerCase().contains(query.toLowerCase()) ||
        syndicate.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  List<FeaturedMarketProperty> searchMarketProperties(String query) {
    if (query.isEmpty) return featuredMarketProperties;

    return featuredMarketProperties.where((property) =>
    property.name.toLowerCase().contains(query.toLowerCase()) ||
        property.address.toLowerCase().contains(query.toLowerCase()) ||
        property.description.toLowerCase().contains(query.toLowerCase()) ||
        property.propertyTypeName.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  List<GiooPlot> searchGiooPlots(String query) {
    if (query.isEmpty) return featuredGiooPlots;

    return featuredGiooPlots.where((plot) =>
    plot.name.toLowerCase().contains(query.toLowerCase()) ||
        plot.address.toLowerCase().contains(query.toLowerCase()) ||
        plot.description.toLowerCase().contains(query.toLowerCase()) ||
        plot.propertyTypeName.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // ========== GET PROPERTY BY ID ==========
  FeaturedSyndicate? getSyndicateById(int id) {
    try {
      return featuredSyndicates.firstWhere((syndicate) => syndicate.id == id);
    } catch (e) {
      return null;
    }
  }

  FeaturedMarketProperty? getMarketPropertyById(int id) {
    try {
      return featuredMarketProperties.firstWhere((property) => property.id == id);
    } catch (e) {
      return null;
    }
  }

  GiooPlot? getGiooPlotById(int id) {
    try {
      return featuredGiooPlots.firstWhere((plot) => plot.id == id);
    } catch (e) {
      return null;
    }
  }

  // ========== ERROR CHECKING ==========
  bool get hasLocationError => locationError.value.isNotEmpty;
  bool get hasServiceError => serviceError.value.isNotEmpty;
  bool get hasMaterialError => materialError.value.isNotEmpty;
  bool get hasBannerError => bannerError.value.isNotEmpty;
  bool get hasSyndicateError => syndicateError.value.isNotEmpty;
  bool get hasMarketError => marketError.value.isNotEmpty;
  bool get hasGiooError => giooError.value.isNotEmpty;

  bool get hasAnyError => hasLocationError ||
      hasServiceError ||
      hasMaterialError ||
      hasBannerError ||
      hasSyndicateError ||
      hasMarketError ||
      hasGiooError;

  // ========== CLEAR ERRORS ==========
  void clearErrors() {
    locationError('');
    serviceError('');
    materialError('');
    bannerError('');
    syndicateError('');
    marketError('');
    giooError('');
  }

  // ========== REFRESH INDIVIDUAL SECTIONS ==========
  Future<void> refreshServices() => fetchServices();
  Future<void> refreshMaterials() => fetchMaterials();
  Future<void> refreshBanners() => fetchBanners();
  Future<void> refreshSyndicates() => fetchFeaturedSyndicates();
  Future<void> refreshMarket() => fetchFeaturedMarket();
  Future<void> refreshGioo() => fetchFeaturedGioo();
  Future<void> refreshPlots() => fetchFeaturedPlots();


  // ========== HELPER METHODS FOR SERVICES AND MATERIALS ==========
  String getServiceImage(int index) {
    if (index < services.length) {
      return services[index]['image'] ?? '';
    }
    return '';
  }

  String getServiceTitle(int index) {
    if (index < services.length) {
      return services[index]['title'] ?? 'Service';
    }
    return 'Service';
  }

  String getMaterialImage(int index) {
    if (index < materials.length) {
      return materials[index]['image'] ?? '';
    }
    return '';
  }

  String getMaterialTitle(int index) {
    if (index < materials.length) {
      return materials[index]['title'] ?? 'Material';
    }
    return 'Material';
  }

  @override
  void onClose() {
    clearErrors();
    super.onClose();
  }
}