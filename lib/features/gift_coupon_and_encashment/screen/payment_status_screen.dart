import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentStatusScreen extends StatelessWidget {
  final bool isSuccess;
  final String? paymentId;
  final String? errorMessage;
  final String? amount;
  final bool isWallet;

  const PaymentStatusScreen({
    super.key,
    required this.isSuccess,
    this.paymentId,
    this.errorMessage,
    this.amount,
    this.isWallet = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor =
    isSuccess ? Colors.green.shade600 : Colors.red.shade600;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context, true),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSuccess
                            ? Icons.check_rounded
                            : Icons.priority_high_rounded,
                        color: statusColor,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      isSuccess
                          ? (isWallet
                          ? "Wallet Payment Successful"
                          : "Payment Successful")
                          : (isWallet
                          ? "Wallet Payment Failed"
                          : "Payment Failed"),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isSuccess
                          ? (isWallet
                          ? "Amount has been deducted from your wallet successfully."
                          : "Your transaction was completed successfully.")
                          : (isWallet
                          ? "Wallet payment failed. Please check your balance."
                          : "We couldn't process your payment."),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.grey[600]),
                    ),

                    const Divider(height: 40, thickness: 1),
                    if (isSuccess && amount != null)
                      _buildDetailRow("Amount Paid", amount!, theme),
                    if (paymentId != null)
                      _buildDetailRow(
                        isWallet ? "Payment Method" : "Transaction ID",
                        isWallet ? "Wallet" : paymentId!,
                        theme,
                      ),
                    if (!isSuccess && errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: statusColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    isSuccess ? "Done" : "Try Again",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}