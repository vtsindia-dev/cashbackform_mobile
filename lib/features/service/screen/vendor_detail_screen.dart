import 'package:cashback_farms/common/colours.dart';
import 'package:cashback_farms/common/widget/loader.dart';
import 'package:cashback_farms/features/service/controller/service_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../model/service_model.dart' as vendor;

class VendorDataDetailScreen extends StatefulWidget {
  final String vendorId;
  final String vendorTitle;

  const VendorDataDetailScreen({
    super.key,
    required this.vendorId,
    required this.vendorTitle,
  });

  @override
  State<VendorDataDetailScreen> createState() => _VendorDataDetailScreenState();
}

class _VendorDataDetailScreenState extends State<VendorDataDetailScreen>
    with SingleTickerProviderStateMixin {
  final ServiceController controller = Get.put(ServiceController());
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchVendorDetail(id: widget.vendorId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServiceController>(
      builder: (controller) {
        if (controller.isVendorDetailLoading) {
          return const Scaffold(body: Center(child: GifLoader()));
        }
        final vendor = controller.vendorDetail;
        final brandList = controller.brandList;

        if (vendor == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.store_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'No Vendor Found',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          );
        }

        final imageUrl = (vendor.thumbnail != null && vendor.thumbnail!.isNotEmpty)
            ? vendor.thumbnail!
            : (vendor.image.isNotEmpty ? vendor.image.first : "");

        final rating = double.tryParse(vendor.reviewsAvgRating ?? "0") ?? 0;
        final initials = vendor.name.isNotEmpty
            ? vendor.name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join()
            : '??';

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: AppColor.primary,
                leading: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      imageUrl.isNotEmpty
                          ? Image.network(imageUrl, fit: BoxFit.cover)
                          : Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF0F3460), Color(0xFF16213E)],
                          ),
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xCC000000)],
                            stops: [0.4, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 80,
                        right: 16,
                        child: _buildVerifiedBadge(),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEB821),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vendor.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    vendor.address??'',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.65),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            body: Column(
              children: [
                _buildInfoStrip(vendor, rating),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildContactSection(vendor),
                        _buildAddReviewSection(),
                        _buildTabSection(vendor,brandList),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerifiedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFEB821).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFEB821).withOpacity(0.4)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, color: Color(0xFFFEB821), size: 12),
          SizedBox(width: 4),
          Text(
            'Verified Vendor',
            style: TextStyle(color: Color(0xFFFEB821), fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoStrip(vendor, double rating) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          _buildInfoChip(
            icon: Icons.assignment_turned_in_rounded,
            label: 'GST: ${vendor.gst ?? 'N/A'}',
            color: const Color(0xFF1A73E8),
            bgColor: const Color(0xFFE8F1FE),
          ),
          const SizedBox(width: 8),
          _buildInfoChip(
            icon: Icons.timer_rounded,
            label: vendor.estimateDate ?? 'Est:- ${vendor.estimateDate??''}',
            color: const Color(0xFFF97316),
            bgColor: const Color(0xFFFFF1E6),
          ),
          const Spacer(),
          _buildRatingChip(rating),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingChip(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFFB45309),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(vendor.Vendor? vendor) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CONTACT DETAILS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9CA3AF),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 12),
            _buildContactRow(
              icon: Icons.phone_rounded,
              text: vendor?.phone ??'N/A',
              iconBg: const Color(0xFFDCFCE7),
              iconColor: const Color(0xFF16A34A),
              onTap: () {
                if ((vendor?.phone ?? '').isNotEmpty) {
                  _launchPhone(vendor!.phone);
                }
              },
            ),
            const SizedBox(height: 8),
            _buildContactRow(
              icon: Icons.location_on_rounded,
              text: vendor?.address ?? 'No Address',
              iconBg: const Color(0xFFFFEDD5),
              iconColor: const Color(0xFFEA580C),
              onTap: () {
                _launchMap(vendor?.address??'');
              },
            ),
            if (vendor?.email != null) ...[
              const SizedBox(height: 8),
              _buildContactRow(
                icon: Icons.email_rounded,
                text: vendor?.email??'N/A',
                iconBg: const Color(0xFFFEE2E2),
                iconColor: const Color(0xFFDC2626),
                onTap: () {
                  _launchEmail(vendor?.email??'');
                },
              ),
            ],
            if (vendor?.website != null) ...[
              const SizedBox(height: 8),
              _buildContactRow(
                icon: Icons.language_rounded,
                text: vendor?.website??'',
                iconBg: const Color(0xFFE0E7FF),
                iconColor: const Color(0xFF4F46E5),
                onTap: () {
                  _launchWebsite(vendor?.website??'');
                },
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'CONNECT',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF9CA3AF),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            _buildSocialRow(vendor),
          ],
        ),
      ),
    );
  }


  Future<void> _launchPhone(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    await launchUrl(uri);
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
    );
    await launchUrl(uri);
  }

  Future<void> _launchWebsite(String url) async {
    if (!url.startsWith('http')) {
      url = 'https://$url';
    }
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchMap(String address) async {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _buildContactRow({
    required IconData icon,
    required String text,
    required Color iconBg,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 15, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF374151)),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialRow(vendor.Vendor? vendor) {
    return Row(
      children: [
        _socialBtn('assets/images/instagram.png', () {
          _openUrl(vendor?.instagram);
        }),
        const SizedBox(width: 10),
        _socialBtn('assets/images/twitter.png', () {
          _openUrl(vendor?.x);
        }),
        const SizedBox(width: 10),
        _socialBtn('assets/images/youtube.png', () {
          _openUrl(vendor?.youtube);
        }),
      ],
    );
  }

  Future<void> _openUrl(String? url) async {
    if (url == null || url.isEmpty) return;

    final Uri uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  Widget _socialBtn(String asset, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFEC84B), Color(0xFFFEB821)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Color(0x40FEB821), blurRadius: 6, offset: Offset(0, 3)),
          ],
        ),
        child: Center(
          child: Image.asset(asset, height: 17, color: Colors.white,
              errorBuilder: (_, __, ___) => const Icon(Icons.link, size: 16, color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildTabSection(vendor, List<vendor.Brand>? brandList) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            padding: EdgeInsets.zero,
            labelColor: AppColor.primary,
            unselectedLabelColor: const Color(0xFF9CA3AF),
            indicatorColor: AppColor.primary,
            indicatorWeight: 2,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            tabs: const [
              Tab(text: 'Products'),
              Tab(text: 'Services'),
              Tab(text: 'About'),
              Tab(text: 'Reviews'),
              Tab(text: 'Photos'),
              Tab(text: 'Brand'),
            ],
          ),
          SizedBox(
            height: 320,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductsTab(vendor),
                _buildServicesTab(vendor),
                _buildAboutTab(vendor),
                _buildReviewsTab(vendor),
                _buildPhotosTab(vendor),
                _buildBrandTab(brandList)
              ],
            ),
          ),
        ],
      ),
    );
  }
  void _showFullImage(BuildContext context, String imageUrl) {
    if (imageUrl.isEmpty) return;

    final TransformationController controller = TransformationController();

    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),

          body: Center(
            child: GestureDetector(
              onDoubleTap: () {
                if (controller.value != Matrix4.identity()) {
                  controller.value = Matrix4.identity();
                } else {
                  controller.value = Matrix4.identity()..scale(2.0);
                }
              },
              child: InteractiveViewer(
                transformationController: controller,
                panEnabled: true,
                scaleEnabled: true,
                minScale: 1,
                maxScale: 5,
                boundaryMargin: const EdgeInsets.all(50),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      );
                    },
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEnquiryPopup(BuildContext context, String title, String serviceId) {
    showDialog(
      context: context,
      builder: (_) {
        return GetBuilder<ServiceController>(
          builder: (controller) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Enquire for $title",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87),
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close, color: Colors.grey),
                          visualDensity: VisualDensity.compact,
                        )
                      ],
                    ),
                    const Divider(height: 20, thickness: 0.5),
                    const Text("Quantity & Unit", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [

                              _buildStepperBtn(Icons.remove, () {
                                if (controller.quantity > 1) {
                                  controller.quantity--;
                                  controller.quantityController.text = controller.quantity.toString();
                                  controller.update();
                                }
                              }),
                              SizedBox(
                                width: 50,
                                child: TextField(
                                  controller: controller.quantityController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (val) {
                                    final parsed = int.tryParse(val);
                                    if (parsed != null && parsed > 0) {
                                      controller.quantity = parsed;
                                    } else {
                                      controller.quantity = 1;
                                    }
                                    controller.update();
                                  },
                                ),
                              ),
                              _buildStepperBtn(Icons.add, () {
                                controller.quantity++;
                                controller.quantityController.text = controller.quantity.toString();
                                controller.update();
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: controller.isUnitLoading
                                  ? const Center(child: CircularProgressIndicator())
                                  : DropdownButton<String>(
                                isExpanded: true,
                                dropdownColor: Colors.white,
                                hint: const Text("Unit"),
                                value: controller.selectedUnit,
                                items: controller.materialUnits
                                    .map((unit) => DropdownMenuItem<String>(
                                  value: unit.id.toString(),
                                  child: Text(unit.name ?? ""),
                                ))
                                    .toList(),
                                onChanged: (val) {
                                  controller.selectedUnit = val;
                                  controller.update();
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    const Text("Your Requirement", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: controller.productQuoteController,
                      maxLines: 4,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "E.g. I need specific dimensions or urgent delivery...",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        contentPadding: const EdgeInsets.all(16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFFEB821), width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFEB821),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: controller.isSubmittingEnquiry
                            ? null
                            : () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          controller.submitProductEnquiry(materialId: serviceId);
                        },
                        child: controller.isSubmittingEnquiry
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                            : const Text(
                          "Send Enquiry",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStepperBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }

  Widget _buildProductsTab(vendor.Vendor vendor) {
    final materials = vendor.vendorMaterials ?? [];
    if (materials.isEmpty) return _buildEmptyState('No products listed', Icons.inventory_2_outlined);
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: materials.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
      itemBuilder: (context, index) {
        final material = materials[index].material;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: (){
                  _showFullImage(context, material.image.isNotEmpty ? material.image.first : '');
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    material.image.isNotEmpty ? material.image.first : '',
                    width: 50, height: 50, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.image_outlined, color: Color(0xFFD1D5DB)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.materialName,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 2),
                    const Text('Agricultural Material', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
                  ],
                ),
              ),
              GestureDetector(
                onTap: (){
                  _showEnquiryPopup(context, material.materialName , material.id.toString());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F1FE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Get Quote', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1A73E8))),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServicesTab(vendor.Vendor vendor) {
    final services = vendor.vendorServices ?? [];
    if (services.isEmpty) return _buildEmptyState('No services listed', Icons.build_outlined);
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: services.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF3F4F6)),
      itemBuilder: (context, index) {
        final service = services[index].service;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: (){
                  _showFullImage(context, service.image.isNotEmpty ? service.image.first : '');
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    service.image.isNotEmpty ? service.image.first : '',
                    width: 50, height: 50, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.home_repair_service_outlined, color: Color(0xFFD1D5DB)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  service.serviceName,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                ),
              ),
              GestureDetector(
                onTap: (){
                  showEnquiryBottomSheet(
                    service.id.toString(),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Get Quote', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF16A34A))),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void showEnquiryBottomSheet(String serviceId) {
    Get.bottomSheet(
      GetBuilder<ServiceController>(
        builder: (controller) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const Text(
                    "Request Service",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.quoteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Tell us more about your requirements...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Preferred Date & Time",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildSelectionTile(
                              label: controller.selectedDate ?? "Preferred Date",
                              icon: Icons.calendar_today_rounded,
                              onTap: () async {
                                DateTime? picked = await showDatePicker(
                                  context: Get.context!,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  controller.selectedDate = picked.toString().split(' ')[0];
                                  controller.update();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSelectionTile(
                              label: controller.selectedTime ?? "Preferred Time",
                              icon: Icons.access_time_rounded,
                              onTap: () async {
                                TimeOfDay? picked = await showTimePicker(
                                  context: Get.context!,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (picked != null) {
                                  controller.selectedTime = picked.format(Get.context!);
                                  controller.update();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        backgroundColor: AppColor.primary
                      ),
                      onPressed: controller.isSubmittingEnquiry
                          ? null
                          : () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        controller.submitEnquiry(serviceId: serviceId);
                      },
                      child: controller.isSubmittingEnquiry
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                          : const Text("Send Request", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }


  Widget _buildSelectionTile({required String label, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColor.primary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(fontSize: 14, overflow: TextOverflow.ellipsis,fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAboutTab(vendor.Vendor? vendor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About the Company',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 8),
          Text(
              vendor?.description != null && vendor!.description!.isNotEmpty
                  ? vendor.description!
                  : 'No description available',
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.7),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTag('Tax Id No(TIN): ${vendor?.taxNumber}', const Color(0xFFF3F4F6), const Color(0xFF6B7280)),
              _buildTag('Fax Number: ${vendor?.fax}', const Color(0xFFDCFCE7), const Color(0xFF15803D)),
              _buildTag('Year Established: ${vendor?.estimateDate}', const Color(0xFFDBEAFE), const Color(0xFF1D4ED8)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: textColor)),
    );
  }


  Widget _buildReviewsTab(vendor.Vendor? vendor) {
    final rating = double.tryParse(vendor?.reviewsAvgRating ?? '0') ?? 0;
    final reviews = vendor?.reviews ?? [];
    final ratingDistribution = _calculateRatingDistribution(reviews);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF111827)),
                  ),
                  Row(
                    children: List.generate(
                      5,
                          (i) => Icon(
                        i < rating.floor()
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: const Color(0xFFF59E0B),
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${reviews.length} reviews',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _buildRatingBar('5', ratingDistribution[5] ?? 0),
                    _buildRatingBar('4', ratingDistribution[4] ?? 0),
                    _buildRatingBar('3', ratingDistribution[3] ?? 0),
                    _buildRatingBar('2', ratingDistribution[2] ?? 0),
                    _buildRatingBar('1', ratingDistribution[1] ?? 0),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF3F4F6)),
          const SizedBox(height: 12),

          ...reviews.map((review) {
            final user = review.user;
            final userName = user.name;

            final userInitials = userName.isNotEmpty
                ? userName
                .split(" ")
                .map((e) => e[0])
                .take(2)
                .join()
                : "U";

            final userRating =
                double.tryParse(review.rating) ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 17,
                        backgroundImage: user.avatar.isNotEmpty
                            ? NetworkImage(user.avatar)
                            : null,
                        child: user.avatar.isEmpty
                            ? Text(userInitials)
                            : null,
                      ),

                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName.isNotEmpty
                                ? userName
                                : user.name,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            _formatDate(review.createdAt),
                            style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9CA3AF)),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: List.generate(
                          5,
                              (i) => Icon(
                            i < userRating.floor()
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: const Color(0xFFF59E0B),
                            size: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.review,
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                        height: 1.6),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Map<int, double> _calculateRatingDistribution(List<vendor.Review> reviews) {
    Map<int, int> countMap = {
      1: 0,
      2: 0,
      3: 0,
      4: 0,
      5: 0,
    };

    for (var review in reviews) {
      final rating = double.tryParse(review.rating) ?? 0;
      final rounded = rating.round().clamp(1, 5);
      countMap[rounded] = countMap[rounded]! + 1;
    }

    final total = reviews.length;

    if (total == 0) {
      return {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    }

    return countMap.map((key, value) {
      return MapEntry(key, value / total);
    });
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) return "Today";
    if (difference == 1) return "1 day ago";
    return "$difference days ago";
  }

  Widget _buildRatingBar(String label, double fraction) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 5,
                backgroundColor: const Color(0xFFF3F4F6),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 24,
            child: Text(
              '${(fraction * 128).round()}',
              style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddReviewSection() {
    return GetBuilder<ServiceController>(
      builder: (controller) {
        return Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Write a Review",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      controller.selectedRating = index + 1.0;
                      controller.update();
                    },
                    child: Icon(
                      index < controller.selectedRating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: const Color(0xFFF59E0B),
                      size: 28,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.reviewController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: "Write your review...",
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    controller.submitReview(
                      vendorId: widget.vendorId,
                    );
                  },
                  child: controller.isSubmittingReview
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text("Submit Review",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w600),),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotosTab(vendor.Vendor vendor) {
    final images = vendor.image;
    if (images.isEmpty) return _buildEmptyState('No photos available', Icons.photo_library_outlined);
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: (){
            _showFullImage(context, images.isNotEmpty ? images[index] : '');
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              images[index],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFF3F4F6),
                child: const Icon(Icons.broken_image_outlined, color: Color(0xFFD1D5DB)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBrandTab(List<vendor.Brand>? brand) {
    if (brand == null || brand.isEmpty) {
      return _buildEmptyState('No brand listed', Icons.build_outlined);
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: brand.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final brandDetails = brand[index];
        final logoUrl = brandDetails.logo ?? '';
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: logoUrl.isNotEmpty
                    ? Image.network(
                  logoUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                )
                    : _buildPlaceholder(),
              ),
              const SizedBox(height: 8),
              Text(
                brandDetails.name ?? 'N/A',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.home_repair_service_outlined,
        color: Color(0xFFD1D5DB),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text(message, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
        ],
      ),
    );
  }
}


