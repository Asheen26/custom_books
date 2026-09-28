import 'package:custom_books/core/utils/app_logger.dart';
import 'package:custom_books/features/banking/models/currency_option.dart';
import 'package:custom_books/features/banking/viewmodels/banking_options_viewmodel.dart';

class BankingOptionsController {
  final _vm = BankingOptionsViewModel();

  /// Fetches currency options, optionally filtered by [search].
  /// Returns an empty list on failure.
  Future<List<CurrencyOption>> searchCurrencies({String? search}) async {
    final resp = await _vm.fetchOptions(search: search);
    final int? status = resp?['_statusCode'] as int?;
    if (resp != null &&
        resp['success'] == true &&
        status != null &&
        status >= 200 &&
        status < 300) {
      final data = resp['data'] as Map<String, dynamic>?;
      final raw = (data?['currencies'] as List<dynamic>?) ?? [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(CurrencyOption.fromJson)
          .toList();
    }
    appLog(
      '⚠️ Banking currency options fetch failed (status: $status)',
      name: 'BankingOptionsController',
    );
    return const [];
  }
}
