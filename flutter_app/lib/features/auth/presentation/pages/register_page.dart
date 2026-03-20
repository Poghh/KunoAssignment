import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/cubit/auth_cubit.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/widgets/app_loading_filled_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/auth_card_layout.dart';
import '../widgets/auth_form_header.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final bool success = await context.read<AuthCubit>().register(
          username: _usernameController.text,
          password: _passwordController.text,
        );

    if (!mounted) {
      return;
    }

    if (success) {
      AppToast.success(context.l10n.registerSuccess);
      Navigator.of(context).pop();
    } else {
      AppToast.error(context.l10n.registerFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: AuthCardLayout(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AuthFormHeader(
                  title: context.l10n.registerTitle,
                  subtitle: context.l10n.registerSubtitle,
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
                  textInputAction: TextInputAction.next,
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
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: context.l10n.confirmPasswordLabel,
                    prefixIcon: const Icon(Icons.lock_reset_rounded),
                  ),
                  validator: (String? value) {
                    if ((value?.trim() ?? '') !=
                        _passwordController.text.trim()) {
                      return context.l10n.confirmPasswordValidationError;
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
                      label: context.l10n.registerButton,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.sm + AppSpacing.xxs),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.l10n.loginNowButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
