import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../common/colours.dart';
import '../controller/bank_details_controller.dart';

void openBankDetailsForm(
    BuildContext context,
    BankDetailsController controller, {
      required bool isEdit,
    }) {
  if (!isEdit) controller.clearForm();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BankDetailsForm(
      controller: controller,
      isEditMode: isEdit,
    ),
  );
}


class BankDetailsForm extends StatelessWidget {
  final BankDetailsController controller;
  final bool isEditMode;

  const BankDetailsForm({
    super.key,
    required this.controller,
    this.isEditMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: AppColor.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(context),
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusToggleCard(controller: controller),
                  const SizedBox(height: 16),
                  _SectionCard(
                    icon: Icons.account_balance_rounded,
                    title: 'Bank Details',
                    required: true,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _BankTextField(
                                label: 'Bank Name',
                                hint: 'e.g. HDFC Bank',
                                icon: Icons.account_balance_outlined,
                                controller: controller.bankNameCtrl,
                                onChanged: (v) {
                                  controller.bankName.value = v;
                                  controller.errorMessage.value = '';
                                },
                                validator: (v) =>
                                v.isEmpty ? 'Bank name is required' : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _BankTextField(
                                label: 'Account Number',
                                hint: 'Enter account number',
                                icon: Icons.credit_card_rounded,
                                controller: controller.accountNumberCtrl,
                                keyboardType: TextInputType.number,
                                maxLength: 20,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                onChanged: (v) {
                                  controller.bankAccountNumber.value = v;
                                  controller.errorMessage.value = '';
                                },
                                validator: (v) {
                                  if (v.isEmpty) return 'Account number is required';
                                  if (v.length < 8) return 'Enter a valid account number';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _BankTextField(
                                label: 'IFSC Code',
                                hint: 'e.g. HDFC0000001',
                                icon: Icons.tag_rounded,
                                controller: controller.ifscCtrl,
                                maxLength: 11,
                                textCapitalization: TextCapitalization.characters,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9]')),
                                  _UpperCaseFormatter(),
                                ],
                                onChanged: (v) {
                                  controller.ifscCode.value = v.toUpperCase();
                                  controller.errorMessage.value = '';
                                },
                                validator: (v) {
                                  if (v.isEmpty) return 'IFSC code is required';
                                  if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$')
                                      .hasMatch(v.toUpperCase())) {
                                    return 'Invalid IFSC (e.g. HDFC0000001)';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _BankTextField(
                                label: 'Account Holder Name',
                                hint: 'Name as per bank records',
                                icon: Icons.person_outline_rounded,
                                controller: controller.holderNameCtrl,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z\s]')),
                                ],
                                onChanged: (v) {
                                  controller.accountHolderName.value = v;
                                  controller.errorMessage.value = '';
                                },
                                validator: (v) {
                                  if (v.isEmpty) return 'Holder name is required';
                                  if (v.trim().length < 3) return 'Enter a valid name';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _BankTextField(
                                label: 'Branch Name',
                                hint: 'e.g. Chennai',
                                icon: Icons.location_on_outlined,
                                controller: controller.branchNameCtrl,
                                onChanged: (v) {
                                  controller.branchName.value = v;
                                  controller.errorMessage.value = '';
                                },
                                validator: (v) {
                                  if (v.isEmpty) return 'Branch name is required';
                                  if (v.trim().length < 3) return 'Enter valid branch name';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _BankTextField(
                                label: 'Phone Number',
                                hint: 'Registered phone number',
                                icon: Icons.phone_outlined,
                                controller: controller.phoneCtrl,
                                keyboardType: TextInputType.phone,
                                maxLength: 15,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9+\-\s]')),
                                ],
                                onChanged: (v) {
                                  controller.phoneNumber.value = v;
                                  controller.errorMessage.value = '';
                                },
                                validator: (v) {
                                  if (v.isEmpty) return 'Phone number is required';
                                  if (v.replaceAll(RegExp(r'\D'), '').length < 10) {
                                    return 'Enter a valid phone number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    icon: Icons.qr_code_scanner_rounded,
                    title: 'UPI / Online Payment',
                    required: true,
                    child: _BankTextField(
                      label: 'UPI ID',
                      hint: 'e.g. xyz@paytm',
                      icon: Icons.alternate_email_rounded,
                      controller: controller.upiCtrl,
                      onChanged: (v) {
                        controller.upiId.value = v;
                        controller.errorMessage.value = '';
                      },
                      validator: (v) =>
                      v.isEmpty ? 'UPI ID is required' : null,
                    ),
                  ),

                  const SizedBox(height: 24),
                  _buildErrorBanner(),
                  _buildSubmitButton(context),
                  const SizedBox(height: 8),
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
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColor.grey.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColor.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEditMode ? Icons.edit_rounded : Icons.account_balance_rounded,
              color: AppColor.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditMode ? 'Edit Bank Details' : 'Add Bank Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColor.textMain,
                  ),
                ),
                Text(
                  isEditMode
                      ? 'Update your payment information'
                      : 'Fill details to receive payments',
                  style: TextStyle(fontSize: 12, color: AppColor.textSecondary),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, color: AppColor.textSecondary),
            onPressed: () {
              if (isEditMode) controller.cancelEdit();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Obx(() {
      if (controller.errorMessage.value.isEmpty) return const SizedBox.shrink();
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColor.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColor.error.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: AppColor.error, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                controller.errorMessage.value,
                style: TextStyle(color: AppColor.error, fontSize: 13),
              ),
            ),
            GestureDetector(
              onTap: () => controller.errorMessage.value = '',
              child: Icon(Icons.close_rounded, color: AppColor.error, size: 16),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSubmitButton(BuildContext context) {
    return Obx(() => SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: controller.isSubmitting.value ? null : (){
          _onSubmit(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          foregroundColor: AppColor.white,
          disabledBackgroundColor: AppColor.primary.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: controller.isSubmitting.value
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              isEditMode ? 'Updating...' : 'Saving...',
              style: const TextStyle(
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
                    : Icons.check_circle_rounded,
                size: 18),
            const SizedBox(width: 8),
            Text(
              isEditMode ? 'Update Details' : 'Add Details',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ],
        ),
      ),
    ));
  }


  Future<void> _onSubmit(BuildContext context) async {
    if (controller.bankName.value.trim().isEmpty) {
      controller.errorMessage.value = 'Bank name is required';
      return;
    }
    if (controller.bankAccountNumber.value.length < 8) {
      controller.errorMessage.value = 'Enter a valid account number';
      return;
    }
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$')
        .hasMatch(controller.ifscCode.value.toUpperCase())) {
      controller.errorMessage.value = 'Invalid IFSC code (e.g. HDFC0000001)';
      return;
    }
    if (controller.accountHolderName.value.trim().length < 3) {
      controller.errorMessage.value = 'Account holder name is required';
      return;
    }
    if (controller.branchName.value.trim().length < 3) {
      controller.errorMessage.value = 'Branch name is required';
      return;
    }
    if (controller.phoneNumber.value.replaceAll(RegExp(r'\D'), '').length < 10) {
      controller.errorMessage.value = 'Enter a valid phone number';
      return;
    }
    // UPI ID — required
    if (controller.upiId.value.trim().isEmpty) {
      controller.errorMessage.value = 'UPI ID is required';
      return;
    }
    final result = await controller.submit();
    if (result['status'] == 200) {
      Navigator.pop(context);
    };
  }
}


class _StatusToggleCard extends StatelessWidget {
  final BankDetailsController controller;
  const _StatusToggleCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.lightGrey),
      ),
      child: Obx(() {
        final isActive = controller.isActive.value;
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (isActive ? Colors.green : AppColor.grey)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isActive
                    ? Icons.check_circle_outline_rounded
                    : Icons.cancel_outlined,
                color: isActive ? Colors.green : AppColor.grey,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status',
                      style: TextStyle(
                          fontSize: 12, color: AppColor.textSecondary)),
                  Text(
                    isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color:
                      isActive ? Colors.green.shade700 : AppColor.grey,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: isActive,
              onChanged: (v) => controller.isActive.value = v,
              activeColor: AppColor.primary,
            ),
          ],
        );
      }),
    );
  }
}


