/// A selectable currency returned by `GET /api/banking/options/`.
class CurrencyOption {
  /// The currency code, e.g. "USD".
  final String value;

  /// The display label, e.g. "USD- United States Dollar".
  final String label;

  const CurrencyOption({required this.value, required this.label});

  factory CurrencyOption.fromJson(Map<String, dynamic> json) {
    return CurrencyOption(
      value: (json['value'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
    );
  }
}
