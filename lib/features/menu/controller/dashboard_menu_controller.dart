import 'package:cashback_farms/common/model/logger_model.dart';
import 'package:cashback_farms/features/profile/controller/profile_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../common/api_constant.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';
import '../model/dashboard_model.dart';
import '../screens/menu.dart';


extension StringExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.isNotEmpty
        ? word[0].toUpperCase() + word.substring(1).toLowerCase()
        : word)
        .join(' ');
  }
}

String _toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text.split(' ')
      .map((word) => word.isNotEmpty
      ? word[0].toUpperCase() + word.substring(1).toLowerCase()
      : word)
      .join(' ');
}

class DashboardController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoadingContact = false.obs;
  final RxBool isLoadingSettings = false.obs;
  final RxBool isLoadingTerms = false.obs;
  final RxBool isLoadingPage = false.obs;
  final RxBool isLoadingServiceRequests = false.obs;
  final RxBool isLoadingVendorRequests = false.obs;
  final RxBool isLoadingAgentRequests = false.obs;
  final Rx<Profile?> profile = Rx<Profile?>(null);
  final RxInt myProperties = 0.obs;
  final RxInt marketEnquiryCount = 0.obs;
  final RxInt materialEnquiryCount = 0.obs;
  final RxInt residentialEnquiry = 0.obs;
  final RxList<GiooBooked> giooBooked = <GiooBooked>[].obs;
  final RxList<MarketEnquiry> marketEnquiry = <MarketEnquiry>[].obs;
  final RxList<dynamic> serviceRequests = <dynamic>[].obs;
  final RxList<dynamic> vendorRequests = <dynamic>[].obs;
  final RxList<dynamic> agentRequests = <dynamic>[].obs;
  final RxString currentRole = 'User'.obs;
  final RxString firstName = ''.obs;
  final RxString lastName = ''.obs;
  final RxString email = ''.obs;
  final RxString phone = ''.obs;
  final RxString requirement = ''.obs;
  final RxString message = ''.obs;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController requirementController = TextEditingController();
  final TextEditingController messageController = TextEditingController();
  final Rx<BusinessSettings?> businessSettings = Rx<BusinessSettings?>(null);
  final Rx<TermsPage?> termsPage = Rx<TermsPage?>(null);
  final RxString termsErrorMessage = ''.obs;
  final RxString pageTitle = ''.obs;
  final RxString pageContent = ''.obs;
  final RxString pageErrorMessage = ''.obs;
  final RxString currentPageSlug = RxString('');
  bool _isRequestInProgress = false;
  bool _isContactRequestInProgress = false;
  bool _isPageRequestInProgress = false;
  bool _isServiceRequestInProgress = false;
  bool _isVendorRequestInProgress = false;
  bool _isAgentRequestInProgress = false;



  @override
  void onInit() {
    super.onInit();
    _setupControllerListeners();
    fetchBusinessSettings();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    requirementController.dispose();
    messageController.dispose();
    super.onClose();
  }


  final ProfileController controller = Get.put(ProfileController());
  final RxMap<RoleType, bool> roleLoadingMap = <RoleType, bool>{
    RoleType.agent:   false,
    RoleType.vendor:  false,
    RoleType.service: false,
  }.obs;

  final ProfileController profileController = Get.put(ProfileController());


  Future<void> applyForRole(RoleType roleType) async {
    roleLoadingMap[roleType] = true;
    switch (roleType) {
      case RoleType.agent:
        await fetchAgentRequests();
        break;
      case RoleType.vendor:
        await fetchVendorRequests();
        break;
      case RoleType.service:
        await fetchServiceRequests();
        break;
    }
    await fetchDashboard();
    roleLoadingMap[roleType] = false;
  }





  void _setupControllerListeners() {
    firstNameController.addListener(() => firstName.value = firstNameController.text);
    lastNameController.addListener(() => lastName.value = lastNameController.text);
    emailController.addListener(() => email.value = emailController.text);
    phoneController.addListener(() => phone.value = phoneController.text);
    requirementController.addListener(() => requirement.value = requirementController.text);
    messageController.addListener(() => message.value = messageController.text);
  }



  Future<void> fetchServiceRequests() async {
    if (_isServiceRequestInProgress) {
      print('⏸️ Service requests already in progress');
      return;
    }
    try {
      _isServiceRequestInProgress = true;
      isLoadingServiceRequests(true);
      final token = await SessionManager.getToken();
      print('📡 Fetching service requests...');
      final response = await ApiService.getRequest(
        ApiUrl.serviceRequest,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200 && response.data != null) {
        if (response.data['status'] == 200) {
          final List<dynamic> data = response.data['data'] ?? [];
          serviceRequests.assignAll(data);
          SnackBarHelper.showSuccess(
            response.data['message'] ?? 'Your Service request has been submitted.',
          );
          print('✅ Service requests loaded successfully: ${serviceRequests.length} items');
        } else {
          print('⚠️ Failed to load service requests: ${response.data['message']}');
        }
      } else {
        print('❌ Invalid service requests response: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException fetching service requests: ${e.type} - ${e.message}');
    } catch (e) {
      print('❌ Error fetching service requests: $e');
    } finally {
      isLoadingServiceRequests(false);
      _isServiceRequestInProgress = false;
    }
  }

  Future<void> fetchVendorRequests() async {
    if (_isVendorRequestInProgress) {
      print('⏸️ Vendor requests already in progress');
      return;
    }
    try {
      _isVendorRequestInProgress = true;
      isLoadingVendorRequests(true);
      final token = await SessionManager.getToken();
      print('📡 Fetching vendor requests...');

      final response = await ApiService.getRequest(
        ApiUrl.vendorRequest,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data['status'] == true) {
          final List<dynamic> data = response.data['data'] ?? [];
          vendorRequests.assignAll(data);
          SnackBarHelper.showSuccess(
            response.data['message'] ?? 'Your Vendor request has been submitted.',
          );
          print('✅ Vendor requests loaded successfully: ${vendorRequests.length} items');
        } else {
          print('⚠️ Failed to load vendor requests: ${response.data['message']}');
        }
      } else {
        print('❌ Invalid vendor requests response: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException fetching vendor requests: ${e.type} - ${e.message}');
    } catch (e) {
      print('❌ Error fetching vendor requests: $e');
    } finally {
      isLoadingVendorRequests(false);
      _isVendorRequestInProgress = false;
    }
  }
  Future<void> fetchAgentRequests() async {
    if (_isAgentRequestInProgress) {
      print('⏸️ Agent requests already in progress');
      return;
    }
    try {
      _isAgentRequestInProgress = true;
      isLoadingAgentRequests(true);
      final token = await SessionManager.getToken();
      print('📡 Fetching agent requests...');
      final response = await ApiService.getRequest(
        ApiUrl.agentRequest,
        headers: {'Authorization': 'Bearer $token'},
      );


      if (response.statusCode == 200 && response.data != null) {
        if (response.data['status'] == true) {
          final List<dynamic> data = response.data['data'] ?? [];
          agentRequests.assignAll(data);
          SnackBarHelper.showSuccess(
            response.data['message'] ?? 'Your Agent request has been submitted.',
          );
        } else {
          print('⚠️ Failed to load agent requests: ${response.data['message']}');
        }
      } else {
        print('❌ Invalid agent requests response: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException fetching agent requests: ${e.type} - ${e.message}');
    } catch (e) {
      print('❌ Error fetching agent requests: $e');
    } finally {
      isLoadingAgentRequests(false);
      _isAgentRequestInProgress = false;
    }
  }
  Future<void> fetchBusinessSettings() async {
    if (isLoadingSettings.value) return;
    try {
      isLoadingSettings(true);
      print('📡 Fetching business settings from API...');
      final response = await ApiService.getRequest(ApiUrl.settings);
      if (response.statusCode == 200 && response.data?['status'] == true) {
        final Map<String, dynamic> data = response.data['data'];
        businessSettings.value = BusinessSettings.fromJson(data);
      } else {
        _setDefaultBusinessSettings();
      }
    } catch (e) {
      print('❌ Error loading business settings: $e');
      _setDefaultBusinessSettings();
    } finally {
      isLoadingSettings(false);
    }
  }

  void _setDefaultBusinessSettings() {
    businessSettings.value = BusinessSettings(
      businessName: 'Geo Rental Farms',
      businessPhone: '+91 81900 59995',
      businessEmail: 'greenheapfarms@gmail.com',
      businessAddress: 'No. 1, 66th Street, Sector 11, Thalapathy vijay nagar, Tamil Nadu, Chennai, India.',
      whatsapp: '+91 81900 59995',
      instagram: 'https://www.instagram.com/',
      youtube: 'https://www.youtube.com/',
      footerDescription: 'Invest smarter and maximize your returns with assured cashback on land investments. Our secure and transparent opportunities are designed to help you grow wealth confidently while enjoying guaranteed benefits from day one.',
      giooAdminPercentage: 52.0,
      giooMaxDuration: 365,
      giooMinProfit: 30.0,
    );
    print('⚠️ Using default business settings');
  }

  Future<void> fetchDashboard() async {
    if (_isRequestInProgress) {
      Loggers.error('⏸️ Dashboard request already   progress');
      return;
    }

    try {
      _isRequestInProgress = true;
      isLoading(true);

      final token = await SessionManager.getToken();
      final response = await ApiService.getRequest(
        ApiUrl.dashBoard,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200 && response.data?['data'] != null) {
        final Map<String, dynamic> data = response.data['data'];

        if (data['profile'] != null) {
          profile.value = Profile.fromJson(data['profile']);
        }

        myProperties.value = data['myproperties'] ?? 0;
        marketEnquiryCount.value = data['market_enquiry_count'] ?? 0;
        materialEnquiryCount.value = data['material_enquiry_count'] ?? 0;
        residentialEnquiry.value = data['residential_enquiry'] ?? 0;

        if (data['gioo_booked'] != null && data['gioo_booked'] is List) {
          giooBooked.assignAll(
            (data['gioo_booked'] as List)
                .map((e) => GiooBooked.fromJson(e))
                .toList(),
          );
        }
        if (data['market_enquiry'] != null && data['market_enquiry'] is List) {
          marketEnquiry.assignAll(
            (data['market_enquiry'] as List)
                .map((e) => MarketEnquiry.fromJson(e))
                .toList(),
          );
        }
      } else {
        Loggers.error('❌ Invalid dashboard response: ${response.data}');
        SnackBarHelper.showError('Failed to load dashboard');
      }
    } catch (e) {
      Loggers.error('❌ Dashboard error: $e');
      SnackBarHelper.showError('Failed to load dashboard');
    } finally {
      isLoading(false);
      _isRequestInProgress = false;
    }
  }



  Future<void> submitContactForm() async {
    if (_isContactRequestInProgress) {
      print('⏸️ Contact request already in progress');
      return;
    }

    // Validation
    if (!_validateContactForm()) {
      return;
    }

    try {
      _isContactRequestInProgress = true;
      isLoadingContact(true);

      // Prepare request data
      final Map<String, dynamic> requestData = {
        'name': '${firstName.value} ${lastName.value}'.trim(),
        'email': email.value,
        'message': message.value.isNotEmpty ? message.value : requirement.value,
      };

      // Add phone if provided
      if (phone.value.isNotEmpty) {
        requestData['phone'] = phone.value;
      }

      print('📤 Sending contact data: $requestData');
      print('🌐 Contact API URL: ${ApiUrl.contactEnquiry}');

      final response = await ApiService.postRequest(
        ApiUrl.contactEnquiry,
        requestData,
      );

      print('📥 API Response Status: ${response.statusCode}');
      print('📥 API Response Data: ${response.data}');

      // Handle successful HTTP status codes (200, 201, etc.)
      if (response.statusCode! >= 200 && response.statusCode! < 300) {
        final data = response.data;

        // Check if response has 'status' field
        if (data is Map && data.containsKey('status')) {
          if (data['status'] == true) {
            // Success case
            SnackBarHelper.showSuccess(
                data['message'] ?? 'Message sent successfully!'
            );
            _clearContactForm();
          } else {
            // Business logic failure (like email already exists)
            SnackBarHelper.showError(
                data['message'] ?? 'Failed to send message. Please try again.'
            );
          }
        } else {
          // Response doesn't have status field, assume success
          SnackBarHelper.showSuccess('Message sent successfully!');
          _clearContactForm();
        }
      }
      // Handle validation errors (422)
      else if (response.statusCode == 422) {
        final data = response.data;
        if (data is Map && data.containsKey('errors')) {
          final errors = data['errors'];
          if (errors != null && errors is Map) {
            final errorMessages = <String>[];
            errors.forEach((key, value) {
              if (value is List) {
                errorMessages.addAll(value.map((e) => e.toString()));
              } else {
                errorMessages.add(value.toString());
              }
            });
            SnackBarHelper.showError(errorMessages.join('\n'));
          } else {
            SnackBarHelper.showError(data['message'] ?? 'Validation failed. Please check your input.');
          }
        } else {
          SnackBarHelper.showError(data?['message'] ?? 'Validation failed. Please check your input.');
        }
      }
      // Handle other status codes
      else {
        final data = response.data;
        final errorMessage = (data is Map && data.containsKey('message'))
            ? data['message']
            : 'Failed to submit form. Please try again.';

        SnackBarHelper.showError(errorMessage);
        print('❌ Invalid contact response: ${response.data}');
      }
    } on DioException catch (e) {
      print('❌ DioException in contact form: ${e.type} - ${e.message}');

      String errorMessage = 'Network error occurred.';
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Please check your internet.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Connection error. Please check your internet.';
      } else if (e.response != null) {
        // Server responded with an error status code
        final data = e.response?.data;
        if (data is Map && data.containsKey('message')) {
          errorMessage = data['message'];
        } else {
          errorMessage = 'Server error: ${e.response?.statusCode}';
        }
      }

      SnackBarHelper.showError(errorMessage);
    } catch (e) {
      print('❌ Contact form error: $e');
      SnackBarHelper.showError('An unexpected error occurred. Please try again.');
    } finally {
      isLoadingContact(false);
      _isContactRequestInProgress = false;
    }
  }
  bool _validateContactForm() {
    // Check name
    if (firstName.value.trim().isEmpty) {
      SnackBarHelper.showError('Please enter your name');
      return false;
    }

    // Check email
    if (email.value.trim().isEmpty) {
      SnackBarHelper.showError('Please enter your email address');
      return false;
    }

    // Validate email format
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.value.trim())) {
      SnackBarHelper.showError('Please enter a valid email address');
      return false;
    }

    // Check message
    final msg = message.value.isNotEmpty ? message.value : requirement.value;
    if (msg.trim().isEmpty) {
      SnackBarHelper.showError('Please enter your message');
      return false;
    }

    return true;
  }
  void _clearContactForm() {
    firstName.value = '';
    lastName.value = '';
    email.value = '';
    phone.value = '';
    requirement.value = '';
    message.value = '';
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    requirementController.clear();
    messageController.clear();

    print('✅ Contact form cleared');
  }
  Future<void> fetchTermsAndConditions() async {
    if (isLoadingTerms.value) return;

    try {
      isLoadingTerms(true);
      termsErrorMessage('');

      print('📡 Fetching Terms & Conditions...');
      final url = '${ApiUrl.baseUrl}/api/v2/pages/slug/terms_condition';
      final response = await ApiService.getRequest(url);
      print('📥 Terms API Response Status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        if (data['status'] == true) {
          final pageData = data['data'];
          termsPage.value = TermsPage.fromJson(pageData);
          print('✅ Terms & Conditions loaded successfully');
          print('   📝 Title: ${termsPage.value?.title}');
        } else {
          termsErrorMessage.value = data['message'] ?? 'Failed to load terms & conditions';
          print('❌ Terms API error: ${termsErrorMessage.value}');
        }
      } else {
        termsErrorMessage.value = 'Failed to load terms & conditions. Status: ${response.statusCode}';
        print('❌ Invalid terms response: ${response.data}');
      }
    } on DioException catch (e) {
      print('❌ DioException fetching terms: ${e.type} - ${e.message}');

      if (e.type == DioExceptionType.connectionTimeout) {
        termsErrorMessage.value = 'Connection timeout. Please check your internet.';
      } else if (e.type == DioExceptionType.connectionError) {
        termsErrorMessage.value = 'Connection error. Please check your internet.';
      } else {
        termsErrorMessage.value = 'Network error occurred. Please try again.';
      }
    } catch (e) {
      print('❌ Error fetching terms: $e');
      termsErrorMessage.value = 'An unexpected error occurred. Please try again.';
    } finally {
      isLoadingTerms(false);
    }
  }

  Future<void> refreshTerms() async {
    await fetchTermsAndConditions();
  }

  void clearTermsData() {
    termsPage.value = null;
    termsErrorMessage.value = '';
  }

  // ===============================
  // PAGE DATA METHODS
  // ===============================
  Future<void> fetchPageData(String slug) async {
    if (_isPageRequestInProgress) {
      print('⏸️ Page data request already in progress');
      return;
    }

    try {
      _isPageRequestInProgress = true;
      isLoadingPage(true);
      pageErrorMessage.value = '';
      currentPageSlug.value = slug;

      print('📡 Fetching page data for slug: $slug...');

      // Use the full URL with dynamic slug
      final url = '${ApiUrl.baseUrl}/api/v2/pages/slug/$slug';
      final response = await ApiService.getRequest(url);

      print('📥 Page API Response Status: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;

        if (data['status'] == true) {
          final pageData = data['data'];

          // Update page data
          pageTitle.value = pageData['title'] ?? _toTitleCase(slug.replaceAll('_', ' '));
          pageContent.value = pageData['content'] ?? '';

          print('✅ Page data loaded successfully');
          print('   📝 Title: ${pageTitle.value}');
          print('   📄 Content length: ${pageContent.value.length} chars');
        } else {
          pageErrorMessage.value = data['message'] ?? 'Failed to load page data';
          SnackBarHelper.showError(pageErrorMessage.value);
          print('❌ Page API error: ${pageErrorMessage.value}');
        }
      } else {
        pageErrorMessage.value = 'Failed to load page data. Status: ${response.statusCode}';
        SnackBarHelper.showError(pageErrorMessage.value);
        print('❌ Invalid page response: ${response.data}');
      }
    } on DioException catch (e) {
      print('❌ DioException fetching page data: ${e.type} - ${e.message}');

      String errorMessageText = 'Network error occurred. Please try again.';
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessageText = 'Connection timeout. Please check your internet.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessageText = 'Connection error. Please check your internet.';
      }

      pageErrorMessage.value = errorMessageText;
      SnackBarHelper.showError(errorMessageText);
    } catch (e) {
      print('❌ Error fetching page data: $e');
      pageErrorMessage.value = 'An unexpected error occurred. Please try again.';
      SnackBarHelper.showError(pageErrorMessage.value);
    } finally {
      isLoadingPage(false);
      _isPageRequestInProgress = false;
    }
  }

  Future<void> refreshPageData() async {
    if (currentPageSlug.value.isNotEmpty) {
      await fetchPageData(currentPageSlug.value);
    }
  }

  void clearPageData() {
    pageTitle.value = '';
    pageContent.value = '';
    pageErrorMessage.value = '';
    currentPageSlug.value = '';
  }

  // Convenience methods for common pages
  Future<void> fetchAboutUs() => fetchPageData('about-us');
  Future<void> fetchPrivacyPolicy() => fetchPageData('privacy-policy');
  Future<void> fetchFAQ() => fetchPageData('faq');

  // Getter for sanitized content
  String get sanitizedPageContent {
    if (pageContent.value.isEmpty) return '';
    return pageContent.value.replaceAll('<br>', '<br/>');
  }

  // Check if page has data
  bool get hasPageContent => pageContent.value.isNotEmpty;
  bool get hasPageError => pageErrorMessage.value.isNotEmpty;

  // ===============================
  // CONTACT ACTIONS METHODS
  // ===============================
  Future<void> makePhoneCall() async {
    final phoneNumber = businessSettings.value?.businessPhone;
    if (phoneNumber == null || phoneNumber.isEmpty) {
      SnackBarHelper.showError('Phone number not available');
      return;
    }

    // Clean the phone number (remove any spaces)
    String cleanedPhoneNumber = phoneNumber.replaceAll(' ', '');

    // Ensure it has the correct format for tel: URL
    if (!cleanedPhoneNumber.startsWith('+')) {
      if (cleanedPhoneNumber.startsWith('91') && cleanedPhoneNumber.length > 2) {
        cleanedPhoneNumber = '+$cleanedPhoneNumber';
      } else {
        cleanedPhoneNumber = '+91$cleanedPhoneNumber';
      }
    }

    final phoneUrl = 'tel:$cleanedPhoneNumber';

    try {
      print('📞 Making call to: $phoneUrl');
      if (await canLaunchUrl(Uri.parse(phoneUrl))) {
        await launchUrl(Uri.parse(phoneUrl));
      } else {
        SnackBarHelper.showError('Could not launch phone app');
      }
    } catch (e) {
      print('❌ Phone call error: $e');
      SnackBarHelper.showError('Unable to make call');
    }
  }

  Future<void> openWhatsApp() async {
    final whatsappNumber = businessSettings.value?.whatsapp;
    if (whatsappNumber == null || whatsappNumber.isEmpty) {
      SnackBarHelper.showError('WhatsApp number not available');
      return;
    }

    // Clean the WhatsApp number
    String cleanedWhatsApp = whatsappNumber.replaceAll(' ', '');

    // Remove any + signs
    if (cleanedWhatsApp.startsWith('+')) {
      cleanedWhatsApp = cleanedWhatsApp.substring(1);
    }

    // Remove any leading 0
    if (cleanedWhatsApp.startsWith('0')) {
      cleanedWhatsApp = cleanedWhatsApp.substring(1);
    }

    // Construct WhatsApp URL
    final businessName = businessSettings.value?.businessName ?? 'Geo Rental Farms';
    final whatsappUrl = 'https://wa.me/$cleanedWhatsApp?text=Hello%20${Uri.encodeComponent(businessName)}';

    try {
      print('💬 Opening WhatsApp: $whatsappUrl');
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      } else {
        SnackBarHelper.showError('Could not launch WhatsApp');
      }
    } catch (e) {
      print('❌ WhatsApp error: $e');
      SnackBarHelper.showError('Unable to open WhatsApp');
    }
  }

  Future<void> openInstagram() async {
    final instagramUrlStr = businessSettings.value?.instagram;
    if (instagramUrlStr == null || instagramUrlStr.isEmpty) {
      SnackBarHelper.showError('Instagram link not available');
      return;
    }

    try {
      print('📸 Opening Instagram: $instagramUrlStr');
      if (await canLaunchUrl(Uri.parse(instagramUrlStr))) {
        await launchUrl(Uri.parse(instagramUrlStr));
      } else {
        SnackBarHelper.showError('Could not launch Instagram');
      }
    } catch (e) {
      print('❌ Instagram error: $e');
      SnackBarHelper.showError('Unable to open Instagram');
    }
  }

  Future<void> openYouTube() async {
    final youtubeUrlStr = businessSettings.value?.youtube;
    if (youtubeUrlStr == null || youtubeUrlStr.isEmpty) {
      SnackBarHelper.showError('YouTube link not available');
      return;
    }

    try {
      print('▶️ Opening YouTube: $youtubeUrlStr');
      if (await canLaunchUrl(Uri.parse(youtubeUrlStr))) {
        await launchUrl(Uri.parse(youtubeUrlStr));
      } else {
        SnackBarHelper.showError('Could not launch YouTube');
      }
    } catch (e) {
      print('❌ YouTube error: $e');
      SnackBarHelper.showError('Unable to open YouTube');
    }
  }

  Future<void> sendEmail() async {
    final businessEmail = businessSettings.value?.businessEmail;
    if (businessEmail == null || businessEmail.isEmpty) {
      SnackBarHelper.showError('Email address not available');
      return;
    }

    final businessName = businessSettings.value?.businessName ?? 'Geo Rental Farms';
    final emailUrl = Uri(
      scheme: 'mailto',
      path: businessEmail,
      queryParameters: {
        'subject': 'Contact Inquiry - $businessName',
        'body': 'Hello $businessName,\n\nI would like to inquire about...',
      },
    ).toString();

    try {
      print('📧 Sending email to: $businessEmail');
      if (await canLaunchUrl(Uri.parse(emailUrl))) {
        await launchUrl(Uri.parse(emailUrl));
      } else {
        SnackBarHelper.showError('Could not launch email app');
      }
    } catch (e) {
      print('❌ Email error: $e');
      SnackBarHelper.showError('Unable to send email');
    }
  }

  // ===============================
  // GETTER METHODS FOR CONVENIENCE
  // ===============================
  String get businessName => businessSettings.value?.businessName ?? 'Geo Rental Farms';
  String get businessPhone => businessSettings.value?.businessPhone ?? '+91 81900 59995';
  String get businessEmail => businessSettings.value?.businessEmail ?? 'greenheapfarms@gmail.com';
  String get businessAddress => businessSettings.value?.businessAddress ?? 'Address not available';
  String get whatsappNumber => businessSettings.value?.whatsapp ?? '+91 81900 59995';
  String get instagramUrl => businessSettings.value?.instagram ?? '';
  String get youtubeUrl => businessSettings.value?.youtube ?? '';
  String get footerDescription => businessSettings.value?.footerDescription ?? '';
  String get logoUrl => businessSettings.value?.fullLogoUrl ?? '';
  double get giooAdminPercentage => businessSettings.value?.giooAdminPercentage ?? 0.0;
  int get giooMaxDuration => businessSettings.value?.giooMaxDuration ?? 0;
  double get giooMinProfit => businessSettings.value?.giooMinProfit ?? 0.0;

  // Role-based request getters
  int get serviceRequestsCount => serviceRequests.length;
  int get vendorRequestsCount => vendorRequests.length;
  int get agentRequestsCount => agentRequests.length;

  // ===============================
  // FORM FIELD UPDATERS
  // ===============================
  void updateFirstName(String value) => firstName.value = value;
  void updateLastName(String value) => lastName.value = value;
  void updateEmail(String value) => email.value = value;
  void updatePhone(String value) => phone.value = value;
  void updateRequirement(String value) => requirement.value = value;
  void updateMessage(String value) => message.value = value;

  // ===============================
  // REFRESH METHODS
  // ===============================
  void refreshDashboard() {
    fetchDashboard();
  }

  void refreshContactInfo() {
    fetchBusinessSettings();
  }


  void refreshAll() {
    fetchDashboard();
    fetchBusinessSettings();
  }
}