import 'package:flutter/material.dart';

import '../../../common/colours.dart';

class WalletTransactionResponse {
  final bool status;
  final String message;
  final List<WalletTransaction> data;
  final Pagination pagination;

  WalletTransactionResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory WalletTransactionResponse.fromJson(Map<String, dynamic> json) {
    return WalletTransactionResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List? ?? [])
          .map((e) => WalletTransaction.fromJson(e))
          .toList(),
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class WalletTransaction {
  final int id;
  final String transactionId;
  final String transactionType;
  final double credit;
  final double debit;
  final double balance;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.transactionId,
    required this.transactionType,
    required this.credit,
    required this.debit,
    required this.balance,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'],
      transactionId: json['transaction_id'] ?? '',
      transactionType: json['transaction_type'] ?? '',
      credit: double.tryParse(json['credit']?.toString() ?? '0') ?? 0,
      debit: double.tryParse(json['debit']?.toString() ?? '0') ?? 0,
      balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0,
      createdAt: DateTime.parse(json['created_at']).toLocal(),
    );
  }

  String get formattedAmount {
    if (credit > 0) {
      return "+₹${credit.toStringAsFixed(2)}";
    } else if (debit > 0) {
      return "-₹${debit.toStringAsFixed(2)}";
    }
    return "₹0.00";
  }

  Color get amountColor {
    if (credit > 0) return Colors.green;
    if (debit > 0) return Colors.red;
    return Colors.grey;
  }

  String get formattedTransactionType {
    switch (transactionType.toLowerCase()) {
      case 'cumlative':
        return 'Cumulative Reward';
      case 'deposit':
        return 'Deposit';
      case 'withdrawal':
        return 'Withdrawal';
      case 'refund':
        return 'Refund';
      case 'purchase':
        return 'Purchase';
      default:
        return transactionType;
    }
  }

  IconData get transactionIcon {
    switch (transactionType.toLowerCase()) {
      case 'cumlative':
        return Icons.card_giftcard;
      case 'deposit':
        return Icons.arrow_downward;
      case 'withdrawal':
        return Icons.arrow_upward;
      case 'refund':
        return Icons.refresh;
      case 'purchase':
        return Icons.shopping_cart;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Color get iconColor {
    if (credit > 0) return Colors.green;
    if (debit > 0) return Colors.red;
    return AppColor.primary;
  }
}

class Pagination {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  Pagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
      lastPage: json['last_page'] ?? 1,
    );
  }

  bool get hasNextPage => currentPage < lastPage;
  bool get hasPreviousPage => currentPage > 1;
}