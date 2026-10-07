enum PaymentMode { cash, bankTransfer, card, cheque, upi }

extension PaymentModeLabel on PaymentMode {
  String get label => switch (this) {
    PaymentMode.cash => 'Cash',
    PaymentMode.bankTransfer => 'Bank Transfer',
    PaymentMode.card => 'Card',
    PaymentMode.cheque => 'Cheque',
    PaymentMode.upi => 'UPI',
  };

  /// Snake-case key expected by the API.
  String get apiKey => switch (this) {
    PaymentMode.cash => 'cash',
    PaymentMode.bankTransfer => 'bank_transfer',
    PaymentMode.card => 'card',
    PaymentMode.cheque => 'cheque',
    PaymentMode.upi => 'upi',
  };
}

/// Converts an API snake_case string back to a [PaymentMode].
PaymentMode paymentModeFromApiKey(String key) => switch (key) {
  'bank_transfer' => PaymentMode.bankTransfer,
  'card' => PaymentMode.card,
  'cheque' => PaymentMode.cheque,
  'upi' => PaymentMode.upi,
  _ => PaymentMode.cash,
};

enum PaymentReceivedSortField {
  createdTime,
  date,
  paymentNumber,
  customerName,
  amount,
}

extension PaymentReceivedSortFieldLabel on PaymentReceivedSortField {
  String get label => switch (this) {
    PaymentReceivedSortField.createdTime => 'Created Time',
    PaymentReceivedSortField.date => 'Date',
    PaymentReceivedSortField.paymentNumber => 'Payment#',
    PaymentReceivedSortField.customerName => 'Customer Name',
    PaymentReceivedSortField.amount => 'Amount',
  };

  /// Value expected by the API's `sort_by` query parameter.
  String get apiKey => switch (this) {
    PaymentReceivedSortField.createdTime => 'created_time',
    PaymentReceivedSortField.date => 'payment_date',
    PaymentReceivedSortField.paymentNumber => 'payment_number',
    PaymentReceivedSortField.customerName => 'customer_name',
    PaymentReceivedSortField.amount => 'amount',
  };
}

// ── Amount summary ────────────────────────────────────────────────────────────

class PaymentAmountSummary {
  final double amountReceived;
  final double bankCharges;
  final double amountUsedForPayments;
  final double amountRefunded;
  final double amountInExcess;

  const PaymentAmountSummary({
    required this.amountReceived,
    required this.bankCharges,
    required this.amountUsedForPayments,
    required this.amountRefunded,
    required this.amountInExcess,
  });

  factory PaymentAmountSummary.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) => double.tryParse((v ?? '0').toString()) ?? 0.0;
    return PaymentAmountSummary(
      amountReceived: toDouble(json['amount_received']),
      bankCharges: toDouble(json['bank_charges']),
      amountUsedForPayments: toDouble(json['amount_used_for_payments']),
      amountRefunded: toDouble(json['amount_refunded']),
      amountInExcess: toDouble(json['amount_in_excess']),
    );
  }

  static const empty = PaymentAmountSummary(
    amountReceived: 0,
    bankCharges: 0,
    amountUsedForPayments: 0,
    amountRefunded: 0,
    amountInExcess: 0,
  );
}

// ── Main model ────────────────────────────────────────────────────────────────

