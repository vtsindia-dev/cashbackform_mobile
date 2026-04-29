import 'package:cashback_farms/common/colours.dart';
import 'package:cashback_farms/common/widget/loader.dart';
import 'package:cashback_farms/features/service/controller/service_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

  // Design tokens
  static const Color _ink = Color(0xFF0D1117);
  static const Color _gold = Color(0xFFE8A020);
  static const Color _goldLight = Color(0xFFFFF3DC);
  static const Color _surface = Color(0xFFFAFAFA);
  static const Color _card = Color(0xFFFFFFFF);
  static const Color _muted = Color(0xFF6B7280);
  static const Color _border = Color(0xFFF0F0F0);
  static const Color _accent1 = Color(0xFF1A6B3C);
  static const Color _accent1Bg = Color(0xFFECFDF5);
  static const Color _accent2 = Color(0xFF1A56DB);
  static const Color _accent2Bg = Color(0xFFEFF6FF);

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
    final size = MediaQuery.of(context).size;
    final top = MediaQuery.of(context).padding.top;

    return GetBuilder<ServiceController>(
      builder: (controller) {
        if (controller.isVendorDetailLoading) {
          return const Scaffold(backgroundColor: _surface, body: Center(child: GifLoader()));
        }
        final vendor = controller.vendorDetail;
        final brandList = controller.brandList;

        if (vendor == null) {
          return Scaffold(
            backgroundColor: _surface,
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _goldLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.store_outlined, size: 36, color: _gold),
                  ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 16),
                  const Text('No Vendor Found',
                      style: TextStyle(fontSize: 16, color: _muted, fontWeight: FontWeight.w500)),
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
          backgroundColor: _surface,
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: size.height * 0.30,
                pinned: true,
                elevation: 0,
                backgroundColor: _ink,
                leading: GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    margin: EdgeInsets.only(left: 14, top: 8, bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Background image or gradient
                      imageUrl.isNotEmpty
                          ? Image.network(imageUrl, fit: BoxFit.cover)
                          : Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF0D1117), Color(0xFF1A2940)],
                          ),
                        ),
                      ),
                      // Dark overlay with diagonal gradient
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x22000000),
                              Color(0xCC000000),
                            ],
                            stops: [0.3, 1.0],
                          ),
                        ),
                      ),
                      // Diagonal accent line
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_gold, Color(0xFFFAD85B), _gold],
                            ),
                          ),
                        ),
                      ),
                      // Vendor info at bottom
                      Positioned(
                        bottom: 20,
                        left: 16,
                        right: 16,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Avatar with gold border
                            Container(
                              width: size.width * 0.14,
                              height: size.width * 0.14,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [_gold, Color(0xFFFAD85B)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: _gold.withOpacity(0.4),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  initials,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: size.width * 0.055,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ).animate().slideX(begin: -0.3, duration: 500.ms, curve: Curves.easeOut),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    vendor.name,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: size.width * 0.05,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.2,
                                    ),
                                  ).animate().fadeIn(delay: 100.ms, duration: 500.ms),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_rounded, color: _gold, size: 12),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          vendor.address ?? '',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.65),
                                            fontSize: size.width * 0.03,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                                ],
                              ),
                            ),
                            // Rating pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: _gold,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: _gold.withOpacity(0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.white, size: 13),
                                  const SizedBox(width: 3),
                                  Text(
                                    rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().scale(delay: 300.ms, duration: 400.ms, curve: Curves.elasticOut),
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
                _buildInfoStrip(vendor, rating, size),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _buildContactSection(vendor, size),
                        _buildAddReviewSection(size),
                        _buildTabSection(vendor, brandList, size),
                        SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
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

  Widget _buildInfoStrip(vendor, double rating, Size size) {
    return Container(
      color: _card,
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04, vertical: 12),
      child: Row(
        children: [
          _buildInfoChip(
            icon: Icons.verified_rounded,
            label: 'GST: ${vendor.gst ?? 'N/A'}',
            color: _accent2,
            bgColor: _accent2Bg,
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
          const SizedBox(width: 8),
          _buildInfoChip(
            icon: Icons.calendar_today_rounded,
            label: vendor.estimateDate ?? 'Est: N/A',
            color: const Color(0xFFD97706),
            bgColor: const Color(0xFFFFFBEB),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideX(begin: -0.2),
          const Spacer(),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _accent1Bg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _accent1.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: _accent1, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                const Text('Active',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _accent1)),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideX(begin: 0.2),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildRatingChip(double rating) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _goldLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: _gold, size: 14),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFB45309)),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(vendor.Vendor? vendor, Size size) {
    return Container(
      margin: EdgeInsets.fromLTRB(size.width * 0.04, 14, size.width * 0.04, 0),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_gold, Color(0xFFFAD85B)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Contact Details',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              children: [
                _buildContactRow(
                  icon: Icons.phone_rounded,
                  text: vendor?.phone ?? 'N/A',
                  iconBg: const Color(0xFFDCFCE7),
                  iconColor: const Color(0xFF16A34A),
                  onTap: () {
                    if ((vendor?.phone ?? '').isNotEmpty) _launchPhone(vendor!.phone);
                  },
                ).animate().fadeIn(delay: 50.ms).slideX(begin: 0.1),
                const Divider(height: 1, color: _border, indent: 42),
                const SizedBox(height: 8),
                _buildContactRow(
                  icon: Icons.location_on_rounded,
                  text: vendor?.address ?? 'No Address',
                  iconBg: const Color(0xFFFFEDD5),
                  iconColor: const Color(0xFFEA580C),
                  onTap: () => _launchMap(vendor?.address ?? ''),
                ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1),
                if (vendor?.email != null) ...[
                  const Divider(height: 1, color: _border, indent: 42),
                  const SizedBox(height: 8),
                  _buildContactRow(
                    icon: Icons.email_rounded,
                    text: vendor?.email ?? 'N/A',
                    iconBg: const Color(0xFFFEE2E2),
                    iconColor: const Color(0xFFDC2626),
                    onTap: () => _launchEmail(vendor?.email ?? ''),
                  ).animate().fadeIn(delay: 150.ms).slideX(begin: 0.1),
                ],
                if (vendor?.website != null) ...[
                  const Divider(height: 1, color: _border, indent: 42),
                  const SizedBox(height: 8),
                  _buildContactRow(
                    icon: Icons.language_rounded,
                    text: vendor?.website ?? '',
                    iconBg: const Color(0xFFE0E7FF),
                    iconColor: const Color(0xFF4F46E5),
                    onTap: () => _launchWebsite(vendor?.website ?? ''),
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
                ],
              ],
            ),
          ),
          // Social section
          Container(
            margin: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Text(
                  'Follow us',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _muted),
                ),
                const SizedBox(width: 14),
                _buildSocialRow(vendor),
              ],
            ),
          ).animate().fadeIn(delay: 250.ms),
        ],
      ),
    );
  }

  Future<void> _launchPhone(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    await launchUrl(uri);
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri(scheme: 'mailto', path: email);
    await launchUrl(uri);
  }

  Future<void> _launchWebsite(String url) async {
    if (!url.startsWith('http')) url = 'https://$url';
    final Uri uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _launchMap(String address) async {
    final Uri uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
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
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 15, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  style: const TextStyle(fontSize: 13, color: _ink),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1),
            ),
            Icon(Icons.chevron_right_rounded, size: 16, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialRow(vendor.Vendor? vendor) {
    return Row(
      children: [
        _socialBtn('assets/images/instagram.png', () => _openUrl(vendor?.instagram)),
        const SizedBox(width: 10),
        _socialBtn('assets/images/twitter.png', () => _openUrl(vendor?.x)),
        const SizedBox(width: 10),
        _socialBtn('assets/images/youtube.png', () => _openUrl(vendor?.youtube)),
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
            colors: [_gold, Color(0xFFFAD85B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Color(0x30E8A020), blurRadius: 8, offset: Offset(0, 3))],
        ),
        child: Center(
          child: Image.asset(asset,
              height: 17,
              color: Colors.white,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.link, size: 16, color: Colors.white)),
        ),
      ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
    );
  }

  Widget _buildTabSection(vendor, List<vendor.Brand>? brandList, Size size) {
    return Container(
      margin: EdgeInsets.fromLTRB(size.width * 0.04, 14, size.width * 0.04, 0),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Custom tab bar
          Container(
            decoration: const BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              labelColor: _ink,
              unselectedLabelColor: _muted,
              indicator: BoxDecoration(
                color: _goldLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _gold.withOpacity(0.3)),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              labelStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
              unselectedLabelStyle:
              const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
              tabs: const [
                Tab(text: 'Products'),
                Tab(text: 'Services'),
                Tab(text: 'About'),
                Tab(text: 'Reviews'),
                Tab(text: 'Photos'),
                Tab(text: 'Brand'),
              ],
            ),
          ),
          Container(height: 1, color: _border),
          SizedBox(
            height: size.height * 0.40,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductsTab(vendor),
                _buildServicesTab(vendor),
                _buildAboutTab(vendor),
                _buildReviewsTab(vendor),
                _buildPhotosTab(vendor),
                _buildBrandTab(brandList),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.05);
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
                          child: CircularProgressIndicator(color: Colors.white));
                    },
                    errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image, color: Colors.white, size: 50)),
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
              insetPadding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * 0.05,
              ),
              backgroundColor: _card,
              surfaceTintColor: _card,
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
                        Expanded(
                          child: Text(
                            "Enquire for $title",
                            style: const TextStyle(
                                fontSize: 17, fontWeight: FontWeight.w800, color: _ink),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close_rounded, color: _muted),
                          visualDensity: VisualDensity.compact,
                        )
                      ],
                    ),
                    const Divider(height: 20, thickness: 0.5, color: _border),
                    const Text("Quantity & Unit",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: _muted, fontSize: 12)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: _surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _border),
                          ),
                          child: Row(
                            children: [
                              _buildStepperBtn(Icons.remove, () {
                                if (controller.quantity > 1) {
                                  controller.quantity--;
                                  controller.quantityController.text =
                                      controller.quantity.toString();
                                  controller.update();
                                }
                              }),
                              SizedBox(
                                width: 50,
                                child: TextField(
                                  controller: controller.quantityController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(border: InputBorder.none),
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
                                controller.quantityController.text =
                                    controller.quantity.toString();
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
                              border: Border.all(color: _border),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: controller.isUnitLoading
                                  ? const Center(child: CircularProgressIndicator())
                                  : DropdownButton<String>(
                                isExpanded: true,
                                dropdownColor: _card,
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
                    const Text("Your Requirement",
                        style: TextStyle(
                            fontWeight: FontWeight.w600, color: _muted, fontSize: 12)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: controller.productQuoteController,
                      maxLines: 4,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "E.g. I need specific dimensions or urgent delivery...",
                        hintStyle: const TextStyle(color: _muted, fontSize: 13),
                        filled: true,
                        fillColor: _surface,
                        contentPadding: const EdgeInsets.all(16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: _gold, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _gold,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
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
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white))
                            : const Text("Send Enquiry",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
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
        child: Icon(icon, size: 20, color: _ink),
      ),
    );
  }

  Widget _buildProductsTab(vendor.Vendor vendor) {
    final materials = vendor.vendorMaterials ?? [];
    if (materials.isEmpty) return _buildEmptyState('No products listed', Icons.inventory_2_outlined);
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: materials.length,
      separatorBuilder: (_, __) => const Divider(height: 1, color: _border),
      itemBuilder: (context, index) {
        final material = materials[index].material;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _showFullImage(
                    context, material.image.isNotEmpty ? material.image.first : ''),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    material.image.isNotEmpty ? material.image.first : '',
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                          color: _surface, borderRadius: BorderRadius.circular(12)),
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
                    Text(material.materialName,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
                    const SizedBox(height: 2),
                    const Text('Agricultural Material',
                        style: TextStyle(fontSize: 11, color: _muted)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showEnquiryPopup(
                    context, material.materialName, material.id.toString()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [_gold, Color(0xFFFAD85B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                          color: _gold.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3))
                    ],
                  ),
                  child: const Text('Quote',
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ).animate(delay: Duration(milliseconds: index * 40)).fadeIn().slideX(begin: 0.05),
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
      separatorBuilder: (_, __) => const Divider(height: 1, color: _border),
      itemBuilder: (context, index) {
        final service = services[index].service;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _showFullImage(
                    context, service.image.isNotEmpty ? service.image.first : ''),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    service.image.isNotEmpty ? service.image.first : '',
                    width: 52,
                    height: 52,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                          color: _surface, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.home_repair_service_outlined,
                          color: Color(0xFFD1D5DB)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(service.serviceName,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
              ),
              GestureDetector(
                onTap: () => showEnquiryBottomSheet(service.id.toString()),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _accent1Bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _accent1.withOpacity(0.2)),
                  ),
                  child: const Text('Quote',
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700, color: _accent1)),
                ),
              ),
            ],
          ).animate(delay: Duration(milliseconds: index * 40)).fadeIn().slideX(begin: 0.05),
        );
      },
    );
  }

  void showEnquiryBottomSheet(String serviceId) {
    Get.bottomSheet(
      GetBuilder<ServiceController>(
        builder: (controller) {
          return Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 16,
            ),
            decoration: const BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                          color: _border, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [_gold, Color(0xFFFAD85B)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text("Request Service",
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w800, color: _ink)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.quoteController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Tell us more about your requirements...",
                      filled: true,
                      fillColor: _surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _gold, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("Preferred Date & Time",
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700, color: _ink)),
                  const SizedBox(height: 10),
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
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                        backgroundColor: _ink,
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
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                          : const Text("Send Request",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSelectionTile(
      {required String label, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(12),
          color: _surface,
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: _gold),
            const SizedBox(width: 8),
            Flexible(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w500),
                  maxLines: 1),
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
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [_gold, Color(0xFFFAD85B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text('About the Company',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: _ink)),
            ],
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 10),
          Text(
            vendor?.description != null && vendor!.description!.isNotEmpty
                ? vendor.description!
                : 'No description available',
            style: const TextStyle(fontSize: 13, color: _muted, height: 1.75),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTag('TIN: ${vendor?.taxNumber ?? 'N/A'}', _surface, _muted),
              _buildTag('Fax: ${vendor?.fax ?? 'N/A'}', _accent1Bg, _accent1),
              _buildTag('Est: ${vendor?.estimateDate ?? 'N/A'}', _accent2Bg, _accent2),
            ]
                .asMap()
                .entries
                .map((e) =>
                e.value.animate(delay: Duration(milliseconds: 150 + e.key * 60)).fadeIn().scale())
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.15)),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: textColor)),
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
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _goldLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _gold.withOpacity(0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                          fontSize: 44, fontWeight: FontWeight.w900, color: _ink, height: 1),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                            (i) => Icon(
                          i < rating.floor() ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: _gold,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text('${reviews.length} reviews',
                        style: const TextStyle(fontSize: 11, color: _muted)),
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
          ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.97, 0.97)),
          const SizedBox(height: 16),
          ...reviews.asMap().entries.map((entry) {
            final index = entry.key;
            final review = entry.value;
            final user = review.user;
            final userName = user.name;
            final userInitials = userName.isNotEmpty
                ? userName.split(" ").map((e) => e[0]).take(2).join()
                : "U";
            final userRating = double.tryParse(review.rating) ?? 0;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: _goldLight,
                        backgroundImage:
                        user.avatar.isNotEmpty ? NetworkImage(user.avatar) : null,
                        child: user.avatar.isEmpty
                            ? Text(userInitials,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, color: _gold, fontSize: 13))
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userName.isNotEmpty ? userName : user.name,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600, color: _ink)),
                            Text(_formatDate(review.createdAt),
                                style: const TextStyle(fontSize: 11, color: _muted)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _goldLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star_rounded, color: _gold, size: 12),
                            const SizedBox(width: 3),
                            Text(userRating.toStringAsFixed(1),
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFB45309))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(review.review,
                      style: const TextStyle(fontSize: 12.5, color: _muted, height: 1.6)),
                ],
              ),
            ).animate(delay: Duration(milliseconds: 100 + index * 50)).fadeIn().slideY(begin: 0.05);
          }),
        ],
      ),
    );
  }

  Map<int, double> _calculateRatingDistribution(List<vendor.Review> reviews) {
    Map<int, int> countMap = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var review in reviews) {
      final rating = double.tryParse(review.rating) ?? 0;
      final rounded = rating.round().clamp(1, 5);
      countMap[rounded] = countMap[rounded]! + 1;
    }
    final total = reviews.length;
    if (total == 0) return {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    return countMap.map((key, value) => MapEntry(key, value / total));
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
          Text(label, style: const TextStyle(fontSize: 10, color: _muted)),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 5,
                backgroundColor: Colors.white.withOpacity(0.6),
                valueColor: const AlwaysStoppedAnimation<Color>(_gold),
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 24,
            child: Text('${(fraction * 128).round()}',
                style: const TextStyle(fontSize: 10, color: _muted)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddReviewSection(Size size) {
    return GetBuilder<ServiceController>(
      builder: (controller) {
        return Container(
          margin: EdgeInsets.fromLTRB(size.width * 0.04, 14, size.width * 0.04, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_gold, Color(0xFFFAD85B)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text("Write a Review",
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700, color: _ink)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(5, (index) {
                  return GestureDetector(
                    onTap: () {
                      controller.selectedRating = index + 1.0;
                      controller.update();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        index < controller.selectedRating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: _gold,
                        size: 30,
                      ).animate(
                        target: index < controller.selectedRating ? 1 : 0,
                      ).scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.0, 1.0),
                        duration: 200.ms,
                        curve: Curves.elasticOut,
                      ),
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
                  hintStyle: const TextStyle(color: _muted, fontSize: 13),
                  filled: true,
                  fillColor: _surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _gold, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _ink,
                    elevation: 0,
                    shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    controller.submitReview(vendorId: widget.vendorId);
                  },
                  child: controller.isSubmittingReview
                      ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                      : const Text("Submit Review",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.04);
      },
    );
  }

  Widget _buildPhotosTab(vendor.Vendor vendor) {
    final images = vendor.image;
    if (images.isEmpty)
      return _buildEmptyState('No photos available', Icons.photo_library_outlined);
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
          onTap: () =>
              _showFullImage(context, images.isNotEmpty ? images[index] : ''),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              images[index],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(color: _surface),
                child: const Icon(Icons.broken_image_outlined, color: Color(0xFFD1D5DB)),
              ),
            ),
          ),
        ).animate(delay: Duration(milliseconds: index * 30)).fadeIn().scale(
          begin: const Offset(0.9, 0.9),
          duration: 300.ms,
          curve: Curves.easeOut,
        );
      },
    );
  }

  Widget _buildBrandTab(List<vendor.Brand>? brand) {
    if (brand == null || brand.isEmpty) {
      return _buildEmptyState('No brands listed', Icons.branding_watermark_outlined);
    }
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: brand.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final brandDetails = brand[index];
        final logoUrl = brandDetails.logo ?? '';
        return Container(
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3)),
            ],
            border: Border.all(color: _border),
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
                  width: 56,
                  height: 56,
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
                    fontSize: 12, fontWeight: FontWeight.w600, color: _ink),
              ),
            ],
          ),
        ).animate(delay: Duration(milliseconds: index * 40)).fadeIn().scale(
          begin: const Offset(0.9, 0.9),
          duration: 350.ms,
          curve: Curves.easeOut,
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(10)),
      child: const Icon(Icons.home_repair_service_outlined, color: Color(0xFFD1D5DB)),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: _goldLight, shape: BoxShape.circle),
            child: Icon(icon, size: 30, color: _gold),
          ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
          const SizedBox(height: 12),
          Text(message,
              style: const TextStyle(color: _muted, fontSize: 13, fontWeight: FontWeight.w500))
              .animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }
}