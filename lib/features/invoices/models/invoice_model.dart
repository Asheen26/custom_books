import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:flutter/material.dart';

class InvoiceModel {
  final String id;
  final String invoiceNumber;
  final String customerId;
  final String customerName;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final String terms;
  final String placeOfSupply;
  final String? orderNumber;
  final String? salesperson;
  final String? subject;
  final bool isTaxInclusive;
  final List<InvoiceLineItem> lineItems;
  final String? customerNotes;
  final String? termsAndConditions;
  final List<String> emailCommunications;
  final bool paymentReceived;
  final List<String> attachments;
  final double subTotal;
  final double taxAmount;
  final double total;
  final double amountPaid;
  final double balanceDue;
  final String? currency;
  final InvoiceStatus status;
  final bool isOverdue;
  final DateTime createdAt;
  final DateTime? updatedAt;

  InvoiceModel({
    required this.id,
    required this.invoiceNumber,
    required this.customerId,
    required this.customerName,
    required this.invoiceDate,
    required this.dueDate,
    required this.terms,
    required this.placeOfSupply,
    this.orderNumber,
    this.salesperson,
    this.subject,
    this.isTaxInclusive = false,
    this.lineItems = const [],
    this.customerNotes,
    this.termsAndConditions,
    this.emailCommunications = const [],
    this.paymentReceived = false,
    this.attachments = const [],
    required this.subTotal,
    required this.taxAmount,
    required this.total,
    this.amountPaid = 0.0,
    this.balanceDue = 0.0,
    this.currency,
    this.status = InvoiceStatus.draft,
    this.isOverdue = false,
    required this.createdAt,
    this.updatedAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['line_items'] as List<dynamic>?) ?? const [];
    final rawAttachments = (json['attachments'] as List<dynamic>?) ?? const [];
    final rawEmails =
        (json['email_recipients'] as List<dynamic>?) ?? const [];

    return InvoiceModel(
      id: (json['invoice_id'] ?? json['id'] ?? '').toString(),
      invoiceNumber: (json['invoice_number'] ?? '').toString(),
      customerId: (json['customer_id'] ?? '').toString(),
      customerName: (json['customer_name'] ?? '').toString(),
      invoiceDate:
          _toDate(json['invoice_date']) ?? DateTime.now(),
      dueDate: _toDate(json['due_date']) ?? DateTime.now(),
      terms:
          (json['payment_terms_label'] ?? json['payment_terms'] ?? '')
              .toString(),
      placeOfSupply: (json['place_of_supply'] ?? '').toString(),
      orderNumber: _nullIfBlank(json['order_number']),
      salesperson: _nullIfBlank(json['salesperson_name']),
      subject: _nullIfBlank(json['subject']),
      isTaxInclusive:
          (json['tax_type']?.toString().toLowerCase() ?? '') == 'inclusive',
      lineItems: rawItems
          .whereType<Map<String, dynamic>>()
          .map(InvoiceLineItem.fromJson)
          .toList(),
      customerNotes: _nullIfBlank(json['customer_notes']),
      termsAndConditions: _nullIfBlank(json['terms_and_conditions']),
      emailCommunications:
          rawEmails.map((e) => e.toString()).toList(),
      paymentReceived: json['payment_received'] == true,
      attachments: rawAttachments.map((e) => e.toString()).toList(),
      subTotal: _toDouble(json['sub_total'] ?? json['total_amount']),
      taxAmount: _toDouble(json['tax_amount']),
      total: _toDouble(json['total_amount']),
      amountPaid: _toDouble(json['amount_paid']),
      balanceDue: _toDouble(json['balance_due']),
      currency: _nullIfBlank(json['currency']),
      status: InvoiceStatusX.fromString(json['status']?.toString()),
      isOverdue: json['is_overdue'] == true,
      createdAt: _toDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _toDate(json['updated_at']),
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }

  static String? _nullIfBlank(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }
}

class InvoiceLineItem {
  final String id;
  final String itemId;
  final String itemName;
  final String? description;
  final double quantity;
  final String unit;
  final double rate;
  final double amount;
  final double? discount;
  final double? taxRate;
  final double? taxAmount;

  InvoiceLineItem({
    required this.id,
    required this.itemId,
    required this.itemName,
    this.description,
    required this.quantity,
    required this.unit,
    required this.rate,
    required this.amount,
    this.discount,
    this.taxRate,
    this.taxAmount,
  });

  factory InvoiceLineItem.fromJson(Map<String, dynamic> json) {
    return InvoiceLineItem(
      id: (json['line_id'] ?? json['id'] ?? '').toString(),
      itemId: (json['item_id'] ?? '').toString(),
      itemName: (json['name'] ?? '').toString(),
      description:
          json['description']?.toString().trim().isNotEmpty == true
              ? json['description'].toString().trim()
              : null,
      quantity: _toDouble(json['quantity']),
      unit: (json['unit'] ?? '').toString(),
      rate: _toDouble(json['rate']),
      amount: _toDouble(json['amount']),
      taxRate: json['tax_rate'] != null
          ? _toDouble(json['tax_rate'])
          : null,
      taxAmount: json['tax_amount'] != null
          ? _toDouble(json['tax_amount'])
          : null,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0.0;
  }
}

enum InvoiceStatus { draft, sent, paid, partiallyPaid, overdue, cancelled }

extension InvoiceStatusX on InvoiceStatus {
  static InvoiceStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'draft':
        return InvoiceStatus.draft;
      case 'sent':
        return InvoiceStatus.sent;
      case 'paid':
        return InvoiceStatus.paid;
      case 'partially_paid':
      case 'partiallypaid':
        return InvoiceStatus.partiallyPaid;
      case 'overdue':
        return InvoiceStatus.overdue;
      case 'cancelled':
        return InvoiceStatus.cancelled;
      default:
        return InvoiceStatus.draft;
    }
  }
}

extension InvoiceStatusLabel on InvoiceStatus {
  String get label => switch (this) {
    InvoiceStatus.draft => 'DRAFT',
    InvoiceStatus.sent => 'SENT',
    InvoiceStatus.paid => 'PAID',
    InvoiceStatus.partiallyPaid => 'PARTIALLY PAID',
    InvoiceStatus.overdue => 'OVERDUE',
    InvoiceStatus.cancelled => 'CANCELLED',
  };
}

extension InvoiceStatusColor on InvoiceStatus {
  Color get color => switch (this) {
    InvoiceStatus.draft => AppColors.statusDraft,
    InvoiceStatus.sent => AppColors.primaryLight,
    InvoiceStatus.paid => AppColors.success,
    InvoiceStatus.partiallyPaid => AppColors.warning,
    InvoiceStatus.overdue => AppColors.error,
    InvoiceStatus.cancelled => AppColors.statusCancelled,
  };
}
