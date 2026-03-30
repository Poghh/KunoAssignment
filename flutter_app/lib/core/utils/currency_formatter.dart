import 'package:intl/intl.dart';

import '../services/exchange_rate_service.dart';
import '../../features/expense/domain/entities/expense.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String _localeCode = 'en_US';
  static String _currencyCode = 'USD';
  static final Map<String, NumberFormat> _cache = <String, NumberFormat>{};
  static final Map<String, NumberFormat> _compactCache =
      <String, NumberFormat>{};

  static String get currencyCode => _currencyCode;

  static void configure({
    required String localeCode,
    required String currencyCode,
  }) {
    if (_localeCode == localeCode && _currencyCode == currencyCode) {
      return;
    }
    _localeCode = localeCode;
    _currencyCode = currencyCode;
    _cache.clear();
    _compactCache.clear();
  }

  static String format(num value) {
    final String cacheKey = '$_localeCode|$_currencyCode';
    final double converted = convertFromBase(value);
    final NumberFormat formatter = _cache.putIfAbsent(
        cacheKey, () => _resolveFormatter(_localeCode, _currencyCode));
    return formatter.format(converted);
  }

  /// Formats [value] that is already in the display currency — no base
  /// conversion applied.  Use this with [Expense.displayAmount] to avoid
  /// floating-point precision loss.
  static String formatValue(num value) {
    final String cacheKey = '$_localeCode|$_currencyCode';
    final NumberFormat formatter = _cache.putIfAbsent(
        cacheKey, () => _resolveFormatter(_localeCode, _currencyCode));
    return formatter.format(value);
  }

  /// Compact-formats [value] that is already in the display currency — no base
  /// conversion applied.  Use this with [Expense.displayAmount].
  static String formatCompactValue(num value) {
    final String cacheKey = 'compact|$_localeCode|$_currencyCode';
    final NumberFormat formatter = _compactCache.putIfAbsent(
      cacheKey,
      () => NumberFormat.compactCurrency(
        locale: _currencyCode == 'VND' ? 'vi_VN' : _localeCode,
        symbol: _resolveSymbol(_currencyCode),
        decimalDigits: _resolveDecimalDigits(_currencyCode),
      ),
    );
    return formatter.format(value);
  }

  static String formatCompact(num value) {
    final String cacheKey = 'compact|$_localeCode|$_currencyCode';
    final double converted = convertFromBase(value);
    final NumberFormat formatter = _compactCache.putIfAbsent(
      cacheKey,
      () => NumberFormat.compactCurrency(
        locale: _currencyCode == 'VND' ? 'vi_VN' : _localeCode,
        symbol: _resolveSymbol(_currencyCode),
        decimalDigits: _resolveDecimalDigits(_currencyCode),
      ),
    );
    return formatter.format(converted);
  }

  static double convertFromBase(num baseValue, {String? targetCurrencyCode}) {
    final String target = (targetCurrencyCode ?? _currencyCode).toUpperCase();
    switch (target) {
      case 'VND':
        final double raw = baseValue * ExchangeRateService.currentUsdToVnd;
        return _roundVnd(raw);
      case 'USD':
      default:
        return baseValue.toDouble();
    }
  }

  /// Returns the expense amount already in the active display currency.
  /// - Same currency as display → use exact [Expense.displayAmount] (no precision loss).
  /// - Different currency → convert [Expense.amount] (USD base) to display currency.
  static double effectiveAmount(Expense expense) {
    final bool same =
        expense.currencyCode.toUpperCase() == _currencyCode.toUpperCase();
    return same ? expense.displayAmount : convertFromBase(expense.amount);
  }

  static double convertToBase(num value, {required String sourceCurrencyCode}) {
    final String source = sourceCurrencyCode.toUpperCase();
    switch (source) {
      case 'VND':
        return value / ExchangeRateService.currentUsdToVnd;
      case 'USD':
      default:
        return value.toDouble();
    }
  }

  /// Rounds VND to the nearest 1,000 — no small change in Vietnamese dong.
  static double _roundVnd(double value) {
    return (value / 1000).round() * 1000.0;
  }

  static NumberFormat _resolveFormatter(
      String localeCode, String currencyCode) {
    switch (currencyCode) {
      case 'VND':
        // Always use Vietnamese locale for VND so the thousands separator is a
        // dot (500.000 ₫) regardless of the UI language setting.
        return NumberFormat.currency(
          locale: 'vi_VN',
          symbol: '₫',
          decimalDigits: 0,
        );
      case 'USD':
      default:
        return NumberFormat.currency(
          locale: localeCode,
          symbol: _resolveSymbol(currencyCode),
          decimalDigits: _resolveDecimalDigits(currencyCode),
        );
    }
  }

  static String _resolveSymbol(String currencyCode) {
    switch (currencyCode) {
      case 'VND':
        return '₫';
      case 'USD':
      default:
        return '\$';
    }
  }

  static int _resolveDecimalDigits(String currencyCode) {
    switch (currencyCode) {
      case 'VND':
        return 0;
      case 'USD':
      default:
        return 2;
    }
  }
}
