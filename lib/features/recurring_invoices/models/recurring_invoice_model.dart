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
  final String? customerId;
  final RecurringFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? nextInvoiceDate;
  final DateTime? lastInvoiceDate;
  final RecurringInvoiceStatus status;
  final List<RecurringInvoiceLineItem> lineItems;
  final double amount;
  final String currency;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RecurringInvoiceModel({
    required this.id,
    required this.profileName,
    required this.customerName,
    this.customerId,
    this.frequency = RecurringFrequency.monthly,
    required this.startDate,
    this.endDate,
    this.nextInvoiceDate,
    this.lastInvoiceDate,
    this.status = RecurringInvoiceStatus.active,
    this.lineItems = const [],
    required this.amount,
    this.currency = 'INR',
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  factory RecurringInvoiceModel.fromJson(Map<String, dynamic> json) {
    return RecurringInvoiceModel(
      id: json['recurring_invoice_id'] as String? ?? '',
      profileName: json['profile_name'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '',
      customerId: json['customer_id'] as String?,
      frequency: _frequencyFromString(json['frequency'] as String? ?? ''),
      startDate: _parseDate(json['start_date'] as String?) ?? DateTime.now(),
      endDate: _parseDate(json['end_date'] as String?),
      nextInvoiceDate: _parseDate(json['next_invoice_date'] as String?),
      lastInvoiceDate: _parseDate(json['last_invoice_date'] as String?),
      status: _statusFromString(json['status'] as String? ?? ''),
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      notes: json['notes'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  static RecurringFrequency _frequencyFromString(String value) {
    return switch (value.toLowerCase()) {
      'weekly' => RecurringFrequency.weekly,
      'monthly' => RecurringFrequency.monthly,
      'quarterly' => RecurringFrequency.quarterly,
      'yearly' => RecurringFrequency.yearly,
      _ => RecurringFrequency.monthly,
    };
  }

  static RecurringInvoiceStatus _statusFromString(String value) {
    return switch (value.toLowerCase()) {
      'active' => RecurringInvoiceStatus.active,
      'stopped' => RecurringInvoiceStatus.stopped,
      'expired' => RecurringInvoiceStatus.expired,
      'draft' => RecurringInvoiceStatus.draft,
      _ => RecurringInvoiceStatus.active,
    };
  }

  static DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  RecurringInvoiceModel copyWith({
    String? id,
    String? profileName,
    String? customerName,
    String? customerId,
    RecurringFrequency? frequency,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextInvoiceDate,
    DateTime? lastInvoiceDate,
    RecurringInvoiceStatus? status,
    List<RecurringInvoiceLineItem>? lineItems,
    double? amount,
    String? currency,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecurringInvoiceModel(
      id: id ?? this.id,
      profileName: profileName ?? this.profileName,
      customerName: customerName ?? this.customerName,
      customerId: customerId ?? this.customerId,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextInvoiceDate: nextInvoiceDate ?? this.nextInvoiceDate,
      lastInvoiceDate: lastInvoiceDate ?? this.lastInvoiceDate,
      status: status ?? this.status,
      lineItems: lineItems ?? this.lineItems,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
