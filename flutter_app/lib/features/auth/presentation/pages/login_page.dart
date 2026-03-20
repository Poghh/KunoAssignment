import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/cubit/auth_cubit.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../expense/data/datasources/expense_local_data_source.dart';
import '../../../../core/widgets/app_loading_filled_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/auth_card_layout.dart';
import '../widgets/auth_form_header.dart';
import 'display_name_setup_page.dart';
import 'register_page.dart';
import '../../../expense/presentation/pages/expense_shell_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _continueOffline() async {
    await context.read<AuthCubit>().enterGuestMode();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const ExpenseShellPage()),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final bool success = await context.read<AuthCubit>().login(
          email: _emailController.text,
          password: _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    if (success) {
      // Migrate any guest-mode offline data into the authenticated user's namespace,
      // then clear the expense/category cache so the shell page does a clean
      // sync + remote fetch — ensuring server data and newly-synced guest data
      // all appear on first load without a manual refresh.
      final ExpenseLocalDataSource localDataSource =
          getIt<ExpenseLocalDataSource>();
      await localDataSource.migrateGuestDataToUser(
          _emailController.text.trim());
      await localDataSource.clearLocalCache();
      if (!mounted) return;

      AppToast.success(context.l10n.loginSuccess);
      final AuthState authState = context.read<AuthCubit>().state;
      final bool hasDisplayName =
          authState.displayName?.trim().isNotEmpty ?? false;
      Navigator.of(context, rootNavigator: true).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => hasDisplayName
              ? const ExpenseShellPage()
              : const DisplayNameSetupPage(),
        ),
      );
    } else {
      final AuthState authState = context.read<AuthCubit>().state;
      final bool isVietnamese =
          Localizations.localeOf(context).languageCode.toLowerCase() == 'vi';
      final String message =
          authState.errorCode == AuthErrorCode.loginRequiresInternet
              ? (isVietnamese
                  ? 'Cần kết nối internet để đăng nhập.'
                  : 'Internet connection is required to sign in.')
              : context.l10n.loginFailed;
      AppToast.error(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: AuthCardLayout(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AuthFormHeader(
                  title: context.l10n.loginTitle,
                  subtitle: context.l10n.loginSubtitle,
                ),
                TextFormField(
                  controller: _emailController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: context.l10n.emailLabel,
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  validator: (String? value) {
                    final String v = value?.trim() ?? '';
                    if (!v.contains('@') || !v.contains('.')) {
                      return context.l10n.loginEmailValidationError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: context.l10n.loginPasswordLabel,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (String? value) {
                    if ((value?.trim().length ?? 0) < 6) {
                      return context.l10n.loginPasswordValidationError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (BuildContext context, AuthState auth) {
                    return AppLoadingFilledButton(
                      onPressed: _submit,
                      isLoading: auth.isSubmitting,
                      label: context.l10n.loginButton,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Text(
                      context.l10n.noAccountPrompt,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const RegisterPage(),
                          ),
                        );
                      },
                      child: Text(context.l10n.registerNowButton),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: <Widget>[
                    Expanded(child: Divider(color: colorScheme.outlineVariant)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: Text(
                        'or',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: colorScheme.outlineVariant)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: _continueOffline,
                  icon: const Icon(Icons.wifi_off_rounded, size: 18),
                  label: Text(context.l10n.continueOfflineButton),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, AppSize.buttonHeight),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
