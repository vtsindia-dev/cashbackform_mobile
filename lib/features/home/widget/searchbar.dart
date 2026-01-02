import 'package:cashback_farms/common/colours.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/homecontroller.dart';

class Home_SearchBar extends StatefulWidget {
  const Home_SearchBar({super.key});

  @override
  State<Home_SearchBar> createState() => _Home_SearchBarState();
}

class _Home_SearchBarState extends State<Home_SearchBar> {
  final TextEditingController _searchController = TextEditingController();
  String recentSearch = "Chennai";

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (_) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey, width: 0.5),
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              if(recentSearch.isNotEmpty)
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.22,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Text(
                        recentSearch,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          recentSearch = "Chennai";
                        });
                      },
                      child:  GestureDetector(onTap: (){setState(() {
                        recentSearch = "";
                      });
                      }, child: Icon(Icons.close,size: 14, color: Colors.white)),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 5),
              if(recentSearch.isNotEmpty)
              Container(
                width: 2,
                height: 24,
                color: Colors.grey,
              ),

              const SizedBox(width: 5),
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColor.black, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: AppColor.black, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: "Search Your Location..",
                          hintStyle: TextStyle(
                              color: AppColor.black,
                              fontSize: 13,
                              fontWeight: FontWeight.bold
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onSubmitted: (value) {
                          _handleSearch(value);
                        },
                      ),
                    ),

                    if (_searchController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                        child: const Icon(Icons.close, color: Colors.grey, size: 16),
                      )
                  ],
                ),
              ),

              // Search Button
              InkWell(
                onTap: () {
                  _handleSearch(_searchController.text);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColor.primary, AppColor.primarylite],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Search",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleSearch(String value) {
    if (value.trim().isNotEmpty) {
      setState(() {
        recentSearch = value.trim();
        _searchController.clear();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}