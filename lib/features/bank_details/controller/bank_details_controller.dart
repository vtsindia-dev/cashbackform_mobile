import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../common/api_constant.dart';
import '../../../common/widget/api_service.dart';
import '../../../common/widget/sessionhandler.dart';
import '../../../common/widget/toster.dart';
import '../model/bank_details_model.dart';

class BankDetailsController extends GetxController {

  var isLoading       = false.obs;
  var isSubmitting    = false.obs;
  var isDeleting      = false.obs;
  var isTogglingStatus = false.obs;
  var errorMessage    = ''.obs;

  var allBankDetails  = <BankDetails>[].obs;
  var editingDetails  = Rxn<BankDetails>();

  var isActive            = true.obs;
  var upiId               = ''.obs;
  var upiPhone            = ''.obs;
  var phoneNumber         = ''.obs;
  var bankAccountNumber   = ''.obs;
  var ifscCode            = ''.obs;
  var accountHolderName   = ''.obs;
  var bankName            = ''.obs;
  var branchName          = ''.obs;

  final upiCtrl           = TextEditingController();
  final upiPhoneCtrl      = TextEditingController();
  final phoneCtrl         = TextEditingController();
  final accountNumberCtrl = TextEditingController();
  final ifscCtrl          = TextEditingController();
  final holderNameCtrl    = TextEditingController();
  final bankNameCtrl      = TextEditingController();
  final branchNameCtrl    = TextEditingController();

  bool get isEditMode  => editingDetails.value != null;
  String get statusValue => isActive.value ? 'active' : 'inactive';

  @override
  void onInit() {
    super.onInit();
    fetchBankDetails();
  }

  @override
  void onClose() {
    _disposeControllers();
    super.onClose();
  }

