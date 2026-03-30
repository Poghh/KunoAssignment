import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/cubit/auth_cubit.dart';
import '../../../../core/extensions/l10n_extension.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({required this.monthLabel, super.key});

  final String monthLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final AuthState auth = context.watch<AuthCubit>().state;
    final String name = (auth.displayName?.trim().isNotEmpty == true
            ? auth.displayName!.trim()
            : auth.username?.trim()) ??
        '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              name.isEmpty
                  ? context.l10n.helloDeveloper
                  : context.l10n.helloName(name),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              monthLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        Container(
          width: AppContainerSize.headerAction,
          height: AppContainerSize.headerAction,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }
}
