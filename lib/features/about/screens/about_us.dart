import 'package:cashback_farms/common/widget/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import '../controller/about_us_controller.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  late AboutController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AboutController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DynamicAppBar(
        title: "About us",
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.title.value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Html(
                data: controller.content.value,
                style: {
                  "p": Style(fontSize: FontSize(16)),
                },
              ),
            ],
          ),
        );

      }),
    );
  }
}
