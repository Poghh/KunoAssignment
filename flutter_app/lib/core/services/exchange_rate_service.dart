import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExchangeRateService {
  ExchangeRateService._();

  // Free tier — no API key required, 1,500 req/month
  static const String _apiUrl = 'https://open.er-api.com/v6/latest/USD';
  static const Duration _cacheDuration = Duration(hours: 24);
  static const double _fallbackUsdToVnd = 26335;

  static const String _prefKeyRate = 'exchange_rate.usd_vnd';
  static const String _prefKeyTimestamp = 'exchange_rate.usd_vnd_ts';

  static double _currentRate = _fallbackUsdToVnd;

  /// Whether the rate is from a stale cache or the hardcoded fallback.
  static bool isStale = false;

  static double get currentUsdToVnd => _currentRate;

  /// Must be called once at app startup (before [CurrencyFormatter] is used).
  static Future<void> initialize(SharedPreferences prefs) async {
    final double? cachedRate = prefs.getDouble(_prefKeyRate);
    final int? cachedTs = prefs.getInt(_prefKeyTimestamp);

    if (cachedRate != null && cachedTs != null) {
      _currentRate = cachedRate;
      final DateTime cachedAt = DateTime.fromMillisecondsSinceEpoch(cachedTs);
      final bool isFresh = DateTime.now().difference(cachedAt) < _cacheDuration;
      if (isFresh) {
        isStale = false;
        return; // Fresh cache — no network needed.
      }
      // Stale cache: keep value while we try to refresh.
      isStale = true;
    }

    // Fetch live rate; on failure keep existing value (cached or fallback).
    try {
      await _fetchAndCache(prefs);
      isStale = false;
    } catch (_) {
      if (cachedRate == null) {
        // No cache at all — use hardcoded fallback.
        _currentRate = _fallbackUsdToVnd;
        isStale = true;
      }
      // Otherwise: keep the stale cached value, isStale stays true.
    }
  }

  static Future<void> _fetchAndCache(SharedPreferences prefs) async {
    final Dio dio = Dio();
    final Response<Map<String, dynamic>> response =
        await dio.get<Map<String, dynamic>>(
      _apiUrl,
      options: Options(receiveTimeout: const Duration(seconds: 10)),
    );

    final Map<String, dynamic>? data = response.data;
    if (data == null || response.statusCode != 200) {
      throw Exception('Exchange rate API returned unexpected response');
    }

    final Map<String, dynamic> rates =
        data['rates'] as Map<String, dynamic>;
    final double vndRate = (rates['VND'] as num).toDouble();

    _currentRate = vndRate;
    await prefs.setDouble(_prefKeyRate, vndRate);
    await prefs.setInt(
      _prefKeyTimestamp,
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}
