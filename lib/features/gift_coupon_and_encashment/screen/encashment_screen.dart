import 'package:cashback_farms/common/colours.dart';
import 'package:cashback_farms/common/widget/appbar.dart';
import 'package:cashback_farms/features/gift_coupon_and_encashment/controller/encashment_controller.dart';
import 'package:cashback_farms/features/menu/controller/dashboard_menu_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'encashment_list_screen.dart';
import 'package:dotted_line/dotted_line.dart';

class EnCashMentScreen extends StatefulWidget {
  const EnCashMentScreen({super.key});

  @override
  State<EnCashMentScreen> createState() => _EnCashMentScreenState();
}

class _EnCashMentScreenState extends State<EnCashMentScreen> {

  final TextEditingController couponController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController upiController = TextEditingController();

  final TextEditingController upiPhoneController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController beneficiaryController = TextEditingController();
  final TextEditingController bankPhoneController = TextEditingController();
  DashboardController dashboardController = Get.put(DashboardController());
  String paymentType = "upi";

  final FocusNode couponsFocusNode = FocusNode();
  final EncashmentController encashmentController = Get.put(EncashmentController());

  @override
  void initState() {
    encashmentController.removeCoupon(showMessage : false);
    super.initState();
  }

  @override
  void dispose() {
    couponController.dispose();
    accountNumberController.dispose();
    upiController.dispose();
    upiPhoneController.dispose();
    bankNameController.dispose();
    ifscController.dispose();
    beneficiaryController.dispose();
    bankPhoneController.dispose();
    couponsFocusNode.dispose();
    super.dispose();
  }

