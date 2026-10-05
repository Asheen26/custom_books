class QuoteLineItem {
  final String id;
  final String itemId;
  final String itemName;
  final String description;
  final double quantity;
  final double rate;
  final double tax;
  final double amount;
  final double discount;
  final bool discountIsPercent;
  final double taxRate;

  const QuoteLineItem({
    required this.id,
    this.itemId = '',
    required this.itemName,
    this.description = '',
    required this.quantity,
    required this.rate,
    this.tax = 0,
    this.amount = 0,
    this.discount = 0,
    this.discountIsPercent = true,
    this.taxRate = 0,
  });

  double get gross => quantity * rate;
  double get discountAmount =>
      discountIsPercent ? gross * discount / 100 : discount;
  double get net => (gross - discountAmount).clamp(0, double.infinity);
  double get taxAmount => net * taxRate / 100;

  factory QuoteLineItem.fromJson(Map<String, dynamic> json) {
    return QuoteLineItem(
      id: (json['line_id'] ?? json['id'] ?? '').toString(),
      itemId: (json['item_id'] ?? '').toString(),
      itemName: (json['name'] ?? json['item_name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      quantity: _toDouble(json['quantity']),
      rate: _toDouble(json['rate']),
      tax: _toDouble(json['tax']),
      amount: _toDouble(json['amount']),
      discount: _toDouble(json['discount']),
      discountIsPercent: json['discount_type'] != 'entity_level',
      taxRate: _toDouble(json['tax_percentage']),
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}
