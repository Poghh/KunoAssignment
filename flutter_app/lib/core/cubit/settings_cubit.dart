import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_network_constants.dart';

enum AppLanguage {
  englishUs,
  vietnameseVn,
}

enum AppCurrency {
  usd,
  vnd,
}

extension AppCurrencyX on AppCurrency {
  String get code {
    switch (this) {
      case AppCurrency.usd:
        return 'USD';
      case AppCurrency.vnd:
        return 'VND';
    }
  }

  String get symbol {
    switch (this) {
      case AppCurrency.usd:
        return '\$';
      case AppCurrency.vnd:
        return '₫';
    }
  }

  int get decimalDigits {
    switch (this) {
      case AppCurrency.usd:
        return 2;
      case AppCurrency.vnd:
        return 0;
    }
  }
}

class SettingsState extends Equatable {
  const SettingsState({
    this.language = AppLanguage.englishUs,
    this.currency = AppCurrency.usd,
    this.themeMode = ThemeMode.light,
    this.hasCompletedSetup = false,
  });

  final AppLanguage language;
  final AppCurrency currency;
  final ThemeMode themeMode;
  final bool hasCompletedSetup;

  String get localeCode {
    switch (language) {
      case AppLanguage.englishUs:
        return 'en_US';
      case AppLanguage.vietnameseVn:
        return 'vi_VN';
    }
  }

  Locale get locale {
    switch (language) {
      case AppLanguage.englishUs:
        return const Locale('en', 'US');
      case AppLanguage.vietnameseVn:
        return const Locale('vi', 'VN');
    }
  }

  SettingsState copyWith({
    AppLanguage? language,
    AppCurrency? currency,
    ThemeMode? themeMode,
    bool? hasCompletedSetup,
  }) {
    return SettingsState(
      language: language ?? this.language,
      currency: currency ?? this.currency,
      themeMode: themeMode ?? this.themeMode,
      hasCompletedSetup: hasCompletedSetup ?? this.hasCompletedSetup,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        language,
        currency,
        themeMode,
        hasCompletedSetup,
      ];
}

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  Future<void> loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? languageRaw = prefs.getString(AppStorageKeys.appLanguage);
    final String? currencyRaw = prefs.getString(AppStorageKeys.appCurrency);
    final String? themeRaw = prefs.getString(AppStorageKeys.appThemeMode);
    final bool hasCompletedSetup =
        prefs.getBool(AppStorageKeys.appSetupCompleted) ?? false;
    final AppLanguage language = _parseLanguage(languageRaw);
    final AppCurrency currency = _parseCurrency(
      currencyRaw,
      fallbackLanguage: language,
    );

    emit(
      state.copyWith(
        language: language,
        currency: currency,
        themeMode: _parseThemeMode(themeRaw),
        hasCompletedSetup: hasCompletedSetup,
      ),
    );
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (state.language == language) {
      return;
    }

    emit(state.copyWith(language: language));

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppStorageKeys.appLanguage, language.name);
  }

  Future<void> setCurrency(AppCurrency currency) async {
    if (state.currency == currency) {
      return;
    }

    emit(state.copyWith(currency: currency));
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppStorageKeys.appCurrency, currency.name);
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (state.themeMode == themeMode) {
      return;
    }

    emit(state.copyWith(themeMode: themeMode));
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppStorageKeys.appThemeMode, themeMode.name);
  }

  Future<void> completeSetup({
    required AppLanguage language,
    required AppCurrency currency,
    required ThemeMode themeMode,
  }) async {
    emit(
      state.copyWith(
        language: language,
        currency: currency,
        themeMode: themeMode,
        hasCompletedSetup: true,
      ),
    );

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppStorageKeys.appLanguage, language.name);
    await prefs.setString(AppStorageKeys.appCurrency, currency.name);
    await prefs.setString(AppStorageKeys.appThemeMode, themeMode.name);
    await prefs.setBool(AppStorageKeys.appSetupCompleted, true);
  }

  AppLanguage _parseLanguage(String? raw) {
    for (final AppLanguage language in AppLanguage.values) {
      if (language.name == raw) {
        return language;
      }
    }
    return AppLanguage.englishUs;
  }

  AppCurrency _parseCurrency(
    String? raw, {
    required AppLanguage fallbackLanguage,
  }) {
    for (final AppCurrency currency in AppCurrency.values) {
      if (currency.name == raw) {
        return currency;
      }
    }
    return _defaultCurrencyFor(fallbackLanguage);
  }

  AppCurrency _defaultCurrencyFor(AppLanguage language) {
    switch (language) {
      case AppLanguage.englishUs:
        return AppCurrency.usd;
      case AppLanguage.vietnameseVn:
        return AppCurrency.vnd;
    }
  }

  ThemeMode _parseThemeMode(String? raw) {
    for (final ThemeMode mode in ThemeMode.values) {
      if (mode.name == raw) {
        return mode;
      }
    }
    return ThemeMode.light;
  }
}
