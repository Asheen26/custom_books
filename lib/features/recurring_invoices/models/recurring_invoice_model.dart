import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:flutter/material.dart';

enum RecurringInvoiceStatus { active, stopped, expired, draft }

extension RecurringInvoiceStatusLabel on RecurringInvoiceStatus {
  String get label => switch (this) {
    RecurringInvoiceStatus.active => 'ACTIVE',
    RecurringInvoiceStatus.stopped => 'STOPPED',
    RecurringInvoiceStatus.expired => 'EXPIRED',
    RecurringInvoiceStatus.draft => 'DRAFT',
  };
}

extension RecurringInvoiceStatusColor on RecurringInvoiceStatus {
  Color get color => switch (this) {
    RecurringInvoiceStatus.active => AppColors.success,
    RecurringInvoiceStatus.stopped => AppColors.error,
    RecurringInvoiceStatus.expired => AppColors.warning,
    RecurringInvoiceStatus.draft => AppColors.statusDraft,
  };
}

enum RecurringFrequency { weekly, monthly, quarterly, yearly }

extension RecurringFrequencyLabel on RecurringFrequency {
  String get label => switch (this) {
    RecurringFrequency.weekly => 'Weekly',
    RecurringFrequency.monthly => 'Monthly',
    RecurringFrequency.quarterly => 'Quarterly',
    RecurringFrequency.yearly => 'Yearly',
  };
}

enum RecurringInvoiceSortField {
  createdTime,
  profileName,
  customerName,
  amount,
}

extension RecurringInvoiceSortFieldLabel on RecurringInvoiceSortField {
  String get label => switch (this) {
    RecurringInvoiceSortField.createdTime => 'Created Time',
    RecurringInvoiceSortField.profileName => 'Profile Name',
    RecurringInvoiceSortField.customerName => 'Customer Name',
    RecurringInvoiceSortField.amount => 'Amount',
  };
}

class RecurringInvoiceLineItem {
  final String id;
  final String itemId;
  final String itemName;
  final String description;
  final double quantity;
  final double rate;
  final double discount;
  final bool discountIsPercent;
  final double taxRate;

  const RecurringInvoiceLineItem({
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

class RecurringInvoiceModel {
  final String id;
  final String profileName;
  final String customerName;
  final RecurringFrequency frequency;
  final DateTime startDate;
  final RecurringInvoiceStatus status;
  final List<RecurringInvoiceLineItem> lineItems;
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecurringInvoiceModel({
    required this.id,
    required this.profileName,
    required this.customerName,
    this.frequency = RecurringFrequency.monthly,
    required this.startDate,
    this.status = RecurringInvoiceStatus.active,
    this.lineItems = const [],
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });

  RecurringInvoiceModel copyWith({
    String? id,
    String? profileName,
    String? customerName,
    RecurringFrequency? frequency,
    DateTime? startDate,
    RecurringInvoiceStatus? status,
    List<RecurringInvoiceLineItem>? lineItems,
    double? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringInvoiceModel(
      id: id ?? this.id,
      profileName: profileName ?? this.profileName,
      customerName: customerName ?? this.customerName,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      status: status ?? this.status,
      lineItems: lineItems ?? this.lineItems,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
