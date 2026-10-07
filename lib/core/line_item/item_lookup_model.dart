/// Shared model used by all line item pickers across the app.
/// Represents a single item returned from the items search API.
class ItemLookupResult {
  final String id;
  final String name;
  final double stockOnHand;
  final String? imageUrl;
  final double costPrice;

  const ItemLookupResult({
    required this.id,
    required this.name,
    required this.stockOnHand,
    this.imageUrl,
    this.costPrice = 0,
  });
}

/// The normalized form data captured by [AddLineItemPage].
/// Each feature caller receives this and maps it to its own model.
class LineItemFormData {
  final String itemId;
  final String itemName;
  final String? imageUrl;
  final String description;
  final double quantity;
  final double rate;
  final double discount;
  final bool discountIsPercent;
  final double taxRate;

  const LineItemFormData({
    required this.itemId,
    required this.itemName,
    this.imageUrl,
    required this.description,
    required this.quantity,
    required this.rate,
    required this.discount,
    required this.discountIsPercent,
    required this.taxRate,
  });

  double get gross => quantity * rate;
  double get discountAmount =>
      discountIsPercent ? gross * discount / 100 : discount;
  double get net => (gross - discountAmount).clamp(0, double.infinity);
  double get taxAmount => net * taxRate / 100;
  double get total => net + taxAmount;
}
