import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../common/colours.dart';
import '../../../common/images.dart';
import '../controller/auth_controller.dart';
class Registration extends StatefulWidget {
  final String? phone;
  const Registration({super.key, this.phone});
  @override
  State<Registration> createState() => _RegistrationState();
}
class _RegistrationState extends State<Registration> {
  final AuthController controller = Get.put(AuthController());
  bool isTermsAccepted = false;
  @override
  void initState() {
    super.initState();
    if (widget.phone != null) {
      controller.phoneController.text = widget.phone!;
    }
  }
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColor.primary,
              onPrimary: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
            cardColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      controller.setDateOfBirth(picked);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Images.loginBackground),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 4,
                    spreadRadius: 2,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: _buildRegistrationForm(),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildRegistrationForm() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Image.asset(
                  Images.logo,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                )
                    .animate()
                    .scale(duration: 800.ms, curve: Curves.elasticOut)
                    .fadeIn(duration: 800.ms),
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColor.primary,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 800.ms)
                    .slideY(begin: 0.5, end: 0, duration: 800.ms),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Obx(() => Center(
            child: GestureDetector(
              onTap: controller.pickImage,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: AppColor.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: controller.selectedImage.value != null
                    ? ClipOval(
                  child: Image.file(
                    controller.selectedImage.value!,
                    fit: BoxFit.cover,
                  ),
                )
                    : Icon(
                  Icons.camera_alt,
                  size: 40,
                  color: AppColor.primary.withOpacity(0.6),
                ),
              )
                  .animate()
                  .scale(duration: 800.ms, delay: 200.ms)
                  .fadeIn(duration: 800.ms, delay: 200.ms),
            ),
          )),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: controller.firstNameController,
                  label: 'First Name',
                  icon: Icons.person,
                  index: 0,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  controller: controller.lastNameController,
                  label: 'Last Name',
                  icon: Icons.person_outline,
                  index: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: controller.phoneController,
            label: 'Phone Number',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            prefixText: '+91 ',
            readOnly: widget.phone != null,
            index: 2,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: controller.emailController,
            label: 'Email Address',
            icon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            index: 3,
          ),
          const SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gender',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              )
                  .animate()
                  .fadeIn(duration: 700.ms, delay: 500.ms)
                  .slideX(begin: -20, end: 0, duration: 700.ms, delay: 500.ms),
              const SizedBox(height: 8),
              Obx(() => Row(
                children: [
                  Expanded(
                    child: _buildGenderOption(
                      value: 1,
                      label: 'Male',
                      isSelected: controller.selectedGender.value == 1,
                      index: 0,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildGenderOption(
                      value: 2,
                      label: 'Female',
                      isSelected: controller.selectedGender.value == 2,
                      index: 1,
                    ),
                  ),
                ],
              )),
            ],
          ),
          // const SizedBox(height: 15),
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   children: [
          //     Text(
          //       'Account Type',
          //       style: TextStyle(
          //         fontSize: 14,
          //         color: Colors.grey.shade700,
          //         fontWeight: FontWeight.w500,
          //       ),
          //     )
          //         .animate()
          //         .fadeIn(duration: 700.ms, delay: 600.ms)
          //         .slideX(begin: -20, end: 0, duration: 700.ms, delay: 600.ms),
          //     const SizedBox(height: 8),
          //     Obx(() => Animate(
          //       effects: [
          //         FadeEffect(duration: 800.ms, delay: 650.ms),
          //         SlideEffect(begin: Offset(-30, 0), duration: 800.ms, delay: 650.ms),
          //         ScaleEffect(begin: Offset(0.95, 0.95), duration: 800.ms, delay: 650.ms),
          //       ],
          //       child: Container(
          //         decoration: BoxDecoration(
          //           borderRadius: BorderRadius.circular(12),
          //           border: Border.all(
          //             color: Colors.grey.shade300,
          //             width: 2,
          //           ),
          //           color: Colors.white,
          //           boxShadow: [
          //             BoxShadow(
          //               color: Colors.black.withOpacity(0.05),
          //               blurRadius: 10,
          //               offset: const Offset(0, 4),
          //             ),
          //           ],
          //         ),
          //         child: DropdownButtonFormField<int>(
          //           value: controller.selectedRole.value,
          //           items: const [
          //             DropdownMenuItem(value: 1, child: Text('Customer')),
          //             DropdownMenuItem(value: 2, child: Text('Agent')),
          //             DropdownMenuItem(value: 3, child: Text('Vendor')),
          //             DropdownMenuItem(value: 4, child: Text('Service Provider')),
          //           ],
          //           onChanged: (value) => controller.selectedRole.value = value!,
          //           decoration: InputDecoration(
          //             border: InputBorder.none,
          //             contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          //             prefixIcon: Icon(Icons.account_circle, color: AppColor.primary),
          //           ),
          //           dropdownColor: Colors.white,
          //           style: TextStyle(
          //             fontFamily: GoogleFonts.montserrat().fontFamily,
          //
          //             color: Colors.grey.shade800,
          //             fontSize: 16,
          //           ),
          //         ),
          //       ),
          //     )),
          //   ],
          // ),
          const SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Date of Birth (YYYY/MM/DD)',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              )
                  .animate()
                  .fadeIn(duration: 700.ms, delay: 700.ms)
                  .slideX(begin: -20, end: 0, duration: 700.ms, delay: 700.ms),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: Animate(
                    effects: [
                      FadeEffect(duration: 800.ms, delay: 750.ms),
                      SlideEffect(begin: Offset(-30, 0), duration: 800.ms, delay: 750.ms),
                      ScaleEffect(begin: Offset(0.95, 0.95), duration: 800.ms, delay: 750.ms),
                    ],
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: controller.dobController,
                        readOnly: true,
                        decoration: InputDecoration(
                          hintText: 'Tap to select date',
                          prefixIcon: Icon(Icons.calendar_today, color: AppColor.primary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: controller.pinCodeController,
            label: 'PIN Code',
            icon: Icons.location_on,
            keyboardType: TextInputType.number,
            index: 5,
          ),
          const SizedBox(height: 15),
          _buildTextField(
            controller: controller.addressController,
            label: 'Address',
            icon: Icons.home,
            maxLines: 2,
            index: 6,
          ),
          const SizedBox(height: 20),
          // Terms and Conditions
          // Animate(
          //   effects: [
          //     FadeEffect(duration: 800.ms, delay: 900.ms),
          //     SlideEffect(begin: Offset(-20, 0), duration: 800.ms, delay: 900.ms),
          //   ],
          //   child: Row(
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: [
          //       GestureDetector(
          //         onTap: () {
          //           setState(() {
          //             isTermsAccepted = !isTermsAccepted;
          //           });
          //         },
          //         child: Container(
          //           width: 20,
          //           height: 20,
          //           decoration: BoxDecoration(
          //             border: Border.all(
          //               color: AppColor.primary,
          //               width: 2,
          //             ),
          //             borderRadius: BorderRadius.circular(5),
          //             color: isTermsAccepted ? AppColor.primary : Colors.black,
          //           ),
          //           child: isTermsAccepted
          //               ? const Align(
          //             alignment: Alignment.center,
          //             child: Icon(
          //               Icons.check,
          //               size: 16,
          //               color: Colors.white,
          //             ),
          //           )
          //               : null,
          //         )
          //             .animate(target: isTermsAccepted ? 1 : 0)
          //             .scale(duration: 400.ms, curve: Curves.elasticOut),
          //       ),
          //       const SizedBox(width: 12),
          //       Expanded(
          //         child: RichText(
          //           text: TextSpan(
          //             text: "I agree to the ",
          //             style: TextStyle(
          //               color: Colors.grey.shade800,
          //               fontSize: 14,
          //               fontFamily: GoogleFonts.montserrat().fontFamily,
          //             ),
          //             children: [
          //               TextSpan(
          //                 text: "Terms & Conditions",
          //                 style: TextStyle(
          //                   color: AppColor.primary,
          //                   fontWeight: FontWeight.bold,
          //                   fontFamily: GoogleFonts.montserrat().fontFamily,
          //                 ),
          //                 recognizer: TapGestureRecognizer()
          //                   ..onTap = () {
          //                     // Navigate to Terms & Conditions
          //                   },
          //               ),
          //               const TextSpan(text: " and "),
          //               TextSpan(
          //                 text: "Privacy Policy",
          //                 style: TextStyle(
          //                   color: AppColor.primary,
          //                   fontWeight: FontWeight.bold,
          //                   fontFamily: GoogleFonts.montserrat().fontFamily,
          //                 ),
          //                 recognizer: TapGestureRecognizer()
          //                   ..onTap = () {
          //                     // Navigate to Privacy Policy
          //                   },
          //               ),
          //               const TextSpan(text: "."),
          //             ],
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          const SizedBox(height: 15),
          Obx(() => Animate(
            effects: [
              FadeEffect(duration: 800.ms, delay: 1000.ms),
              SlideEffect(begin: Offset(0, 20), duration: 800.ms, delay: 1000.ms),
            ],
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 6,
                  shadowColor: AppColor.primary.withOpacity(0.3),
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          )),
          const SizedBox(height: 15),
          ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? prefixText,
    String? hintText,
    int maxLines = 1,
    bool readOnly = false,
    required int index,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Animate(
          effects: [
            FadeEffect(duration: 700.ms, delay: (100 + index * 50).ms),
            SlideEffect(begin: Offset(-20, 0), duration: 700.ms, delay: (100 + index * 50).ms),
          ],
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Animate(
          effects: [
            FadeEffect(duration: 800.ms, delay: (150 + index * 50).ms),
            SlideEffect(begin: Offset(-30, 0), duration: 800.ms, delay: (150 + index * 50).ms),
            ScaleEffect(begin: const Offset(0.95, 0.95), duration: 800.ms, delay: (150 + index * 50).ms),
          ],
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 2,
              ),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              readOnly: readOnly,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                ),
                prefixIcon: Icon(icon, color: AppColor.primary),
                prefixText: prefixText,
                prefixStyle: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 16,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: false,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderOption({
    required int value,
    required String label,
    required bool isSelected,
    required int index,
  }) {
    return MouseRegion(
      onEnter: (_) => controller.hoveredGender.value = value,
      onExit: (_) => controller.hoveredGender.value = -1,
      child: Obx(() {
        final isHovered = controller.hoveredGender.value == value;
        return Animate(
          effects: [
            FadeEffect(duration: 700.ms, delay: (200 + index * 100).ms),
            SlideEffect(begin: Offset(-40, 0), duration: 700.ms, delay: (200 + index * 100).ms),
            ScaleEffect(begin: const Offset(0.8, 0.8), duration: 700.ms, delay: (200 + index * 100).ms, curve: Curves.elasticOut),
          ],
          child: GestureDetector(
            onTap: () => controller.selectedGender.value = value,
            child: Animate(
              effects: [
                ScaleEffect(
                  begin: const Offset(1, 1),
                  end: Offset(isHovered ? 1.02 : 1.0, isHovered ? 1.02 : 1.0),
                  duration: 300.ms,
                ),
              ],
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColor.primary
                        : isHovered
                        ? AppColor.primary.withOpacity(0.5)
                        : Colors.grey.shade300,
                    width: isSelected ? 3 : (isHovered ? 2.5 : 2),
                  ),
                  color: isSelected
                      ? AppColor.primary.withOpacity(0.1)
                      : isHovered
                      ? AppColor.primary.withOpacity(0.05)
                      : Colors.white,
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: AppColor.primary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    else if (isHovered)
                      BoxShadow(
                        color: AppColor.primary.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: Center(
                  child: Animate(
                    effects: [
                      ScaleEffect(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1, 1),
                        duration: 400.ms,
                        curve: Curves.elasticOut,
                      ),
                    ],
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        color: isSelected
                            ? AppColor.primary
                            : isHovered
                            ? AppColor.primary.withOpacity(0.8)
                            : Colors.grey.shade600,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}