class BankAccount {
  final String id;
  final String name;
  final String icon;
  final double amountInZohoBooks;
  final double amountInBank;

  final String? accountType;
  final String? accountTypeLabel;
  final String? currency;
  final String? status;
  final bool isPrimary;

  BankAccount({
    required this.id,
    required this.name,
    required this.icon,
    required this.amountInZohoBooks,
    required this.amountInBank,
    this.accountType,
    this.accountTypeLabel,
    this.currency,
    this.status,
    this.isPrimary = false,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: (json['account_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      icon: (json['icon'] ?? json['account_type'] ?? '').toString(),
      amountInZohoBooks: _toDouble(json['books_balance']),
      amountInBank: _toDouble(json['bank_balance']),
      accountType: _nullIfBlank(json['account_type']),
      accountTypeLabel: _nullIfBlank(json['account_type_label']),
      currency: _nullIfBlank(json['currency']),
      status: _nullIfBlank(json['status']),
      isPrimary: json['is_primary'] == true,
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
}
