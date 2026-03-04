import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:url_launcher/url_launcher.dart';

import '../../../common/colours.dart';
import '../../../common/widget/appbar.dart';
import '../../../common/widget/toster.dart';
import '../controller/dashboard_menu_controller.dart';
import '../model/dashboard_model.dart';


class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({Key? key}) : super(key: key);

  @override
  State<TermsAndConditionsScreen> createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> with SingleTickerProviderStateMixin {
  final DashboardController controller = Get.put(DashboardController());
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut),
      ),
    );

    // Start animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });

    // Fetch terms if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.termsPage.value == null) {
        controller.fetchTermsAndConditions();
      }
    });

    // Fetch business settings if not loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.businessSettings.value == null) {
        controller.fetchBusinessSettings();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _restartAnimations() {
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundLight,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: DynamicAppBar(
          title: "Terms & Conditions",
          showBackButton: true,
          actions: [
            IconButton(
              onPressed: () {
                controller.refreshTerms();
                controller.refreshContactInfo();
                _restartAnimations();
              },
              icon: AnimatedIcon(
                icon: AnimatedIcons.search_ellipsis,
                progress: _animationController,
                size: 20.sp,
              ),
              tooltip: "Refresh",
            ),
          ],
        ),
      ),
      body: Obx(() {
        // Loading State for Terms
        if (controller.isLoadingTerms.value && controller.termsPage.value == null) {
          return _buildLoadingState();
        }

        // Error State for Terms
        if (controller.termsErrorMessage.value.isNotEmpty) {
          return _buildErrorState();
        }

        // Empty State for Terms
        if (controller.termsPage.value == null) {
          return _buildEmptyState();
        }

        final terms = controller.termsPage.value!;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: RefreshIndicator(
                    color: AppColor.primary,
                    backgroundColor: AppColor.white,
                    onRefresh: () async {
                      await controller.refreshTerms();
                       controller.refreshContactInfo();
                      _restartAnimations();
                    },
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with last updated info
                          _buildHeader(terms),

                          // Content with staggered animation
                          _buildAnimatedContent(terms),

                          // Spacer
                          SizedBox(height: 30.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: RotationTransition(
              turns: _animationController,
              child: Icon(
                Iconsax.document,
                size: 30.sp,
                color: AppColor.primary,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              "Loading Terms & Conditions...",
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColor.textSecondary,
              ),
            ),
          ),
          SizedBox(height: 8.h),
          if (controller.isLoadingSettings.value)
            Text(
              "Loading business information...",
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColor.grey,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.warning_2,
                size: 60.sp,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 16.h),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Text(
                    "Unable to Load",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColor.textMain,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    controller.termsErrorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColor.textSecondary,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: ElevatedButton(
                      onPressed: () {
                        controller.refreshTerms();
                        _restartAnimations();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.primary,
                        foregroundColor: AppColor.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                      ),
                      child: Text("Try Again"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.bounceOut,
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              color: AppColor.lightGrey,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.document_text,
              size: 50.sp,
              color: AppColor.grey.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 16.h),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                Text(
                  "No Terms Available",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColor.textMain,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Terms & Conditions are not available at the moment.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColor.textSecondary,
                  ),
                ),
                SizedBox(height: 20.h),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.refreshTerms();
                      _restartAnimations();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      foregroundColor: AppColor.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                    ),
                    child: Text("Load Terms"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(TermsPage terms) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.05),
                border: Border(
                  bottom: BorderSide(color: AppColor.primary.withOpacity(0.1), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Text(
                      terms.title ?? 'Terms & Conditions',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColor.textMain,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.3, 0.7),
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.calendar_1, size: 12.sp, color: AppColor.grey),
                        SizedBox(width: 6.w),
                        Text(
                          "Last updated: ${_formatDate(terms.updatedAt ?? DateTime.now())}",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColor.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedContent(TermsPage terms) {
    final sections = _parseHtmlContent(terms.content ?? '');

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display description if no sections found
              if (sections.isEmpty && terms.content?.isNotEmpty == true)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - _animationController.value)),
                    child: _buildDescriptionCard(terms.content!),
                  ),
                ),

              // Sections with staggered animations
              ...sections.asMap().entries.map((entry) {
                final index = entry.key;
                final section = entry.value;

                final double delay = (index * 0.1).clamp(0.0, 1.0);
                final double sectionAnimationValue = max(0.0, _animationController.value - delay);

                return FadeTransition(
                  opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: _animationController,
                      curve: Interval(delay, 1.0, curve: Curves.easeInOut),
                    ),
                  ),
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - sectionAnimationValue)),
                    child: _buildSectionCard(
                      index + 1,
                      section['title'] ?? 'Section ${index + 1}',
                      section['content'] ?? '',
                    ),
                  ),
                );
              }).toList(),

              // Contact info with animation
              FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
                  ),
                ),
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - _animationController.value)),
                  child: _buildContactCard(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDescriptionCard(String description) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        description,
        style: TextStyle(
          fontSize: 13.sp,
          height: 1.6,
          color: AppColor.textSecondary,
        ),
      ),
    );
  }

  List<Map<String, String>> _parseHtmlContent(String htmlContent) {
    try {
      if (htmlContent.isEmpty) return [];

      final document = html_parser.parse(htmlContent);
      final List<Map<String, String>> sections = [];

      // Find all h2, h3, h4 elements
      final headings = document.querySelectorAll('h2, h3, h4');

      for (var heading in headings) {
        // Get title from heading
        String title = heading.text.trim();
        if (title.isEmpty) continue;

        // Get content after this heading until next heading
        String content = '';
        var nextElement = heading.nextElementSibling;

        while (nextElement != null) {
          if (nextElement.localName == 'h2' ||
              nextElement.localName == 'h3' ||
              nextElement.localName == 'h4') {
            break;
          }

          // Handle different element types
          if (nextElement.localName == 'p') {
            content += '${nextElement.text}\n\n';
          } else if (nextElement.localName == 'ul') {
            final liElements = nextElement.querySelectorAll('li');
            for (var li in liElements) {
              content += '• ${li.text.trim()}\n';
            }
            content += '\n';
          } else if (nextElement.localName == 'ol') {
            final liElements = nextElement.querySelectorAll('li');
            for (var j = 0; j < liElements.length; j++) {
              content += '${j + 1}. ${liElements[j].text.trim()}\n';
            }
            content += '\n';
          } else if (nextElement.localName == 'div' ||
              nextElement.localName == 'span') {
            // Extract text from nested elements
            content += '${nextElement.text}\n\n';
          }

          nextElement = nextElement.nextElementSibling;
        }

        sections.add({
          'title': title,
          'content': content.trim(),
        });
      }

      return sections;
    } catch (e) {
      print('❌ Error parsing HTML: $e');
      return [];
    }
  }

  Widget _buildSectionCard(int number, String title, String content) {
    // Extract just the title text (remove the number if present)
    String displayTitle = title.replaceFirst(RegExp(r'^\d+\.\s*'), '').trim();

    // If displayTitle is empty, use a generic title
    if (displayTitle.isEmpty) {
      displayTitle = 'Section $number';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: AppColor.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header with shimmer animation
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColor.primary.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animated number badge
                ScaleTransition(
                  scale: CurvedAnimation(
                    parent: _animationController,
                    curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
                  ),
                  child: Container(
                    width: 28.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        number.toString(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColor.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayTitle,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColor.textMain,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Section Content with fade-in animation
          if (content.isNotEmpty)
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _animationController,
                curve: const Interval(0.3, 1.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Text(
                  content,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.6,
                    color: AppColor.textSecondary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      margin: EdgeInsets.only(top: 20.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColor.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColor.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ScaleTransition(
                scale: CurvedAnimation(
                  parent: _animationController,
                  curve: const Interval(0.6, 0.8, curve: Curves.elasticOut),
                ),
                child: Icon(Iconsax.info_circle, size: 16.sp, color: AppColor.primary),
              ),
              SizedBox(width: 8.w),
              Text(
                "Contact Information",
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColor.textMain,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          Obx(() {
            final settings = controller.businessSettings.value;
            if (settings == null) {
              return _buildLoadingContactInfo();
            }

            return Column(
              children: [
                // Email with animation
                if (settings.businessEmail?.isNotEmpty == true)
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.7, 0.9),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          Icon(Iconsax.sms, size: 14.sp, color: AppColor.grey),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _launchEmail(settings.businessEmail!),
                              onTapDown: (_) => _animateButtonPress(),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  settings.businessEmail!,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColor.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Phone with animation
                if (settings.businessPhone?.isNotEmpty == true)
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.75, 0.95),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          Icon(Iconsax.call, size: 14.sp, color: AppColor.grey),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _launchPhone(settings.businessPhone!),
                              onTapDown: (_) => _animateButtonPress(),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                child: Text(
                                  settings.businessPhone!,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColor.primary,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // WhatsApp with animation
                if (settings.whatsapp?.isNotEmpty == true)
                  FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _animationController,
                      curve: const Interval(0.8, 1.0),
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.message, size: 14.sp, color: AppColor.grey),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _launchWhatsApp(settings.whatsapp!),
                            onTapDown: (_) => _animateButtonPress(),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              child: Text(
                                settings.whatsapp!,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColor.primary,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLoadingContactInfo() {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          children: [
            Icon(Iconsax.search_normal, size: 14.sp, color: AppColor.grey),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                "Loading contact information...",
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColor.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _animateButtonPress() {
    _animationController.forward(from: 0.8);
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      SnackBarHelper.showError('Could not launch email app');
    }
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      SnackBarHelper.showError('Could not launch phone app');
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    // Clean phone number
    String cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');

    // Ensure it starts with country code
    if (!cleanPhone.startsWith('+') && !cleanPhone.startsWith('91')) {
      cleanPhone = '+91$cleanPhone';
    }

    // Remove any + signs if multiple
    if (cleanPhone.startsWith('++')) {
      cleanPhone = cleanPhone.substring(1);
    }

    final uri = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      SnackBarHelper.showError('Could not launch WhatsApp');
    }
  }
}