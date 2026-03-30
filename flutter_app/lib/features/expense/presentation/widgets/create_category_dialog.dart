import 'package:flutter/material.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/utils/color_parser.dart';
import 'category_icon_registry.dart';

class CreateCategoryDialogResult {
  const CreateCategoryDialogResult({
    required this.name,
    required this.iconKey,
    required this.colorHex,
  });

  final String name;
  final String iconKey;
  final String colorHex;
}

Future<CreateCategoryDialogResult?> showCreateCategoryDialog(
  BuildContext context,
) {
  return showDialog<CreateCategoryDialogResult>(
    context: context,
    builder: (_) => const _CreateCategoryDialog(),
  );
}

class _CreateCategoryDialog extends StatefulWidget {
  const _CreateCategoryDialog();

  @override
  State<_CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends State<_CreateCategoryDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  String _selectedIconKey = categoryIconOptions.first.key;
  String _selectedColorHex = kCategoryColorHexOptions.first;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    Navigator.of(context).pop(
      CreateCategoryDialogResult(
        name: _nameController.text.trim(),
        iconKey: _selectedIconKey,
        colorHex: _selectedColorHex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(context.l10n.createCategoryTitle),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.done,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: context.l10n.createCategoryLabel,
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().length < 2) {
                      return context.l10n.createCategoryValidationError;
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(height: _DialogSpacing.beforeLabel),
              Text(
                context.l10n.createCategoryIconLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: _DialogSpacing.afterLabel),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: categoryIconOptions
                    .map(
                      (CategoryIconOption option) => InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        onTap: () {
                          setState(() {
                            _selectedIconKey = option.key;
                          });
                        },
                        child: AnimatedContainer(
                          duration: AppDurationMs.fast,
                          width: AppContainerSize.iconMd,
                          height: AppContainerSize.iconMd,
                          decoration: BoxDecoration(
                            color: _selectedIconKey == option.key
                                ? colorScheme.primary.withValues(alpha: 0.14)
                                : colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: _selectedIconKey == option.key
                                  ? colorScheme.primary
                                  : colorScheme.outline.withValues(alpha: 0.35),
                              width: _selectedIconKey == option.key ? 1.4 : 1,
                            ),
                          ),
                          child: Icon(
                            option.iconData,
                            size: AppIconSize.md,
                            color: _selectedIconKey == option.key
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
              const SizedBox(height: _DialogSpacing.beforeLabel),
              Text(
                context.l10n.createCategoryColorLabel,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: _DialogSpacing.afterLabel),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: kCategoryColorHexOptions
                    .map(
                      (String colorHex) => InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        onTap: () {
                          setState(() {
                            _selectedColorHex = colorHex;
                          });
                        },
                        child: AnimatedContainer(
                          duration: AppDurationMs.fast,
                          width: AppContainerSize.iconMd,
                          height: AppContainerSize.iconMd,
                          decoration: BoxDecoration(
                            color: parseHexColor(
                              colorHex,
                              fallback: colorScheme.primary,
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: _selectedColorHex == colorHex
                                  ? colorScheme.onSurface
                                  : colorScheme.outline.withValues(alpha: 0.45),
                              width: _selectedColorHex == colorHex ? 2 : 1,
                            ),
                          ),
                          child: _selectedColorHex == colorHex
                              ? Icon(
                                  Icons.check_rounded,
                                  size: AppIconSize.md,
                                  color: colorScheme.onPrimary,
                                )
                              : null,
                        ),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(context.l10n.createCategoryConfirm),
        ),
      ],
    );
  }
}

class _DialogSpacing {
  const _DialogSpacing._();

  /// Space above a section label (between field/picker and next label).
  static const double beforeLabel = 14;

  /// Space below a section label (between label and its picker grid).
  static const double afterLabel = 10;
}

const List<String> kCategoryColorHexOptions = <String>[
  '#4CAF50',
  '#EF5350',
  '#42A5F5',
  '#AB47BC',
  '#FFA726',
  '#26A69A',
  '#66BB6A',
  '#F06292',
  '#8D6E63',
  '#78909C',
];
