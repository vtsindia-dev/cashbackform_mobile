// controller/kyc_controller.dart

import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;

import '../../../common/api_constant.dart';
import '../../../common/colours.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';
import '../model/kyc_model.dart';
import '../widget/signature_pad.dart';

class KYCController extends GetxController {
  // ──────────────────────────────────────────
  // State
  // ──────────────────────────────────────────
  final RxList<KYCDocument> kycList = <KYCDocument>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  // Form fields
  final RxString name = ''.obs;
  final RxString panNo = ''.obs;
  final RxString aadharNo = ''.obs;

  // Document files
  final Rx<File?> panDoc = Rx<File?>(null);
  final Rx<File?> aadharDoc = Rx<File?>(null);
  final Rx<File?> signDoc = Rx<File?>(null);
  final Rx<File?> capturedSignature = Rx<File?>(null);
  final RxBool showSignaturePad = false.obs;
  final ImagePicker _picker = ImagePicker();


  @override
  void onInit() {
    super.onInit();
    fetchKYCList();
  }



  String? validateName(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Full name is required';
    if (v.length < 3) return 'Name must be at least 3 characters';
    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(v)) {
      return 'Name can only contain alphabets';
    }
    return null;
  }

  /// PAN format: 5 letters, 4 digits, 1 letter (e.g. ABCDE1234F)
  String? validatePAN(String value) {
    final v = value.trim().toUpperCase();
    if (v.isEmpty) return 'PAN number is required';
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(v)) {
      return 'Invalid PAN — expected format ABCDE1234F';
    }
    return null;
  }

  String? validateAadhar(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Aadhar number is required';
    if (v.length != 12) return 'Aadhar must be exactly 12 digits';
    if (!RegExp(r'^[2-9][0-9]{11}$').hasMatch(v)) {
      return 'Enter a valid 12-digit Aadhar number';
    }
    return null;
  }

  bool _validateForm() {
    final nameErr = validateName(name.value);
    if (nameErr != null) { errorMessage.value = nameErr; return false; }

    final panErr = validatePAN(panNo.value);
    if (panErr != null) { errorMessage.value = panErr; return false; }

    final aadharErr = validateAadhar(aadharNo.value);
    if (aadharErr != null) { errorMessage.value = aadharErr; return false; }

    return true;
  }

  // ──────────────────────────────────────────
  // API — Fetch KYC List
  // ──────────────────────────────────────────
  Future<Map<String, dynamic>> fetchKYCList() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Please login to view KYC documents';
        return {'status': 401, 'message': errorMessage.value};
      }
      final response = await ApiService.getAuthenticatedRequest(
        '${ApiUrl.baseUrl}/api/v2/kyc_list',
        token,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['status'] == true) {
          kycList.value = (data['data'] as List)
              .map((json) => KYCDocument.fromJson(json))
              .toList();
          return {'status': 200, 'message': 'Success'};
        } else {
          errorMessage.value = data['message'] ?? 'Failed to fetch KYC list';
          return {'status': 400, 'message': errorMessage.value};
        }
      } else {
        errorMessage.value = 'Server error (${response.statusCode})';
        return {'status': response.statusCode ?? 500, 'message': errorMessage.value};
      }
    } catch (e) {
      debugPrint('❌ fetchKYCList error: $e');
      errorMessage.value = 'Network error. Please check your connection.';
      return {'status': 500, 'message': errorMessage.value};
    } finally {

      isLoading.value = false;
    }
  }


  Future<Map<String, dynamic>> submitKYC() async {
    try {
      isSubmitting.value = true;
      errorMessage.value = '';

      // 1. Basic Validation (Ensure name, PAN, and Aadhar are filled)
      if (!_validateForm()) {
        return {'status': 400, 'message': errorMessage.value};
      }

      // 2. Authentication Check
      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Please login to submit KYC';
        return {'status': 401, 'message': errorMessage.value};
      }

      // 3. Prepare Form Data
      final formData = dio.FormData.fromMap({});
      formData.fields.add(MapEntry('name[]', name.value.trim()));
      formData.fields.add(MapEntry('pan_no[]', panNo.value.trim().toUpperCase()));
      formData.fields.add(MapEntry('aadhar_no[]', aadharNo.value.trim()));

      // PAN document — Required
      if (panDoc.value != null && await panDoc.value!.exists()) {
        formData.files.add(MapEntry(
          'pan_doc[]',
          await dio.MultipartFile.fromFile(
            panDoc.value!.path,
            filename: 'pan_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        ));
      } else {
        errorMessage.value = 'Please upload your PAN card document';
        return {'status': 400, 'message': errorMessage.value};
      }

      // Aadhar document — Required
      if (aadharDoc.value != null && await aadharDoc.value!.exists()) {
        formData.files.add(MapEntry(
          'aadhar_doc[]',
          await dio.MultipartFile.fromFile(
            aadharDoc.value!.path,
            filename: 'aadhar_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        ));
      } else {
        errorMessage.value = 'Please upload your Aadhar card document';
        return {'status': 400, 'message': errorMessage.value};
      }

      // Signature — OPTIONAL
      // If signFile is null or doesn't exist, we just don't add it to formData
      final signFile = signDoc.value ?? capturedSignature.value;
      if (signFile != null && await signFile.exists()) {
        final ext = signDoc.value != null ? 'jpg' : 'png';
        formData.files.add(MapEntry(
          'sign_doc[]',
          await dio.MultipartFile.fromFile(
            signFile.path,
            filename: 'sign_${DateTime.now().millisecondsSinceEpoch}.$ext',
          ),
        ));
      }

      // 4. API Request Setup
      final dioClient = dio.Dio();
      dioClient.options.headers['Authorization'] = 'Bearer $token';

      final response = await dioClient.post(
        'https://admincashback.vrikshatech.in/public/api/v2/kyc',
        data: formData,
      );

      // 5. Handle Response
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['status'] == true) {
          await fetchKYCList();
          clearForm();
          final msg = data['message'] ?? 'KYC submitted successfully';
          SnackBarHelper.showSuccess(msg);
          return {'status': 200, 'message': msg, 'data': data['data']};
        } else {
          final msg = data['message'] ?? 'Failed to submit KYC';
          errorMessage.value = msg;
          return {'status': 400, 'message': msg};
        }
      } else {
        final msg = response.data?['message'] ?? 'Server error (${response.statusCode})';
        errorMessage.value = msg;
        return {'status': response.statusCode ?? 500, 'message': msg};
      }

    } on dio.DioException catch (e) {
      debugPrint('❌ submitKYC DioException: $e');
      String msg;
      if (e.response != null) {
        msg = e.response?.data?['message'] ?? 'Server error (${e.response?.statusCode})';
      } else if (e.type == dio.DioExceptionType.connectionTimeout) {
        msg = 'Connection timed out. Check your internet.';
      } else if (e.type == dio.DioExceptionType.receiveTimeout) {
        msg = 'Server took too long to respond.';
      } else {
        msg = 'Network error. Please check your connection.';
      }
      errorMessage.value = msg;
      return {'status': 500, 'message': msg};

    } catch (e) {
      debugPrint('❌ submitKYC error: $e');
      final msg = 'Unexpected error: ${e.toString()}';
      errorMessage.value = msg;
      return {'status': 500, 'message': msg};

    } finally {
      isSubmitting.value = false;
    }
  }
  // ──────────────────────────────────────────
  // Image Picker Helpers
  // ──────────────────────────────────────────
  Future<void> pickImage(String type) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) _assignFile(type, File(image.path));
    } catch (e) {
      SnackBarHelper.showError('Could not pick image: $e');
    }
  }

  Future<void> captureImage(String type) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null) _assignFile(type, File(image.path));
    } catch (e) {
      SnackBarHelper.showError('Could not capture image: $e');
    }
  }

  void _assignFile(String type, File file) {
    switch (type) {
      case 'pan':
        panDoc.value = file;
        break;
      case 'aadhar':
        aadharDoc.value = file;
        break;
      case 'sign':
        signDoc.value = file;
        capturedSignature.value = null;
        break;
    }
    SnackBarHelper.showSuccess('${_docLabel(type)} added successfully');
  }

  void removeDocument(String type) {
    switch (type) {
      case 'pan':
        panDoc.value = null;
        break;
      case 'aadhar':
        aadharDoc.value = null;
        break;
      case 'sign':
        signDoc.value = null;
        capturedSignature.value = null;
        break;
    }
    SnackBarHelper.showInfo('${_docLabel(type)} removed');
  }

  String _docLabel(String type) {
    switch (type) {
      case 'pan': return 'PAN Card';
      case 'aadhar': return 'Aadhar Card';
      case 'sign': return 'Signature';
      default: return 'Document';
    }
  }

  // ──────────────────────────────────────────
  // Dialogs
  // ──────────────────────────────────────────
  void showImagePickerDialog(String type) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 32),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColor.lightGrey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Text(
              'Upload ${_docLabel(type)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColor.textMain,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _pickerOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  color: AppColor.primary,
                  onTap: () { Get.back(); captureImage(type); },
                ),
                _pickerOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: AppColor.accent,
                  onTap: () { Get.back(); pickImage(type); },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showSignatureOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 32),
        decoration: BoxDecoration(
          color: AppColor.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColor.lightGrey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Text(
              'Add Signature',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColor.textMain,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _pickerOption(
                  icon: Icons.draw_rounded,
                  label: 'Draw',
                  color: AppColor.accent,
                  onTap: () { Get.back(); showSignaturePadDialog(); },
                ),
                _pickerOption(
                  icon: Icons.upload_rounded,
                  label: 'Upload',
                  color: AppColor.orange,
                  onTap: () { Get.back(); showImagePickerDialog('sign'); },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showSignaturePadDialog() {
    Get.dialog(
      SignaturePadWidget(controller: this),
      barrierDismissible: false,
    );
  }

  Widget _pickerOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColor.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // Clear Form
  // ──────────────────────────────────────────
  void clearForm() {
    name.value = '';
    panNo.value = '';
    aadharNo.value = '';
    panDoc.value = null;
    aadharDoc.value = null;
    signDoc.value = null;
    capturedSignature.value = null;
    errorMessage.value = '';
  }
}