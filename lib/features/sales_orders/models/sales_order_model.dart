import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:flutter/material.dart';

enum SalesOrderStatus { draft, confirmed, invoiced, cancelled }

extension SalesOrderStatusLabel on SalesOrderStatus {
  String get label => switch (this) {
    SalesOrderStatus.draft => 'DRAFT',
    SalesOrderStatus.confirmed => 'CONFIRMED',
    SalesOrderStatus.invoiced => 'INVOICED',
    SalesOrderStatus.cancelled => 'CANCELLED',
  };
}

extension SalesOrderStatusColor on SalesOrderStatus {
  Color get color => switch (this) {
    SalesOrderStatus.draft => AppColors.statusDraft,
    SalesOrderStatus.confirmed => AppColors.primaryLight,
    SalesOrderStatus.invoiced => AppColors.success,
    SalesOrderStatus.cancelled => AppColors.error,
  };
}

enum SalesOrderSortField {
  createdTime,
  date,
  salesOrderNumber,
  referenceNumber,
  customerName,
  amount,
}

extension SalesOrderSortFieldLabel on SalesOrderSortField {
  String get label => switch (this) {
    SalesOrderSortField.createdTime => 'Created Time',
    SalesOrderSortField.date => 'Date',
    SalesOrderSortField.salesOrderNumber => 'Sales Order#',
    SalesOrderSortField.referenceNumber => 'Reference#',
    SalesOrderSortField.customerName => 'Customer Name',
    SalesOrderSortField.amount => 'Amount',
  };
}

class SalesOrderLineItem {
  final String id;
  final String itemName;
  final String description;
  final double quantity;
  final double rate;
  final double discount;
  final bool discountIsPercent;
  final double taxRate;