  Future<void> fetchBankDetails() async {
    try {
      isLoading(true);
      errorMessage('');

      final token    = await SessionManager.getToken();
      final response = await ApiService.getRequest(
        ApiUrl.listOfBankDetails,
        headers: _authHeader(token),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true) {
          final raw = data['data'];
          if (raw is List) {
            allBankDetails.value =
                raw.map((e) => BankDetails.fromJson(e)).toList();
          } else if (raw is Map) {
            allBankDetails.value = [BankDetails.fromJson(raw as Map<String, dynamic>)];
          } else {
            allBankDetails.clear();
          }
        } else {
          allBankDetails.clear();
        }
      } else if (response.statusCode == 404) {
        allBankDetails.clear();
      } else {
        _handleError(response);
      }
    } catch (e) {
      SnackBarHelper.showError('Failed to load bank details: $e');
    } finally {
      isLoading(false);
    }
  }


  Future<Map<String, dynamic>> addBankDetails() async {
    try {
      isSubmitting(true);
      errorMessage('');

      final token    = await SessionManager.getToken();
      final payload  = _buildPayload();

      final response = await ApiService.postRequestWithToken(
        ApiUrl.bankDetails,
        data: payload,
        token: token ?? '',
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true) {
          if (data['data'] != null) {
            final newItem = BankDetails.fromJson(data['data']);
            allBankDetails.add(newItem);
          } else {
            await fetchBankDetails();
          }
          fetchBankDetails();
          SnackBarHelper.showSuccess(
              data['message'] ?? 'Bank details added successfully');
          clearForm();
          return {'status': 200};
        } else {
          errorMessage.value = data['message'] ?? 'Failed to add bank details';
          return {'status': 422, 'message': errorMessage.value};
        }
      } else if (response.statusCode == 422) {
        final errors = response.data['errors'] ?? {};
        errorMessage.value = _flattenErrors(errors) ?? 'Validation error';
        return {'status': 422, 'message': errorMessage.value};
      } else {
        _handleError(response);
        return {'status': response.statusCode ?? 500};
      }
    } catch (e) {
      errorMessage.value = 'Network error: $e';
      return {'status': 500, 'message': errorMessage.value};
    } finally {
      isSubmitting(false);
    }
  }


  Future<Map<String, dynamic>> updateBankDetails() async {
    final id = editingDetails.value?.id;
    if (id == null) return {'status': 400, 'message': 'No record to update'};

    try {
      isSubmitting(true);
      errorMessage('');

      final token   = await SessionManager.getToken();
      final payload = _buildPayload();

      final response = await ApiService.putRequestWithHeaders(
        '${ApiUrl.bankDetails}/$id',
        data: payload,
        headers: _authHeader(token),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true) {
          final updated = data['data'] != null
              ? BankDetails.fromJson(data['data'])
              : null;
          if (updated != null) {
            final idx = allBankDetails.indexWhere((e) => e.id == id);
            if (idx != -1) allBankDetails[idx] = updated;
          } else {
            await fetchBankDetails();
          }
          fetchBankDetails();
          SnackBarHelper.showSuccess(
              data['message'] ?? 'Bank details updated successfully');
          cancelEdit();
          return {'status': 200};
        } else {
          errorMessage.value =
              data['message'] ?? 'Failed to update bank details';
          return {'status': 422, 'message': errorMessage.value};
        }
      } else if (response.statusCode == 422) {
        final errors = response.data['errors'] ?? {};
        errorMessage.value = _flattenErrors(errors) ?? 'Validation error';
        return {'status': 422, 'message': errorMessage.value};
      } else {
        _handleError(response);
        return {'status': response.statusCode ?? 500};
      }
    } catch (e) {
      errorMessage.value = 'Network error: $e';
      return {'status': 500, 'message': errorMessage.value};
    } finally {
      isSubmitting(false);
    }
  }


  Future<bool> deleteBankDetails(int id) async {
    try {
      isDeleting(true);

      final token = await SessionManager.getToken();
      final response = await ApiService.deleteRequestWithHeaders(
        '${ApiUrl.bankDetails}/$id',
        headers: _authHeader(token),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['status'] == true) {
          allBankDetails.removeWhere((e) => e.id == id);
          fetchBankDetails();
          SnackBarHelper.showSuccess(
              data['message'] ?? 'Bank details deleted successfully');
          return true;
        }
      }
      SnackBarHelper.showError(
          response.data?['message'] ?? 'Failed to delete');
      return false;
    } catch (e) {
      SnackBarHelper.showError('Network error: $e');
      return false;
    } finally {
      isDeleting(false);
    }
  }


  Future<void> toggleStatus(BankDetails details) async {
    try {
      isTogglingStatus(true);

      final token      = await SessionManager.getToken();
      final newStatus  = details.isActive ? 'inactive' : 'active';

      final response = await ApiService.putRequestWithHeaders(
        '${ApiUrl.bankDetails}/${details.id}',
        data: _buildPayload(details)..['status'] = newStatus,
        headers: _authHeader(token),
      );

      if (response.statusCode == 200 &&
          response.data?['status'] == true) {
        final responseData = response.data?['data'];
        final updated = responseData != null
            ? BankDetails.fromJson(responseData)
            : BankDetails.fromJson({
          'id': details.id,
          'user_id': details.userId,
          'bank_name': details.bankName,
          'bank_account_number': details.bankAccountNumber,
          'ifsc_code': details.ifscCode,
          'account_holder_name': details.accountHolderName,
          'branch_name': details.branchName,
          'phone_number': details.phoneNumber,
          'upi_id': details.upiId,
          'upi_phone': details.upiPhone,
          'status': newStatus,
          'created_at': details.createdAt,
          'updated_at': details.updatedAt,
        });
        final idx = allBankDetails.indexWhere((e) => e.id == details.id);
        if (idx != -1) allBankDetails[idx] = updated;
        SnackBarHelper.showSuccess(
            'Status set to ${newStatus == 'active' ? 'Active' : 'Inactive'}');
        fetchBankDetails();
      } else {
        SnackBarHelper.showError(
            response.data?['message'] ?? 'Failed to update status');
      }
    } catch (e) {
      SnackBarHelper.showError('Network error: $e');
    } finally {
      isTogglingStatus(false);
    }
  }


  Future<Map<String, dynamic>> submit() =>
      isEditMode ? updateBankDetails() : addBankDetails();

  void startEdit(BankDetails details) {
    editingDetails.value = details;
    _populateFormFrom(details);
  }

  void cancelEdit() {
    editingDetails.value = null;
    clearForm();
  }

  void clearForm() {
    isActive.value          = true;
    upiId.value             = '';
    upiPhone.value          = '';
    phoneNumber.value       = '';
    bankAccountNumber.value = '';
    ifscCode.value          = '';
    accountHolderName.value = '';
    bankName.value          = '';
    branchName.value        = '';
    errorMessage.value      = '';

    upiCtrl.clear();
    upiPhoneCtrl.clear();
    phoneCtrl.clear();
    accountNumberCtrl.clear();
    ifscCtrl.clear();
    holderNameCtrl.clear();
    bankNameCtrl.clear();
    branchNameCtrl.clear();
  }

  void showDeleteDialog(int id,BuildContext context) {
    Get.defaultDialog(
      title: 'Delete Bank Details',
      titleStyle: const TextStyle(
          fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),
      middleText:
      'Are you sure you want to delete this record? This cannot be undone.',
      middleTextStyle:
      const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
      confirm: Obx(() => ElevatedButton(
        onPressed: isDeleting.value
            ? null
            : () async {
          final ok = await deleteBankDetails(id);
          if (ok) {
            Navigator.pop(context);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
        child: isDeleting.value
            ? const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Colors.white),
        )
            : const Text('Delete'),
      )),
      cancel: TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Cancel'),
      ),
    );
  }


  void _populateFormFrom(BankDetails d) {
    isActive.value          = d.isActive;
    bankAccountNumber.value = d.bankAccountNumber ?? '';
    ifscCode.value          = d.ifscCode ?? '';
    accountHolderName.value = d.accountHolderName ?? '';
    bankName.value          = d.bankName ?? '';
    branchName.value        = d.branchName ?? '';
    phoneNumber.value       = d.phoneNumber ?? '';
    upiId.value             = d.upiId ?? '';
    upiPhone.value          = d.upiPhone ?? '';

    accountNumberCtrl.text  = bankAccountNumber.value;
    ifscCtrl.text           = ifscCode.value;
    holderNameCtrl.text     = accountHolderName.value;
    bankNameCtrl.text       = bankName.value;
    branchNameCtrl.text     = branchName.value;
    phoneCtrl.text          = phoneNumber.value;
    upiCtrl.text            = upiId.value;
    upiPhoneCtrl.text       = upiPhone.value;
  }

  Map<String, dynamic> _buildPayload([BankDetails? d]) {
    // If a BankDetails object is passed, use its fields directly.
    // Otherwise fall back to the form observables (add / edit flow).
    final bankNameVal          = d?.bankName          ?? bankName.value;
    final accountNumberVal     = d?.bankAccountNumber ?? bankAccountNumber.value;
    final ifscVal              = d?.ifscCode          ?? ifscCode.value;
    final holderNameVal        = d?.accountHolderName ?? accountHolderName.value;
    final branchVal            = d?.branchName        ?? branchName.value;
    final phoneVal             = d?.phoneNumber       ?? phoneNumber.value;
    final upiIdVal             = d?.upiId             ?? upiId.value;
    final upiPhoneVal          = d?.upiPhone          ?? upiPhone.value;
    final statusVal            = d != null ? (d.isActive ? 'active' : 'inactive') : statusValue;

    final payload = <String, dynamic>{'status': statusVal};

    if (bankNameVal.isNotEmpty)      payload['bank_name']           = bankNameVal;
    if (accountNumberVal.isNotEmpty) payload['bank_account_number'] = accountNumberVal;
    if (ifscVal.isNotEmpty)          payload['ifsc_code']           = ifscVal;
    if (holderNameVal.isNotEmpty)    payload['account_holder_name'] = holderNameVal;
    if (branchVal.isNotEmpty)        payload['branch_name']         = branchVal;
    if (phoneVal.isNotEmpty)         payload['phone_number']        = phoneVal;
    if (upiIdVal.isNotEmpty)         payload['upi_id']              = upiIdVal;
    if (upiPhoneVal.isNotEmpty)      payload['upi_phone']           = upiPhoneVal;

    return payload;
  }

  Map<String, String> _authHeader(String? token) => {
    'Authorization': 'Bearer ${token ?? ''}',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  void _handleError(dynamic response) {
    final msg = response.data?['message'] ?? 'Something went wrong';
    errorMessage.value = msg;
    SnackBarHelper.showError(msg);
  }

  String? _flattenErrors(Map errors) {
    if (errors.isEmpty) return null;
    final first = errors.values.first;
    if (first is List && first.isNotEmpty) return first.first.toString();
    return first.toString();
  }

  void _disposeControllers() {
    upiCtrl.dispose();
    upiPhoneCtrl.dispose();
    phoneCtrl.dispose();
    accountNumberCtrl.dispose();
    ifscCtrl.dispose();
    holderNameCtrl.dispose();
    bankNameCtrl.dispose();
    branchNameCtrl.dispose();
  }
}