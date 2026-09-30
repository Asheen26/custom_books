import 'package:custom_books/features/quotes/models/quote_line_item.dart';
import 'package:custom_books/features/quotes/models/quote_status.dart';

export 'package:custom_books/features/quotes/models/quote_line_item.dart';
export 'package:custom_books/features/quotes/models/quote_status.dart';

class QuoteModel {
  final String id;
  final String quoteNumber;
  final String customerId;
  final String customerName;
  final String referenceNumber;
  final DateTime quoteDate;

  final String quoteDateLabel;
  final DateTime? expiryDate;

  final String expiryDateLabel;
  final String salesperson;
  final String projectName;
  final String subject;
  final String taxType;
  final bool taxInclusive;
  final List<QuoteLineItem> lineItems;
  final String customerNotes;
  final String termsAndConditions;
  final List<String> attachments;
  final QuoteStatus status;

  final double totalAmount;
  final String currency;
  final DateTime? sentAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QuoteModel({
    required this.id,
    required this.quoteNumber,
    this.customerId = '',
    required this.customerName,
    this.referenceNumber = '',
    required this.quoteDate,
    this.quoteDateLabel = '',
    this.expiryDate,
    this.expiryDateLabel = '',
    this.salesperson = '',
    this.projectName = '',
    this.subject = '',
    this.taxType = 'exclusive',
    this.taxInclusive = false,
    this.lineItems = const [],
    this.customerNotes = '',
    this.termsAndConditions = '',
    this.attachments = const [],
    this.status = QuoteStatus.draft,
    this.totalAmount = 0,
    this.currency = 'INR',
    this.sentAt,
    required this.createdAt,
    required this.updatedAt,
  });

  double get subTotal => lineItems.fold(0, (sum, item) => sum + item.net);
  double get taxAmountComputed =>
      lineItems.fold(0, (sum, item) => sum + item.taxAmount);

  double get total => taxInclusive ? subTotal : subTotal + taxAmountComputed;

  QuoteModel copyWith({
    String? id,
    String? quoteNumber,
    String? customerId,
    String? customerName,
    String? referenceNumber,
    DateTime? quoteDate,
    String? quoteDateLabel,
    DateTime? expiryDate,
    String? expiryDateLabel,
    String? salesperson,
    String? projectName,
    String? subject,
    String? taxType,
    bool? taxInclusive,
    List<QuoteLineItem>? lineItems,
    String? customerNotes,
    String? termsAndConditions,
    List<String>? attachments,
    QuoteStatus? status,
    double? totalAmount,
    String? currency,
    DateTime? sentAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => QuoteModel(
    id: id ?? this.id,
    quoteNumber: quoteNumber ?? this.quoteNumber,
    customerId: customerId ?? this.customerId,
    customerName: customerName ?? this.customerName,
    referenceNumber: referenceNumber ?? this.referenceNumber,
    quoteDate: quoteDate ?? this.quoteDate,
    quoteDateLabel: quoteDateLabel ?? this.quoteDateLabel,
    expiryDate: expiryDate ?? this.expiryDate,
    expiryDateLabel: expiryDateLabel ?? this.expiryDateLabel,
    salesperson: salesperson ?? this.salesperson,
    projectName: projectName ?? this.projectName,
    subject: subject ?? this.subject,
    taxType: taxType ?? this.taxType,
    taxInclusive: taxInclusive ?? this.taxInclusive,
    lineItems: lineItems ?? this.lineItems,
    customerNotes: customerNotes ?? this.customerNotes,
    termsAndConditions: termsAndConditions ?? this.termsAndConditions,
    attachments: attachments ?? this.attachments,
    status: status ?? this.status,
    totalAmount: totalAmount ?? this.totalAmount,
    currency: currency ?? this.currency,
    sentAt: sentAt ?? this.sentAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? DateTime.now(),
  );

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    final taxTypeStr = (json['tax_type'] ?? 'exclusive').toString();
    return QuoteModel(
      id: (json['quote_id'] ?? '').toString(),
      quoteNumber: (json['quote_number'] ?? '').toString(),
      customerId: (json['customer_id'] ?? '').toString(),
      customerName: (json['customer_name'] ?? '').toString(),
      referenceNumber: (json['reference_number'] ?? '').toString(),
      quoteDate:
          DateTime.tryParse(json['quote_date']?.toString() ?? '') ??
          DateTime.now(),
      quoteDateLabel: (json['quote_date_label'] ?? '').toString(),
      expiryDate: json['expiry_date'] != null
          ? DateTime.tryParse(json['expiry_date'].toString())
          : null,
      expiryDateLabel: (json['expiry_date_label'] ?? '').toString(),
      salesperson: (json['salesperson_name'] ?? '').toString(),
      projectName: (json['project_name'] ?? '').toString(),
      subject: (json['subject'] ?? '').toString(),
      taxType: taxTypeStr,
      taxInclusive: taxTypeStr == 'inclusive',
      lineItems: (json['line_items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(QuoteLineItem.fromJson)
          .toList(),
      customerNotes: (json['customer_notes'] ?? '').toString(),
      termsAndConditions: (json['terms_and_conditions'] ?? '').toString(),
      attachments: (json['attachments'] as List<dynamic>? ?? [])
          .map((a) => a.toString())
          .toList(),
      status: _statusFromString(json['status']?.toString()),
      totalAmount: _toDouble(json['total_amount']),
      currency: (json['currency'] ?? 'INR').toString(),
      sentAt: json['sent_at'] != null
          ? DateTime.tryParse(json['sent_at'].toString())
          : null,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static QuoteStatus _statusFromString(String? s) => switch (s) {
    'sent' => QuoteStatus.sent,
    'accepted' => QuoteStatus.accepted,
    'declined' => QuoteStatus.declined,
    'expired' => QuoteStatus.expired,
    'converted' => QuoteStatus.converted,
    _ => QuoteStatus.draft,
  };

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}