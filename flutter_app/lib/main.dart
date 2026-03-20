import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/cubit/auth_cubit.dart';
import 'core/cubit/settings_cubit.dart';
import 'core/di/injection.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/currency_formatter.dart';
import 'features/auth/presentation/pages/display_name_setup_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/setup_preferences_page.dart';
import 'features/expense/presentation/cubit/dashboard_cubit.dart';
import 'features/expense/presentation/cubit/expense_list_cubit.dart';
import 'features/expense/presentation/pages/expense_shell_page.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  await configureDependencies();
  final SettingsCubit settingsCubit = SettingsCubit();
  await settingsCubit.loadSettings();
  final AuthCubit authCubit = AuthCubit(apiClient: getIt<ApiClient>());
  await authCubit.loadSession();
  runApp(
    ExpenseTrackerApp(
      settingsCubit: settingsCubit,
      authCubit: authCubit,
    ),
  );
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({
    required this.settingsCubit,
    required this.authCubit,
    super.key,
  });

  final SettingsCubit settingsCubit;
  final AuthCubit authCubit;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<SettingsCubit>.value(value: settingsCubit),
        BlocProvider<AuthCubit>.value(value: authCubit),
        BlocProvider<DashboardCubit>(
          create: (_) => getIt<DashboardCubit>()..loadDashboard(),
        ),
        BlocProvider<ExpenseListCubit>(
          create: (_) => getIt<ExpenseListCubit>()..loadExpenses(),
        ),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (BuildContext context, SettingsState settings) {
          CurrencyFormatter.configure(
            localeCode: settings.localeCode,
            currencyCode: settings.currency.code,
          );

          return MaterialApp(
            onGenerateTitle: (BuildContext context) =>
                AppLocalizations.of(context)!.appTitle,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: settings.themeMode,
            locale: settings.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: settings.hasCompletedSetup
                ? BlocBuilder<AuthCubit, AuthState>(
                    builder: (BuildContext context, AuthState auth) {
                      if (auth.status == AuthStatus.authenticated) {
                        final bool hasDisplayName =
                            (auth.displayName?.trim().isNotEmpty ?? false);
                        if (!hasDisplayName) {
                          return const DisplayNameSetupPage();
                        }
                        return const ExpenseShellPage();
                      }
                      return const LoginPage();
                    },
                  )
                : const SetupPreferencesPage(),
          );
        },
      ),
    );
  }
}
