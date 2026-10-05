import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:flutter/material.dart';

enum CreditNoteStatus { draft, open, closed, void_ }

extension CreditNoteStatusLabel on CreditNoteStatus {
  String get label => switch (this) {
    CreditNoteStatus.draft => 'DRAFT',
    CreditNoteStatus.open => 'OPEN',
    CreditNoteStatus.closed => 'CLOSED',
    CreditNoteStatus.void_ => 'VOID',
  };
}

extension CreditNoteStatusColor on CreditNoteStatus {
  Color get color => switch (this) {
    CreditNoteStatus.draft => AppColors.statusDraft,
    CreditNoteStatus.open => AppColors.primaryLight,
    CreditNoteStatus.closed => AppColors.success,
    CreditNoteStatus.void_ => AppColors.error,
  };
}

enum CreditNoteSortField {
  createdTime,
  date,
  creditNoteNumber,
  customerName,
  amount,
}

extension CreditNoteSortFieldLabel on CreditNoteSortField {
  String get label => switch (this) {
    CreditNoteSortField.createdTime => 'Created Time',
    CreditNoteSortField.date => 'Date',
    CreditNoteSortField.creditNoteNumber => 'Credit Note#',
    CreditNoteSortField.customerName => 'Customer Name',
    CreditNoteSortField.amount => 'Amount',
  };
}

class CreditNoteLineItem {
  final String id;
  final String itemId;
  final String itemName;
  final String description;
  final double quantity;
  final double rate;
  final double discount;
  final bool discountIsPercent;
  final double taxRate;

  const CreditNoteLineItem({
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

class CreditNoteModel {
  final String id;
  final String creditNoteNumber;
  final String customerName;
  final String referenceNumber;
  final DateTime creditNoteDate;
  final CreditNoteStatus status;
  final List<CreditNoteLineItem> lineItems;
  final double total;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CreditNoteModel({
    required this.id,
    required this.creditNoteNumber,
    required this.customerName,
    this.referenceNumber = '',
    required this.creditNoteDate,
    this.status = CreditNoteStatus.draft,
    this.lineItems = const [],
    required this.total,
    required this.createdAt,
    required this.updatedAt,
  });

  CreditNoteModel copyWith({
    String? id,
    String? creditNoteNumber,
    String? customerName,
    String? referenceNumber,
    DateTime? creditNoteDate,
    CreditNoteStatus? status,
    List<CreditNoteLineItem>? lineItems,
    double? total,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CreditNoteModel(
      id: id ?? this.id,
      creditNoteNumber: creditNoteNumber ?? this.creditNoteNumber,
      customerName: customerName ?? this.customerName,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      creditNoteDate: creditNoteDate ?? this.creditNoteDate,
      status: status ?? this.status,
      lineItems: lineItems ?? this.lineItems,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
