import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart';
import '../../../common/api_constant.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';
import '../model/dashboard_model.dart';

class DashboardController extends GetxController {
  // ===============================
  // STATE
  // ===============================

  final RxBool isLoading = false.obs;
  final RxBool isLoadingContact = false.obs;

  final Rx<Profile?> profile = Rx<Profile?>(null);

  // Dashboard Counters
  final RxInt myProperties = 0.obs;
  final RxInt marketEnquiryCount = 0.obs;
  final RxInt materialEnquiryCount = 0.obs;
  final RxInt residentialEnquiry = 0.obs;

  // Dashboard Lists
  final RxList<GiooBooked> giooBooked = <GiooBooked>[].obs;
  final RxList<MarketEnquiry> marketEnquiry = <MarketEnquiry>[].obs;

  // Contact Form Fields
  final RxString firstName = ''.obs;
  final RxString lastName = ''.obs;
  final RxString email = ''.obs;
  final RxString phone = ''.obs;
  final RxString requirement = ''.obs;
  final RxString message = ''.obs;

  // Business Info (from settings)
  final RxString businessPhone = '74347'.obs;
  final RxString businessEmail = 'Test@gmail.com'.obs;
  final RxString whatsappNumber = '9685741235'.obs;

  bool _isRequestInProgress = false;
  bool _isContactRequestInProgress = false;

  // ===============================
  // LIFECYCLE
  // ===============================

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
    fetchBusinessInfo();
  }

  // ===============================
  // DASHBOARD API CALL
  // ===============================

  Future<void> fetchDashboard() async {
    if (_isRequestInProgress) {
      print('⏸️ Dashboard request already in progress');
      return;
    }

    try {
      _isRequestInProgress = true;
      isLoading(true);
      final token = await SessionManager.getToken();
      final response = await ApiService.getRequest(ApiUrl.dashBoard, headers: {
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200 && response.data?['data'] != null) {
        final data = response.data['data'];

        profile.value = Profile.fromJson(data['profile']);

        myProperties.value = data['myproperties'] ?? 0;
        marketEnquiryCount.value = data['market_enquiry_count'] ?? 0;
        materialEnquiryCount.value = data['material_enquiry_count'] ?? 0;
        residentialEnquiry.value = data['residential_enquiry'] ?? 0;

        giooBooked.assignAll(
          (data['gioo_booked'] as List? ?? [])
              .map((e) => GiooBooked.fromJson(e))
              .toList(),
        );

        marketEnquiry.assignAll(
          (data['market_enquiry'] as List? ?? [])
              .map((e) => MarketEnquiry.fromJson(e))
              .toList(),
        );

        print('✅ Dashboard loaded successfully');
      } else {
        SnackBarHelper.showError('Failed to load dashboard');
        print('❌ Invalid dashboard response: ${response.data}');
      }
    } catch (e) {
      SnackBarHelper.showError('Network error');
      print('❌ Dashboard error: $e');
    } finally {
      isLoading(false);
      _isRequestInProgress = false;
    }
  }

  // ===============================
  // BUSINESS INFO API CALL
  // ===============================

  Future<void> fetchBusinessInfo() async {
    try {
      final response = await ApiService.getRequest(ApiUrl.settings);

      if (response.statusCode == 200 && response.data?['data'] != null) {
        final data = response.data['data'];

        businessPhone.value = data['business_phone']?.toString() ?? '74347';
        businessEmail.value = data['business_email']?.toString() ?? 'Test@gmail.com';
        whatsappNumber.value = data['whatsapp']?.toString() ?? '9685741235';

        print('✅ Business info loaded successfully');
      } else {
        print('⚠️ Using default business info');
      }
    } catch (e) {
      print('❌ Business info error: $e');
    }
  }

  // ===============================
  // CONTACT FORM SUBMISSION
  // ===============================

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

      // FIX: Removed comma after ApiUrl.contactEnquiry
      final response = await ApiService.postRequest(
        ApiUrl.contactEnquiry, // URL
        requestData,          // Data
      );

      print('📥 API Response Status: ${response.statusCode}');
      print('📥 API Response Data: ${response.data}');

      if (response.statusCode == 201 && response.data != null) {
        final data = response.data;

        if (data['status'] == true) {
          SnackBarHelper.showSuccess(data['message'] ?? 'Message sent successfully!');
          _clearContactForm();
        } else {
          SnackBarHelper.showError(data['message'] ?? 'Failed to send message. Please try again.');
        }
      } else if (response.statusCode == 201) {
        SnackBarHelper.showSuccess('Message sent successfully!');
        _clearContactForm();
      } else if (response.statusCode == 422) {
        // Validation errors from server
        final errors = response.data['errors'];
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
          SnackBarHelper.showError('Validation failed. Please check your input.');
        }
      } else {
        SnackBarHelper.showError('Failed to submit form. Status: ${response.statusCode}');
        print('❌ Invalid contact response: ${response.data}');
      }
    } on DioException catch (e) {
      print('❌ DioException in contact form: ${e.type} - ${e.message}');

      String errorMessage = 'Network error occurred.';
      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Please check your internet.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Connection error. Please check your internet.';
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

  // ===============================
  // CONTACT FORM VALIDATION
  // ===============================

  bool _validateContactForm() {
    // Check name fields
    if (firstName.value.isEmpty || lastName.value.isEmpty) {
      SnackBarHelper.showError('Please enter your full name');
      return false;
    }

    // Validate email
    if (email.value.isEmpty) {
      SnackBarHelper.showError('Please enter your email');
      return false;
    }

    if (!GetUtils.isEmail(email.value)) {
      SnackBarHelper.showError('Please enter a valid email address');
      return false;
    }

    // Check if either message or requirement is filled
    if (message.value.isEmpty && requirement.value.isEmpty) {
      SnackBarHelper.showError('Please enter either a message or requirement');
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
  }

  // ===============================
  // CONTACT ACTION METHODS
  // ===============================

  Future<void> makePhoneCall() async {
    final phoneNumber = 'tel:${businessPhone.value}';

    try {
      if (await canLaunchUrl(Uri.parse(phoneNumber))) {
        await launchUrl(Uri.parse(phoneNumber));
      } else {
        SnackBarHelper.showError('Could not launch phone app');
      }
    } catch (e) {
      print('❌ Phone call error: $e');
      SnackBarHelper.showError('Unable to make call');
    }
  }

  Future<void> openWhatsApp() async {
    final whatsappUrl = 'https://wa.me/${whatsappNumber.value}';

    try {
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

  Future<void> sendEmail() async {
    final emailUrl = Uri(
      scheme: 'mailto',
      path: businessEmail.value,
      queryParameters: {
        'subject': 'Contact Inquiry - ${DateTime.now().toString()}',
      },
    ).toString();

    try {
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
  // FIELD UPDATE METHODS
  // ===============================

  void updateFirstName(String value) => firstName.value = value;
  void updateLastName(String value) => lastName.value = value;
  void updateEmail(String value) => email.value = value;
  void updatePhone(String value) => phone.value = value;
  void updateRequirement(String value) => requirement.value = value;
  void updateMessage(String value) => message.value = value;

  // ===============================
  // HELPERS
  // ===============================

  void refreshDashboard() {
    fetchDashboard();
    fetchBusinessInfo();
  }

  void refreshContactInfo() {
    fetchBusinessInfo();
  }
}