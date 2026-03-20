import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/cubit/auth_cubit.dart';
import '../../../../core/cubit/settings_cubit.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/expense.dart';
import '../cubit/category_management_cubit.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../cubit/expense_list_cubit.dart';
import 'category_management_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final SettingsState settings = context.watch<SettingsCubit>().state;
    final AuthState auth = context.watch<AuthCubit>().state;

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (BuildContext context, DashboardState state) {
        final _MonthSummary summary = _buildMonthSummary(state, settings);
        final String currentUsername = auth.username?.trim() ?? '';
        final String currentDisplayName = auth.displayName?.trim() ?? '';
        final String profileDisplayName = currentDisplayName.isEmpty
            ? (currentUsername.isEmpty
                ? context.l10n.userDefaultDisplayName
                : currentUsername)
            : currentDisplayName;

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            110,
          ),
          children: <Widget>[
            Text(
              context.l10n.userTitle,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (auth.status == AuthStatus.guest) ...<Widget>[
              const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.account_circle_outlined,
                        size: 18, color: AppTheme.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        context.l10n.guestModeBanner,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: _UserMetrics.headerSpacing),
            _ProfileCard(
              displayName: profileDisplayName,
              account: currentUsername.isEmpty
                  ? context.l10n.userDefaultDisplayName
                  : currentUsername,
              onEdit: () => _showEditProfileSheet(
                currentUsername: currentUsername,
                currentDisplayName: currentDisplayName,
              ),
            ),
            const SizedBox(height: AppSpacing.md + AppSpacing.xxs),
            AppSectionHeader(
              title: context.l10n.monthlySummaryTitle,
              subtitle: context.l10n.monthlySummarySubtitle,
            ),
            const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
            _MonthSummaryCard(summary: summary),
            const SizedBox(height: AppSpacing.md + AppSpacing.xxs),
            AppSectionHeader(
              title: context.l10n.categoryManagementTitle,
              subtitle: context.l10n.categoryManagementSubtitle,
            ),
            const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
            _CategoryManagementCard(
              onTap: _openCategoryManagementPage,
            ),
            const SizedBox(height: AppSpacing.md + AppSpacing.xxs),
            AppSectionHeader(
              title: context.l10n.settingsTitle,
              subtitle: context.l10n.settingsSubtitle,
            ),
            const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
            _SettingsCard(
              settings: settings,
              onLanguageChanged: (AppLanguage language) async {
                final String toastMessage = context.l10n.languageUpdated;
                await context.read<SettingsCubit>().setLanguage(language);
                if (!mounted) {
                  return;
                }
                AppToast.info(toastMessage);
              },
              onCurrencyChanged: (AppCurrency currency) async {
                final String toastMessage = context.l10n.currencyUnitUpdated;
                await context.read<SettingsCubit>().setCurrency(currency);
                if (!mounted) {
                  return;
                }
                AppToast.info(toastMessage);
              },
              onDarkModeChanged: (bool isDark) async {
                final String toastMessage = isDark
                    ? context.l10n.darkModeEnabled
                    : context.l10n.lightModeEnabled;
                await context
                    .read<SettingsCubit>()
                    .setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
                if (!mounted) {
                  return;
                }
                AppToast.info(toastMessage);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            if (auth.status == AuthStatus.guest)
              FilledButton.icon(
                onPressed: _handleLoginToSync,
                icon: const Icon(Icons.sync_rounded),
                style: FilledButton.styleFrom(
                  minimumSize:
                      const Size.fromHeight(_UserMetrics.logoutButtonHeight),
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
                label: Text(context.l10n.loginToSyncButton),
              )
            else
              FilledButton.tonalIcon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout_rounded),
                style: FilledButton.styleFrom(
                  minimumSize:
                      const Size.fromHeight(_UserMetrics.logoutButtonHeight),
                ),
                label: Text(context.l10n.logoutButton),
              ),
            const SizedBox(height: AppSpacing.md),
            if (state.status == DashboardStatus.loading)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Center(
                  child: Text(
                    context.l10n.syncingData,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  _MonthSummary _buildMonthSummary(
    DashboardState state,
    SettingsState settings,
  ) {
    final DateTime now = DateTime.now();
    final String monthLabel = state.insights?.monthly.month ??
        DateFormat('MMMM yyyy', settings.localeCode).format(now);

    final double totalThisMonth =
        state.insights?.monthly.totalThisMonth ?? _fallbackMonthExpense(state);
    final double dailyAverage = state.insights?.dailyAverage.dailyAverage ??
        _fallbackDailyAverage(state);

    return _MonthSummary(
      monthLabel: monthLabel,
      totalThisMonth: totalThisMonth,
      dailyAverage: dailyAverage,
    );
  }

  double _fallbackMonthExpense(DashboardState state) {
    final DateTime now = DateTime.now();
    double total = 0;
    for (final Expense expense in state.allExpenses) {
      final bool inCurrentMonth =
          expense.date.year == now.year && expense.date.month == now.month;
      if (inCurrentMonth && expense.amount > 0) {
        total += expense.displayAmount;
      }
    }
    return total;
  }

  double _fallbackDailyAverage(DashboardState state) {
    final DateTime now = DateTime.now();
    final double total = _fallbackMonthExpense(state);
    final int elapsedDays = now.day.clamp(1, 31);
    return total / elapsedDays;
  }

  Future<void> _showEditProfileSheet({
    required String currentUsername,
    required String currentDisplayName,
  }) async {
    final String profileUpdatedMessage = context.l10n.profileUpdated;
    final AuthCubit sessionCubit = context.read<AuthCubit>();
    final String initialDisplayName =
        currentDisplayName.isEmpty ? currentUsername : currentDisplayName;
    final TextEditingController nameController =
        TextEditingController(text: initialDisplayName);

    final bool? saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final ColorScheme colorScheme = Theme.of(context).colorScheme;
        final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;

        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.48,
          minChildSize: 0.38,
          maxChildSize: 0.76,
          builder: (
            BuildContext context,
            ScrollController scrollController,
          ) {
            return ListView(
              controller: scrollController,
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                bottomInset + AppSpacing.lg,
              ),
              children: <Widget>[
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  context.l10n.editProfileTitle,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  controller: nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: context.l10n.displayNameLabel,
                    hintText: context.l10n.userDefaultDisplayName,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  initialValue: currentUsername,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.registerUsernameLabel,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Text(context.l10n.saveProfileButton),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved == true) {
      final String updatedDisplayName = nameController.text.trim().isEmpty
          ? initialDisplayName
          : nameController.text.trim();
      final bool success =
          await sessionCubit.setDisplayName(updatedDisplayName);
      if (!mounted) {
        return;
      }
      if (success) {
        AppToast.info(profileUpdatedMessage);
      } else {
        AppToast.error(context.l10n.requestFailed);
      }
    }
  }

  Future<void> _openCategoryManagementPage() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider<CategoryManagementCubit>(
          create: (_) => getIt<CategoryManagementCubit>()..load(),
          child: const CategoryManagementPage(),
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    context.read<DashboardCubit>().loadDashboard(showLoading: false);
    context.read<ExpenseListCubit>().loadExpenses(showLoading: false);
  }

  Future<void> _handleLoginToSync() async {
    await context.read<AuthCubit>().logout();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
    );
  }

  Future<void> _handleLogout() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.l10n.logoutConfirmTitle),
          content: Text(context.l10n.logoutConfirmMessage),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.logoutButton),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await context.read<AuthCubit>().logout();
    if (!mounted) {
      return;
    }
    AppToast.info(context.l10n.logoutSuccess);
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.displayName,
    required this.account,
    required this.onEdit,
  });

  final String displayName;
  final String account;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      radius: AppRadius.xxl,
      outlined: false,
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: _UserMetrics.avatarRadius,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
            child: Icon(
              Icons.person_rounded,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  account,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.l10n.editProfileTooltip,
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.settings,
    required this.onLanguageChanged,
    required this.onCurrencyChanged,
    required this.onDarkModeChanged,
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
              if (value != null) {
                onLanguageChanged(value);
              }
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
              if (value != null) {
                onCurrencyChanged(value);
              }
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

class _CategoryManagementCard extends StatelessWidget {
  const _CategoryManagementCard({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      radius: AppRadius.xl,
      outlined: false,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
          child: Icon(
            Icons.category_rounded,
            color: colorScheme.primary,
          ),
        ),
        title: Text(
          context.l10n.manageCategoriesButton,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        subtitle: Text(context.l10n.manageCategoriesDescription),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}

class _MonthSummaryCard extends StatelessWidget {
  const _MonthSummaryCard({required this.summary});

  final _MonthSummary summary;

  @override
  Widget build(BuildContext context) {
    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      radius: AppRadius.xxl,
      outlined: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            summary.monthLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
          Row(
            children: <Widget>[
              Expanded(
                child: _SummaryItem(
                  label: context.l10n.summaryTotalThisMonth,
                  value: CurrencyFormatter.formatValue(summary.totalThisMonth),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _SummaryItem(
                  label: context.l10n.summaryAvgDaily,
                  value: CurrencyFormatter.formatValue(summary.dailyAverage),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      radius: AppRadius.md,
      outlined: false,
      color: colorScheme.primary.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _MonthSummary {
  const _MonthSummary({
    required this.monthLabel,
    required this.totalThisMonth,
    required this.dailyAverage,
  });

  final String monthLabel;
  final double totalThisMonth;
  final double dailyAverage;
}

class _UserMetrics {
  const _UserMetrics._();

  static const double headerSpacing = 14;
  static const double logoutButtonHeight =
      AppSize.buttonHeight - AppSpacing.xxs;
  static const double avatarRadius = 26;
}
