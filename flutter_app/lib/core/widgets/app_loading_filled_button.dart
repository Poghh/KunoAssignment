import 'package:flutter/material.dart';

import '../constants/app_ui_constants.dart';

class AppLoadingFilledButton extends StatelessWidget {
  const AppLoadingFilledButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(AppSize.buttonHeight),
      ),
      child: isLoading
          ? const SizedBox(
              width: AppSize.loadingIndicator,
              height: AppSize.loadingIndicator,
              child: CircularProgressIndicator(
                strokeWidth: AppSize.loadingStroke,
                color: Colors.white,
              ),
            )
          : Text(label),
    );
  }
}
