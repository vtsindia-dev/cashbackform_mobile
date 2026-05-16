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
  final RxList<KYCDocument> kycList = <KYCDocument>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString name = ''.obs;
  final RxString panNo = ''.obs;
  final RxString aadharNo = ''.obs;
  final Rx<File?> panDoc = Rx<File?>(null);
  final Rx<File?> aadharDoc = Rx<File?>(null);
  final Rx<File?> signDoc = Rx<File?>(null);
  final Rx<File?> capturedSignature = Rx<File?>(null);
  final RxBool showSignaturePad = false.obs;
  final ImagePicker _picker = ImagePicker();

  final selectedBeneficiaries = <KYCDocument>[].obs;
  final RxList<String> selectedPans = <String>[].obs;

  final Rx<KYCDocument?> editingKYC = Rx<KYCDocument?>(null);
  final RxBool isEditMode = false.obs;

  void toggleBeneficiary(KYCDocument kyc) {
    if (selectedPans.contains(kyc.id.toString())) {
      selectedPans.remove(kyc.id.toString());
    } else {
      selectedPans.add(kyc.id.toString());
    }

    selectedBeneficiaries.assignAll(
      kycList.where((e) => selectedPans.contains(e.id.toString())).toList(),
    );

    selectedPans.refresh();
  }

  @override
  void onInit() {
    super.onInit();
    fetchKYCList();
  }

  void startEdit(KYCDocument kyc) {
    editingKYC.value = kyc;
    isEditMode.value = true;
    name.value = kyc.name;
    panNo.value = kyc.panNo;
    aadharNo.value = kyc.aadharNo;
    panDoc.value = null;
    aadharDoc.value = null;
    signDoc.value = null;
    capturedSignature.value = null;
    errorMessage.value = '';
  }

  void cancelEdit() {
    isEditMode.value = false;
    editingKYC.value = null;
    clearForm();
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
    if (nameErr != null) {
      errorMessage.value = nameErr;
      return false;
    }

    final panErr = validatePAN(panNo.value);
    if (panErr != null) {
      errorMessage.value = panErr;
      return false;
    }

    final aadharErr = validateAadhar(aadharNo.value);
    if (aadharErr != null) {
      errorMessage.value = aadharErr;
      return false;
    }

    return true;
  }

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
        return {
          'status': response.statusCode ?? 500,
          'message': errorMessage.value,
        };
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

      if (!_validateForm()) {
        return {'status': 400, 'message': errorMessage.value};
      }

      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Please login to submit KYC';
        return {'status': 401, 'message': errorMessage.value};
      }

      final formData = dio.FormData.fromMap({});
      formData.fields.add(MapEntry('name[]', name.value.trim()));
      formData.fields.add(
          MapEntry('pan_no[]', panNo.value.trim().toUpperCase()));
      formData.fields.add(MapEntry('aadhar_no[]', aadharNo.value.trim()));
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

      final dioClient = dio.Dio();
      dioClient.options.headers['Authorization'] = 'Bearer $token';

      final response = await dioClient.post(
        '${ApiUrl.baseUrl}/api/v2/kyc',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['status'] == true) {
          await fetchKYCList();
          clearForm();
          Get.back();
          final msg = data['message'] ?? 'KYC submitted successfully';
          SnackBarHelper.showSuccess(msg);
          return {'status': 200, 'message': msg, 'data': data['data']};
        } else {
          final msg = data['message'] ?? 'Failed to submit KYC';
          errorMessage.value = msg;
          return {'status': 400, 'message': msg};
        }
      } else {
        final msg =
            response.data?['message'] ?? 'Server error (${response.statusCode})';
        errorMessage.value = msg;
        return {'status': response.statusCode ?? 500, 'message': msg};
      }
    } on dio.DioException catch (e) {
      debugPrint('❌ submitKYC DioException: $e');
      String msg;
      if (e.response != null) {
        msg = e.response?.data?['message'] ??
            'Server error (${e.response?.statusCode})';
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

  Future<Map<String, dynamic>> updateKYC() async {
    try {
      isSubmitting.value = true;
      errorMessage.value = '';

      if (editingKYC.value == null) {
        errorMessage.value = 'No KYC record selected for update';
        return {'status': 400, 'message': errorMessage.value};
      }

      if (!_validateForm()) {
        return {'status': 400, 'message': errorMessage.value};
      }

      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Please login to update KYC';
        return {'status': 401, 'message': errorMessage.value};
      }

      final kycId = editingKYC.value!.id;
      final formData = dio.FormData.fromMap({});

      formData.fields.add(MapEntry('name', name.value.trim()));
      formData.fields
          .add(MapEntry('pan_no', panNo.value.trim().toUpperCase()));
      formData.fields.add(MapEntry('aadhar_no', aadharNo.value.trim()));

      if (panDoc.value != null && await panDoc.value!.exists()) {
        formData.files.add(MapEntry(
          'pan_doc',
          await dio.MultipartFile.fromFile(
            panDoc.value!.path,
            filename: 'pan_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        ));
      }

      if (aadharDoc.value != null && await aadharDoc.value!.exists()) {
        formData.files.add(MapEntry(
          'aadhar_doc',
          await dio.MultipartFile.fromFile(
            aadharDoc.value!.path,
            filename: 'aadhar_${DateTime.now().millisecondsSinceEpoch}.jpg',
          ),
        ));
      }

      final signFile = signDoc.value ?? capturedSignature.value;
      if (signFile != null && await signFile.exists()) {
        final ext = signDoc.value != null ? 'jpg' : 'png';
        formData.files.add(MapEntry(
          'sign_doc',
          await dio.MultipartFile.fromFile(
            signFile.path,
            filename: 'sign_${DateTime.now().millisecondsSinceEpoch}.$ext',
          ),
        ));
      }

      final dioClient = dio.Dio();
      dioClient.options.headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      final response = await dioClient.post(
        '${ApiUrl.baseUrl}/api/v2/kyc-update/$kycId',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['status'] == true) {
          await fetchKYCList();
          cancelEdit();
          Get.back();
          final msg = data['message'] ?? 'KYC updated successfully';
          SnackBarHelper.showSuccess(msg);
          return {'status': 200, 'message': msg, 'data': data['data']};
        } else {
          final msg = data['message'] ?? 'Failed to update KYC';
          errorMessage.value = msg;
          SnackBarHelper.showError(msg);
          return {'status': 400, 'message': msg};
        }
      } else {
        final msg = response.data?['message'] ??
            'Server error (${response.statusCode})';
        errorMessage.value = msg;
        return {'status': response.statusCode ?? 500, 'message': msg};
      }
    } on dio.DioException catch (e) {
      debugPrint('❌ updateKYC DioException: $e');
      String msg;
      if (e.response != null) {
        msg = e.response?.data?['message'] ??
            'Server error (${e.response?.statusCode})';
      } else if (e.type == dio.DioExceptionType.connectionTimeout) {
        msg = 'Connection timed out. Check your internet.';
      } else if (e.type == dio.DioExceptionType.receiveTimeout) {
        msg = 'Server took too long to respond.';
      } else {
        msg = 'Network error. Please check your connection.';
      }
      errorMessage.value = msg;
      SnackBarHelper.showError(msg);
      return {'status': 500, 'message': msg};
    } catch (e) {
      debugPrint('❌ updateKYC error: $e');
      final msg = 'Unexpected error: ${e.toString()}';
      errorMessage.value = msg;
      SnackBarHelper.showError(msg);
      return {'status': 500, 'message': msg};
    } finally {
      isSubmitting.value = false;
    }
  }


  final RxSet<int> deletingIds = <int>{}.obs;
  bool isDeletingCard(int kycId) => deletingIds.contains(kycId);

  Future<Map<String, dynamic>> deleteKYC(int kycId) async {
    try {
      deletingIds.add(kycId);
      errorMessage.value = '';

      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Please login to delete KYC';
        return {'status': 401, 'message': errorMessage.value};
      }

      final dioClient = dio.Dio();
      dioClient.options.headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      final response = await dioClient.post(
        '${ApiUrl.baseUrl}/api/v2/kyc-delete/$kycId',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['status'] == true) {
          kycList.removeWhere((k) => k.id == kycId);
          final msg = data['message'] ?? 'KYC deleted successfully';
          SnackBarHelper.showSuccess(msg);
          return {'status': 200, 'message': msg};
        } else {
          final msg = data['message'] ?? 'Failed to delete KYC';
          errorMessage.value = msg;
          SnackBarHelper.showError(msg);
          return {'status': 400, 'message': msg};
        }
      } else {
        final msg = response.data?['message'] ??
            'Server error (${response.statusCode})';
        errorMessage.value = msg;
        return {'status': response.statusCode ?? 500, 'message': msg};
      }
    } on dio.DioException catch (e) {
      debugPrint('❌ deleteKYC DioException: $e');
      String msg;
      if (e.response != null) {
        msg = e.response?.data?['message'] ??
            'Server error (${e.response?.statusCode})';
      } else if (e.type == dio.DioExceptionType.connectionTimeout) {
        msg = 'Connection timed out. Check your internet.';
      } else {
        msg = 'Network error. Please check your connection.';
      }
      errorMessage.value = msg;
      SnackBarHelper.showError(msg);
      return {'status': 500, 'message': msg};
    } catch (e) {
      debugPrint('❌ deleteKYC error: $e');
      final msg = 'Unexpected error: ${e.toString()}';
      errorMessage.value = msg;
      SnackBarHelper.showError(msg);
      return {'status': 500, 'message': msg};
    } finally {
      deletingIds.remove(kycId);
    }
  }


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
      case 'pan':
        return 'PAN Card';
      case 'aadhar':
        return 'Aadhar Card';
      case 'sign':
        return 'Signature';
      default:
        return 'Document';
    }
  }

  Future<Map<String, dynamic>> kycVerification({
    required String propertyId,
    required String transactionId,
    required String type,
  }) async {
    try {
      isSubmitting.value = true;
      errorMessage.value = '';

      final token = await SessionManager.getToken();

      if (token == null || token.isEmpty) {
        errorMessage.value = 'Please login first';
        return {'status': 401, 'message': errorMessage.value};
      }

      if (selectedBeneficiaries.isEmpty) {
        errorMessage.value = 'Please select beneficiary';
        SnackBarHelper.showError(errorMessage.value);
        return {'status': 400, 'message': errorMessage.value};
      }

      final formData = dio.FormData();
      formData.fields.add(MapEntry('property_id', propertyId));
      formData.fields.add(MapEntry('transaction_id', transactionId));
      formData.fields.add(MapEntry('type', type));

      for (var item in selectedBeneficiaries) {
        formData.fields.add(MapEntry('benficiary_id[]', item.id.toString()));
      }

      final dioClient = dio.Dio();
      dioClient.options.headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      };

      final response = await dioClient.post(
        '${ApiUrl.baseUrl}/api/v2/kyc_verification',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['status'] == true) {
          final msg = data['message'] ?? 'KYC verification successful';
          SnackBarHelper.showSuccess(msg);
          return {'status': 200, 'message': msg, 'data': data};
        } else {
          final msg = data['message'] ?? 'KYC verification failed';
          errorMessage.value = msg;
          SnackBarHelper.showError(msg);
          return {'status': 400, 'message': msg};
        }
      } else {
        final msg = 'Server error (${response.statusCode})';
        errorMessage.value = msg;
        return {'status': response.statusCode ?? 500, 'message': msg};
      }
    } on dio.DioException catch (e) {
      debugPrint('❌ kycVerification Dio Error: $e');
      String msg;
      if (e.response != null) {
        msg = e.response?.data?['message'] ?? 'Server error';
      } else {
        msg = 'Network error';
      }
      errorMessage.value = msg;
      SnackBarHelper.showError(msg);
      return {'status': 500, 'message': msg};
    } catch (e) {
      debugPrint('❌ kycVerification Error: $e');
      const msg = 'Unexpected error';
      errorMessage.value = msg;
      SnackBarHelper.showError(msg);
      return {'status': 500, 'message': msg};
    } finally {
      isSubmitting.value = false;
    }
  }

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
                  onTap: () {
                    Get.back();
                    captureImage(type);
                  },
                ),
                _pickerOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  color: AppColor.accent,
                  onTap: () {
                    Get.back();
                    pickImage(type);
                  },
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
                  onTap: () {
                    Get.back();
                    showSignaturePadDialog();
                  },
                ),
                _pickerOption(
                  icon: Icons.upload_rounded,
                  label: 'Upload',
                  color: AppColor.orange,
                  onTap: () {
                    Get.back();
                    showImagePickerDialog('sign');
                  },
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

  void showDeleteConfirmDialog(KYCDocument kyc) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColor.error, size: 24),
            SizedBox(width: 8),
            Text(
              'Delete KYC',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColor.textMain,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete KYC record for "${kyc.name}"?\n\nThis action cannot be undone.',
          style: TextStyle(
            color: AppColor.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColor.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              deleteKYC(kyc.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.error,
              foregroundColor: AppColor.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }


  void clearForm() {
    name.value = '';
    panNo.value = '';
    aadharNo.value = '';
    panDoc.value = null;
    aadharDoc.value = null;
    signDoc.value = null;
    capturedSignature.value = null;
    errorMessage.value = '';
    isEditMode.value = false;
    editingKYC.value = null;
  }
}