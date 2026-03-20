import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/extensions/error_localization_extension.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/utils/color_parser.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../core/widgets/app_surface_card.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/category.dart';
import '../cubit/category_management_cubit.dart';
import '../cubit/category_management_state.dart';
import '../widgets/category_icon_registry.dart';
import '../widgets/create_category_dialog.dart';

class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  Future<void> _refresh() {
    return context.read<CategoryManagementCubit>().load(showLoading: false);
  }

  Future<void> _createCategory() async {
    final CreateCategoryDialogResult? result =
        await showCreateCategoryDialog(context);
    if (result == null || !mounted) {
      return;
    }

    final CategoryManagementCubit cubit =
        context.read<CategoryManagementCubit>();
    final Category? created = await cubit.createCategory(
      name: result.name,
      icon: result.iconKey,
      color: result.colorHex,
    );

    if (!mounted) {
      return;
    }

    if (created == null) {
      AppToast.error(
        context.localizeErrorMessage(
          cubit.state.errorMessage,
          fallback: context.l10n.createCategoryFailed,
        ),
      );
      return;
    }

    AppToast.success(context.l10n.categoryCreatedSuccessfully(created.name));
  }

  Future<void> _promptDeleteCategory(Category category) async {
    final CategoryManagementCubit cubit =
        context.read<CategoryManagementCubit>();
    if (!cubit.state.canDeleteCategory(category.id)) {
      AppToast.error(context.l10n.deleteCategoryInUse);
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.l10n.deleteCategoryTitle),
          content:
              Text(context.l10n.deleteCategoryConfirmMessage(category.name)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(context.l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(context.l10n.commonDelete),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final bool deleted = await cubit.deleteCategory(category.id);
    if (!mounted) {
      return;
    }

    if (!deleted) {
      AppToast.error(
        context.localizeErrorMessage(
          cubit.state.errorMessage,
          fallback: context.l10n.deleteCategoryFailed,
        ),
      );
      return;
    }

    AppToast.success(context.l10n.deleteCategorySuccess);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryManagementCubit, CategoryManagementState>(
      builder: (BuildContext context, CategoryManagementState state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(context.l10n.categoryManagementTitle),
            actions: <Widget>[
              IconButton(
                onPressed: state.isMutating ? null : _createCategory,
                tooltip: context.l10n.addCategoryButton,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: state.isMutating ? null : _createCategory,
            icon: const Icon(Icons.add_rounded),
            label: Text(context.l10n.addCategoryButton),
          ),
          body: _CategoryManagementBody(
            state: state,
            onRefresh: _refresh,
            onCreateCategory: _createCategory,
            onDeleteCategory: _promptDeleteCategory,
          ),
        );
      },
    );
  }
}

class _CategoryManagementBody extends StatelessWidget {
  const _CategoryManagementBody({
    required this.state,
    required this.onRefresh,
    required this.onCreateCategory,
    required this.onDeleteCategory,
  });

  final CategoryManagementState state;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onCreateCategory;
  final Future<void> Function(Category category) onDeleteCategory;

  @override
  Widget build(BuildContext context) {
    if (state.status == CategoryManagementStatus.loading &&
        state.categories.isEmpty) {
      return const AppLoadingState();
    }

    if (state.status == CategoryManagementStatus.failure &&
        state.categories.isEmpty) {
      return AppErrorState(
        message: context.localizeErrorMessage(
          state.errorMessage,
          fallback: context.l10n.requestFailed,
        ),
        onRetry: () => context.read<CategoryManagementCubit>().load(),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          110,
        ),
        children: <Widget>[
          Text(
            context.l10n.categoryManagementSubtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (state.status == CategoryManagementStatus.failure &&
              state.errorMessage?.trim().isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppSurfaceCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                radius: AppRadius.lg,
                outlined: false,
                child: Row(
                  children: <Widget>[
                    Icon(
                      Icons.info_outline_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        context.localizeErrorMessage(
                          state.errorMessage,
                          fallback: context.l10n.requestFailed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (state.categories.isEmpty)
            Column(
              children: <Widget>[
                AppEmptyState(
                  title: context.l10n.noCategoriesAvailableTitle,
                  description: context.l10n.noCategoriesAvailableDescription,
                  icon: Icons.category_outlined,
                ),
                const SizedBox(height: AppSpacing.sm),
                FilledButton.icon(
                  onPressed: state.isMutating ? null : onCreateCategory,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(context.l10n.addCategoryButton),
                ),
              ],
            )
          else
            ...state.categories.map(
              (Category category) {
                final int usageCount = state.expenseCountOf(category.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _CategoryCard(
                    category: category,
                    usageCount: usageCount,
                    isMutating: state.isMutating,
                    onDelete: () => onDeleteCategory(category),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.usageCount,
    required this.isMutating,
    required this.onDelete,
  });

  final Category category;
  final int usageCount;
  final bool isMutating;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool canDelete = usageCount == 0 && !isMutating;

    return AppSurfaceCard(
      padding: EdgeInsets.zero,
      radius: AppRadius.xl,
      outlined: false,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: CircleAvatar(
          backgroundColor: parseHexColor(
            category.color,
            fallback: colorScheme.primary,
          ).withValues(alpha: 0.18),
          child: Icon(
            resolveCategoryIcon(category.icon),
            color: parseHexColor(
              category.color,
              fallback: colorScheme.primary,
            ),
          ),
        ),
        title: Text(
          category.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        subtitle: Text(
          usageCount == 0
              ? context.l10n.categoryUsageEmpty
              : context.l10n.categoryUsageCount(usageCount.toString()),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        trailing: IconButton(
          onPressed: canDelete ? onDelete : null,
          tooltip: canDelete
              ? context.l10n.deleteCategoryButton
              : context.l10n.deleteCategoryInUse,
          icon: const Icon(Icons.delete_outline_rounded),
        ),
      ),
    );
  }
}
