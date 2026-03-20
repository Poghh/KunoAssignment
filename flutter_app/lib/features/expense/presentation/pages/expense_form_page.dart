import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_ui_constants.dart';
import '../../../../core/cubit/settings_cubit.dart';
import '../../../../core/extensions/error_localization_extension.dart';
import '../../../../core/extensions/category_localization_extension.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/color_parser.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_filled_button.dart';
import '../../../../core/widgets/app_loading_state.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense.dart';
import '../cubit/expense_form_cubit.dart';
import '../cubit/expense_form_state.dart';
import '../widgets/create_category_dialog.dart';
import '../widgets/category_icon_registry.dart';

enum _TransactionType { expense, income }

class ExpenseFormPage extends StatefulWidget {
  const ExpenseFormPage({
    this.initialExpense,
    super.key,
  });

  final Expense? initialExpense;

  @override
  State<ExpenseFormPage> createState() => _ExpenseFormPageState();
}

class _ExpenseFormPageState extends State<ExpenseFormPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;

  String? _selectedCategoryId;
  late DateTime _selectedDate;
  late _TransactionType _transactionType;
  late AppCurrency _activeCurrency;

  @override
  void initState() {
    super.initState();
    final SettingsState settings = context.read<SettingsCubit>().state;
    _activeCurrency = settings.currency;

    _titleController =
        TextEditingController(text: widget.initialExpense?.title ?? '');
    _transactionType = (widget.initialExpense?.amount ?? 0) < 0
        ? _TransactionType.income
        : _TransactionType.expense;

    // For edit: show amount in current display currency.
    // If the expense was saved in a different currency, convert via USD base.
    final double initialAmount = _resolveInitialAmount(
      expense: widget.initialExpense,
      currency: settings.currency,
    );

    _amountController = TextEditingController(
      text: widget.initialExpense == null
          ? ''
          : _formatInputAmount(initialAmount, settings.currency),
    );
    _notesController =
        TextEditingController(text: widget.initialExpense?.notes ?? '');
    _selectedCategoryId = widget.initialExpense?.categoryId;
    _selectedDate = widget.initialExpense?.date ?? DateTime.now();

    _titleController.addListener(_onFormChanged);
    _amountController.addListener(_onFormChanged);

    // Listen for currency setting changes while the form is open.
    context.read<SettingsCubit>().stream.listen(_onSettingsChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _validateFormInputs();
    });
  }

  void _onSettingsChanged(SettingsState settings) {
    if (!mounted) return;
    final AppCurrency newCurrency = settings.currency;
    if (newCurrency == _activeCurrency) return;

    final AppCurrency oldCurrency = _activeCurrency;
    _activeCurrency = newCurrency;

    // Convert the current amount field value to the new currency.
    final String rawText = oldCurrency == AppCurrency.vnd
        ? _amountController.text.replaceAll('.', '')
        : _amountController.text.trim();
    final double? inputAmount = double.tryParse(rawText);

    if (inputAmount != null && inputAmount > 0) {
      final double baseAmount = CurrencyFormatter.convertToBase(
        inputAmount,
        sourceCurrencyCode: oldCurrency.code,
      );
      final double converted = CurrencyFormatter.convertFromBase(
        baseAmount,
        targetCurrencyCode: newCurrency.code,
      );
      _amountController.removeListener(_onFormChanged);
      _amountController.text = _formatInputAmount(converted, newCurrency);
      _amountController.addListener(_onFormChanged);
    }

    setState(() {});
    _validateFormInputs();
  }

  double _resolveInitialAmount({
    required Expense? expense,
    required AppCurrency currency,
  }) {
    if (expense == null) return 0;
    // Same currency: use displayAmount to avoid base-conversion precision loss.
    if (expense.currencyCode.toUpperCase() == currency.code.toUpperCase()) {
      return expense.displayAmount.abs();
    }
    // Different currency: convert from USD base to the current display currency.
    return CurrencyFormatter.convertFromBase(
      expense.amount.abs(),
      targetCurrencyCode: currency.code,
    );
  }

  @override
  void dispose() {
    _titleController
      ..removeListener(_onFormChanged)
      ..dispose();
    _amountController
      ..removeListener(_onFormChanged)
      ..dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onFormChanged() {
    setState(() {});
    _validateFormInputs();
  }

  void _validateFormInputs() {
    final String rawAmount = _activeCurrency == AppCurrency.vnd
        ? _amountController.text.trim().replaceAll('.', '')
        : _amountController.text.trim();
    context.read<ExpenseFormCubit>().validateForm(
          title: _titleController.text,
          amountText: rawAmount,
          categoryId: _selectedCategoryId,
        );
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 3650)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _submit() async {
    if (!context.read<ExpenseFormCubit>().state.isFormValid) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String rawAmount = _activeCurrency == AppCurrency.vnd
        ? _amountController.text.trim().replaceAll('.', '')
        : _amountController.text.trim();
    final double amount = double.parse(rawAmount).abs();
    final ExpenseDraft draft = ExpenseDraft(
      title: _titleController.text.trim(),
      amount: _transactionType == _TransactionType.income ? -amount : amount,
      currencyCode: _activeCurrency.code,
      date: _selectedDate,
      categoryId: _selectedCategoryId!,
      location: null,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    final bool success = await context.read<ExpenseFormCubit>().saveExpense(
          expenseId: widget.initialExpense?.id,
          draft: draft,
        );

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop(
        widget.initialExpense == null
            ? context.l10n.transactionAddedSuccessfully
            : context.l10n.transactionUpdatedSuccessfully,
      );
    } else {
      AppToast.error(
        context.localizeErrorMessage(
          context.read<ExpenseFormCubit>().state.errorMessage,
          fallback: context.l10n.saveTransactionFailed,
        ),
      );
    }
  }

  Future<void> _promptCreateCategory() async {
    final CreateCategoryDialogResult? result =
        await showCreateCategoryDialog(context);

    if (result == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    final ExpenseFormCubit cubit = context.read<ExpenseFormCubit>();
    final Category? createdCategory = await cubit.createCategory(
      name: result.name,
      icon: result.iconKey,
      color: result.colorHex,
    );

    if (!mounted) {
      return;
    }

    if (createdCategory == null) {
      AppToast.error(
        context.localizeErrorMessage(
          cubit.state.errorMessage,
          fallback: context.l10n.createCategoryFailed,
        ),
      );
      return;
    }

    setState(() {
      _selectedCategoryId = createdCategory.id;
    });
    _validateFormInputs();
    AppToast.success(
      context.l10n.categoryCreatedSuccessfully(createdCategory.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ExpenseFormState state = context.watch<ExpenseFormCubit>().state;
    final String locale = Localizations.localeOf(context).toString();
    final String currencyPrefix = _activeCurrency.symbol;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialExpense == null
              ? context.l10n.addTransactionTitle
              : context.l10n.editTransactionTitle,
        ),
      ),
      body: state.status == ExpenseFormStatus.loadingCategories &&
              state.categories.isEmpty
          ? const AppLoadingState()
          : state.categories.isEmpty
              ? ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.xl,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                  ),
                  children: <Widget>[
                    AppEmptyState(
                      title: context.l10n.noCategoriesAvailableTitle,
                      description:
                          context.l10n.noCategoriesAvailableDescription,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton.icon(
                      onPressed: _promptCreateCategory,
                      icon: const Icon(Icons.add_rounded),
                      label: Text(context.l10n.createCategoryConfirm),
                    ),
                  ],
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.sm,
                      AppSpacing.lg,
                      AppSpacing.xxl,
                    ),
                    children: <Widget>[
                      SegmentedButton<_TransactionType>(
                        segments: <ButtonSegment<_TransactionType>>[
                          ButtonSegment<_TransactionType>(
                            value: _TransactionType.expense,
                            icon: const Icon(Icons.south_east_rounded),
                            label: Text(context.l10n.transactionTypeExpense),
                          ),
                          ButtonSegment<_TransactionType>(
                            value: _TransactionType.income,
                            icon: const Icon(Icons.north_east_rounded),
                            label: Text(context.l10n.transactionTypeIncome),
                          ),
                        ],
                        selected: <_TransactionType>{_transactionType},
                        onSelectionChanged: (Set<_TransactionType> selected) {
                          setState(() {
                            _transactionType = selected.first;
                          });
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _titleController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: context.l10n.titleLabel,
                          prefixIcon: const Icon(Icons.title_rounded),
                        ),
                        validator: (String? value) {
                          if (value == null || value.trim().length < 2) {
                            return context.l10n.titleValidationError;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      AnimatedContainer(
                        duration: AppDurationMs.normal,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          boxShadow: <BoxShadow>[
                            if (_amountController.text.isNotEmpty)
                              BoxShadow(
                                color: AppTheme.primary.withValues(alpha: 0.16),
                                blurRadius: AppRadius.lg,
                                offset: const Offset(0, 8),
                              ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.numberWithOptions(
                              decimal: _activeCurrency != AppCurrency.vnd,
                              signed: false),
                          textInputAction: TextInputAction.next,
                          inputFormatters: _activeCurrency == AppCurrency.vnd
                              ? <TextInputFormatter>[_vndInputFormatter()]
                              : null,
                          decoration: InputDecoration(
                            labelText: context.l10n.amountLabel,
                            prefixText: currencyPrefix,
                            prefixIcon: const Icon(Icons.attach_money_rounded),
                          ),
                          validator: (String? value) {
                            final String raw =
                                _activeCurrency == AppCurrency.vnd
                                    ? (value?.trim() ?? '').replaceAll('.', '')
                                    : (value?.trim() ?? '');
                            final double? amount = double.tryParse(raw);
                            if (amount == null || amount <= 0) {
                              return context.l10n.amountValidationError;
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<String>(
                        value: _selectedCategoryId,
                        decoration: InputDecoration(
                          labelText: context.l10n.categoryLabel,
                          prefixIcon: const Icon(Icons.category_rounded),
                        ),
                        items: state.categories
                            .map(
                              (category) => DropdownMenuItem<String>(
                                value: category.id,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Icon(
                                      resolveCategoryIcon(category.icon),
                                      size: 18,
                                      color: parseHexColor(
                                        category.color,
                                        fallback: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text(
                                      context.l10n.localizeCategory(category.name),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (String? value) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                          _validateFormInputs();
                        },
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return context.l10n.categoryValidationError;
                          }
                          return null;
                        },
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _promptCreateCategory,
                          icon: const Icon(Icons.add_rounded),
                          label: Text(context.l10n.addCategoryButton),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      InkWell(
                        onTap: _pickDate,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: context.l10n.dateLabel,
                            prefixIcon: const Icon(Icons.date_range_rounded),
                          ),
                          child: Text(
                            DateFormat('EEE, dd MMM yyyy', locale)
                                .format(_selectedDate),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextFormField(
                        controller: _notesController,
                        minLines: 3,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: context.l10n.notesLabel,
                          alignLabelWithHint: true,
                          prefixIcon: const Icon(Icons.sticky_note_2_outlined),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      AppLoadingFilledButton(
                        onPressed: state.isFormValid ? _submit : null,
                        isLoading: state.isSubmitting,
                        label: widget.initialExpense == null
                            ? context.l10n.saveTransactionButton
                            : context.l10n.updateTransactionButton,
                      ),
                    ],
                  ),
                ),
    );
  }

  String _formatInputAmount(double amount, AppCurrency currency) {
    if (currency == AppCurrency.vnd) {
      // Show VND with thousand separators (e.g. 500.000) using vi_VN locale.
      return NumberFormat('#,##0', 'vi_VN').format(amount.round());
    }
    return amount.toStringAsFixed(currency.decimalDigits);
  }
}

/// Returns a [TextInputFormatter] that formats VND amounts as the user types:
/// strips non-digits and re-formats with dot thousand-separators
/// (e.g. "500000" → "500.000").
TextInputFormatter _vndInputFormatter() {
  final NumberFormat fmt = NumberFormat('#,##0', 'vi_VN');
  return TextInputFormatter.withFunction((
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) {
      return newValue.copyWith(text: '');
    }
    final String formatted = fmt.format(int.parse(digits));
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  });
}