class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool required;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.required,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColor.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColor.primary, size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColor.primary,
                ),
              ),
              if (required) ...[
                const SizedBox(width: 2),
                Text(' *',
                    style: TextStyle(color: AppColor.error, fontSize: 13)),
              ] else ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColor.textSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Optional',
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColor.textSecondary,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}


class _BankTextField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? Function(String)? validator;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  const _BankTextField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.onChanged,
    this.validator,
    this.maxLength,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  @override
  State<_BankTextField> createState() => _BankTextFieldState();
}

class _BankTextFieldState extends State<_BankTextField> {
  String? _error;
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller.text.isNotEmpty) _touched = true;
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
      setState(() => _error = widget.validator!(widget.controller.text));
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _error != null && _error!.isNotEmpty;
    final hasValue =
        widget.controller.text.isNotEmpty && !hasError && _touched;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          onFocusChange: (focused) {
            if (!focused) _onBlur();
          },
          child: TextField(
            controller: widget.controller,
            onChanged: _onChanged,
            maxLength: widget.maxLength,
            keyboardType: widget.keyboardType,
            textCapitalization: widget.textCapitalization,
            inputFormatters: widget.inputFormatters,
            style: TextStyle(
              color: AppColor.textMain,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              hintStyle: TextStyle(color: AppColor.grey, fontSize: 12),
              labelStyle: TextStyle(
                color: hasError ? AppColor.error : AppColor.textSecondary,
                fontSize: 13,
              ),
              prefixIcon: Icon(widget.icon,
                  color: hasError ? AppColor.error : AppColor.primary,
                  size: 18),
              suffixIcon: hasValue
                  ? Icon(Icons.check_circle_rounded,
                  color: AppColor.success, size: 16)
                  : null,
              counterText: '',
              filled: true,
              fillColor: AppColor.white,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColor.lightGrey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColor.lightGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColor.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColor.error, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColor.error, width: 1.5),
              ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 12, color: AppColor.error),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(_error!,
                      style:
                      TextStyle(color: AppColor.error, fontSize: 11)),
                ),
              ],
            ),
          ),
      ],
    );
  }
}


class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}