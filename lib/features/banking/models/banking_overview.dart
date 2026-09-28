import 'package:custom_books/features/banking/models/bank_account.dart';

/// A selectable option (used for both date ranges and accounts).
class BankingOption {
  final String key;
  final String label;

  const BankingOption({required this.key, required this.label});

  factory BankingOption.fromDateRange(Map<String, dynamic> json) {
    return BankingOption(
      key: (json['key'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
    );
  }

  factory BankingOption.fromAccount(Map<String, dynamic> json) {
    return BankingOption(
      key: (json['account_id'] ?? '').toString(),
      label: (json['name'] ?? '').toString(),
    );
  }
}

/// A single point on the balance chart.
class BankingChartPoint {
  final String date;
  final String dateLabel;
  final double balance;

  const BankingChartPoint({
    required this.date,
    required this.dateLabel,
    required this.balance,
  });

  factory BankingChartPoint.fromJson(Map<String, dynamic> json) {
    return BankingChartPoint(
      date: (json['date'] ?? '').toString(),
      dateLabel: (json['date_label'] ?? '').toString(),
      balance: BankingOverview._toDouble(json['balance']),
    );
  }
}

/// The full banking overview payload returned by
/// `GET /api/banking/overview/`.
class BankingOverview {
  final String title;
  final String subtitle;
  final String currency;
  final String dateRange;
  final String dateRangeLabel;
  final List<BankingOption> availableDateRanges;
  final String? startDate;
  final String? endDate;
  final String accountId;
  final String accountLabel;
  final List<BankingOption> accountOptions;
  final double cashInHand;
  final double bankBalance;
  final List<BankingChartPoint> chart;
  final int accountsCount;
  final List<BankAccount> accounts;

  const BankingOverview({
    required this.title,
    required this.subtitle,
    required this.currency,
    required this.dateRange,
    required this.dateRangeLabel,
    required this.availableDateRanges,
    required this.startDate,
    required this.endDate,
    required this.accountId,
    required this.accountLabel,
    required this.accountOptions,
    required this.cashInHand,
    required this.bankBalance,
    required this.chart,
    required this.accountsCount,
    required this.accounts,
  });

  factory BankingOverview.fromJson(Map<String, dynamic> json) {
    return BankingOverview(
      title: (json['title'] ?? 'Banking Overview').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      currency: (json['currency'] ?? 'INR').toString(),
      dateRange: (json['date_range'] ?? '').toString(),
      dateRangeLabel: (json['date_range_label'] ?? '').toString(),
      availableDateRanges:
          ((json['available_date_ranges'] as List<dynamic>?) ?? [])
              .whereType<Map<String, dynamic>>()
              .map(BankingOption.fromDateRange)
              .toList(),
      startDate: _nullIfBlank(json['start_date']),
      endDate: _nullIfBlank(json['end_date']),
      accountId: (json['account_id'] ?? 'all').toString(),
      accountLabel: (json['account_label'] ?? 'All Accounts').toString(),
      accountOptions: ((json['account_options'] as List<dynamic>?) ?? [])
          .whereType<Map<String, dynamic>>()
          .map(BankingOption.fromAccount)
          .toList(),
      cashInHand: _toDouble(json['cash_in_hand']),
      bankBalance: _toDouble(json['bank_balance']),
      chart: ((json['chart'] as List<dynamic>?) ?? [])
          .whereType<Map<String, dynamic>>()
          .map(BankingChartPoint.fromJson)
          .toList(),
      accountsCount: (json['accounts_count'] as num?)?.toInt() ?? 0,
      accounts: ((json['accounts'] as List<dynamic>?) ?? [])
          .whereType<Map<String, dynamic>>()
          .map(BankAccount.fromJson)
          .toList(),
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
