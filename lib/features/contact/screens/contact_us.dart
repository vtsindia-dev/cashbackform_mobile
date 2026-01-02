import 'package:cashback_farms/common/widget/appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import '../controller/contact_us_controller.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  late ContactController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ContactController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DynamicAppBar(
        title: "Contact us",
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
              Html(data: controller.content.value,style: {
                "p": Style(fontSize: FontSize(16)),
              },),
            ],
          ),
        );
      }),
    );
  }
}
