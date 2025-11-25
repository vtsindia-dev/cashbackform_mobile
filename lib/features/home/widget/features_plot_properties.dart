import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Properties/widget/property_card.dart';
import '../controller/homecontroller.dart';

class FeaturesPlotProperties extends StatelessWidget {
  const FeaturesPlotProperties({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      builder: (controller) {
        final List<Map<String, dynamic>> dummyList = [
          {
            "image": "https://picsum.photos/500/300",
            "title": controller.areaName.isNotEmpty
                ? "${controller.areaName} Premium Plot"
                : "Premium Plot",
            "price": "9,80,000",
            "area": "1200",
            "location": controller.currentLocation,
            "description": "DTCP approved land with great surroundings.",
          },
          {
            "image": "https://picsum.photos/510/300",
            "title": "Luxury Villa Land",
            "price": "25,00,000",
            "area": "1500",
            "location": "Chennai, Tamil Nadu",
            "description": "Near main road, prime location.",
          },
          {
            "image": "https://picsum.photos/520/300",
            "title": "Budget Friendly Plot",
            "price": "8,40,000",
            "area": "900",
            "location": controller.areaName,
            "description": "Perfect for small investment.",
          },
        ];

         return SizedBox(
          height: 253,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 0),
            itemCount: dummyList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final item = dummyList[i];

              return SizedBox(
                width: 180,
                child: PropertyCard(
                  imageUrl: item["image"],
                  title: item["title"],
                  price: item["price"],
                  area: item["area"],
                  location: item["location"],
                  description: item["description"],
                  onTap: () {
                    print("View: ${item['title']}");
                  },
                ),
              );
            },
          ),
        );
        ;
      },
    );
  }
}
