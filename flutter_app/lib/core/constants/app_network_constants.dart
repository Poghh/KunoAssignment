import 'package:flutter/foundation.dart';

class AppStorageKeys {
  const AppStorageKeys._();

  static const String sessionLoggedIn = 'session.logged_in';
  static const String sessionUsername = 'session.username';
  static const String sessionDisplayName = 'session.display_name';

  static const String appLanguage = 'app.language';
  static const String appCurrency = 'app.currency';
  static const String appThemeMode = 'app.theme_mode';
  static const String appSetupCompleted = 'app.setup_completed';
}

class AppApiTimeout {
  const AppApiTimeout._();

  static const Duration connect = Duration(seconds: 12);
  static const Duration send = Duration(seconds: 12);
  static const Duration receive = Duration(seconds: 12);
}

class AppApiHeader {
  const AppApiHeader._();

  static const String accept = 'Accept';
  static const String username = 'x-username';
}

class AppApiHeaderValue {
  const AppApiHeaderValue._();

  static const String json = 'application/json';
}

class AppApiPath {
  const AppApiPath._();

  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authProfileDisplayName = '/auth/profile/display-name';

  static const String expenses = '/expenses';
  static const String categories = '/categories';
  static const String insightsMonthly = '/insights/monthly';
  static const String insightsCategory = '/insights/category';
  static const String insightsDailyAverage = '/insights/daily-average';
  static const String insightsTopDay = '/insights/top-day';

  static String expenseById(String expenseId) => '$expenses/$expenseId';
  static String categoryById(String categoryId) => '$categories/$categoryId';
}

class AppApiResponseKey {
  const AppApiResponseKey._();

  static const String data = 'data';
  static const String message = 'message';
  static const String username = 'username';
  static const String displayName = 'displayName';
}

class AppApiErrorMessage {
  const AppApiErrorMessage._();

  static const String timeout = 'Request timeout. Please try again.';
  static const String connectionError =
      'Unable to connect to server. Please check your network.';
  static const String cancelled = 'Request cancelled.';
  static const String serverError = 'Server error';
  static const String unauthorized = 'Unauthorized request.';
  static const String forbidden = 'Forbidden request.';
  static const String notFound = 'Resource not found.';
  static const String invalidRequest = 'Invalid request data.';
  static const String requestFailed = 'Request failed';
  static const String unexpectedNetworkError = 'Unexpected network error.';
  static const String unknown = 'Something went wrong. Please try again.';
}

class AppApiBaseUrl {
  const AppApiBaseUrl._();

  static const String web = 'http://localhost:3000';
  static const String androidEmulator = 'http://10.0.2.2:3000';
  static const String local = 'http://localhost:3000';

  static String resolve() {
    if (kIsWeb) {
      return web;
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return androidEmulator;
    }

    return local;
  }
}
