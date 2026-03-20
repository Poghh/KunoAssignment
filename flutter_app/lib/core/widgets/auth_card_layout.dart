import 'package:flutter/material.dart';

import '../constants/app_ui_constants.dart';

class AuthCardLayout extends StatelessWidget {
  const AuthCardLayout({
    required this.child,
    this.scrollPadding = const EdgeInsets.all(AppSpacing.lg),
    this.cardPadding = const EdgeInsets.all(AppSpacing.xl),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry scrollPadding;
  final EdgeInsetsGeometry cardPadding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: scrollPadding,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: AppSize.authMaxWidth),
          child: Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: cardPadding,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
