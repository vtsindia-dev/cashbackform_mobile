import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../common/colours.dart';
import '../../../common/widget/loader.dart';
import '../../service/controller/service_controller.dart';
import '../../service/model/service_model.dart' show MaterialEnquiry;

class MyMaterialList extends StatefulWidget {
  const MyMaterialList({super.key});

  @override
  State<MyMaterialList> createState() => _MyMaterialListState();
}

class _MyMaterialListState extends State<MyMaterialList>
    with SingleTickerProviderStateMixin {
  final ServiceController controller = Get.put(ServiceController());
  final ScrollController _scrollController = ScrollController();

  static const _bg      = Color(0xFFF4F1EB);
  static const _card    = Color(0xFFFFFFFF);
  static const _ink     = Color(0xFF1A1A1A);
  static const _muted   = Color(0xFF8C8C8C);
  static const _border  = Color(0xFFEEEEEE);
  static const _gold    = Color(0xFFD4921A);
  static const _goldBg  = Color(0xFFFFF7E6);
  static const _green   = Color(0xFF2D7A3A);
  static const _greenBg = Color(0xFFEAF5EB);
  static const _h1      = Color(0xFF1A2E12);
  static const _h2      = Color(0xFF2E5020);
  late AnimationController _headerAnim;
  late Animation<double>   _headerFade;
  late Animation<Offset>   _headerSlide;

  @override
  void initState() {
    super.initState();

    _headerAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 580));
    _headerFade  = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.10), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMaterialEnquiries();
      _headerAnim.forward();
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100 &&
        !controller.isLoadMore.value &&
        controller.hasMoreData.value) {
      controller.fetchMaterialEnquiries(loadMore: true);
    }
  }

  // ── ROOT ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Column(children: [
        // ── Animated header ──────────────────────────────────────────────────
        FadeTransition(
          opacity: _headerFade,
          child: SlideTransition(position: _headerSlide,
              child: _buildHeader()),
        ),

        // ── Body ─────────────────────────────────────────────────────────────
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value &&
                controller.materialEnquiries.isEmpty) {
              return Center(
                child: GifLoader(
                    message: 'Loading your enquiries…', size: 110),
              );
            }

            if (controller.materialEnquiries.isEmpty &&
                !controller.isLoading.value) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              color: _gold,
              backgroundColor: _card,
              onRefresh: () =>
                  controller.fetchMaterialEnquiries(loadMore: false),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                itemCount: controller.materialEnquiries.length +
                    (controller.isLoadMore.value ? 1 : 0) +
                    (!controller.hasMoreData.value &&
                        controller.materialEnquiries.isNotEmpty
                        ? 1
                        : 0),
                itemBuilder: (context, index) {
                  // Load-more spinner
                  if (controller.isLoadMore.value &&
                      index == controller.materialEnquiries.length) {
                    return _buildLoadMoreIndicator();
                  }
                  // End-of-list
                  if (!controller.hasMoreData.value &&
                      controller.materialEnquiries.isNotEmpty &&
                      index == controller.materialEnquiries.length) {
                    return _buildEndOfList();
                  }
                  final enquiry = controller.materialEnquiries[index];
                  return _EnquiryCard(
                    enquiry: enquiry,
                    index: index,
                  );
                },
              ),
            );
          }),
        ),
      ]),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_h1, _h2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(children: [
        // Decorative circles
        Positioned(top: -40, right: -40,
            child: Container(width: 160, height: 160,
                decoration: BoxDecoration(shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.06)))),
        Positioned(top: 28, right: 78,
            child: Container(width: 58, height: 58,
                decoration: BoxDecoration(shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05)))),
        Positioned(bottom: -22, left: -28,
            child: Container(width: 100, height: 100,
                decoration: BoxDecoration(shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.04)))),
        // Gold accent line
        // Positioned(top: 0, left: 0, right: 0,
        //     child: Container(height: 2.5,
        //         decoration: const BoxDecoration(gradient: LinearGradient(
        //           colors: [Color(0xFFD4921A), Color(0xFFF5C842), Color(0xFFD4921A)],
        //         )))),

        SafeArea(bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back + title row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.22)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 15),
                      ),
                    ),
                    // Count badge
                    Obx(() => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.28)),
                      ),
                      child: Text(
                        '${controller.materialEnquiries.length} enquiries',
                        style: const TextStyle(color: Colors.white,
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    )),
                  ],
                ),
                const SizedBox(height: 18),

                // Title block
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('ENQUIRIES',
                      style: TextStyle(fontSize: 9.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white.withOpacity(0.6),
                          letterSpacing: 3.5)),
                  const SizedBox(height: 2),
                  const Text('My Materials',
                      style: TextStyle(fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.8,
                          height: 1.1)),
                ]),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  // ── Load-more ──────────────────────────────────────────────────────────────
  Widget _buildLoadMoreIndicator() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Center(child: Column(children: [
      const CircularProgressIndicator(color: _gold, strokeWidth: 2),
      const SizedBox(height: 10),
      Text('Loading more…', style: TextStyle(
          fontSize: 12.sp, color: _muted)),
    ])),
  );

  Widget _buildEndOfList() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 24),
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 40, height: 1, color: _border),
      const SizedBox(width: 10),
      Text('All enquiries loaded',
          style: TextStyle(fontSize: 12.sp, color: _muted)),
      const SizedBox(width: 10),
      Container(width: 40, height: 1, color: _border),
    ]),
  );

  // ── Empty state ────────────────────────────────────────────────────────────
  Widget _buildEmptyState() => Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 60),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 90, height: 90,
          decoration: const BoxDecoration(
              color: _goldBg, shape: BoxShape.circle),
          child: const Icon(Icons.inbox_outlined, size: 44, color: _gold),
        ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
        const SizedBox(height: 22),
        const Text('No Enquiries Yet',
            style: TextStyle(fontSize: 20,
                fontWeight: FontWeight.w800, color: _ink))
            .animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 10),
        Text("You haven't made any material enquiries yet.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp,
                color: _muted, height: 1.6))
            .animate().fadeIn(delay: 220.ms),
        const SizedBox(height: 30),
        GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [_h1, _h2],
                  begin: Alignment.centerLeft, end: Alignment.centerRight),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: _h1.withOpacity(0.35),
                  blurRadius: 12, offset: const Offset(0, 5))],
            ),
            child: const Text('Browse Materials',
                style: TextStyle(color: Colors.white,
                    fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Enquiry card — separate stateful widget for press animation
// ─────────────────────────────────────────────────────────────────────────────
class _EnquiryCard extends StatefulWidget {
  final MaterialEnquiry enquiry;
  final int index;
  const _EnquiryCard({required this.enquiry, required this.index});

  @override
  State<_EnquiryCard> createState() => _EnquiryCardState();
}

class _EnquiryCardState extends State<_EnquiryCard>
    with SingleTickerProviderStateMixin {
  static const _bg      = Color(0xFFF4F1EB);
  static const _card    = Color(0xFFFFFFFF);
  static const _ink     = Color(0xFF1A1A1A);
  static const _muted   = Color(0xFF8C8C8C);
  static const _border  = Color(0xFFEEEEEE);
  static const _gold    = Color(0xFFD4921A);
  static const _goldBg  = Color(0xFFFFF7E6);
  static const _green   = Color(0xFF2D7A3A);
  static const _greenBg = Color(0xFFEAF5EB);
  static const _h1      = Color(0xFF1A2E12);

  late AnimationController _enterCtrl;
  late Animation<double>   _enterFade;
  late Animation<Offset>   _enterSlide;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(vsync: this,
        duration: Duration(milliseconds: 380 + (widget.index % 6) * 55));
    _enterFade  = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _enterSlide = Tween<Offset>(
      begin: const Offset(0, 0.10), end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));

    Future.delayed(
        Duration(milliseconds: (widget.index % 8) * 55), () {
      if (mounted) _enterCtrl.forward();
    });
  }

  @override
  void dispose() { _enterCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final e = widget.enquiry;
    final name = e.material?.materialName ?? 'Material ${e.materialId}';

    return FadeTransition(
      opacity: _enterFade,
      child: SlideTransition(
        position: _enterSlide,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp:   (_) => setState(() => _pressed = false),
          onTapCancel: ()  => setState(() => _pressed = false),
          onTap: () => debugPrint('Tapped enquiry: ${e.id}'),
          child: AnimatedScale(
            scale: _pressed ? 0.975 : 1.0,
            duration: const Duration(milliseconds: 110),
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(_pressed ? 0.03 : 0.07),
                  blurRadius: _pressed ? 6 : 18,
                  offset: Offset(0, _pressed ? 2 : 7),
                )],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Column(children: [
                  // ── Top accent bar (colour = status) ─────────────────────
                  Container(height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _statusGradient(e.enquiryStatus),
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Name + status ───────────────────────────────────
                        Row(children: [
                          // Material icon badge
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: _goldBg,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.inventory_2_rounded,
                                size: 20, color: _gold),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name,
                                  style: const TextStyle(fontSize: 14,
                                      fontWeight: FontWeight.w800, color: _ink),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text('Enquiry #${e.id}',
                                  style: const TextStyle(fontSize: 10.5,
                                      color: _muted, fontWeight: FontWeight.w500)),
                            ],
                          )),
                          _statusPill(e.enquiryStatus),
                        ]),

                        // ── Quote box ───────────────────────────────────────
                        if (e.quote.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: _bg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _border),
                            ),
                            child: Text(e.quote,
                                style: const TextStyle(fontSize: 12.5,
                                    color: _muted, height: 1.55),
                                maxLines: 3, overflow: TextOverflow.ellipsis),
                          ),
                        ],

                        // ── Qty / unit chips ─────────────────────────────────
                        if (e.quantity != null || e.unitId != null) ...[
                          const SizedBox(height: 10),
                          Wrap(spacing: 7, runSpacing: 7, children: [
                            if (e.quantity != null)
                              _infoChip(Icons.production_quantity_limits_rounded,
                                  'Qty: ${e.quantity}'),
                            if (e.unitId != null)
                              _infoChip(Icons.calculate_rounded,
                                  'Unit: ${e.unitId}'),
                          ]),
                        ],

                        // ── Divider ──────────────────────────────────────────
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(height: 1, color: _border),
                        ),

                        // ── Shop + agent row ─────────────────────────────────
                        if (e.shopName.isNotEmpty)
                          _iconRow(Icons.store_rounded, e.shopName, _green),
                        if (e.agentname.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          _iconRow(Icons.person_outline_rounded,
                              e.agentname, _gold),
                        ],

                        // ── Date ─────────────────────────────────────────────
                        const SizedBox(height: 8),
                        Row(children: [
                          Icon(Icons.access_time_rounded,
                              size: 12, color: Colors.grey.shade400),
                          const SizedBox(width: 5),
                          Text(_formatDate(e.createdAt),
                              style: TextStyle(fontSize: 10.5,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w500)),
                          const Spacer(),
                          // Chevron hint
                          Icon(Icons.chevron_right_rounded,
                              size: 16, color: Colors.grey.shade300),
                        ]),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    ); 
  }

  // ── Status ────────────────────────────────────────────────────────────────
  Widget _statusPill(String status) {
    final cfg = _statusConfig(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cfg.color.withOpacity(0.3)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 5, height: 5,
            decoration: BoxDecoration(
                color: cfg.color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(status,
            style: TextStyle(fontSize: 10.5,
                fontWeight: FontWeight.w700, color: cfg.color)),
      ]),
    );
  }

  List<Color> _statusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return [const Color(0xFF2D7A3A), const Color(0xFF4CAF50)];
      case 'assigned':
        return [const Color(0xFFD4921A), const Color(0xFFF5C842)];
      case 'pending':
        return [const Color(0xFF1A56C8), const Color(0xFF4A90E2)];
      case 'rejected':
        return [const Color(0xFFDC2626), const Color(0xFFEF5350)];
      default:
        return [const Color(0xFF8C8C8C), const Color(0xFFBDBDBD)];
    }
  }

  _StatusCfg _statusConfig(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return _StatusCfg(_green, _greenBg);
      case 'assigned':
        return _StatusCfg(_gold, _goldBg);
      case 'pending':
        return _StatusCfg(const Color(0xFF1A56C8), const Color(0xFFEBF0FF));
      case 'rejected':
        return _StatusCfg(const Color(0xFFDC2626), const Color(0xFFFEE2E2));
      default:
        return _StatusCfg(_muted, const Color(0xFFF5F5F5));
    }
  }

  // ── Chip / row helpers ────────────────────────────────────────────────────
  Widget _infoChip(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: _goldBg,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _gold.withOpacity(0.25)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: _gold),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11,
          fontWeight: FontWeight.w600, color: _gold)),
    ]),
  );

  Widget _iconRow(IconData icon, String text, Color color) => Row(children: [
    Container(width: 26, height: 26,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Icon(icon, size: 13, color: color),
    ),
    const SizedBox(width: 8),
    Expanded(child: Text(text,
        style: const TextStyle(fontSize: 12, color: _ink,
            fontWeight: FontWeight.w500),
        maxLines: 1, overflow: TextOverflow.ellipsis)),
  ]);

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 7)
      return '${date.day}/${date.month}/${date.year}';
    if (diff.inDays > 0)
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    if (diff.inHours > 0)
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    if (diff.inMinutes > 0)
      return '${diff.inMinutes} min${diff.inMinutes > 1 ? 's' : ''} ago';
    return 'Just now';
  }
}

// ── Status config data class ───────────────────────────────────────────────────
class _StatusCfg {
  final Color color;
  final Color bg;
  const _StatusCfg(this.color, this.bg);
}