import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
            "image":"https://admincashback.vrikshatech.in/public/uploads/property/1764415266_expand_svgrepo.com.png",

            "title": controller.areaName.isNotEmpty
                ? "${controller.areaName} Premium Plot"
                : "Premium Plot",
            "price": "9,80,000",
            "area": "1200",
            "location": controller.currentLocation,
            "description": "DTCP approved land with great surroundings.",
          },
          {
            "image":'https://admincashback.vrikshatech.in/public/uploads/property/1764252610_download%201.png',
            "title": "Luxury Villa Land",
            "price": "25,00,000",
            "area": "1500",
            "location": "Chennai, Tamil Nadu",
            "description": "Near main road, prime location.",
          },
          {
            "image":'https://admincashback.vrikshatech.in/public/uploads/property/1764416700_expand_svgrepo.com-1.png',
            "title": "Budget Friendly Plot",
            "price": "8,40,000",
            "area": "900",
            "location": controller.areaName,
            "description": "Perfect for small investment.",
          },
        ];

        return SizedBox(
          height: 230,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 0),
            itemCount: dummyList.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) {
              final item = dummyList[i];

              return SizedBox(
                width: 170,
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
                )
                    .animate()
                    .slideX(
                  begin: 0.5,
                  end: 0,
                  duration: 600.ms,
                  curve: Curves.easeOutCubic,
                )
                    .fadeIn(duration: 500.ms)
                    .scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  curve: Curves.easeOutBack,
                )
                    .then(delay: (i * 200).ms)
                    .shimmer(
                  duration: 800.ms,
                  color: Colors.white.withOpacity(0.3),
                ),
              );
            },
          ),
        );
      },
    );
  }
}