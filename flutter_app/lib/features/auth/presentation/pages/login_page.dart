import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/cubit/auth_cubit.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/widgets/app_loading_filled_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/auth_card_layout.dart';
import '../widgets/auth_form_header.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final bool success = await context.read<AuthCubit>().login(
          username: _usernameController.text,
          password: _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    if (success) {
      AppToast.success(context.l10n.loginSuccess);
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
                  controller: _usernameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: context.l10n.registerUsernameLabel,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                  validator: (String? value) {
                    if ((value?.trim().length ?? 0) < 2) {
                      return context.l10n.registerUsernameValidationError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: context.l10n.loginPasswordLabel,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
