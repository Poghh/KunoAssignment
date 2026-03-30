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
import '../../../../core/widgets/app_bottom_sheet_handle.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/expense.dart';
import '../cubit/category_management_cubit.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../cubit/expense_list_cubit.dart';
import '../widgets/user_category_card.dart';
import '../widgets/user_month_summary_card.dart';
import '../widgets/user_profile_card.dart';
import '../widgets/user_settings_card.dart';
import 'category_management_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  static const double _logoutButtonHeight =
      AppSize.buttonHeight - AppSpacing.xxs;

  @override
  Widget build(BuildContext context) {
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
            AppSpacing.bottomNavClearance,
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
              _GuestBanner(),
            ],
            const SizedBox(height: AppSpacing.md + AppSpacing.xxs),
            UserProfileCard(
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
            UserMonthSummaryCard(
              monthLabel: summary.monthLabel,
              totalThisMonth: summary.totalThisMonth,
              dailyAverage: summary.dailyAverage,
            ),
            const SizedBox(height: AppSpacing.md + AppSpacing.xxs),
            AppSectionHeader(
              title: context.l10n.categoryManagementTitle,
              subtitle: context.l10n.categoryManagementSubtitle,
            ),
            const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
            UserCategoryCard(onTap: _openCategoryManagementPage),
            const SizedBox(height: AppSpacing.md + AppSpacing.xxs),
            AppSectionHeader(
              title: context.l10n.settingsTitle,
              subtitle: context.l10n.settingsSubtitle,
            ),
            const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
            UserSettingsCard(
              settings: settings,
              onLanguageChanged: (AppLanguage language) async {
                final String msg = context.l10n.languageUpdated;
                await context.read<SettingsCubit>().setLanguage(language);
                if (!mounted) return;
                AppToast.info(msg);
              },
              onCurrencyChanged: (AppCurrency currency) async {
                final String msg = context.l10n.currencyUnitUpdated;
                await context.read<SettingsCubit>().setCurrency(currency);
                if (!mounted) return;
                AppToast.info(msg);
              },
              onDarkModeChanged: (bool isDark) async {
                final String msg = isDark
                    ? context.l10n.darkModeEnabled
                    : context.l10n.lightModeEnabled;
                await context
                    .read<SettingsCubit>()
                    .setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
                if (!mounted) return;
                AppToast.info(msg);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            if (auth.status == AuthStatus.guest)
              FilledButton.icon(
                onPressed: _handleLoginToSync,
                icon: const Icon(Icons.sync_rounded),
                style: FilledButton.styleFrom(
                  minimumSize:
                      const Size.fromHeight(_logoutButtonHeight),
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
                      const Size.fromHeight(_logoutButtonHeight),
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
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
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
    final String monthLabel = DateFormat(AppDateFormat.monthYear, settings.localeCode)
        .format(state.insights?.monthly.monthDate ?? now);
    final double totalThisMonth =
        state.insights?.monthly.totalThisMonth ?? _fallbackMonthExpense(state);
    final double dailyAverage =
        state.insights?.dailyAverage.dailyAverage ?? _fallbackDailyAverage(state);
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
      if (expense.date.year == now.year &&
          expense.date.month == now.month &&
          expense.amount > 0) {
        total += expense.amount;
      }
    }
    return total;
  }

  double _fallbackDailyAverage(DashboardState state) =>
      _fallbackMonthExpense(state) / DateTime.now().day.clamp(1, 31);

  Future<void> _showEditProfileSheet({
    required String currentUsername,
    required String currentDisplayName,
  }) async {
    final AuthCubit authCubit = context.read<AuthCubit>();
    final String profileUpdatedMsg = context.l10n.profileUpdated;
    final String requestFailedMsg = context.l10n.requestFailed;

    // Sheet pops with the new display name string, or null if cancelled.
    final String? newName = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EditProfileSheet(
        currentUsername: currentUsername,
        currentDisplayName: currentDisplayName,
      ),
    );

    if (newName == null || !mounted) return;

    final bool success = await authCubit.setDisplayName(newName);
    if (!mounted) return;
    AppToast.info(success ? profileUpdatedMsg : requestFailedMsg);
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
    if (!mounted) return;
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
      builder: (BuildContext context) => AlertDialog(
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
      ),
    );
    if (confirmed != true || !mounted) return;
    await context.read<AuthCubit>().logout();
    if (!mounted) return;
    AppToast.info(context.l10n.logoutSuccess);
  }
}

// ── Edit Profile Bottom Sheet ─────────────────────────────────────────────────

/// Bottom sheet that pops with the updated display name string on save,
/// or null if the user cancels.
class _EditProfileSheet extends StatefulWidget {
  const _EditProfileSheet({
    required this.currentUsername,
    required this.currentDisplayName,
  });

  final String currentUsername;
  final String currentDisplayName;

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final String initial = widget.currentDisplayName.isEmpty
        ? widget.currentUsername
        : widget.currentDisplayName;
    _nameController = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.48,
      minChildSize: 0.38,
      maxChildSize: 0.76,
      builder: (BuildContext context, ScrollController scrollController) {
        return ListView(
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            bottomInset + AppSpacing.lg,
          ),
          children: <Widget>[
            const AppBottomSheetHandle(),
            const SizedBox(height: AppSpacing.lg),
            Text(
              context.l10n.editProfileTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: context.l10n.displayNameLabel,
                hintText: context.l10n.userDefaultDisplayName,
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              initialValue: widget.currentUsername,
              readOnly: true,
              decoration: InputDecoration(
                labelText: context.l10n.registerUsernameLabel,
                prefixIcon: const Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            FilledButton(
              onPressed: () {
                final String text = _nameController.text.trim();
                final String result = text.isEmpty
                    ? (widget.currentDisplayName.isEmpty
                        ? widget.currentUsername
                        : widget.currentDisplayName)
                    : text;
                Navigator.of(context).pop(result);
              },
              child: Text(context.l10n.saveProfileButton),
            ),
          ],
        );
      },
    );
  }
}

// ── Guest Banner ──────────────────────────────────────────────────────────────

class _GuestBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.account_circle_outlined,
            size: AppIconSize.sm,
            color: AppTheme.primary,
          ),
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
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

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