  Widget _buildRow(String label, String value, {bool isTotal = false, bool isSecondary = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isSecondary ? Colors.grey.shade600 : Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.bold,
            color: color ?? (isTotal ? Colors.green.shade700 : Colors.black87),
          ),
        ),
      ],
    );
  }

  void clearAllFields() {
    couponController.clear();
    upiController.clear();
    upiPhoneController.clear();
    bankNameController.clear();
    accountNumberController.clear();
    ifscController.clear();
    beneficiaryController.clear();
    bankPhoneController.clear();

    setState(() {
      paymentType = "upi";
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double enhancementGST = dashboardController.businessSettings.value?.encashmentGst ?? 0;
    return Scaffold(
      appBar: DynamicAppBar(
        title: 'Encashment',
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> const EncashmentListScreen()));
            },
            icon: const Icon(
              Icons.list,
              color: Colors.white,
              size: 22,
            ),
          )
        ],
      ),
      body: GetBuilder<EncashmentController>(
        builder: (encashmentController) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Important: Please make sure to apply the gift coupon and verify availability. The $enhancementGST% service charge will be deducted, and the remaining amount will "
                              "be credited to your account. Kindly provide accurate UPI or bank details to ensure a smooth transaction.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: size.width,
                  decoration: BoxDecoration(
                    color: AppColor.primarylite.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Row(
                        children: [
                          Text(
                            'Coupon Code',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: AppColor.grey, width: 1.5),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    "assets/images/discount.png",
                                    height: 20,
                                    width: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: TextFormField(
                                      controller: couponController,
                                      focusNode: couponsFocusNode,
                                      readOnly: encashmentController.isAppliedCoupon ? true : false,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Enter coupon code',
                                        hintStyle: TextStyle(
                                            color: Colors.grey.withValues(alpha: 0.7),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: encashmentController.isAppliedLoading ? (){} :() {
                              couponsFocusNode.unfocus();
                              if (encashmentController.isAppliedCoupon) {
                                encashmentController.removeCoupon(showMessage : true);
                                couponController.clear();
                                return;
                              }
                              if (couponController.text.trim().isEmpty) {
                                Get.snackbar("Failed", "Please enter coupon code",
                                    backgroundColor: Colors.red, colorText: Colors.white);
                                return;
                              }
                              encashmentController.checkCoupon(
                                couponCode: couponController.text.trim(),
                              );
                            },
                            child: Container(
                              height: 50,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: encashmentController.isAppliedCoupon
                                    ? Colors.red.shade50
                                    : Colors.green.shade50,
                                border: Border.all(
                                  color: encashmentController.isAppliedCoupon
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                              child: Center(
                                child: encashmentController.isAppliedLoading
                                    ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColor.primary,
                                  ),
                                )
                                    : Text(
                                  encashmentController.isAppliedCoupon ? "Remove" : "Apply",
                                  style: TextStyle(
                                    color: encashmentController.isAppliedCoupon
                                        ? Colors.red
                                        : Colors.green,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (encashmentController.isAppliedCoupon)
                        Container(
                          margin: const EdgeInsets.only(top: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildRow("Coupon Worth", "₹${encashmentController.totalAmount.toStringAsFixed(0)}", isSecondary: true),
                                    const SizedBox(height: 12),
                                    _buildRow("Service Charge($enhancementGST%)", "- ₹${encashmentController.couponDiscount.toStringAsFixed(0)}", color: Colors.red.shade400),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                ),
                                child: _buildRow(
                                  "You Receive",
                                  "₹${encashmentController.finalAmount.toStringAsFixed(0)}",
                                  isTotal: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if(encashmentController.isShowForm) ...[
                        const SizedBox(height: 20),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RadioGroup<String>(
                              groupValue: paymentType,
                              onChanged: (value) {
                                setState(() => paymentType = value!);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: RadioListTile<String>(
                                  value: "upi",
                                  title: const Text(
                                    "UPI",
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  secondary: const Icon(
                                    Icons.account_balance_wallet,
                                    color: Colors.green,
                                  ),
                                  activeColor: Colors.green,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            RadioGroup<String>(
                              groupValue: paymentType,
                              onChanged: (value) {
                                setState(() => paymentType = value!);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: RadioListTile<String>(
                                  value: "bank",
                                  title: const Text(
                                    "Bank Transfer",
                                    style: TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  secondary: const Icon(
                                    Icons.account_balance,
                                    color: Colors.blue,
                                  ),
                                  activeColor: Colors.blue,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        if (paymentType == "upi") ...[
                          const Text(
                            'UPI Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                          dashedLine(),
                          _buildTextFieldSection(
                            'UPI ID',
                            upiController,
                            size,
                            'Enter UPI ID',
                            requiredField: true,
                          ),
                          _buildTextFieldSection(
                            'UPI Phone Number',
                            upiPhoneController,
                            size,
                            'Enter phone number',
                            requiredField: true,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                        if (paymentType == "bank") ...[
                          const Text(
                            'Bank Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black,
                            ),
                          ),
                          dashedLine(),
                          _buildTextFieldSection(
                            'Bank Name',
                            bankNameController,
                            size,
                            'Enter bank name',
                            requiredField: true,
                          ),
                          _buildTextFieldSection(
                            'Account Number',
                            accountNumberController,
                            size,
                            'Enter account number',
                            requiredField: true,
                            keyboardType: TextInputType.number,
                          ),
                          _buildTextFieldSection(
                            'IFSC Code',
                            ifscController,
                            size,
                            'Enter IFSC code',
                            requiredField: true,
                          ),
                          _buildTextFieldSection(
                            'Beneficiary Name',
                            beneficiaryController,
                            size,
                            'Enter name',
                            requiredField: true,
                          ),
                          _buildTextFieldSection(
                            'Phone Number',
                            bankPhoneController,
                            size,
                            'Enter phone number',
                            requiredField: true,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                        const SizedBox(height: 10),
                        GestureDetector(
                          onTap: encashmentController.isFormLoading ? (){} :() async {
                            FocusScope.of(context).unfocus();
                            String errorMessage = "";
                            if (paymentType == "upi") {
                              String upi = upiController.text.trim();

                              if (upi.isEmpty) {
                                errorMessage = "Enter UPI ID";
                              }
                              else if (!RegExp(r'^[\w.-]+@[\w.-]+$').hasMatch(upi)) {
                                errorMessage = "Enter valid UPI ID";
                              }
                              else if (upiPhoneController.text.trim().isEmpty) {
                                errorMessage = "Enter UPI Phone Number";
                              }
                              else if (upiPhoneController.text.trim().length != 10) {
                                errorMessage = "Enter valid UPI Phone Number";
                              }
                            }
                            if (paymentType == "bank") {
                              String ifsc = ifscController.text.trim().toUpperCase();

                              if (bankNameController.text.trim().isEmpty) {
                                errorMessage = "Enter Bank Name";
                              }
                              else if (accountNumberController.text.trim().isEmpty) {
                                errorMessage = "Enter Account Number";
                              }
                              else if (ifsc.isEmpty) {
                                errorMessage = "Enter IFSC Code";
                              }
                              else if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(ifsc)) {
                                errorMessage = "Enter valid IFSC Code";
                              }
                              else if (beneficiaryController.text.trim().isEmpty) {
                                errorMessage = "Enter Beneficiary Name";
                              }
                              else if (bankPhoneController.text.trim().isEmpty) {
                                errorMessage = "Enter Bank Phone Number";
                              }
                              else if (bankPhoneController.text.trim().length != 10) {
                                errorMessage = "Enter valid Bank Phone Number";
                              }
                            }
                            if (errorMessage.isNotEmpty) {
                              Fluttertoast.showToast(
                                msg: errorMessage,
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.CENTER,
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16,
                              );
                              return;
                            }

                            final result = await encashmentController.submitEncashment(
                              code: couponController.text,
                              paymentType: paymentType,
                              amount: encashmentController.finalAmount.toString(),
                              tax: encashmentController.couponDiscount.toString(),
                              total: encashmentController.totalAmount.toString(),
                              upiId: upiController.text,
                              upiPhone: upiPhoneController.text,
                              bankName: bankNameController.text,
                              accountNumber: accountNumberController.text,
                              ifsc: ifscController.text,
                              beneficiary: beneficiaryController.text,
                              bankPhone: bankPhoneController.text,
                            );

                            if(result){
                              encashmentController.removeCoupon(showMessage : false);
                              clearAllFields();
                              Navigator.push(context, MaterialPageRoute(builder: (context)=> const EncashmentListScreen()));
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppColor.primary,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Center(
                              child: encashmentController.isFormLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                'Submit',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context)=> const EncashmentListScreen()));
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Ink(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, color: Colors.white),
                        SizedBox(width: 10),
                        Text(
                          'Encashment Request History',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextFieldSection(
      String label,
      TextEditingController controller,
      Size size,
      String hintText, {
        bool? readOnly,
        TextInputType? keyboardType,
        bool? requiredField,
        int maxLines = 1,
      }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black,
              ),
            ),
            if (requiredField == true)
              const Padding(
                padding: EdgeInsets.only(left: 5),
                child: Text(
                  '*',
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: _buildTextField(
            keyboardType: keyboardType ?? TextInputType.text,
            controller: controller,
            size: size,
            hintText: hintText,
            maxLines: maxLines,
            readOnly: readOnly ?? false,
          ),
        ),
        const SizedBox(height: 2),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required Size size,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    int maxLines = 1,
  }) {
    return SizedBox(
      width: size.width,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hintText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}

Widget dashedLine() {
  return const Padding(
    padding: EdgeInsets.symmetric(vertical: 11),
    child: DottedLine(
      direction: Axis.horizontal,
      alignment: WrapAlignment.center,
      lineThickness: 1.0,
      dashColor: AppColor.primary,
    ),
  );
}