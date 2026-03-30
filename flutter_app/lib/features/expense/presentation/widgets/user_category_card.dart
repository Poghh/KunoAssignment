import 'package:flutter/material.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/widgets/app_surface_card.dart';

class UserCategoryCard extends StatelessWidget {
  const UserCategoryCard({required this.onTap, super.key});

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
          child: Icon(Icons.category_rounded, color: colorScheme.primary),
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
