// material_enquiry_sheet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/materialstore_controller.dart';

class MaterialEnquirySheet extends StatefulWidget {
  final int materialId;
  final int vendorId;
  final Function(bool success) onSubmitted;

  const MaterialEnquirySheet({
    super.key,
    required this.materialId,
    required this.vendorId,
    required this.onSubmitted,
  });

  @override
  State<MaterialEnquirySheet> createState() => _MaterialEnquirySheetState();
}

class _MaterialEnquirySheetState extends State<MaterialEnquirySheet> {
  final MaterialController controller = Get.find<MaterialController>();
  final _formKey = GlobalKey<FormState>();

  String _requirement = '';
  double _quantity = 1.0;
  int _unitId = 1;

  final FocusNode _requirementFocusNode = FocusNode();
  final Color primaryGreen = const Color(0xFF7FA93C);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_requirementFocusNode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handlebar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: primaryGreen.withOpacity(0.1),
                    child: Icon(Icons.send_rounded, color: primaryGreen, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Send Enquiry',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                      ),
                      Text(
                        'Fill in details to get a quote',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Requirement Field
                    _buildTextField(
                      label: 'Your Requirement',
                      hint: 'Specify grade, size, or special instructions...',
                      icon: Icons.edit_note_rounded,
                      maxLines: 3,
                      focusNode: _requirementFocusNode,
                      validator: (value) => value!.trim().isEmpty ? 'Requirement is required' : null,
                      onSaved: (value) => _requirement = value!.trim(),
                    ),

                    const SizedBox(height: 20),

                    // Quantity and Unit Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _buildTextField(
                            label: 'Quantity',
                            hint: '0.0',
                            icon: Icons.summarize_rounded,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            initialValue: '1.0',
                            validator: (value) {
                              final val = double.tryParse(value ?? '');
                              return (val == null || val <= 0) ? 'Invalid' : null;
                            },
                            onSaved: (value) => _quantity = double.parse(value!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _buildDropdown(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Submit Button Logic
                    Obx(() {
                      bool isLoading = controller.isSubmittingEnquiry.value;
                      bool isSuccess = controller.enquirySuccess.value;

                      return Column(
                        children: [
                          if (controller.enquiryError.value.isNotEmpty)
                            _buildStatusMsg(controller.enquiryError.value, Colors.red),

                          if (isSuccess)
                            _buildStatusMsg('Enquiry sent successfully!', Colors.green),

                          const SizedBox(height: 8),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: isLoading || isSuccess ? null : _submitEnquiry,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                disabledBackgroundColor: isSuccess ? Colors.green : primaryGreen.withOpacity(0.6),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                                  : Text(
                                isSuccess ? 'SENT' : 'SUBMIT ENQUIRY',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for TextFields
  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    FocusNode? focusNode,
    String? initialValue,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return TextFormField(
      focusNode: focusNode,
      initialValue: initialValue,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: primaryGreen, size: 20),
        filled: true,
        fillColor: Colors.grey[50],
        labelStyle: TextStyle(color: Colors.grey[700], fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryGreen, width: 2),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<int>(
      value: _unitId,
      decoration: InputDecoration(
        labelText: 'Unit',
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey[200]!)),
      ),
      items: const [
        DropdownMenuItem(value: 1, child: Text('Kg')),
        DropdownMenuItem(value: 2, child: Text('Grams')),
        DropdownMenuItem(value: 3, child: Text('Liters')),
        DropdownMenuItem(value: 4, child: Text('Pieces')),
      ],
      onChanged: (v) => setState(() => _unitId = v!),
    );
  }

  Widget _buildStatusMsg(String msg, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(msg, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13), textAlign: TextAlign.center),
    );
  }

  Future<void> _submitEnquiry() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final success = await controller.submitMaterialEnquiry(
        materialId: widget.materialId,
        requirement: _requirement,
        unitId: _unitId,
        quantity: _quantity,
        userId: 1, // Replace with actual user ID
      );

      if (success) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) widget.onSubmitted(true);
        });
      } else {
        widget.onSubmitted(false);
      }
    }
  }

  @override
  void dispose() {
    _requirementFocusNode.dispose();
    super.dispose();
  }
}