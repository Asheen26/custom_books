import 'dart:async';

import 'package:custom_books/core/apptheme/apptheme.dart';
import 'package:custom_books/core/utils/dimensions.dart';
import 'package:custom_books/features/banking/controllers/banking_options_controller.dart';
import 'package:custom_books/features/banking/models/currency_option.dart';
import 'package:flutter/material.dart';

class CurrencyBottomSheet extends StatefulWidget {
  final String selectedCurrency;
  final ValueChanged<String> onCurrencySelected;

  const CurrencyBottomSheet({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencySelected,
  });

  static void show(
    BuildContext context, {
    required String selectedCurrency,
    required ValueChanged<String> onCurrencySelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return CurrencyBottomSheet(
          selectedCurrency: selectedCurrency,
          onCurrencySelected: onCurrencySelected,
        );
      },
    );
  }

  @override
  State<CurrencyBottomSheet> createState() => _CurrencyBottomSheetState();
}

class _CurrencyBottomSheetState extends State<CurrencyBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final BankingOptionsController _controller = BankingOptionsController();

  Timer? _debounce;
  bool _isLoading = false;
  List<CurrencyOption> _currencies = [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _fetch);
  }

  Future<void> _fetch() async {
    setState(() => _isLoading = true);
    final results = await _controller.searchCurrencies(
      search: _searchController.text.trim(),
    );
    if (!mounted) return;
    setState(() {
      _currencies = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(Dimensions.radius20),
          topRight: Radius.circular(Dimensions.radius20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width20,
              vertical: Dimensions.height15,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: context.colors.border, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Currency',
                  style: TextStyle(
                    fontSize: Dimensions.font20,
                    fontWeight: FontWeight.w700,
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: EdgeInsets.all(Dimensions.width20),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.85,
                color: context.colors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(
                  fontSize: Dimensions.font16 * 0.85,
                  color: context.colors.textTertiary,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: context.colors.textSecondary,
                ),
                filled: true,
                fillColor: context.colors.surfaceLight,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width15,
                  vertical: Dimensions.height10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radius15 / 2),
                  borderSide: BorderSide(color: context.colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radius15 / 2),
                  borderSide: BorderSide(color: context.colors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radius15 / 2),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
          ),

          // Currency List / states
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_currencies.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: Dimensions.iconSize24 * 1.6,
              color: context.colors.textTertiary,
            ),
            SizedBox(height: Dimensions.height10),
            Text(
              'No currencies found',
              style: TextStyle(
                fontSize: Dimensions.font16 * 0.9,
                color: context.colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
      itemCount: _currencies.length,
      itemBuilder: (context, index) {
        final currency = _currencies[index];
        final isSelected = currency.label == widget.selectedCurrency;

        return GestureDetector(
          onTap: () {
            widget.onCurrencySelected(currency.label);
            Navigator.pop(context);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: Dimensions.height10),
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width15,
              vertical: Dimensions.height15,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.05)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(Dimensions.radius15),
              border: Border.all(
                color: isSelected ? AppColors.primary : context.colors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currency.label,
                  style: TextStyle(
                    fontSize: Dimensions.font16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primary
                        : context.colors.textPrimary,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                    size: Dimensions.iconSize24,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