class PaymentReceivedModel {
  final String id;
  final String paymentNumber;
  final String customerName;
  final String customerId;
  final List<String> invoiceNumbers;
  final DateTime paymentDate;
  final String paymentDateLabel;
  final PaymentMode mode;
  final String referenceNumber;
  final double amount;
  final double amountApplied;
  final double unusedAmount;
  final String currency;
  final String status;
  final String statusLabel;
  final bool isUnapplied;
  final String notes;
  final double bankCharges;
  final String receiptStatus;
  final String receiptStatusLabel;
  final bool isVoid;
  final PaymentAmountSummary amountSummary;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentReceivedModel({
    required this.id,
    required this.paymentNumber,
    required this.customerName,
    this.customerId = '',
    this.invoiceNumbers = const [],
    required this.paymentDate,
    this.paymentDateLabel = '',
    this.mode = PaymentMode.cash,
    this.referenceNumber = '',
    required this.amount,
    this.amountApplied = 0.0,
    this.unusedAmount = 0.0,
    this.currency = 'INR',
    this.status = '',
    this.statusLabel = '',
    this.isUnapplied = false,
    this.notes = '',
    this.bankCharges = 0.0,
    this.receiptStatus = '',
    this.receiptStatusLabel = '',
    this.isVoid = false,
    this.amountSummary = PaymentAmountSummary.empty,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PaymentReceivedModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic v) => double.tryParse((v ?? '0').toString()) ?? 0.0;
    DateTime toDate(dynamic v) => v != null
        ? DateTime.tryParse(v.toString()) ?? DateTime.now()
        : DateTime.now();

    final summaryJson = json['amount_summary'];
    return PaymentReceivedModel(
      id: (json['payment_id'] ?? json['id'] ?? '').toString(),
      paymentNumber: (json['payment_number'] ?? '').toString(),
      customerName: (json['customer_name'] ?? '').toString(),
      customerId: (json['customer_id'] ?? '').toString(),
      invoiceNumbers:
          (json['applications'] as List<dynamic>?)
              ?.map(
                (e) =>
                    (e as Map<String, dynamic>)['invoice_number']?.toString() ??
                    '',
              )
              .where((s) => s.isNotEmpty)
              .toList() ??
          const [],
      paymentDate: toDate(json['payment_date']),
      paymentDateLabel: (json['payment_date_label'] ?? '').toString(),
      mode: paymentModeFromApiKey((json['payment_mode'] ?? '').toString()),
      referenceNumber: (json['reference_number'] ?? '').toString(),
      amount: toDouble(json['amount']),
      amountApplied: toDouble(json['amount_applied']),
      unusedAmount: toDouble(json['unused_amount']),
      currency: (json['currency'] ?? 'INR').toString(),
      status: (json['status'] ?? '').toString(),
      statusLabel: (json['status_label'] ?? '').toString(),
      isUnapplied: json['is_unapplied'] == true,
      notes: (json['notes'] ?? '').toString(),
      bankCharges: toDouble(json['bank_charges']),
      receiptStatus: (json['receipt_status'] ?? '').toString(),
      receiptStatusLabel: (json['receipt_status_label'] ?? '').toString(),
      isVoid: json['is_void'] == true,
      amountSummary: summaryJson is Map<String, dynamic>
          ? PaymentAmountSummary.fromJson(summaryJson)
          : PaymentAmountSummary.empty,
      createdAt: toDate(json['created_at']),
      updatedAt: toDate(json['updated_at']),
    );
  }

  PaymentReceivedModel copyWith({
    String? id,
    String? paymentNumber,
    String? customerName,
    String? customerId,
    List<String>? invoiceNumbers,
    DateTime? paymentDate,
    String? paymentDateLabel,
    PaymentMode? mode,
    String? referenceNumber,
    double? amount,
    double? amountApplied,
    double? unusedAmount,
    String? currency,
    String? status,
    String? statusLabel,
    bool? isUnapplied,
    String? notes,
    double? bankCharges,
    String? receiptStatus,
    String? receiptStatusLabel,
    bool? isVoid,
    PaymentAmountSummary? amountSummary,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentReceivedModel(
      id: id ?? this.id,
      paymentNumber: paymentNumber ?? this.paymentNumber,
      customerName: customerName ?? this.customerName,
      customerId: customerId ?? this.customerId,
      invoiceNumbers: invoiceNumbers ?? this.invoiceNumbers,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentDateLabel: paymentDateLabel ?? this.paymentDateLabel,
      mode: mode ?? this.mode,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      amount: amount ?? this.amount,
      amountApplied: amountApplied ?? this.amountApplied,
      unusedAmount: unusedAmount ?? this.unusedAmount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      statusLabel: statusLabel ?? this.statusLabel,
      isUnapplied: isUnapplied ?? this.isUnapplied,
      notes: notes ?? this.notes,
      bankCharges: bankCharges ?? this.bankCharges,
      receiptStatus: receiptStatus ?? this.receiptStatus,
      receiptStatusLabel: receiptStatusLabel ?? this.receiptStatusLabel,
      isVoid: isVoid ?? this.isVoid,
      amountSummary: amountSummary ?? this.amountSummary,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
