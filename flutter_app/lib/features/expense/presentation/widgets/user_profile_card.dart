import 'package:flutter/material.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/widgets/app_surface_card.dart';

class UserProfileCard extends StatelessWidget {
  const UserProfileCard({
    required this.displayName,
    required this.account,
    required this.onEdit,
    super.key,
  });

  final String displayName;
  final String account;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AppSurfaceCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      radius: AppRadius.xxl,
      outlined: false,
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: AppContainerSize.avatarRadius,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.12),
            child: Icon(Icons.person_rounded, color: colorScheme.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  account,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.l10n.editProfileTooltip,
            onPressed: onEdit,
            icon: const Icon(Icons.edit_rounded),
          ),
        ],
      ),
    );
  }
}
