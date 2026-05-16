import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../common/colours.dart';
import '../controller/kyc_controller.dart';

class KYCDocumentForm extends StatelessWidget {
  final KYCController controller;
  final bool isEditMode;

  const KYCDocumentForm({
    Key? key,
    required this.controller,
    this.isEditMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColor.backgroundLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(),
          Flexible(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('Personal Information'),
                  SizedBox(height: 12),
                  _buildNameField(),
                  SizedBox(height: 12),
                  _buildPANField(),
                  SizedBox(height: 12),
                  _buildAadharField(),
                  SizedBox(height: 24),
                  _buildSectionLabel('Upload Documents'),
                  if (isEditMode) ...[
                    SizedBox(height: 6),
                    _buildEditDocHint(),
                  ],
                  SizedBox(height: 12),
                  _buildDocumentUpload(
                    label: 'PAN Card',
                    hint: isEditMode
                        ? 'Upload new PAN card to replace existing'
                        : 'Front side of your PAN card',
                    icon: Icons.badge_rounded,
                    docType: 'pan',
                    file: controller.panDoc,
                    existingUrl: isEditMode
                        ? controller.editingKYC.value?.panDoc
                        : null,
                  ),
                  SizedBox(height: 12),
                  _buildDocumentUpload(
                    label: 'Aadhar Card',
                    hint: isEditMode
                        ? 'Upload new Aadhar card to replace existing'
                        : 'Front side of Aadhar card',
                    icon: Icons.credit_card_rounded,
                    docType: 'aadhar',
                    file: controller.aadharDoc,
                    existingUrl: isEditMode
                        ? controller.editingKYC.value?.aadharDoc
                        : null,
                  ),
                  SizedBox(height: 12),
                  _buildSignatureSection(),
                  SizedBox(height: 24),
                  _buildErrorBanner(),
                  _buildSubmitButton(),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHandle() {
    return Padding(
      padding: EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColor.grey.withValues(alpha:0.35),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 8, 16),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isEditMode
                  ? AppColor.primary.withValues(alpha:0.12)
                  : AppColor.primary.withValues(alpha:0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEditMode ? Icons.edit_rounded : Icons.shield_rounded,
              color: isEditMode ? AppColor.primary : AppColor.primary,
              size: 22,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditMode ? 'Edit KYC Document' : 'Add KYC Document',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColor.textMain,
                  ),
                ),
                Text(
                  isEditMode
                      ? 'Update your KYC details below'
                      : 'Fill all details to complete verification',
                  style:
                  TextStyle(fontSize: 12, color: AppColor.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, color: AppColor.textSecondary),
            onPressed: () {
              if (isEditMode) {
                controller.cancelEdit();
              } else {
                controller.clearForm();
              }
              Get.back();
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: isEditMode ? AppColor.primary : AppColor.primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isEditMode ? AppColor.primary : AppColor.primary,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

 
  Widget _buildEditDocHint() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColor.primary.withValues(alpha:0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.primary.withValues(alpha:0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: 15, color: AppColor.primary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Leave documents unchanged to keep existing files.',
              style: TextStyle(
                  fontSize: 12, color: AppColor.primary, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
  

  Widget _buildNameField() {
    return _KYCTextField(
      label: 'Full Name',
      hint: 'As per official ID',
      icon: Icons.person_outline_rounded,
      initialValue: controller.name.value,
      accentColor: isEditMode ? AppColor.primary : AppColor.primary,
      onChanged: (v) {
        controller.name.value = v;
        controller.errorMessage.value = '';
      },
      validator: (v) {
        if (v.isEmpty) return 'Name is required';
        if (v.trim().length < 3) return 'Enter a valid full name';
        if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(v)) {
          return 'Only alphabets allowed';
        }
        return null;
      },
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
      ],
    );
  }

  Widget _buildPANField() {
    return _KYCTextField(
      label: 'PAN Number',
      hint: 'e.g. ABCDE1234F',
      icon: Icons.card_membership_rounded,
      initialValue: controller.panNo.value,
      maxLength: 10,
      textCapitalization: TextCapitalization.characters,
      accentColor: isEditMode ? AppColor.primary : AppColor.primary,
      onChanged: (v) {
        controller.panNo.value = v.toUpperCase();
        controller.errorMessage.value = '';
      },
      validator: (v) {
        if (v.isEmpty) return 'PAN Number is required';
        if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$')
            .hasMatch(v.toUpperCase())) {
          return 'Invalid PAN format (e.g. ABCDE1234F)';
        }
        return null;
      },
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
        UpperCaseTextFormatter(),
      ],
    );
  }

  Widget _buildAadharField() {
    return _KYCTextField(
      label: 'Aadhar Number',
      hint: '12-digit Aadhar number',
      icon: Icons.fingerprint_rounded,
      initialValue: controller.aadharNo.value,
      maxLength: 12,
      keyboardType: TextInputType.number,
      accentColor: isEditMode ? AppColor.primary : AppColor.primary,
      onChanged: (v) {
        controller.aadharNo.value = v;
        controller.errorMessage.value = '';
      },
      validator: (v) {
        if (v.isEmpty) return 'Aadhar number is required';
        if (v.length != 12) return 'Aadhar must be exactly 12 digits';
        if (!RegExp(r'^[2-9]{1}[0-9]{11}$').hasMatch(v)) {
          return 'Enter a valid Aadhar number';
        }
        return null;
      },
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    );
  }
  

  Widget _buildDocumentUpload({
    required String label,
    required String hint,
    required IconData icon,
    required String docType,
    required Rx<File?> file,
    String? existingUrl, 
  }) {
    return Obx(() {
      final hasNewFile = file.value != null;
      final hasExisting =
          existingUrl != null && existingUrl.isNotEmpty && !hasNewFile;

      Color borderColor = AppColor.lightGrey;
      Color bgColor = AppColor.white;

      if (hasNewFile) {
        borderColor = AppColor.primary.withValues(alpha:0.4);
        bgColor = AppColor.primary.withValues(alpha:0.05);
      } else if (hasExisting) {
        borderColor = AppColor.success.withValues(alpha:0.4);
        bgColor = AppColor.success.withValues(alpha:0.04);
      }

      return AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: (hasNewFile || hasExisting) ? 1.5 : 1,
          ),
        ),
        child: hasNewFile
            ? _buildFilledDocRow(
          label: label,
          icon: icon,
          file: file.value!,
          docType: docType,
        )
            : hasExisting
            ? _buildExistingDocRow(
          label: label,
          icon: icon,
          docType: docType,
        )
            : _buildEmptyDocRow(
          label: label,
          hint: hint,
          icon: icon,
          docType: docType,
        ),
      );
    });
  }
  
  Widget _buildExistingDocRow({
    required String label,
    required IconData icon,
    required String docType,
  }) {
    return Padding(
      padding: EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColor.success.withValues(alpha:0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColor.success),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 14, color: AppColor.success),
                    SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        color: AppColor.textMain,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  'Existing file on server — tap to replace',
                  style: TextStyle(color: AppColor.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => controller.showImagePickerDialog(docType),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.primary.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColor.primary.withValues(alpha:0.3)),
              ),
              child: Text(
                'Replace',
                style: TextStyle(
                  color: AppColor.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDocRow({
    required String label,
    required String hint,
    required IconData icon,
    required String docType,
  }) {
    return InkWell(
      onTap: () => controller.showImagePickerDialog(docType),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColor.lightGrey,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AppColor.grey),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: AppColor.textMain,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(hint,
                      style: TextStyle(color: AppColor.grey, fontSize: 12)),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Upload',
                style: TextStyle(
                  color: AppColor.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilledDocRow({
    required String label,
    required IconData icon,
    required File file,
    required String docType,
  }) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child:
            Image.file(file, width: 56, height: 56, fit: BoxFit.cover),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 14, color: AppColor.success),
                    SizedBox(width: 4),
                    Text(
                      label,
                      style: TextStyle(
                        color: AppColor.textMain,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  _shortPath(file.path),
                  style: TextStyle(color: AppColor.grey, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon:
            Icon(Icons.delete_outline_rounded, color: AppColor.error),
            onPressed: () => controller.removeDocument(docType),
          ),
        ],
      ),
    );
  }
  

  Widget _buildSignatureSection() {
    return Obx(() {
      final hasSign = controller.signDoc.value != null ||
          controller.capturedSignature.value != null;
      final existingSignUrl =
      isEditMode ? controller.editingKYC.value?.signDoc : null;
      final hasExistingSign = existingSignUrl != null &&
          existingSignUrl.isNotEmpty &&
          !hasSign;

      Color borderColor = AppColor.lightGrey;
      Color bgColor = AppColor.white;
      if (hasSign) {
        borderColor = AppColor.primary.withValues(alpha:0.4);
        bgColor = AppColor.primary.withValues(alpha:0.05);
      } else if (hasExistingSign) {
        borderColor = AppColor.success.withValues(alpha:0.4);
        bgColor = AppColor.success.withValues(alpha:0.04);
      }

      final signFile =
          controller.signDoc.value ?? controller.capturedSignature.value;

      return AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: (hasSign || hasExistingSign) ? 1.5 : 1,
          ),
        ),
        child: hasSign && signFile != null
            ? _buildFilledDocRow(
          label: 'Signature',
          icon: Icons.draw_rounded,
          file: signFile,
          docType: 'sign',
        )
            : hasExistingSign
            ? _buildExistingDocRow(
          label: 'Signature',
          icon: Icons.draw_rounded,
          docType: 'sign',
        )
            : InkWell(
          onTap: controller.showSignatureOptions,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColor.primary.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.draw_rounded,
                      size: 20, color: AppColor.primary),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Signature',
                        style: TextStyle(
                          color: AppColor.textMain,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        isEditMode
                            ? 'Draw or upload to replace signature'
                            : 'Draw or upload your signature',
                        style: TextStyle(
                            color: AppColor.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColor.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isEditMode ? 'Replace' : 'Add',
                    style: TextStyle(
                      color: AppColor.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildErrorBanner() {
    return Obx(() {
      if (controller.errorMessage.value.isEmpty) return SizedBox.shrink();
      return Container(
        margin: EdgeInsets.only(bottom: 16),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColor.error.withValues(alpha:0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.error.withValues(alpha:0.25)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded,
                color: AppColor.error, size: 18),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                controller.errorMessage.value,
                style: TextStyle(
                    color: AppColor.error, fontSize: 13, height: 1.4),
              ),
            ),
            GestureDetector(
              onTap: () => controller.errorMessage.value = '',
              child: Icon(Icons.close_rounded,
                  color: AppColor.error, size: 16),
            ),
          ],
        ),
      );
    });
  }
  

  Widget _buildSubmitButton() {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed:
        controller.isSubmitting.value ? null : _onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor:
          isEditMode ? AppColor.primary : AppColor.primary,
          foregroundColor: AppColor.white,
          disabledBackgroundColor: isEditMode
              ? AppColor.primary.withValues(alpha:0.5)
              : AppColor.primary.withValues(alpha:0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: controller.isSubmitting.value
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColor.white),
            ),
            SizedBox(width: 10),
            Text(
              isEditMode ? 'Updating...' : 'Submitting...',
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isEditMode
                  ? Icons.save_rounded
                  : Icons.shield_rounded,
              size: 18,
            ),
            SizedBox(width: 8),
            Text(
              isEditMode ? 'Update KYC' : 'Submit KYC',
              style: TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ],
        ),
      ),
    ));
  }
  

  Future<void> _onSubmit() async {
    final nameErr = _validateName(controller.name.value);
    final panErr = _validatePAN(controller.panNo.value);
    final aadharErr = _validateAadhar(controller.aadharNo.value);

    if (nameErr != null) {
      controller.errorMessage.value = nameErr;
      return;
    }
    if (panErr != null) {
      controller.errorMessage.value = panErr;
      return;
    }
    if (aadharErr != null) {
      controller.errorMessage.value = aadharErr;
      return;
    }

    final result = isEditMode
        ? await controller.updateKYC()
        : await controller.submitKYC();

    if (result['status'] == 200) {
      Get.back();
    }
  }
  

  String? _validateName(String v) {
    if (v.trim().isEmpty) return 'Full name is required';
    if (v.trim().length < 3) return 'Name must be at least 3 characters';
    if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(v)) {
      return 'Only alphabets are allowed in name';
    }
    return null;
  }

  String? _validatePAN(String v) {
    if (v.isEmpty) return 'PAN number is required';
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$')
        .hasMatch(v.toUpperCase())) {
      return 'Invalid PAN — format must be ABCDE1234F';
    }
    return null;
  }

  String? _validateAadhar(String v) {
    if (v.isEmpty) return 'Aadhar number is required';
    if (v.length != 12) return 'Aadhar must be exactly 12 digits';
    if (!RegExp(r'^[2-9]{1}[0-9]{11}$').hasMatch(v)) {
      return 'Enter a valid 12-digit Aadhar number';
    }
    return null;
  }

  String _shortPath(String path) {
    return path.split('/').last;
  }
}


