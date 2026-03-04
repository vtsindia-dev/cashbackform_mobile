import 'package:get/get.dart';

class Transaction {
  final int id;
  final String userName;
  final String propertyType;
  final String paymentType;
  final String amount;
  final String invoiceUrl;
  final String createdAt;

  Transaction({
    required this.id,
    required this.userName,
    required this.propertyType,
    required this.paymentType,
    required this.amount,
    required this.invoiceUrl,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,
      userName: json['user_name'] ?? '',
      propertyType: json['property_type'] ?? '',
      paymentType: json['payment_type'] ?? '',
      amount: json['amount'] ?? '0.00',
      invoiceUrl: json['invoice_url'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class TransactionResponse {
  final bool status;
  final String message;
  final List<Transaction> data;
  final TransactionMeta meta;

  TransactionResponse({
    required this.status,
    required this.message,
    required this.data,
    required this.meta,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> dataList = json['data'] ?? [];
    return TransactionResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: dataList.map((item) => Transaction.fromJson(item)).toList(),
      meta: TransactionMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class TransactionMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  TransactionMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory TransactionMeta.fromJson(Map<String, dynamic> json) {
    return TransactionMeta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
    );
  }
}

enum TransactionType {
  gioo,
  syndicate,
  residential,
  market,
}