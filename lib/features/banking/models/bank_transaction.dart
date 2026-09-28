/// The direction of money movement for a bank transaction.
enum TransactionFlow { credit, debit }

/// A single transaction row in an account's transaction history.
///
/// Mirrors the fields shown in the banking transaction list and detail
/// screens: date, type (e.g. "Journal", "Customer Payment"), the signed
/// amount, an optional reference number, the party involved, and the
/// source label (e.g. "Manually Added").
class BankTransaction {
  final String id;

  /// The date the transaction was recorded.
  final DateTime date;

  /// Human readable type, e.g. "Journal", "Customer Payment".
  final String type;

  /// The transaction amount. Sign is derived from [flow].
  final double amount;

  /// Whether the amount increases (credit) or decreases (debit) the balance.
  final TransactionFlow flow;

  /// Optional reference number, e.g. "00001H".
  final String? referenceNumber;

  /// Optional related party, e.g. "Parthiv Ajith".
  final String? party;

  /// The party role label, e.g. "Customer", "Vendor".
  final String? partyLabel;

  /// How the transaction was created, e.g. "Manually Added".
  final String source;

  /// Currency code, e.g. "AED", "INR".
  final String currency;

  // ── Optional richer detail (used by the details page) ────────────────
  final String? referenceType; // e.g. "Payment Receipt", "Invoice"
  final String? paymentMode; // e.g. "credit_card"
  final String? status; // e.g. "PAID"
  final String? depositTo; // e.g. "ADBC"
  final String? notes;
  final String? invoiceNumber; // e.g. "INV-000017"
  final DateTime? invoiceDate;
  final double? invoiceAmount;
  final String? template; // e.g. "Elite Template"

  const BankTransaction({
    required this.id,
    required this.date,
    required this.type,
    required this.amount,
    required this.flow,
    this.referenceNumber,
    this.party,
    this.partyLabel,
    this.source = 'Manually Added',
    this.currency = 'AED',
    this.referenceType,
    this.paymentMode,
    this.status,
    this.depositTo,
    this.notes,
    this.invoiceNumber,
    this.invoiceDate,
    this.invoiceAmount,
    this.template,
  });

  bool get isCredit => flow == TransactionFlow.credit;

  /// The amount rendered with its sign, e.g. "-315.00" for a debit.
  String get signedAmount {
    final formatted = amount.abs().toStringAsFixed(2);
    return isCredit ? formatted : '-$formatted';
  }

  factory BankTransaction.fromJson(Map<String, dynamic> json) {
    // Prefer the explicit signed amount when present, otherwise fall back to
    // the raw amount and infer the sign from the transaction type.
    final rawAmount = _toDouble(json['amount']);
    final signed = json.containsKey('signed_amount')
        ? _toDouble(json['signed_amount'])
        : rawAmount;
    final rawType = (json['transaction_type'] ?? json['flow'] ?? '')
        .toString()
        .toLowerCase();
    final flow = rawType == 'debit' || signed < 0
        ? TransactionFlow.debit
        : TransactionFlow.credit;

    final description = _nullIfBlank(json['description'] ?? json['notes']);

    return BankTransaction(
      id: (json['transaction_id'] ?? json['id'] ?? '').toString(),
      date: _toDate(json['transaction_date'] ?? json['date']) ?? DateTime.now(),
      // The API has no display "type" label, so use the description
      // (e.g. "Customer payment") and fall back to the raw type.
      type:
          (json['transaction_type_label'] ??
                  description ??
                  (rawType.isNotEmpty ? _capitalize(rawType) : 'Transaction'))
              .toString(),
      amount: signed.abs(),
      flow: flow,
      referenceNumber: _nullIfBlank(json['reference_number']),
      party: _nullIfBlank(json['party'] ?? json['contact_name']),
      partyLabel: _nullIfBlank(json['party_label'] ?? json['contact_type']),
      source: (json['source'] ?? 'Manually Added').toString(),
      currency: (json['currency'] ?? 'AED').toString(),
      referenceType: _nullIfBlank(json['reference_type']),
      paymentMode: _nullIfBlank(json['payment_mode']),
      status: _nullIfBlank(json['status']),
      depositTo: _nullIfBlank(json['deposit_to'] ?? json['account_name']),
      notes: description,
      invoiceNumber: _nullIfBlank(json['invoice_number']),
      invoiceDate: _toDate(json['invoice_date']),
      invoiceAmount: json['invoice_amount'] == null
          ? null
          : _toDouble(json['invoice_amount']),
      template: _nullIfBlank(json['template']),
    );
  }

  static String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  static String? _nullIfBlank(dynamic value) {
    if (value == null) return null;
    final str = value.toString().trim();
    return str.isEmpty ? null : str;
  }
}
