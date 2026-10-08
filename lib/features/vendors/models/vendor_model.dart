import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:flutter/material.dart';

enum VendorStatus { active, inactive }

extension VendorStatusLabel on VendorStatus {
  String get label => switch (this) {
    VendorStatus.active => 'ACTIVE',
    VendorStatus.inactive => 'INACTIVE',
  };
}

extension VendorStatusColor on VendorStatus {
  Color get color => switch (this) {
    VendorStatus.active => AppColors.success,
    VendorStatus.inactive => AppColors.statusCancelled,
  };
}

enum VendorsSortField { createdTime, name, companyName, payables }

extension VendorsSortFieldLabel on VendorsSortField {
  String get label => switch (this) {
    VendorsSortField.createdTime => 'Created Time',
    VendorsSortField.name => 'Name',
    VendorsSortField.companyName => 'Company Name',
    VendorsSortField.payables => 'Payables',
  };
}

class VendorModel {
  final String id;
  final String displayName;
  final String companyName;
  final String email;
  final String phone;
  final double payables;
  final double unusedCredits;
  final VendorStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VendorModel({
    required this.id,
    required this.displayName,
    this.companyName = '',
    this.email = '',
    this.phone = '',
    this.payables = 0,
    this.unusedCredits = 0,
    this.status = VendorStatus.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: (json['vendor_id'] ?? json['id'] ?? '').toString(),
      displayName: (json['display_name'] ?? '').toString(),
      companyName: _nullIfBlank(json['company_name']) ?? '',
      email: _nullIfBlank(json['email']) ?? '',
      phone: _nullIfBlank(json['phone']) ?? '',
      payables: _toDouble(json['payables']),
      unusedCredits: _toDouble(json['unused_credits']),
      status: (json['status']?.toString().toLowerCase() == 'active')
          ? VendorStatus.active
          : VendorStatus.inactive,
      createdAt: _toDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _toDate(json['updated_at']) ?? DateTime.now(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static String? _nullIfBlank(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    return str.isEmpty ? null : str;
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  VendorModel copyWith({
    String? id,
    String? displayName,
    String? companyName,
    String? email,
    String? phone,
    double? payables,
    double? unusedCredits,
    VendorStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VendorModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      payables: payables ?? this.payables,
      unusedCredits: unusedCredits ?? this.unusedCredits,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
