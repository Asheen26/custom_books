import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:flutter/material.dart';

// ── Line Item ──────────────────────────────────────────────────────────────────

class PurchaseOrderLineItem {
  final String id;
  final String itemId;
  final String itemName;
  final String description;
  final double quantity;
  final double rate;
  final double discount;
  final bool discountIsPercent;
  final double taxRate;

  const PurchaseOrderLineItem({
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

  double get gross => quantity * rate;
  double get discountAmount =>
      discountIsPercent ? gross * discount / 100 : discount;
  double get net => (gross - discountAmount).clamp(0, double.infinity);
  double get taxAmount => net * taxRate / 100;
}

// ── Enums ──────────────────────────────────────────────────────────────────────

enum PurchaseOrderStatus { draft, issued, billed, cancelled }

extension PurchaseOrderStatusLabel on PurchaseOrderStatus {
  String get label => switch (this) {
    PurchaseOrderStatus.draft => 'DRAFT',
    PurchaseOrderStatus.issued => 'ISSUED',
    PurchaseOrderStatus.billed => 'BILLED',
    PurchaseOrderStatus.cancelled => 'CANCELLED',
  };
}

extension PurchaseOrderStatusColor on PurchaseOrderStatus {
  Color get color => switch (this) {
    PurchaseOrderStatus.draft => AppColors.statusDraft,
    PurchaseOrderStatus.issued => AppColors.primaryLight,
    PurchaseOrderStatus.billed => AppColors.success,
    PurchaseOrderStatus.cancelled => AppColors.error,
  };
}

enum PurchaseOrderSortField {
  createdTime,
  date,
  purchaseOrderNumber,
  vendorName,
  amount,
}

extension PurchaseOrderSortFieldLabel on PurchaseOrderSortField {
  String get label => switch (this) {
    PurchaseOrderSortField.createdTime => 'Created Time',
    PurchaseOrderSortField.date => 'Date',
    PurchaseOrderSortField.purchaseOrderNumber => 'Purchase Order#',
    PurchaseOrderSortField.vendorName => 'Vendor Name',
    PurchaseOrderSortField.amount => 'Amount',
  };
}

class PurchaseOrderModel {
  final String id;
  final String purchaseOrderNumber;
  final String vendorName;
  final String referenceNumber;
  final DateTime orderDate;
  final DateTime? expectedDeliveryDate;
  final PurchaseOrderStatus status;
  final List<PurchaseOrderLineItem> lineItems;
  final double total;
  final String customerNotes;
  final String termsAndConditions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PurchaseOrderModel({
    required this.id,
    required this.purchaseOrderNumber,
    required this.vendorName,
    this.referenceNumber = '',
    required this.orderDate,
    this.expectedDeliveryDate,
    this.status = PurchaseOrderStatus.draft,
    this.lineItems = const [],
    this.total = 0,
    this.customerNotes = '',
    this.termsAndConditions = '',
    required this.createdAt,
    required this.updatedAt,
  });

  PurchaseOrderModel copyWith({
    String? id,
    String? purchaseOrderNumber,
    String? vendorName,
    String? referenceNumber,
    DateTime? orderDate,
    DateTime? expectedDeliveryDate,
    PurchaseOrderStatus? status,
    List<PurchaseOrderLineItem>? lineItems,
    double? total,
    String? customerNotes,
    String? termsAndConditions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PurchaseOrderModel(
      id: id ?? this.id,
      purchaseOrderNumber: purchaseOrderNumber ?? this.purchaseOrderNumber,
      vendorName: vendorName ?? this.vendorName,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      orderDate: orderDate ?? this.orderDate,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      status: status ?? this.status,
      lineItems: lineItems ?? this.lineItems,
      total: total ?? this.total,
      customerNotes: customerNotes ?? this.customerNotes,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
