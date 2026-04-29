import 'package:cashback_farms/common/api_constant.dart';
import 'package:cashback_farms/common/model/logger_model.dart';
import 'package:cashback_farms/common/widget/api_service.dart';
import 'package:cashback_farms/features/search/model/common_search_model.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class FilterModel {
  final String title;
  final String value;

    FilterModel({required this.title, required this.value});
}

class CommonSearchController extends GetxController {
  List<FilterModel> filterCategoryItems = [
    FilterModel(title: 'All', value: 'all'),
    FilterModel(title: 'Land', value: 'market'),
    FilterModel(title: 'Gioo Nano Plots', value: 'geo'),
    FilterModel(title: 'GIO Rental Syndicate', value: 'syndicate'),
    FilterModel(title: 'GIO Rental Yield', value: 'rental'),
    FilterModel(title: 'Flats / Villas', value: 'plot'),
  ];

  int selectedIndex = 0;
  final TextEditingController searchTextController = TextEditingController();

  void selectCategory(int index) {
    selectedIndex = index;
    resetSearch();
    update();
  }

  bool isLoading = false;
  bool isLoadMore = false;
  int currentPage = 1;
  int totalPages = 1;

  List<CommonSearchModel> searchList = [];
  List<CommonSearchModel> suggestionList = [];
  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();
    searchTextController.addListener(_onSearchTextChanged);
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchTextController.removeListener(_onSearchTextChanged);
    searchTextController.dispose();
    super.onClose();
  }

  void _onSearchTextChanged() {
    // Clear suggestions immediately when text is empty
    if (searchTextController.text.isEmpty) {
      suggestionList.clear();
      update();
      return;
    }

    // Debounce the API call for non-empty text
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (searchTextController.text.isNotEmpty) {
        fetchSuggestions();
      }
    });
  }

  Future<void> fetchSuggestions() async {
    try {
      String url = "${ApiUrl.searchApi}?page=1&per_page=10";
      String selectedCategory = filterCategoryItems[selectedIndex].value;

      if (selectedCategory != "all") {
        url += "&property_type=$selectedCategory";
      }
      if (searchTextController.text.isNotEmpty) {
        url += "&search=${searchTextController.text}";
      }

      final response = await ApiService.getRequest(url);

      if (response.data != null) {
        List list = response.data['data']?['items'] ?? [];
        List<CommonSearchModel> tempList = list.map((e) => CommonSearchModel.fromJson(e)).toList();
        suggestionList = tempList;
        update();
      }
    } catch (e) {
      Loggers.error('Suggestion Error :: $e');
      suggestionList = [];
      update();
    }
  }

  Future<void> resetSearch() async {
    searchList.clear();
    suggestionList.clear();
    currentPage = 1;
    totalPages = 1;
    isLoadMore = false;
    isLoading = true;
    update();

    await fetchSearch(isInitialLoad: true);
  }

  Future<void> fetchSearch({bool isInitialLoad = true}) async {
    if (isInitialLoad) {
      searchList.clear();
      currentPage = 1;
      totalPages = 1;
      isLoading = true;
    } else {
      isLoadMore = true;
    }

    update();

    try {
      String url = "${ApiUrl.searchApi}?page=$currentPage&per_page=10";
      String selectedCategory = filterCategoryItems[selectedIndex].value;

      if (selectedCategory != "all") {
        url += "&property_type=$selectedCategory";
      }
      if (searchTextController.text.isNotEmpty) {
        url += "&search=${searchTextController.text}";
      }
      final response = await ApiService.getRequest(url);

      if (response.data != null) {
        List list = response.data['data']?['items'] ?? [];
        totalPages = response.data['data']?['pagination']?['last_page'] ?? 1;
        List<CommonSearchModel> tempList = list.map((e) => CommonSearchModel.fromJson(e)).toList();
        if (isInitialLoad) {
          searchList = tempList;
        } else {
          final newItems = tempList.where((newItem) =>
          !searchList.any((old) => old.id == newItem.id)).toList();
          searchList.addAll(newItems);
        }
        suggestionList.clear();
      }
    } catch (e) {
      Loggers.error('Search Error :: $e');
    }

    isLoading = false;
    isLoadMore = false;
    update();
  }

  void loadMoreSearch() {
    if (currentPage < totalPages && !isLoadMore) {
      currentPage++;
      fetchSearch(isInitialLoad: false);
    }
  }
}