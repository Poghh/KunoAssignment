import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/cubit/settings_cubit.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_toast.dart';

class SetupPreferencesPage extends StatefulWidget {
  const SetupPreferencesPage({super.key});

  @override
  State<SetupPreferencesPage> createState() => _SetupPreferencesPageState();
}

class _SetupPreferencesPageState extends State<SetupPreferencesPage> {
  static const String _logoAssetPath = 'assets/images/app-logo.png';

  AppLanguage _selectedLanguage = AppLanguage.englishUs;
  AppCurrency _selectedCurrency = AppCurrency.usd;
  ThemeMode _selectedThemeMode = ThemeMode.light;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final SettingsState state = context.read<SettingsCubit>().state;
    _selectedLanguage = state.language;
    _selectedCurrency = state.currency;
    _selectedThemeMode = state.themeMode;
  }

  Future<void> _continue() async {
    if (_submitting) {
      return;
    }

    setState(() {
      _submitting = true;
    });

    await context.read<SettingsCubit>().completeSetup(
          language: _selectedLanguage,
          currency: _selectedCurrency,
          themeMode: _selectedThemeMode,
        );

    if (!mounted) {
      return;
    }

    setState(() {
      _submitting = false;
    });
    AppToast.success(context.l10n.setupSaved);
  }

  void _onLanguageChanged(AppLanguage language) {
    setState(() {
      _selectedLanguage = language;
    });
    context.read<SettingsCubit>().setLanguage(language);
  }

  void _onCurrencyChanged(AppCurrency currency) {
    setState(() {
      _selectedCurrency = currency;
    });
  }

  void _onThemeChanged(ThemeMode mode) {
    setState(() {
      _selectedThemeMode = mode;
    });
    context.read<SettingsCubit>().setThemeMode(mode);
  }

  String _languageLabel(BuildContext context, AppLanguage language) {
    switch (language) {
      case AppLanguage.englishUs:
        return context.l10n.languageEnglishUsd;
      case AppLanguage.vietnameseVn:
        return context.l10n.languageVietnameseVnd;
    }
  }

  String _languageFlag(AppLanguage language) {
    switch (language) {
      case AppLanguage.englishUs:
        return '🇬🇧';
      case AppLanguage.vietnameseVn:
        return '🇻🇳';
    }
  }

  Widget _buildBrandHeader(BuildContext context, bool isDark) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color subtitleColor =
        isDark ? _SetupColors.subtitleDark : _SetupColors.subtitleLight;

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset(
              _logoAssetPath,
              width: _SetupMetrics.logoSize,
              height: _SetupMetrics.logoSize,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) {
                return const Icon(
                  Icons.trending_up_rounded,
                  size: _SetupMetrics.logoFallbackSize,
                  color: AppTheme.primary,
                );
              },
            ),
            const SizedBox(width: AppSpacing.sm + AppSpacing.xxs),
            Text(
              context.l10n.appTitle,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: _SetupMetrics.brandTitleFontSize,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
        Text(
          context.l10n.setupSubtitle,
          style: textTheme.titleMedium?.copyWith(
            color: subtitleColor,
            fontSize: _SetupMetrics.subtitleFontSize,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLanguageField(BuildContext context, bool isDark) {
    final Color borderColor =
        isDark ? _SetupColors.fieldBorderDark : _SetupColors.fieldBorderLight;
    final Color fieldColor = isDark
        ? _SetupColors.fieldBackgroundDark
        : _SetupColors.fieldBackgroundLight;
    final Color textColor = isDark ? Colors.white : _SetupColors.bodyTextLight;

    return Container(
      width: _SetupMetrics.controlWidth,
      height: _SetupMetrics.languageControlHeight,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + AppSpacing.xxs),
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AppLanguage>(
          value: _selectedLanguage,
          isExpanded: true,
          borderRadius: BorderRadius.circular(AppRadius.md),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color:
                isDark ? _SetupColors.subtitleDark : _SetupColors.subtitleLight,
          ),
          items: AppLanguage.values
              .map(
                (AppLanguage language) => DropdownMenuItem<AppLanguage>(
                  value: language,
                  child: Row(
                    children: <Widget>[
                      Text(
                        _languageFlag(language),
                        style: const TextStyle(
                            fontSize: _SetupMetrics.flagFontSize),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          _languageLabel(context, language),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(growable: false),
          style: TextStyle(
            color: textColor,
            fontSize: _SetupMetrics.controlTextSize,
            fontWeight: FontWeight.w600,
          ),
          onChanged: (AppLanguage? value) {
            if (value == null) {
              return;
            }
            _onLanguageChanged(value);
          },
        ),
      ),
    );
  }

  Widget _buildCurrencyField(bool isDark) {
    final Color borderColor =
        isDark ? _SetupColors.fieldBorderDark : _SetupColors.fieldBorderLight;
    final Color fieldColor = isDark
        ? _SetupColors.fieldBackgroundDark
        : _SetupColors.fieldBackgroundLight;

    return Container(
      width: _SetupMetrics.controlWidth,
      height: _SetupMetrics.currencyControlHeight,
      padding: const EdgeInsets.all(AppSpacing.xxs),
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: <Widget>[
          _CurrencyOption(
            label: AppCurrency.vnd.code,
            selected: _selectedCurrency == AppCurrency.vnd,
            onTap: () => _onCurrencyChanged(AppCurrency.vnd),
            isDark: isDark,
          ),
          _CurrencyOption(
            label: AppCurrency.usd.code,
            selected: _selectedCurrency == AppCurrency.usd,
            onTap: () => _onCurrencyChanged(AppCurrency.usd),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSwitch(bool isDark) {
    final bool isDarkSelected = _selectedThemeMode == ThemeMode.dark;
    final Color borderColor =
        isDark ? _SetupColors.fieldBorderDark : _SetupColors.fieldBorderLight;
    final Color trackColor = isDarkSelected
        ? _SetupColors.themeTrackSelected
        : (isDark
            ? _SetupColors.fieldBackgroundDark
            : _SetupColors.themeTrackLight);

    return GestureDetector(
      onTap: () => _onThemeChanged(
        isDarkSelected ? ThemeMode.light : ThemeMode.dark,
      ),
      child: Container(
        width: _SetupMetrics.themeSwitchWidth,
        height: _SetupMetrics.themeSwitchHeight,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm - AppSpacing.xxs,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(AppRadius.xxl),
          border: Border.all(color: borderColor),
        ),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding:
                    const EdgeInsets.only(left: AppSpacing.sm + AppSpacing.xxs),
                child: Icon(
                  Icons.light_mode_rounded,
                  size: _SetupMetrics.themeIconSize,
                  color: isDarkSelected
                      ? _SetupColors.themeSunDark
                      : AppTheme.warningOrange,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(
                    right: AppSpacing.sm + AppSpacing.xxs),
                child: Icon(
                  Icons.nightlight_round,
                  size: _SetupMetrics.themeIconSize,
                  color: isDarkSelected
                      ? _SetupColors.themeMoonDark
                      : _SetupColors.subtitleLight,
                ),
              ),
            ),
            AnimatedAlign(
              duration: AppDurationMs.fast,
              curve: Curves.easeOut,
              alignment:
                  isDarkSelected ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: _SetupMetrics.themeThumbWidth,
                height: _SetupMetrics.themeThumbHeight,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black
                          .withValues(alpha: _SetupMetrics.thumbShadowOpacity),
                      blurRadius: _SetupMetrics.thumbShadowBlur,
                      offset: const Offset(0, _SetupMetrics.thumbShadowOffsetY),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(
    BuildContext context, {
    required String label,
    required Widget control,
    bool showDivider = true,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color labelColor =
        isDark ? _SetupColors.subtitleDark : _SetupColors.bodyTextLight;
    final Color dividerColor =
        isDark ? AppTheme.dividerSubtle : _SetupColors.dividerLight;

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: _SetupMetrics.rowLabelSize,
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),
            ),
            control,
          ],
        ),
        if (showDivider) ...<Widget>[
          const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
          Divider(height: 1, color: dividerColor),
          const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
        ],
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Center(
      child: Opacity(
        opacity: _submitting ? 0.75 : 1,
        child: SizedBox(
          width: _SetupMetrics.continueButtonWidth,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  _SetupColors.continueGradientTop,
                  _SetupColors.continueGradientBottom,
                ],
              ),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: _SetupColors.continueGradientBottom
                      .withValues(alpha: 0.32),
                  blurRadius: _SetupMetrics.continueShadowBlur,
                  offset: const Offset(0, _SetupMetrics.continueShadowOffsetY),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                onTap: _submitting ? null : _continue,
                child: SizedBox(
                  height: _SetupMetrics.continueButtonHeight,
                  child: Center(
                    child: _submitting
                        ? const SizedBox(
                            width: AppSize.loadingIndicator,
                            height: AppSize.loadingIndicator,
                            child: CircularProgressIndicator(
                              strokeWidth: AppSize.loadingStroke,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            context.l10n.setupContinueButton,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: _SetupMetrics.continueButtonFontSize,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color backgroundColor =
        isDark ? AppTheme.darkBackground : AppTheme.background;
    final Color cardColor = isDark ? AppTheme.darkCardBackground : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: _SetupMetrics.pagePadding,
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: _SetupMetrics.maxContentWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildBrandHeader(context, isDark),
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding:
                        const EdgeInsets.all(_SetupMetrics.settingsCardPadding),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.black.withValues(
                              alpha: _SetupMetrics.cardShadowOpacity),
                          blurRadius: _SetupMetrics.cardShadowBlur,
                          offset:
                              const Offset(0, _SetupMetrics.cardShadowOffsetY),
                        ),
                      ],
                    ),
                    child: Column(
                      children: <Widget>[
                        _buildSettingRow(
                          context,
                          label: context.l10n.setupLanguageLabel,
                          control: _buildLanguageField(context, isDark),
                        ),
                        _buildSettingRow(
                          context,
                          label: context.l10n.setupCurrencyLabel,
                          control: _buildCurrencyField(isDark),
                        ),
                        _buildSettingRow(
                          context,
                          label: context.l10n.setupThemeLabel,
                          control: _buildThemeSwitch(isDark),
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: _SetupMetrics.continueTopSpacing),
                  _buildContinueButton(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CurrencyOption extends StatelessWidget {
  const _CurrencyOption({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;
    final Color selectedColor = _SetupColors.continueGradientTop;
    final Color textColor = selected
        ? Colors.white
        : isDisabled
            ? (isDark
                ? AppTheme.darkTextDisabled
                : _SetupColors.disabledTextLight)
            : (isDark
                ? _SetupColors.themeMoonDark
                : _SetupColors.subtitleLight);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppDurationMs.fast,
          height: _SetupMetrics.currencyOptionHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.sm),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: _SetupMetrics.currencyOptionFontSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupColors {
  const _SetupColors._();

  static const Color subtitleDark = AppTheme.darkTextSecondary;
  static const Color subtitleLight = Color(0xFF6B7280);
  static const Color bodyTextLight = Color(0xFF374151);
  static const Color disabledTextLight = Color(0xFF9CA3AF);

  static const Color fieldBorderDark = AppTheme.darkInputBorder;
  static const Color fieldBorderLight = Color(0xFFD6DCE5);
  static const Color fieldBackgroundDark = AppTheme.darkInputBackground;
  static const Color fieldBackgroundLight = Color(0xFFF8FAFD);
  static const Color dividerLight = Color(0xFFE5E7EB);

  static const Color themeTrackSelected = Color(0xFF374151);
  static const Color themeTrackLight = Color(0xFFF3F4F6);
  static const Color themeSunDark = Color(0xFFD1D5DB);
  static const Color themeMoonDark = Color(0xFFE5E7EB);

  static const Color continueGradientTop = Color(0xFF4CC463);
  static const Color continueGradientBottom = Color(0xFF2AA35D);
}

class _SetupMetrics {
  const _SetupMetrics._();

  static const double logoSize = 46;
  static const double logoFallbackSize = 38;
  static const double brandTitleFontSize = 17;
  static const double subtitleFontSize = 12.5;
  static const double flagFontSize = 16;

  static const double controlWidth = 170;
  static const double languageControlHeight = 38;
  static const double currencyControlHeight = 36;
  static const double controlTextSize = 14;

  static const double themeSwitchWidth = 90;
  static const double themeSwitchHeight = 36;
  static const double themeIconSize = 16;
  static const double themeThumbWidth = 28;
  static const double themeThumbHeight = 24;
  static const double thumbShadowOpacity = 0.14;
  static const double thumbShadowBlur = 6;
  static const double thumbShadowOffsetY = 2;

  static const double rowLabelSize = 16;
  static const double maxContentWidth = 330;
  static const EdgeInsets pagePadding = EdgeInsets.fromLTRB(24, 18, 24, 24);
  static const double settingsCardPadding = 14;
  static const double cardShadowOpacity = 0.08;
  static const double cardShadowBlur = 18;
  static const double cardShadowOffsetY = 10;

  static const double continueTopSpacing = 32;
  static const double continueButtonWidth = 210;
  static const double continueButtonHeight = 48;
  static const double continueButtonFontSize = 14;
  static const double continueShadowBlur = 10;
  static const double continueShadowOffsetY = 5;

  static const double currencyOptionHeight = 30;
  static const double currencyOptionFontSize = 13;
}
