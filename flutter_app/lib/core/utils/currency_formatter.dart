import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static String _localeCode = 'en_US';
  static String _currencyCode = 'USD';
  static final Map<String, NumberFormat> _cache = <String, NumberFormat>{};
  static final Map<String, NumberFormat> _compactCache =
      <String, NumberFormat>{};

  static const double _usdToVnd = 25500;

  static void configure({
    required String localeCode,
    required String currencyCode,
  }) {
    if (_localeCode == localeCode && _currencyCode == currencyCode) {
      return;
    }
    _localeCode = localeCode;
    _currencyCode = currencyCode;
  }

  static String format(num value) {
    final String cacheKey = '$_localeCode|$_currencyCode';
    final double converted = convertFromBase(value);
    final NumberFormat formatter = _cache.putIfAbsent(
        cacheKey, () => _resolveFormatter(_localeCode, _currencyCode));
    return formatter.format(converted);
  }

  static String formatCompact(num value) {
    final String cacheKey = 'compact|$_localeCode|$_currencyCode';
    final double converted = convertFromBase(value);
    final NumberFormat formatter = _compactCache.putIfAbsent(
      cacheKey,
      () => NumberFormat.compactCurrency(
        locale: _localeCode,
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
        return baseValue * _usdToVnd;
      case 'USD':
      default:
        return baseValue.toDouble();
    }
  }

  static double convertToBase(num value, {required String sourceCurrencyCode}) {
    final String source = sourceCurrencyCode.toUpperCase();
    switch (source) {
      case 'VND':
        return value / _usdToVnd;
      case 'USD':
      default:
        return value.toDouble();
    }
  }

  static NumberFormat _resolveFormatter(
      String localeCode, String currencyCode) {
    switch (currencyCode) {
      case 'VND':
        return NumberFormat.currency(
          locale: localeCode,
          symbol: _resolveSymbol(currencyCode),
          decimalDigits: _resolveDecimalDigits(currencyCode),
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
