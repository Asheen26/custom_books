import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:flutter/material.dart';

enum DeliveryChallanStatus { draft, delivered, returned, cancelled }

extension DeliveryChallanStatusLabel on DeliveryChallanStatus {
  String get label => switch (this) {
    DeliveryChallanStatus.draft => 'DRAFT',
    DeliveryChallanStatus.delivered => 'DELIVERED',
    DeliveryChallanStatus.returned => 'RETURNED',
    DeliveryChallanStatus.cancelled => 'CANCELLED',
  };
}

extension DeliveryChallanStatusColor on DeliveryChallanStatus {
  Color get color => switch (this) {
    DeliveryChallanStatus.draft => AppColors.statusDraft,
    DeliveryChallanStatus.delivered => AppColors.success,
    DeliveryChallanStatus.returned => AppColors.warning,
    DeliveryChallanStatus.cancelled => AppColors.error,
  };
}

enum DeliveryChallanSortField {
  createdTime,
  date,
  challanNumber,
  customerName,
  amount,
}

extension DeliveryChallanSortFieldLabel on DeliveryChallanSortField {
  String get label => switch (this) {
    DeliveryChallanSortField.createdTime => 'Created Time',
    DeliveryChallanSortField.date => 'Date',
    DeliveryChallanSortField.challanNumber => 'Challan#',
    DeliveryChallanSortField.customerName => 'Customer Name',
    DeliveryChallanSortField.amount => 'Amount',
  };
}

class DeliveryChallanLineItem {
  final String id;
  final String itemId;
  final String itemName;
  final String description;
  final double quantity;
  final double rate;
  final double discount;
  final bool discountIsPercent;
  final double taxRate;

  const DeliveryChallanLineItem({
    required this.id,
    this.itemId = '',
    required this.itemName,
    this.description = '',
    required this.quantity,
    required this.rate,
    this.discount = 0,
    this.discountIsPercent = true,
    this.taxRate = 0,
  });

  factory DeliveryChallanLineItem.fromJson(Map<String, dynamic> json) {
    return DeliveryChallanLineItem(
      id: (json['line_id'] ?? json['id'] ?? '').toString(),
      itemId: (json['item_id'] ?? '').toString(),
      itemName: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      quantity: double.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      rate: double.tryParse(json['rate']?.toString() ?? '0') ?? 0,
      discount: 0,
      discountIsPercent: true,
      taxRate: 0,
    );
  }

  double get gross => quantity * rate;
  double get discountAmount =>
      discountIsPercent ? gross * discount / 100 : discount;
  double get net => (gross - discountAmount).clamp(0, double.infinity);
  double get taxAmount => net * taxRate / 100;
}

class DeliveryChallanModel {
  final String id;
  final String customerId;
  final String challanNumber;
  final String customerName;
  final String referenceNumber;
  final DateTime challanDate;
  final String type;
  final DeliveryChallanStatus status;
  final List<DeliveryChallanLineItem> lineItems;
  final double total;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeliveryChallanModel({
    required this.id,
    this.customerId = '',
    required this.challanNumber,
    required this.customerName,
    this.referenceNumber = '',
    required this.challanDate,
    this.type = 'Job Work',
    this.status = DeliveryChallanStatus.draft,
    this.lineItems = const [],
    required this.total,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeliveryChallanModel.fromJson(Map<String, dynamic> json) {
    DeliveryChallanStatus parseStatus(String? raw) {
      switch (raw?.toLowerCase()) {
        case 'delivered':
          return DeliveryChallanStatus.delivered;
        case 'returned':
          return DeliveryChallanStatus.returned;
        case 'cancelled':
          return DeliveryChallanStatus.cancelled;
        default:
          return DeliveryChallanStatus.draft;
      }
    }

    final rawLines = (json['line_items'] as List<dynamic>?) ?? [];
    final lines = rawLines
        .whereType<Map<String, dynamic>>()
        .map(DeliveryChallanLineItem.fromJson)
        .toList();

    return DeliveryChallanModel(
      id: (json['delivery_challan_id'] ?? json['id'] ?? '').toString(),
      customerId: (json['customer_id'] ?? '').toString(),
      challanNumber: (json['challan_number'] ?? '').toString(),
      customerName: (json['customer_name'] ?? '').toString(),
      referenceNumber: (json['reference_number'] ?? '').toString(),
      challanDate:
          DateTime.tryParse(json['challan_date']?.toString() ?? '') ??
          DateTime.now(),
      type: (json['challan_type_label'] ?? json['challan_type'] ?? 'Job Work')
          .toString(),
      status: parseStatus(json['status']?.toString()),
      lineItems: lines,
      total: double.tryParse(json['total_amount']?.toString() ?? '0') ?? 0,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  DeliveryChallanModel copyWith({
    String? id,
    String? customerId,
    String? challanNumber,
    String? customerName,
    String? referenceNumber,
    DateTime? challanDate,
    String? type,
    DeliveryChallanStatus? status,
    List<DeliveryChallanLineItem>? lineItems,
    double? total,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeliveryChallanModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      challanNumber: challanNumber ?? this.challanNumber,
      customerName: customerName ?? this.customerName,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      challanDate: challanDate ?? this.challanDate,
      type: type ?? this.type,
      status: status ?? this.status,
      lineItems: lineItems ?? this.lineItems,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
