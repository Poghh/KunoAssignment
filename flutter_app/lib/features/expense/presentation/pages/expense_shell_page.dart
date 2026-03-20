import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent_bottom_nav_bar_v2.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/extensions/l10n_extension.dart';
import '../../../../core/widgets/app_toast.dart';
import '../../domain/entities/expense.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/expense_form_cubit.dart';
import '../cubit/expense_list_cubit.dart';
import 'calendar_page.dart';
import 'dashboard_page.dart';
import 'expense_form_page.dart';
import 'expense_list_page.dart';
import 'user_page.dart';

class ExpenseShellPage extends StatefulWidget {
  const ExpenseShellPage({super.key});

  @override
  State<ExpenseShellPage> createState() => _ExpenseShellPageState();
}

class _ExpenseShellPageState extends State<ExpenseShellPage> {
  static const int _addTabIndex = 2;
  late final PersistentTabController _tabController;
  int _selectedIndex = 0;
  int _lastContentTabIndex = 0;
  bool _isRestoringAfterAddTap = false;

  @override
  void initState() {
    super.initState();
    _tabController = PersistentTabController(initialIndex: _selectedIndex);
    context.read<DashboardCubit>().loadDashboard();
    context.read<ExpenseListCubit>().loadExpenses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openExpenseForm({Expense? expense}) async {
    final String? message = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => BlocProvider<ExpenseFormCubit>(
          create: (_) => getIt<ExpenseFormCubit>()..loadCategories(),
          child: ExpenseFormPage(initialExpense: expense),
        ),
      ),
    );

    if (!mounted || message == null) {
      return;
    }

    AppToast.success(message);
    context.read<DashboardCubit>().loadDashboard(showLoading: false);
    context.read<ExpenseListCubit>().loadExpenses(showLoading: false);
  }

  void _handleTabChanged(int index) {
    if (_isRestoringAfterAddTap) {
      _isRestoringAfterAddTap = false;
      return;
    }

    if (index == _addTabIndex) {
      _isRestoringAfterAddTap = true;
      _tabController.jumpToTab(_lastContentTabIndex);
      _openExpenseForm();
      return;
    }

    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
        _lastContentTabIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      controller: _tabController,
      onTabChanged: _handleTabChanged,
      tabs: <PersistentTabConfig>[
        PersistentTabConfig(
          screen: SafeArea(
            top: true,
            bottom: false,
            child: DashboardPage(
              onEditExpense: (Expense expense) =>
                  _openExpenseForm(expense: expense),
            ),
          ),
          item: ItemConfig(
            icon: const Icon(Icons.dashboard_rounded),
            inactiveIcon: const Icon(Icons.dashboard_outlined),
            title: context.l10n.tabDashboard,
            activeForegroundColor: Theme.of(context).colorScheme.primary,
            inactiveForegroundColor:
                Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        PersistentTabConfig(
          screen: SafeArea(
            top: true,
            bottom: false,
            child: ExpenseListPage(
              onEditExpense: (Expense expense) =>
                  _openExpenseForm(expense: expense),
            ),
          ),
          item: ItemConfig(
            icon: const Icon(Icons.receipt_long_rounded),
            inactiveIcon: const Icon(Icons.receipt_long_outlined),
            title: context.l10n.tabCashflow,
            activeForegroundColor: Theme.of(context).colorScheme.primary,
            inactiveForegroundColor:
                Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        PersistentTabConfig(
          screen: const _AddActionPlaceholderPage(),
          item: ItemConfig(
            icon: const Icon(Icons.add_rounded),
            inactiveIcon: const Icon(Icons.add_rounded),
            title: context.l10n.tabAdd,
            activeForegroundColor: Theme.of(context).colorScheme.primary,
            inactiveForegroundColor: Colors.white,
          ),
        ),
        PersistentTabConfig(
          screen: const SafeArea(
            top: true,
            bottom: false,
            child: CalendarPage(),
          ),
          item: ItemConfig(
            icon: const Icon(Icons.calendar_today_rounded),
            inactiveIcon: const Icon(Icons.calendar_today_outlined),
            title: context.l10n.tabCalendar,
            activeForegroundColor: Theme.of(context).colorScheme.primary,
            inactiveForegroundColor:
                Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        PersistentTabConfig(
          screen: const SafeArea(
            top: true,
            bottom: false,
            child: UserPage(),
          ),
          item: ItemConfig(
            icon: const Icon(Icons.person_rounded),
            inactiveIcon: const Icon(Icons.person_outline_rounded),
            title: context.l10n.tabUser,
            activeForegroundColor: Theme.of(context).colorScheme.primary,
            inactiveForegroundColor:
                Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
      navBarBuilder: (NavBarConfig navBarConfig) => SizedBox(
        width: MediaQuery.sizeOf(context).width,
        child: Style13BottomNavBar(
          navBarConfig: navBarConfig,
          navBarDecoration: NavBarDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(_ShellMetrics.navBarTopRadius),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black
                    .withValues(alpha: _ShellMetrics.navBarShadowOpacity),
                blurRadius: _ShellMetrics.navBarShadowBlur,
                offset: const Offset(0, _ShellMetrics.navBarShadowOffsetY),
              ),
            ],
          ),
        ),
      ),
      margin: EdgeInsets.zero,
      resizeToAvoidBottomInset: true,
      handleAndroidBackButtonPress: true,
      stateManagement: true,
      screenTransitionAnimation: const ScreenTransitionAnimation(
        duration: Duration(milliseconds: _ShellMetrics.transitionDurationMs),
      ),
      navBarOverlap: const NavBarOverlap.none(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      avoidBottomPadding: true,
    );
  }
}

class _AddActionPlaceholderPage extends StatelessWidget {
  const _AddActionPlaceholderPage();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _ShellMetrics {
  const _ShellMetrics._();

  static const double navBarTopRadius = 20;
  static const double navBarShadowOpacity = 0.08;
  static const double navBarShadowBlur = 18;
  static const double navBarShadowOffsetY = 6;
  static const int transitionDurationMs = 200;
}
