import 'package:cashback_farms/features/material_store/controller/material_store_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../common/widget/loader.dart';
import '../model/material_model.dart' as vendorModel;

class MaterialVendorDetailScreen extends StatefulWidget {
  final String vendorId;
  final String vendorTitle;

  const MaterialVendorDetailScreen({
    super.key,
    required this.vendorId,
    required this.vendorTitle,
  });

  @override
  State<MaterialVendorDetailScreen> createState() =>
      _MaterialVendorDetailScreenState();
}

class _MaterialVendorDetailScreenState
    extends State<MaterialVendorDetailScreen> {
  final MaterialController controller = Get.put(MaterialController());


  static const _bg      = Color(0xFFF4F1EB);
  static const _card    = Color(0xFFFFFFFF);
  static const _ink     = Color(0xFF1A1A1A);
  static const _muted   = Color(0xFF8C8C8C);
  static const _border  = Color(0xFFEEEEEE);
  static const _gold    = Color(0xFFD4921A);
  static const _goldBg  = Color(0xFFFFF7E6);
  static const _green   = Color(0xFF2D7A3A);
  static const _greenBg = Color(0xFFEAF5EB);
  static const _blue    = Color(0xFF1A56C8);
  static const _blueBg  = Color(0xFFEBF0FF);
  static const _h1      = Color(0xFF1A2E12);
  static const _h2      = Color(0xFF2E5020);

  int  _active     = 0;
  bool _hasServices = false;

  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.fetchVendorDetail(id: widget.vendorId);
      if (mounted) {
        setState(() {
        _hasServices = controller.vendorDetail?.vendorServices?.isNotEmpty ?? false;
      });
      }
    });
  }

  @override
  void dispose() { _scroll.dispose(); super.dispose(); }

  // ── URL helpers ───────────────────────────────────────────────────────────
  Future<void> _call(String p) async => launchUrl(Uri(scheme: 'tel',    path: p));
  Future<void> _mail(String e) async => launchUrl(Uri(scheme: 'mailto', path: e));
  Future<void> _map(String a)  async => launchUrl(Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(a)}'), mode: LaunchMode.externalApplication);
  Future<void> _web(String u)  async { if (!u.startsWith('http')) u='https://$u'; launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication); }
  Future<void> _url(String? u) async { if (u==null||u.isEmpty) return; launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication); }

  List<_Sec> get _secs => [
    _Sec('Products', Icons.inventory_2_rounded),
    if (_hasServices) _Sec('Services', Icons.build_circle_rounded),
    _Sec('About',   Icons.info_outline_rounded),
    _Sec('Reviews', Icons.star_rounded),
    _Sec('Photos',  Icons.photo_library_rounded),
    _Sec('Brands',  Icons.branding_watermark_rounded),
  ];

  
  @override
  Widget build(BuildContext context) {
    return GetBuilder<MaterialController>(builder: (ctrl) {
      if (ctrl.isVendorDetailLoading) {
        return Scaffold(backgroundColor: _bg, body: const Center(child: GifLoader()));
      }
      final v      = ctrl.vendorDetail;
      final brands = ctrl.brandDetailList;
      if (v == null) {
        return Scaffold(backgroundColor: _bg, appBar: _miniBar('Vendor'),
            body: _empty('Vendor not found', Icons.store_outlined));
      }
      final imgUrl  = (v.thumbnail?.isNotEmpty ?? false) ? v.thumbnail! : (v.image.isNotEmpty ? v.image.first : '');
      final rating  = double.tryParse(v.reviewsAvgRating ?? '0') ?? 0;
      final initials = v.name.trim().split(' ').take(2).map((w) => w[0].toUpperCase()).join();

      return Scaffold(
        backgroundColor: _h1,
        body: CustomScrollView(
          controller: _scroll,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              stretch: true,
              backgroundColor: _h1,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.14),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 15),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [StretchMode.zoomBackground],
                background: _hero(v, imgUrl, rating, initials),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                color: _bg,
                child: Column(children: [
                  _infoStrip(v),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                    child: _contactCard(v),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                    child: _reviewInputCard(ctrl),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 0, 0),
                    child: _pillNav(),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 36),
                    child: _activeSection(v, brands, rating, ctrl),
                  ),
                ]),
              ),
            ),
          ],
        ),
      );
    });
  }
  
  Widget _hero(vendorModel.Vendor v, String imgUrl, double rating, String initials) {
    return Stack(fit: StackFit.expand, children: [
      imgUrl.isNotEmpty
          ? Image.network(imgUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _heroGrad())
          : _heroGrad(),
      Container(decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0x44000000), Color(0xE6122007)], stops: [0.1, 1.0],
      ))),
      Positioned(top: 0, left: 0, right: 0,
        child: Container(height: 3, decoration: const BoxDecoration(gradient: LinearGradient(
          colors: [Color(0xFFD4921A), Color(0xFFF5C842), Color(0xFFD4921A)],
        ))),
      ),
      Positioned(bottom: 18, left: 16, right: 16,
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(width: 54, height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFD4921A), Color(0xFFF5C842)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: _gold.withValues(alpha:0.55), blurRadius: 14, offset: const Offset(0, 6))],
            ),
            child: Center(child: Text(initials, style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20))),
          ).animate().slideX(begin: -0.4, duration: 500.ms, curve: Curves.easeOutCubic),
          const SizedBox(width: 12),
          Expanded(child: Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(v.name, style: const TextStyle(color: Colors.white, fontSize: 18,
                    fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis)
                    .animate().fadeIn(delay: 100.ms, duration: 450.ms),
                if (v.address?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 3),
                  Row(children: [
                    const Icon(Icons.location_on_rounded, color: _gold, size: 11),
                    const SizedBox(width: 3),
                    Expanded(child: Text(v.address!, style: TextStyle(
                        color: Colors.white.withValues(alpha:0.6), fontSize: 11),
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]).animate().fadeIn(delay: 180.ms, duration: 400.ms),
                ],
              ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: _gold, borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: _gold.withValues(alpha:0.45), blurRadius: 10, offset: const Offset(0, 4))]),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.star_rounded, color: Colors.white, size: 13),
              const SizedBox(width: 3),
              Text(rating.toStringAsFixed(1), style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
            ]),
          ).animate().scale(delay: 280.ms, duration: 380.ms, curve: Curves.elasticOut),
        ]),
      ),
    ]);
  }

  Widget _heroGrad() => Container(decoration: const BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [_h1, _h2])));
  
  Widget _infoStrip(vendorModel.Vendor v) => Container(
    color: _card,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
    child: Row(children: [
      _chip(Icons.verified_rounded,  'GST: ${v.gst ?? 'N/A'}', _blue,  _blueBg),
      const SizedBox(width: 6),
      _chip(Icons.schedule_rounded,  v.estimateDate ?? 'N/A',   _gold,  _goldBg),
      const Spacer(),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: _greenBg, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _green.withValues(alpha:0.2))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 5, height: 5,
              decoration: const BoxDecoration(color: _green, shape: BoxShape.circle)),
          const SizedBox(width: 4),
          const Text('Active', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _green)),
        ]),
      ),
    ]),
  ).animate().fadeIn(duration: 300.ms);

  Widget _chip(IconData icon, String label, Color c, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.withValues(alpha:0.15))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 10, color: c), const SizedBox(width: 4),
      Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: c)),
    ]),
  );

  // ── Contact card ──────────────────────────────────────────────────────────
  Widget _contactCard(vendorModel.Vendor v) {
    final socials = <_Soc>[];
    if (v.instagram?.isNotEmpty ?? false) socials.add(_Soc('assets/images/instagram.png', const Color(0xFFE1306C), () => _url(v.instagram)));
    if (v.x?.isNotEmpty        ?? false) socials.add(_Soc('assets/images/twitter.png',   const Color(0xFF1DA1F2), () => _url(v.x)));
    if (v.youtube?.isNotEmpty  ?? false) socials.add(_Soc('assets/images/youtube.png',   const Color(0xFFFF0000), () => _url(v.youtube)));
    if (v.whatsapp?.isNotEmpty ?? false) socials.add(_Soc('assets/images/whatsapp.png',  const Color(0xFF25D366), () => _url(v.whatsapp)));

    return Container(
      decoration: _box(),
      child: Column(children: [
        _head(Icons.contacts_rounded, 'Contact & Reach'),
        const Divider(height: 1, color: _border),
        if (v.phone.isNotEmpty)       _cRow(Icons.phone_rounded,    v.phone,     const Color(0xFF16A34A), const Color(0xFFDCFCE7), () => _call(v.phone)),
        if (v.address?.isNotEmpty??false) _cRow(Icons.location_on_rounded, v.address!,  const Color(0xFFEA580C), const Color(0xFFFFEDD5), () => _map(v.address!)),
        if (v.email.isNotEmpty)   _cRow(Icons.email_rounded,       v.email,    const Color(0xFFDC2626), const Color(0xFFFEE2E2), () => _mail(v.email)),
        if (v.website?.isNotEmpty??false) _cRow(Icons.language_rounded,    v.website!,  const Color(0xFF4F46E5), const Color(0xFFE0E7FF), () => _web(v.website!)),
        if (socials.isNotEmpty) ...[
          const Divider(height: 1, color: _border),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(children: [
              Text('Follow', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _muted)),
              const SizedBox(width: 10),
              ...socials.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: e.value.onTap,
                  child: Container(width: 32, height: 32,
                    decoration: BoxDecoration(color: e.value.color.withValues(alpha:0.1),
                        shape: BoxShape.circle, border: Border.all(color: e.value.color.withValues(alpha:0.3))),
                    child: Center(child: Image.asset(e.value.asset, width: 15, height: 15,
                        errorBuilder: (_, __, ___) => Icon(Icons.link, size: 15, color: e.value.color))),
                  ).animate(delay: Duration(milliseconds: e.key * 60))
                      .scale(curve: Curves.elasticOut, duration: 350.ms),
                ),
              )),
            ]),
          ),
        ] else const SizedBox(height: 10),
      ]),
    ).animate().fadeIn(delay: 80.ms, duration: 400.ms).slideY(begin: 0.05);
  }

  Widget _cRow(IconData icon, String text, Color ic, Color bg, VoidCallback tap) =>
      InkWell(onTap: tap, child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(children: [
          Container(width: 30, height: 30,
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 14, color: ic)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12.5, color: _ink),
              overflow: TextOverflow.ellipsis, maxLines: 1)),
          Icon(Icons.chevron_right_rounded, size: 14, color: Colors.grey.shade300),
        ]),
      ));

  // ── Write review ──────────────────────────────────────────────────────────
  Widget _reviewInputCard(MaterialController ctrl) => Container(
    decoration: _box(),
    child: Column(children: [
      _head(Icons.rate_review_outlined, 'Write a Review'),
      const Divider(height: 1, color: _border),
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(children: [
          Row(children: List.generate(5, (i) => GestureDetector(
            onTap: () { ctrl.selectedRating = i + 1.0; ctrl.update(); },
            child: Padding(padding: const EdgeInsets.only(right: 3),
              child: Icon(i < ctrl.selectedRating ? Icons.star_rounded : Icons.star_border_rounded,
                color: _gold, size: 28,
              ).animate(target: i < ctrl.selectedRating ? 1 : 0)
                  .scale(begin: const Offset(0.7, 0.7), end: const Offset(1.0, 1.0),
                  duration: 200.ms, curve: Curves.elasticOut),
            ),
          ))),
          const SizedBox(height: 10),
          TextField(controller: ctrl.reviewController, maxLines: 3,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(hintText: 'Share your experience…',
              hintStyle: const TextStyle(color: _muted, fontSize: 12.5),
              filled: true, fillColor: _bg, contentPadding: const EdgeInsets.all(12),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: _gold, width: 1.5)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, height: 42,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _ink, elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: ctrl.isSubmittingReview ? null : () {
                FocusScope.of(context).unfocus();
                ctrl.submitReview(vendorId: widget.vendorId);
              },
              child: ctrl.isSubmittingReview
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Submit Review', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
        ]),
      ),
    ]),
  ).animate().fadeIn(delay: 160.ms, duration: 400.ms).slideY(begin: 0.05);

  // ── Pill nav ──────────────────────────────────────────────────────────────
  Widget _pillNav() {
    final secs = _secs;
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 14),
        itemCount: secs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final active = _active == i;
          return GestureDetector(
            onTap: () => setState(() => _active = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: active ? _gold : _card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? _gold : _border, width: active ? 0 : 1),
                boxShadow: active ? [BoxShadow(color: _gold.withValues(alpha:0.4),
                    blurRadius: 10, offset: const Offset(0, 4))] : [],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(secs[i].icon, size: 13, color: active ? Colors.white : _muted),
                const SizedBox(width: 5),
                Text(secs[i].label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                    color: active ? Colors.white : _muted)),
              ]),
            ),
          ).animate(delay: Duration(milliseconds: i * 45)).fadeIn(duration: 300.ms).slideX(begin: 0.15);
        },
      ),
    );
  }

  // ── Section dispatcher ────────────────────────────────────────────────────
  Widget _activeSection(vendorModel.Vendor v, List<vendorModel.Brand>? brands,
      double rating, MaterialController ctrl) {
    // Build ordered index list same as _secs
    final offsets = <int>[];
    offsets.add(0); // Products
    if (_hasServices) offsets.add(1); // Services
    offsets.add(_hasServices ? 2 : 1); // About
    offsets.add(_hasServices ? 3 : 2); // Reviews
    offsets.add(_hasServices ? 4 : 3); // Photos
    offsets.add(_hasServices ? 5 : 4); // Brands

    switch (_active) {
      case 0: return _productsSection(v);
      default:
        if (_hasServices) {
          switch (_active) {
            case 1: return _servicesSection(v);
            case 2: return _aboutSection(v);
            case 3: return _reviewsSection(v, rating);
            case 4: return _photosSection(v);
            case 5: return _brandsSection(brands);
          }
        } else {
          switch (_active) {
            case 1: return _aboutSection(v);
            case 2: return _reviewsSection(v, rating);
            case 3: return _photosSection(v);
            case 4: return _brandsSection(brands);
          }
        }
        return const SizedBox.shrink();
    }
  }
  
  Widget _productsSection(vendorModel.Vendor v) {
    final items = v.vendorMaterials ?? [];
    if (items.isEmpty) return _empty('No products listed', Icons.inventory_2_outlined);
    return Column(children: items.asMap().entries.map((e) {
      final i = e.key; final m = e.value.material;
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: _box(),
        child: Row(children: [
          GestureDetector(
            onTap: () => _viewImg(m.image.isNotEmpty ? m.image.first : ''),
            child: ClipRRect(borderRadius: BorderRadius.circular(12),
                child: m.image.isNotEmpty
                    ? Image.network(m.image.first, width: 60, height: 60, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imgBox(60, Icons.inventory_2_outlined))
                    : _imgBox(60, Icons.inventory_2_outlined)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m.materialName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _ink),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: _greenBg, borderRadius: BorderRadius.circular(6)),
                child: const Text('Agricultural Material',
                    style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: _green))),
          ])),
          const SizedBox(width: 8),
          _pillBtn('Quote', _gold, _goldBg, () => _productDialog(m.materialName, m.id.toString(), v.userId.toString())),
        ]),
      ).animate(delay: Duration(milliseconds: i * 50)).fadeIn(duration: 300.ms)
          .slideY(begin: 0.08, curve: Curves.easeOutCubic);
    }).toList());
  }

  // ══ SERVICES ══════════════════════════════════════════════════════════════
  Widget _servicesSection(vendorModel.Vendor v) {
    final items = v.vendorServices ?? [];
    if (items.isEmpty) return _empty('No services listed', Icons.build_circle_outlined);
    return Column(children: items.asMap().entries.map((e) {
      final i = e.key; final s = e.value.service;
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: _box(),
        child: Row(children: [
          GestureDetector(
            onTap: () => _viewImg(s.image.isNotEmpty ? s.image.first : ''),
            child: ClipRRect(borderRadius: BorderRadius.circular(12),
                child: s.image.isNotEmpty
                    ? Image.network(s.image.first, width: 60, height: 60, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imgBox(60, Icons.home_repair_service_outlined))
                    : _imgBox(60, Icons.home_repair_service_outlined)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(s.serviceName,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _ink),
              maxLines: 2, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          _pillBtn('Book', _green, _greenBg, () => _serviceSheet(s.id.toString())),
        ]),
      ).animate(delay: Duration(milliseconds: i * 50)).fadeIn().slideY(begin: 0.08);
    }).toList());
  }

  // ══ ABOUT ═════════════════════════════════════════════════════════════════
  Widget _aboutSection(vendorModel.Vendor? v) => Container(
    decoration: _box(), padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Header band
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [_h1, _h2],
              begin: Alignment.centerLeft, end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(children: [
          Icon(Icons.storefront_rounded, color: Colors.white, size: 15),
          SizedBox(width: 8),
          Text('About the Company', style: TextStyle(color: Colors.white,
              fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
      ).animate().fadeIn(duration: 300.ms),
      const SizedBox(height: 14),
      Text((v?.description?.isNotEmpty ?? false) ? v!.description! : 'No description available.',
        style: const TextStyle(fontSize: 13, color: _muted, height: 1.75),
      ).animate().fadeIn(delay: 80.ms, duration: 400.ms),
      const SizedBox(height: 16),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _factChip(Icons.numbers_rounded,        'TIN', v?.taxNumber  ?? 'N/A', _blue,  _blueBg),
        _factChip(Icons.fax_rounded,            'Fax', v?.fax        ?? 'N/A', _green, _greenBg),
        _factChip(Icons.calendar_month_rounded, 'Est', v?.estimateDate ?? 'N/A', _gold, _goldBg),
      ].asMap().entries.map((e) => e.value
          .animate(delay: Duration(milliseconds: 120 + e.key * 60))
          .fadeIn().scale(curve: Curves.easeOutBack)).toList()),
    ]),
  ).animate().fadeIn(delay: 60.ms, duration: 380.ms).slideY(begin: 0.06);

  Widget _factChip(IconData icon, String label, String val, Color c, Color bg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withValues(alpha:0.2))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 12, color: c), const SizedBox(width: 5),
      Text('$label: $val', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c)),
    ]),
  );

  // ══ REVIEWS ═══════════════════════════════════════════════════════════════
  Widget _reviewsSection(vendorModel.Vendor? v, double rating) {
    final reviews = v?.reviews ?? [];
    final dist    = _ratingDist(reviews);
    return Column(children: [
      // Summary
      Container(
        padding: const EdgeInsets.all(16), decoration: _box(),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(rating.toStringAsFixed(1), style: const TextStyle(
                fontSize: 44, fontWeight: FontWeight.w900, color: _ink, height: 1)),
            const SizedBox(height: 5),
            Row(children: List.generate(5, (i) => Icon(
                i < rating.floor() ? Icons.star_rounded : Icons.star_outline_rounded,
                color: _gold, size: 15))),
            const SizedBox(height: 3),
            Text('${reviews.length} reviews', style: const TextStyle(fontSize: 10.5, color: _muted)),
          ]),
          const SizedBox(width: 20),
          Expanded(child: Column(children: [5, 4, 3, 2, 1].map((star) {
            final frac = dist[star] ?? 0.0;
            return Padding(padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(children: [
                Text('$star', style: const TextStyle(fontSize: 9.5, color: _muted)),
                const SizedBox(width: 5),
                Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: frac, minHeight: 5,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          frac > 0.4 ? _gold : _gold.withValues(alpha:0.5)),
                    ))),
              ]),
            );
          }).toList())),
        ]),
      ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.97, 0.97)),
      const SizedBox(height: 10),
      if (reviews.isEmpty) _empty('No reviews yet', Icons.rate_review_outlined),
      ...reviews.asMap().entries.map((e) {
        final i = e.key; final r = e.value; final user = r.user;
        final uRat = double.tryParse(r.rating) ?? 0;
        final ini = user.name.isNotEmpty ? user.name.split(' ').take(2).map((w) => w[0]).join() : 'U';
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(13),
          decoration: _box(),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(radius: 18, backgroundColor: _goldBg,
                backgroundImage: user.avatar.isNotEmpty ? NetworkImage(user.avatar) : null,
                child: user.avatar.isEmpty ? Text(ini, style: const TextStyle(
                    fontWeight: FontWeight.w700, color: _gold, fontSize: 12)) : null,
              ),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user.name.isNotEmpty ? user.name : 'Anonymous',
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _ink)),
                Text(_fmtDate(r.createdAt), style: const TextStyle(fontSize: 10, color: _muted)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: _goldBg, borderRadius: BorderRadius.circular(10)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.star_rounded, color: _gold, size: 11),
                  const SizedBox(width: 2),
                  Text(uRat.toStringAsFixed(1), style: const TextStyle(fontSize: 10.5,
                      fontWeight: FontWeight.w700, color: Color(0xFFB45309))),
                ]),
              ),
            ]),
            const SizedBox(height: 9),
            Text(r.review, style: const TextStyle(fontSize: 12.5, color: _muted, height: 1.65)),
          ]),
        ).animate(delay: Duration(milliseconds: 80 + i * 55)).fadeIn(duration: 300.ms).slideY(begin: 0.06);
      }),
    ]);
  }

  // ══ PHOTOS ════════════════════════════════════════════════════════════════
  Widget _photosSection(vendorModel.Vendor v) {
    final imgs = v.image;
    if (imgs.isEmpty) return _empty('No photos available', Icons.photo_library_outlined);
    return Container(
      decoration: _box(), padding: const EdgeInsets.all(10),
      child: GridView.builder(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 6, mainAxisSpacing: 6),
        itemCount: imgs.length,
        itemBuilder: (_, i) => GestureDetector(
          onTap: () => _viewImg(imgs[i]),
          child: ClipRRect(borderRadius: BorderRadius.circular(10),
            child: Image.network(imgs[i], fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: _bg,
                    child: const Icon(Icons.broken_image_outlined, color: _muted))),
          ),
        ).animate(delay: Duration(milliseconds: i * 30)).fadeIn(duration: 280.ms)
            .scale(begin: const Offset(0.85, 0.85), curve: Curves.easeOutBack),
      ),
    ).animate().fadeIn(delay: 60.ms, duration: 350.ms);
  }

  // ══ BRANDS ════════════════════════════════════════════════════════════════
  Widget _brandsSection(List<vendorModel.Brand>? brands) {
    if (brands == null || brands.isEmpty)
      return _empty('No brands listed', Icons.branding_watermark_outlined);
    return Container(
      decoration: _box(), padding: const EdgeInsets.all(10),
      child: GridView.builder(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 0.88),
        itemCount: brands.length,
        itemBuilder: (_, i) {
          final b = brands[i];
          return Container(
            decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border)),
            padding: const EdgeInsets.all(8),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              ClipRRect(borderRadius: BorderRadius.circular(8),
                  child: (b.logo?.isNotEmpty ?? false)
                      ? Image.network(b.logo!, width: 44, height: 44, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imgBox(44, Icons.business_outlined))
                      : _imgBox(44, Icons.business_outlined)),
              const SizedBox(height: 6),
              Text(b.name ?? 'N/A', textAlign: TextAlign.center, maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: _ink)),
            ]),
          ).animate(delay: Duration(milliseconds: i * 40))
              .fadeIn().scale(begin: const Offset(0.88, 0.88), curve: Curves.easeOutBack, duration: 320.ms);
        },
      ),
    ).animate().fadeIn(delay: 60.ms);
  }

  // ── Product enquiry dialog ────────────────────────────────────────────────
  void _productDialog(String title, String materialId, String userId) {
    showDialog(context: context, builder: (_) => GetBuilder<MaterialController>(
      builder: (ctrl) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        backgroundColor: _card, surfaceTintColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(padding: const EdgeInsets.fromLTRB(18, 10, 18, 20), child: Column(
          mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text('Enquire – $title', style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w800, color: _ink),
                maxLines: 1, overflow: TextOverflow.ellipsis)),
            IconButton(onPressed: () => Get.back(),
                icon: const Icon(Icons.close_rounded, color: _muted, size: 18),
                visualDensity: VisualDensity.compact),
          ]),
          const Divider(color: _border, height: 16),
          Row(children: [
            Container(decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _border)),
              child: Row(children: [
                _stepBtn(Icons.remove, () { if (ctrl.quantity>1) { ctrl.quantity--; ctrl.quantityController.text=ctrl.quantity.toString(); ctrl.update(); } }),
                SizedBox(width: 44, child: TextField(controller: ctrl.quantityController,
                  keyboardType: TextInputType.number, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(border: InputBorder.none, isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8)),
                  onChanged: (val) { ctrl.quantity = int.tryParse(val) ?? 1; ctrl.update(); },
                )),
                _stepBtn(Icons.add, () { ctrl.quantity++; ctrl.quantityController.text=ctrl.quantity.toString(); ctrl.update(); }),
              ]),
            ),
            const SizedBox(width: 10),
            Expanded(child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), border: Border.all(color: _border)),
              child: DropdownButtonHideUnderline(child: ctrl.isUnitLoading
                  ? const Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 1.5)))
                  : DropdownButton<String>(isExpanded: true, dropdownColor: _card,
                hint: const Text('Unit', style: TextStyle(fontSize: 13)), value: ctrl.selectedUnit,
                items: ctrl.materialUnits.map((u) => DropdownMenuItem(value: u.id.toString(),
                    child: Text(u.name ?? '', style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (val) { ctrl.selectedUnit = val; ctrl.update(); },
              )),
            )),
          ]),
          const SizedBox(height: 12),
          TextField(controller: ctrl.productQuoteController, maxLines: 3,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(hintText: 'Describe your requirement…',
              hintStyle: const TextStyle(color: _muted, fontSize: 12.5),
              filled: true, fillColor: _bg, contentPadding: const EdgeInsets.all(12),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _gold, width: 1.5)),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(width: double.infinity, height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _gold, foregroundColor: Colors.white,
                  elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: ctrl.isSubmittingEnquiry ? null : () {
                FocusManager.instance.primaryFocus?.unfocus();
                ctrl.submitProductEnquiry(materialId: materialId, userId: userId);
              },
              child: ctrl.isSubmittingEnquiry
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Send Enquiry', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
        )),
      ),
    ));
  }

  // ── Service sheet ─────────────────────────────────────────────────────────
  void _serviceSheet(String serviceId) {
    Get.bottomSheet(GetBuilder<MaterialController>(builder: (ctrl) => Container(
      padding: EdgeInsets.only(left: 18, right: 18, top: 10,
          bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 16),
      decoration: const BoxDecoration(color: _card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 36, height: 4, margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(10)))),
            const Text('Request Service', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _ink)),
            const SizedBox(height: 12),
            TextField(controller: ctrl.quoteController, maxLines: 3, style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(hintText: 'Tell us your requirements…',
                filled: true, fillColor: _bg, contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _gold, width: 1.5)),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Preferred Date & Time', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _ink)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _selTile(ctrl.selectedDate ?? 'Date', Icons.calendar_today_rounded, () async {
                final d = await showDatePicker(context: Get.context!, initialDate: DateTime.now(),
                    firstDate: DateTime.now(), lastDate: DateTime(2100));
                if (d != null) { ctrl.selectedDate = d.toString().split(' ')[0]; ctrl.update(); }
              })),
              const SizedBox(width: 10),
              Expanded(child: _selTile(ctrl.selectedTime ?? 'Time', Icons.access_time_rounded, () async {
                final t = await showTimePicker(context: Get.context!, initialTime: TimeOfDay.now());
                if (t != null) { ctrl.selectedTime = t.format(Get.context!); ctrl.update(); }
              })),
            ]),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: _ink, elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: ctrl.isSubmittingEnquiry ? null : () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  ctrl.submitEnquiry(serviceId: serviceId);
                },
                child: ctrl.isSubmittingEnquiry
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Send Request', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
              ),
            ),
            const SizedBox(height: 6),
          ])),
    )), isScrollControlled: true);
  }

  // ── Full image viewer ──────────────────────────────────────────────────────
  void _viewImg(String url) {
    if (url.isEmpty) return;
    final tc = TransformationController();
    showDialog(context: context, barrierColor: Colors.black,
      builder: (_) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black, elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white)),
        body: Center(child: GestureDetector(
          onDoubleTap: () { tc.value = tc.value != Matrix4.identity() ? Matrix4.identity() : (Matrix4.identity()..scale(2.5)); },
          child: InteractiveViewer(transformationController: tc, minScale: 1, maxScale: 5,
              child: Image.network(url, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white, size: 50))),
        )),
      ),
    );
  }

  // ── Micro helpers ─────────────────────────────────────────────────────────
  AppBar _miniBar(String t) => AppBar(backgroundColor: _h1, elevation: 0,
    leading: GestureDetector(onTap: () => Get.back(),
        child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16)),
    title: Text(t, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
  );

  BoxDecoration _box() => BoxDecoration(color: _card, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha:0.05), blurRadius: 12, offset: const Offset(0, 4))]);

  Widget _head(IconData icon, String title) => Padding(
    padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
    child: Row(children: [
      Icon(icon, size: 15, color: _gold), const SizedBox(width: 7),
      Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: _ink)),
    ]),
  );

  Widget _pillBtn(String label, Color c, Color bg, VoidCallback tap) => GestureDetector(
    onTap: tap,
    child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10),
            border: Border.all(color: c.withValues(alpha:0.4))),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c))),
  );

  Widget _stepBtn(IconData icon, VoidCallback tap) => InkWell(onTap: tap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(padding: const EdgeInsets.all(8), child: Icon(icon, size: 17, color: _ink)));

  Widget _selTile(String label, IconData icon, VoidCallback tap) => InkWell(
    onTap: tap, borderRadius: BorderRadius.circular(10),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: _border)),
      child: Row(children: [
        Icon(icon, size: 14, color: _gold), const SizedBox(width: 6),
        Flexible(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 1, overflow: TextOverflow.ellipsis)),
      ]),
    ),
  );

  Widget _imgBox(double s, IconData icon) => Container(width: s, height: s,
      decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(10)),
      child: Icon(icon, size: s * 0.38, color: _muted));

  Widget _empty(String msg, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 60, height: 60,
          decoration: BoxDecoration(color: _goldBg, shape: BoxShape.circle),
          child: Icon(icon, size: 28, color: _gold))
          .animate().scale(duration: 350.ms, curve: Curves.elasticOut),
      const SizedBox(height: 10),
      Text(msg, style: const TextStyle(color: _muted, fontSize: 12.5, fontWeight: FontWeight.w500))
          .animate().fadeIn(delay: 150.ms),
    ])),
  );

  Map<int, double> _ratingDist(List<vendorModel.Review> reviews) {
    final m = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final r in reviews) {
      final s = (double.tryParse(r.rating) ?? 0).round().clamp(1, 5);
      m[s] = m[s]! + 1;
    }
    final total = reviews.length;
    if (total == 0) return {1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0, 5: 0.0};
    return m.map((k, v) => MapEntry(k, v / total));
  }

  String _fmtDate(DateTime d) {
    final diff = DateTime.now().difference(d).inDays;
    if (diff == 0) return 'Today'; if (diff == 1) return '1 day ago'; return '$diff days ago';
  }
}

class _Sec { final String label; final IconData icon; const _Sec(this.label, this.icon); }
class _Soc { final String asset; final Color color; final VoidCallback onTap; const _Soc(this.asset, this.color, this.onTap); }