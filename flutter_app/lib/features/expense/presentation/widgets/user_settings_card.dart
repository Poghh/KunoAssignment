import 'package:flutter/material.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/cubit/settings_cubit.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/widgets/app_surface_card.dart';

class UserSettingsCard extends StatelessWidget {
  const UserSettingsCard({
    required this.settings,
    required this.onLanguageChanged,
    required this.onCurrencyChanged,
    required this.onDarkModeChanged,
    super.key,
  });

  final SettingsState settings;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final ValueChanged<AppCurrency> onCurrencyChanged;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.lg - AppSpacing.xxs),
      radius: AppRadius.xl,
      outlined: false,
      child: Column(
        children: <Widget>[
          DropdownButtonFormField<AppLanguage>(
            value: settings.language,
            decoration: InputDecoration(
              labelText: context.l10n.languageLabel,
              prefixIcon: const Icon(Icons.language_rounded),
            ),
            items: <DropdownMenuItem<AppLanguage>>[
              DropdownMenuItem<AppLanguage>(
                value: AppLanguage.englishUs,
                child: Text(context.l10n.languageEnglishUsd),
              ),
              DropdownMenuItem<AppLanguage>(
                value: AppLanguage.vietnameseVn,
                child: Text(context.l10n.languageVietnameseVnd),
              ),
            ],
            onChanged: (AppLanguage? value) {
              if (value != null) onLanguageChanged(value);
            },
          ),
          const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
          DropdownButtonFormField<AppCurrency>(
            value: settings.currency,
            decoration: InputDecoration(
              labelText: context.l10n.currencyUnitLabel,
              prefixIcon: const Icon(Icons.attach_money_rounded),
            ),
            items: <DropdownMenuItem<AppCurrency>>[
              DropdownMenuItem<AppCurrency>(
                value: AppCurrency.usd,
                child: Text(context.l10n.currencyUnitUsd),
              ),
              DropdownMenuItem<AppCurrency>(
                value: AppCurrency.vnd,
                child: Text(context.l10n.currencyUnitVnd),
              ),
            ],
            onChanged: (AppCurrency? value) {
              if (value != null) onCurrencyChanged(value);
            },
          ),
          const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: settings.themeMode == ThemeMode.dark,
            onChanged: onDarkModeChanged,
            title: Text(context.l10n.darkModeTitle),
            subtitle: Text(context.l10n.darkModeSubtitle),
          ),
        ],
      ),
    );
  }
}
