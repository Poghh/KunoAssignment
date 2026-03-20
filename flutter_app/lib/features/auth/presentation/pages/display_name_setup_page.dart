import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/cubit/auth_cubit.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/widgets/app_loading_filled_button.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../../../core/widgets/auth_card_layout.dart';
import '../widgets/auth_form_header.dart';

class DisplayNameSetupPage extends StatefulWidget {
  const DisplayNameSetupPage({super.key});

  @override
  State<DisplayNameSetupPage> createState() => _DisplayNameSetupPageState();
}

class _DisplayNameSetupPageState extends State<DisplayNameSetupPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _displayNameController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final String fallbackName = context.read<AuthCubit>().state.username ?? '';
    _displayNameController = TextEditingController(text: fallbackName);
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_submitting || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _submitting = true;
    });

    final bool success = await context
        .read<AuthCubit>()
        .setDisplayName(_displayNameController.text);
    if (!mounted) {
      return;
    }

    setState(() {
      _submitting = false;
    });
    if (success) {
      AppToast.success(context.l10n.displayNameSaved);
    } else {
      AppToast.error(context.l10n.requestFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  title: context.l10n.displayNameSetupTitle,
                  subtitle: context.l10n.displayNameSetupSubtitle,
                ),
                TextFormField(
                  controller: _displayNameController,
                  textInputAction: TextInputAction.done,
                  textCapitalization: TextCapitalization.words,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: context.l10n.displayNameLabel,
                    hintText: context.l10n.displayNameSetupHint,
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                  validator: (String? value) {
                    if ((value?.trim().length ?? 0) < 2) {
                      return context.l10n.displayNameSetupValidationError;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                AppLoadingFilledButton(
                  onPressed: _submit,
                  isLoading: _submitting,
                  label: context.l10n.displayNameSetupButton,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
