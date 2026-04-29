import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/loader.dart';
import '../../payment/controller/razorpay_controller.dart';
import '../controller/rental_yield_controller.dart';
import '../model/rental_yeild_model.dart';
import '../widget/about_rental_yeild.dart';
import '../widget/legal_documents.dart';

class RentalPropertyDetailsScreen extends StatefulWidget {
  final int? id;
  final String? title;

  RentalPropertyDetailsScreen({
    super.key,
    this.id,
    this.title,
  });

  @override
  State<RentalPropertyDetailsScreen> createState() => _RentalPropertyDetailsScreenState();
}

class _RentalPropertyDetailsScreenState extends State<RentalPropertyDetailsScreen> {
  final RentalYieldController controller = Get.put(RentalYieldController());
  final razorpayController = Get.put(RazorpayController());

  @override
  void initState() {
    super.initState();
    _fetchPropertyDetails();
  }

  Future<void> _fetchPropertyDetails() async {
    try {
      if (widget.id == null) {
        return;
      }
      controller.clearPropertyDetailsCache();
      await controller.getPropertyDetails(widget.id!);
    } catch (e) {
      print('Error in initState: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DynamicAppBar(
        title: widget.title ?? 'Rental Property Details',
        showBackButton: true,
      ),
      body: Obx(() => _buildBody()),
    );
  }

  Widget _buildBody() {
    // Get loading state from controller
    if (controller.isLoadingDetail.value) {
      return _buildLoadingIndicator();
    }

    // Get property details from controller
    final property = controller.rentalDetail.value;

    if (property == null) {
      return _buildNoDataAvailable();
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                AboutPlot(property: property),
                if (property.documents.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  RentalLegalDocumentsScreen(
                    propertyId: property.id,
                    propertyName: property.name,
                    documentPrice: property.totalDocumentPrice,
                    documents: property.documents,
                    hasPaid: property.hasPaidForDocuments,
                  ),
                  const SizedBox(height: 45),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const GifLoader(message: "Loading property details...", size: 100),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildNoDataAvailable() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.real_estate_agent_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            "No Property Details Available",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "This rental property information is currently unavailable",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (widget.id != null)
            ElevatedButton(
              onPressed: () {
                // Clear cache and fetch again
                controller.clearPropertyDetailsCache();
                _fetchPropertyDetails();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
              child: const Text(
                "Try Again",
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}