import 'package:cashback_farms/common/widget/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

import '../controller/dashboard_menu_controller.dart';

class AboutUs extends StatefulWidget {
  const AboutUs({super.key, this.slug = 'about_us'});

  final String slug;

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<DashboardController>();
      controller.fetchPageData(widget.slug);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return Scaffold(
      appBar: DynamicAppBar(
        title: "About us",
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoadingPage.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasPageError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  controller.pageErrorMessage.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.refreshPageData,
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                controller.pageTitle.value.isNotEmpty
                    ? controller.pageTitle.value
                    : 'About Us',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              controller.hasPageContent
                  ? Html(
                data: controller.sanitizedPageContent,
                style: {
                  "body": Style(
                    margin: Margins.zero,
                  ),
                  "p": Style(
                    fontSize: FontSize(16),
                    lineHeight: LineHeight(1.5),
                    margin: Margins.only(bottom: 12),
                  ),
                  "h1": Style(
                    fontSize: FontSize(24),
                    fontWeight: FontWeight.bold,
                    margin: Margins.only(bottom: 16, top: 20),
                  ),
                  "h2": Style(
                    fontSize: FontSize(20),
                    fontWeight: FontWeight.bold,
                    margin: Margins.only(bottom: 12, top: 16),
                  ),
                  "h3": Style(
                    fontSize: FontSize(18),
                    fontWeight: FontWeight.w600,
                    margin: Margins.only(bottom: 10, top: 14),
                  ),
                  "ul": Style(
                    margin: Margins.only(bottom: 12),
                  ),
                  "li": Style(
                    fontSize: FontSize(16),
                    lineHeight: LineHeight(1.5),
                  ),
                },
              )
                  : Center(
                child: Column(
                  children: [
                    Icon(Icons.info_outline, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No content available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}