class _KYCTextField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? Function(String)? validator;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  
  final Color accentColor;

  const _KYCTextField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.initialValue,
    required this.onChanged,
    required this.accentColor,
    this.validator,
    this.maxLength,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  @override
  State<_KYCTextField> createState() => _KYCTextFieldState();
}

class _KYCTextFieldState extends State<_KYCTextField> {
  late final TextEditingController _ctrl;
  String? _error;
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
    if (widget.initialValue.isNotEmpty) {
      _touched = true;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    widget.onChanged(v);
    if (_touched && widget.validator != null) {
      setState(() => _error = widget.validator!(v));
    }
  }

  void _onBlur() {
    if (!_touched) setState(() => _touched = true);
    if (widget.validator != null) {
      setState(() => _error = widget.validator!(_ctrl.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _error != null && _error!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          onFocusChange: (focused) {
            if (!focused) _onBlur();
          },
          child: TextField(
            controller: _ctrl,
            onChanged: _onChanged,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            textCapitalization: widget.textCapitalization,
            inputFormatters: widget.inputFormatters,
            style: TextStyle(
              color: AppColor.textMain,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              hintStyle: TextStyle(color: AppColor.grey, fontSize: 13),
              labelStyle: TextStyle(
                color: hasError ? AppColor.error : AppColor.textSecondary,
                fontSize: 14,
              ),
              prefixIcon: Icon(
                widget.icon,
                color: hasError ? AppColor.error : widget.accentColor,
                size: 20,
              ),
              suffixIcon: _ctrl.text.isNotEmpty && !hasError && _touched
                  ? Icon(Icons.check_circle_rounded,
                  color: AppColor.success, size: 18)
                  : null,
              counterText: '',
              filled: true,
              fillColor: AppColor.white,
              contentPadding:
              EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColor.lightGrey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColor.lightGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                BorderSide(color: widget.accentColor, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColor.error, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColor.error, width: 1.5),
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: EdgeInsets.only(top: 5, left: 4),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 13, color: AppColor.error),
                SizedBox(width: 4),
                Text(
                  _error!,
                  style: TextStyle(color: AppColor.error, fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }
}


class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}