  const SalesOrderLineItem({
    required this.id,
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
  double get total => net + taxAmount;

  factory SalesOrderLineItem.fromJson(Map<String, dynamic> json) {
    return SalesOrderLineItem(
      id: (json['line_id'] ?? json['id'] ?? '').toString(),
      itemName: (json['name'] ?? json['item_name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      quantity: _toDouble(json['quantity']),
      rate: _toDouble(json['rate']),
      discount: _toDouble(json['discount']),
      discountIsPercent: json['discount_type'] != 'entity_level',
      taxRate: _toDouble(json['tax_percentage']),
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

class SalesOrderModel {
  final String id;
  final String salesOrderNumber;
  final String customerId;
  final String customerName;
  final String referenceNumber;
  final DateTime salesOrderDate;
  final String orderDateLabel;
  final DateTime? expectedShipmentDate;
  final String expectedShipmentDateLabel;
  final String paymentTerms;
  final String deliveryMethod;
  final String salesperson;
  final String taxType;
  final bool taxInclusive;
  final List<SalesOrderLineItem> lineItems;
  final String customerNotes;
  final String termsAndConditions;
  final List<String> attachments;
  final SalesOrderStatus status;
  final bool isInvoiced;
  final double totalAmount;
  final String currency;
  final DateTime? confirmedAt;
  final DateTime? invoicedAt;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SalesOrderModel({
    required this.id,
    required this.salesOrderNumber,
    this.customerId = '',
    required this.customerName,
    this.referenceNumber = '',
    required this.salesOrderDate,
    this.orderDateLabel = '',
    this.expectedShipmentDate,
    this.expectedShipmentDateLabel = '',
    this.paymentTerms = 'Due on Receipt',
    this.deliveryMethod = '',
    this.salesperson = '',
    this.taxType = 'exclusive',
    this.taxInclusive = false,
    this.lineItems = const [],
    this.customerNotes = '',
    this.termsAndConditions = '',
    this.attachments = const [],
    this.status = SalesOrderStatus.draft,
    this.isInvoiced = false,
    this.totalAmount = 0,
    this.currency = 'INR',
    this.confirmedAt,
    this.invoicedAt,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  double get subTotal => lineItems.fold(0, (sum, item) => sum + item.net);
  double get taxAmount =>
      lineItems.fold(0, (sum, item) => sum + item.taxAmount);

  /// Uses server-returned [totalAmount] when available (non-zero), otherwise
  /// falls back to the locally computed value.
  double get total =>
      totalAmount > 0
          ? totalAmount
          : (taxInclusive ? subTotal : subTotal + taxAmount);

  SalesOrderModel copyWith({
    String? id,
    String? salesOrderNumber,
    String? customerId,
    String? customerName,
    String? referenceNumber,
    DateTime? salesOrderDate,
    String? orderDateLabel,
    DateTime? expectedShipmentDate,
    String? expectedShipmentDateLabel,
    String? paymentTerms,
    String? deliveryMethod,
    String? salesperson,
    String? taxType,
    bool? taxInclusive,
    List<SalesOrderLineItem>? lineItems,
    String? customerNotes,
    String? termsAndConditions,
    List<String>? attachments,
    SalesOrderStatus? status,
    bool? isInvoiced,
    double? totalAmount,
    String? currency,
    DateTime? confirmedAt,
    DateTime? invoicedAt,
    DateTime? cancelledAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SalesOrderModel(
      id: id ?? this.id,
      salesOrderNumber: salesOrderNumber ?? this.salesOrderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      salesOrderDate: salesOrderDate ?? this.salesOrderDate,
      orderDateLabel: orderDateLabel ?? this.orderDateLabel,
      expectedShipmentDate: expectedShipmentDate ?? this.expectedShipmentDate,
      expectedShipmentDateLabel:
          expectedShipmentDateLabel ?? this.expectedShipmentDateLabel,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      salesperson: salesperson ?? this.salesperson,
      taxType: taxType ?? this.taxType,
      taxInclusive: taxInclusive ?? this.taxInclusive,
      lineItems: lineItems ?? this.lineItems,
      customerNotes: customerNotes ?? this.customerNotes,
      termsAndConditions: termsAndConditions ?? this.termsAndConditions,
      attachments: attachments ?? this.attachments,
      status: status ?? this.status,
      isInvoiced: isInvoiced ?? this.isInvoiced,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      invoicedAt: invoicedAt ?? this.invoicedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  factory SalesOrderModel.fromJson(Map<String, dynamic> json) {
    final taxTypeStr = (json['tax_type'] ?? 'exclusive').toString();
    final statusStr = (json['status'] ?? '').toString();

    final invoicedAt = json['invoiced_at'] != null
        ? DateTime.tryParse(json['invoiced_at'].toString())
        : null;

    return SalesOrderModel(
      id: (json['sales_order_id'] ?? '').toString(),
      salesOrderNumber: (json['sales_order_number'] ?? '').toString(),
      customerId: (json['customer_id'] ?? '').toString(),
      customerName: (json['customer_name'] ?? '').toString(),
      referenceNumber: (json['reference_number'] ?? '').toString(),
      salesOrderDate:
          DateTime.tryParse(json['order_date']?.toString() ?? '') ??
          DateTime.now(),
      orderDateLabel: (json['order_date_label'] ?? '').toString(),
      expectedShipmentDate: json['expected_shipment_date'] != null
          ? DateTime.tryParse(json['expected_shipment_date'].toString())
          : null,
      expectedShipmentDateLabel:
          (json['expected_shipment_date_label'] ?? '').toString(),
      paymentTerms: (json['payment_terms'] ?? '').toString(),
      deliveryMethod: (json['delivery_method'] ?? '').toString(),
      salesperson: (json['salesperson_name'] ?? '').toString(),
      taxType: taxTypeStr,
      taxInclusive: taxTypeStr == 'inclusive',
      lineItems: (json['line_items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(SalesOrderLineItem.fromJson)
          .toList(),
      customerNotes: (json['customer_notes'] ?? '').toString(),
      termsAndConditions: (json['terms_and_conditions'] ?? '').toString(),
      attachments: (json['attachments'] as List<dynamic>? ?? [])
          .map((a) => a.toString())
          .toList(),
      status: _statusFromString(statusStr),
      isInvoiced: invoicedAt != null || statusStr == 'invoiced',
      totalAmount: _toDouble(json['total_amount']),
      currency: (json['currency'] ?? 'INR').toString(),
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.tryParse(json['confirmed_at'].toString())
          : null,
      invoicedAt: invoicedAt,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.tryParse(json['cancelled_at'].toString())
          : null,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static SalesOrderStatus _statusFromString(String? s) => switch (s) {
    'confirmed' => SalesOrderStatus.confirmed,
    'invoiced' => SalesOrderStatus.invoiced,
    'cancelled' => SalesOrderStatus.cancelled,
    _ => SalesOrderStatus.draft,
  };

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
