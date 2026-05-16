import 'package:cashback_farms/common/colours.dart';
import 'package:cashback_farms/common/widget/appbar.dart';
import 'package:cashback_farms/features/gift_coupon_and_encashment/controller/encashment_controller.dart';
import 'package:cashback_farms/features/gift_coupon_and_encashment/model/encashment_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class EncashmentListScreen extends StatefulWidget {
  const EncashmentListScreen({super.key});

  @override
  State<EncashmentListScreen> createState() => _EncashmentListScreenState();
}

class _EncashmentListScreenState extends State<EncashmentListScreen> {

  final EncashmentController encashmentController = Get.put(EncashmentController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      encashmentController.getMyPurchasedVouchersList();
    });
  }

  Future<void> _refreshProducts() async {
    await encashmentController.getMyPurchasedVouchersList();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      backgroundColor: Colors.white,
      color: AppColor.primary,
      onRefresh: _refreshProducts,
      child: GetBuilder<EncashmentController>(
        builder: (encashmentController) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: DynamicAppBar(
              title: 'Encashment Request History',
              showBackButton: true,
            ),
            body: encashmentController.isMyEnCashMentListLoading
                ? const Center(child: CircularProgressIndicator(color: AppColor.primary))
                : encashmentController.getMyEnCashMentList == null || encashmentController.getMyEnCashMentList!.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: encashmentController.getMyEnCashMentList!.length,
              itemBuilder: (context, index) {
                final item = encashmentController.getMyEnCashMentList![index];
                return _buildEncashmentCard(item);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEncashmentCard(EnCashMentModel item) {
    // Determine status based on both status and reuse/enStatus
    int reuse = item.reuse ?? 0;
    int enStatus = item.enStatus ?? 0;
    int status = item.status ?? 0;

    Color statusColor;
    String statusText;

    // Priority: reuse=1 (Rejected) > enStatus=0 (Inactive) > status
    if (reuse == 1) {
      statusColor = Colors.red;
      statusText = "Rejected";
    } else if (enStatus == 0) {
      statusColor = Colors.orange;
      statusText = "Inactive";
    } else if (status == 1) {
      statusColor = Colors.green;
      statusText = "Success";
    } else if (status == 2) {
      statusColor = Colors.red;
      statusText = "Failed";
    } else {
      statusColor = Colors.orange;
      statusText = "Pending";
    }

    bool isGpay = item.paymentType == 'gpay' || item.paymentType == 'upi';
    final bank = item.bank;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// HEADER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(color: statusColor.withOpacity(0.2)),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.circle, size: 8, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formatDate(item.createdAt),
                        style: const TextStyle(fontSize: 11, color: Colors.black, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  if (reuse == 1) ...[
                    const SizedBox(height: 5),
                    const Row(
                      children: [
                        Icon(Icons.refresh, size: 16, color: Colors.green),
                        SizedBox(width: 6),
                        Text(
                          "Coupon Reactivated - You can use this coupon again",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (enStatus == 0 && reuse != 1) ...[
                    const SizedBox(height: 5),
                    const Row(
                      children: [
                        Icon(Icons.warning, size: 16, color: Colors.orange),
                        SizedBox(width: 6),
                        Text(
                          "This request is currently inactive",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            /// MAIN CONTENT
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// REF + AMOUNT
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Reference",
                                style: TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 3),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "#${item.id}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade800),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text("Received Amount",
                              style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 3),
                          Text(
                            "₹${item.grandTotal?.toStringAsFixed(2) ?? '0'}",
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  /// PAYMENT DETAILS
                  if (bank != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isGpay
                                      ? Icons.account_balance_wallet
                                      : Icons.account_balance,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isGpay ? "UPI Payment" : "Bank Transfer",
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const Spacer(),
                              Text(
                                "Total: ₹${item.totalAmount?.toStringAsFixed(2) ?? '0'}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          /// DETAILS
                          if (isGpay) ...[
                            if (bank.gpayUpiId != null && bank.gpayUpiId!.isNotEmpty)
                              _buildDetailRow(Icons.person, 'UPI ID', bank.gpayUpiId!),
                            if (bank.gpayPhoneNumber != null && bank.gpayPhoneNumber!.isNotEmpty)
                              _buildDetailRow(Icons.phone, 'Phone', bank.gpayPhoneNumber!),
                          ] else ...[
                            if (bank.bankName != null && bank.bankName!.isNotEmpty)
                              _buildDetailRow(Icons.business, 'Bank Name', bank.bankName!),
                            if (bank.bankAccountNumber != null && bank.bankAccountNumber!.isNotEmpty)
                              _buildDetailRow(Icons.numbers, 'Account No', bank.bankAccountNumber!),
                            if (bank.bankIfscCode != null && bank.bankIfscCode!.isNotEmpty)
                              _buildDetailRow(Icons.code, 'IFSC', bank.bankIfscCode!),
                            if (bank.bankBeneficiaryName != null && bank.bankBeneficiaryName!.isNotEmpty)
                              _buildDetailRow(Icons.person, 'Beneficiary', bank.bankBeneficiaryName!),
                            if (bank.bankPhoneNumber != null && bank.bankPhoneNumber!.isNotEmpty)
                              _buildDetailRow(Icons.phone, 'Phone', bank.bankPhoneNumber!),
                          ],

                          // Show message if no bank details available
                          if ((isGpay && (bank.gpayUpiId == null || bank.gpayUpiId!.isEmpty)) &&
                              (!isGpay && (bank.bankName == null || bank.bankName!.isEmpty)))
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                "No payment details available",
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Service Charge: ₹${item.gst?.toStringAsFixed(2) ?? '0'}",
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                      ),
                      if (item.cancelStatus == 1)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.cancel, size: 12, color: Colors.red),
                              SizedBox(width: 4),
                              Text(
                                "Cancelled",
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  // Add coupon name if available
                  if (item.name != null && item.name!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(Icons.local_offer, size: 12, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            "Coupon: ${item.name}",
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            "$label:",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value.isEmpty ? "Not provided" : value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No encashment requests found',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

String formatDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '';
  try {
    DateTime parsed = DateTime.parse(dateStr).toLocal();
    return DateFormat("dd-MM-yyyy hh:mm a").format(parsed);
  } catch (e) {
    return dateStr;
  }
}