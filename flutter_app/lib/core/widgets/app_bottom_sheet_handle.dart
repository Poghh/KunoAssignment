import 'package:flutter/material.dart';

import '../constants/app_ui_constants.dart';

class AppBottomSheetHandle extends StatelessWidget {
  const AppBottomSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        width: AppContainerSize.bottomSheetHandleWidth,
        height: AppContainerSize.bottomSheetHandleHeight,
        decoration: BoxDecoration(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}
