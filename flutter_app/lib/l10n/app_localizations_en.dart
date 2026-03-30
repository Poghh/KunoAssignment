// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Expense Tracker';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get tabDashboard => 'Dashboard';

  @override
  String get tabCashflow => 'Cashflow';

  @override
  String get tabAdd => 'Add';

  @override
  String get tabCalendar => 'Calendar';

  @override
  String get tabUser => 'User';

  @override
  String get helloDeveloper => 'Hello there';

  @override
  String helloName(String name) => 'Hello, $name';

  @override
  String get categorySplitTitle => 'Category Split';

  @override
  String get categorySplitSubtitle => 'Interactive spending chart';

  @override
  String get recentTransactionsTitle => 'Recent Transactions';

  @override
  String get recentTransactionsSubtitle => 'Latest 5 expenses';

  @override
  String get noExpensesYetTitle => 'No expenses yet';

  @override
  String get noExpensesYetDescription => 'Tap Add Expense to track your first spending.';

  @override
  String get totalThisMonth => 'Total this month';

  @override
  String summaryVsLastMonth(String percentage) {
    return '$percentage% vs last month';
  }

  @override
  String get failedLoadDashboard => 'Failed to load dashboard';

  @override
  String get spendingInsightsTitle => 'Spending Insights';

  @override
  String get insightTrendIncreased => 'increased';

  @override
  String get insightTrendDecreased => 'decreased';

  @override
  String get insightTopCategoryFallback => 'Top category';

  @override
  String insightLineOne(String categoryName, String trendVerb, String percentage) {
    return '$categoryName $trendVerb by $percentage%';
  }

  @override
  String get insightTopDayEmpty => 'No top spending day yet this month';

  @override
  String insightTopDayText(String weekday) {
    return 'You spend most on $weekday';
  }

  @override
  String avgDailySpendText(String amount) {
    return 'Avg daily spend: $amount';
  }

  @override
  String get categoryNameFood => 'Food';

  @override
  String get categoryNameTransport => 'Transport';

  @override
  String get categoryNameShopping => 'Shopping';

  @override
  String get categoryNameUtilities => 'Utilities';

  @override
  String get categoryNameEntertainment => 'Entertainment';

  @override
  String get categoryNameHealth => 'Health';

  @override
  String get categoryNameBills => 'Bills';

  @override
  String get categoryNameSalary => 'Salary';

  @override
  String get otherCategory => 'Other';

  @override
  String get noCategorySpendingYetThisMonth => 'No category spending yet this month';

  @override
  String get categoryFallback => 'Category';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get failedLoadCalendar => 'Failed to load calendar';

  @override
  String get expenseLabel => 'Expense';

  @override
  String get incomeLabel => 'Income';

  @override
  String get netLabel => 'Net';

  @override
  String selectedDaySummary(String expense, String income) {
    return 'Expense: $expense  |  Income: $income';
  }

  @override
  String get noTransactionsForDay => 'No transactions for this day.';

  @override
  String get expensesTitle => 'Expenses';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get categoryLabel => 'Category';

  @override
  String get allCategories => 'All categories';

  @override
  String get filterByDate => 'Filter by date';

  @override
  String get sortByLabel => 'Sort by';

  @override
  String get sortLatest => 'Latest first';

  @override
  String get sortOldest => 'Oldest first';

  @override
  String get sortAmountHigh => 'Amount (high → low)';

  @override
  String get sortAmountLow => 'Amount (low → high)';

  @override
  String get failedLoadExpenses => 'Failed to load expenses';

  @override
  String get noMatchingExpensesTitle => 'No matching expenses';

  @override
  String get noMatchingExpensesDescription => 'Try adjusting filters or add a new expense.';

  @override
  String get deleteExpenseTitle => 'Delete expense?';

  @override
  String removeExpensePermanently(String title) {
    return 'Remove \"$title\" permanently?';
  }

  @override
  String get expenseDeleted => 'Expense deleted';

  @override
  String get deleteExpenseFailed => 'Failed to delete expense. Please retry.';

  @override
  String get addTransactionTitle => 'Add Transaction';

  @override
  String get editTransactionTitle => 'Edit Transaction';

  @override
  String get transactionAddedSuccessfully => 'Transaction added successfully';

  @override
  String get transactionUpdatedSuccessfully => 'Transaction updated successfully';

  @override
  String get saveTransactionFailed => 'Failed to save transaction. Please retry.';

  @override
  String get noCategoriesAvailableTitle => 'No categories available';

  @override
  String get noCategoriesAvailableDescription => 'Create your first category to add transactions.';

  @override
  String get transactionTypeExpense => 'Expense';

  @override
  String get transactionTypeIncome => 'Income';

  @override
  String get titleLabel => 'Title';

  @override
  String get titleValidationError => 'Title must have at least 2 characters';

  @override
  String get amountLabel => 'Amount';

  @override
  String get amountValidationError => 'Enter a valid amount';

  @override
  String get categoryValidationError => 'Please select a category';

  @override
  String get addCategoryButton => 'Add category';

  @override
  String get createCategoryTitle => 'Create Category';

  @override
  String get createCategoryLabel => 'Category name';

  @override
  String get createCategoryIconLabel => 'Icon';

  @override
  String get createCategoryColorLabel => 'Color';

  @override
  String get createCategoryValidationError => 'Category name must have at least 2 characters';

  @override
  String get createCategoryConfirm => 'Create';

  @override
  String get createCategoryFailed => 'Failed to create category. Please retry.';

  @override
  String get deleteCategoryButton => 'Delete category';

  @override
  String get deleteCategoryTitle => 'Delete category?';

  @override
  String deleteCategoryConfirmMessage(String name) {
    return 'Delete category \"$name\"?';
  }

  @override
  String get deleteCategorySuccess => 'Category deleted';

  @override
  String get deleteCategoryFailed => 'Unable to delete category. Please retry.';

  @override
  String get deleteCategoryInUse => 'Cannot delete category because it has existing transactions.';

  @override
  String categoryCreatedSuccessfully(String name) {
    return 'Category \"$name\" created';
  }

  @override
  String get categoryManagementTitle => 'Category Management';

  @override
  String get categoryManagementSubtitle => 'Create categories and delete ones that are no longer used.';

  @override
  String get manageCategoriesButton => 'Manage categories';

  @override
  String get manageCategoriesDescription => 'View all categories and clean up unused ones.';

  @override
  String get categoryUsageEmpty => 'No transactions yet';

  @override
  String categoryUsageCount(String count) {
    return '$count transactions';
  }

  @override
  String get dateLabel => 'Date';

  @override
  String get locationLabel => 'Location';

  @override
  String get notesLabel => 'Notes';

  @override
  String get saveTransactionButton => 'Save Transaction';

  @override
  String get updateTransactionButton => 'Update Transaction';

  @override
  String get userTitle => 'User';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle => 'Sign in to continue tracking your expenses';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get loginEmailValidationError => 'Enter a valid email';

  @override
  String get loginPasswordValidationError => 'Password must have at least 6 characters';

  @override
  String get loginSuccess => 'Logged in successfully';

  @override
  String get loginFailed => 'Login failed. Please check your credentials.';

  @override
  String get registerTitle => 'Create account';

  @override
  String get registerSubtitle => 'Use email and password to continue';

  @override
  String get registerButton => 'Register';

  @override
  String get registerSuccess => 'Registered successfully. Please login.';

  @override
  String get registerFailed => 'Registration failed. Please check your input.';

  @override
  String get registerUsernameLabel => 'Username';

  @override
  String get registerUsernameValidationError => 'Username must have at least 2 characters';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get confirmPasswordValidationError => 'Confirm password does not match';

  @override
  String get noAccountPrompt => 'No account yet?';

  @override
  String get registerNowButton => 'Register now';

  @override
  String get loginNowButton => 'Back to login';

  @override
  String get logoutButton => 'Logout';

  @override
  String get logoutConfirmTitle => 'Logout?';

  @override
  String get logoutConfirmMessage => 'Do you want to logout from this device?';

  @override
  String get logoutSuccess => 'Logged out';

  @override
  String get setupTitle => 'Before you start';

  @override
  String get setupSubtitle => 'Setup your preferences';

  @override
  String get setupLanguageLabel => 'Language';

  @override
  String get setupCurrencyLabel => 'Currency';

  @override
  String get setupThemeLabel => 'Theme';

  @override
  String get setupThemeLight => 'Light';

  @override
  String get setupThemeDark => 'Dark';

  @override
  String get setupNextButton => 'Next';

  @override
  String get setupContinueButton => 'Continue';

  @override
  String get setupSaved => 'Preferences saved';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Language, currency and appearance';

  @override
  String get currencyFormatUpdated => 'Currency format updated';

  @override
  String get darkModeEnabled => 'Dark mode enabled';

  @override
  String get lightModeEnabled => 'Light mode enabled';

  @override
  String get monthlySummaryTitle => 'Monthly Summary';

  @override
  String get monthlySummarySubtitle => 'Simple overview of current month';

  @override
  String get syncingData => 'Syncing data...';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get userDefaultDisplayName => 'Your Account';

  @override
  String get displayNameLabel => 'Display name';

  @override
  String get displayNameSetupTitle => 'What should we call you?';

  @override
  String get displayNameSetupSubtitle => 'Set your display name to personalize your experience.';

  @override
  String get displayNameSetupHint => 'Enter your display name';

  @override
  String get displayNameSetupValidationError => 'Display name must have at least 2 characters';

  @override
  String get displayNameSetupButton => 'Continue';

  @override
  String get displayNameSaved => 'Display name saved';

  @override
  String get emailLabel => 'Email';

  @override
  String get saveProfileButton => 'Save Profile';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get editProfileTooltip => 'Edit Profile';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageCurrencyLabel => 'Language / Currency';

  @override
  String get languageEnglishUsd => 'English';

  @override
  String get languageVietnameseVnd => 'Tiếng Việt';

  @override
  String get currencyUnitLabel => 'Currency Unit';

  @override
  String get currencyUnitUsd => 'US Dollar (USD)';

  @override
  String get currencyUnitVnd => 'Vietnamese Dong (VND)';

  @override
  String get languageUpdated => 'Language updated';

  @override
  String get currencyUnitUpdated => 'Currency unit updated';

  @override
  String get darkModeTitle => 'Dark Mode';

  @override
  String get darkModeSubtitle => 'Use dark appearance for the app';

  @override
  String get summaryTotalThisMonth => 'Total this month';

  @override
  String get summaryAvgDaily => 'Avg daily';

  @override
  String get requestFailed => 'Request failed';

  @override
  String get requestTimeoutTryAgain => 'Request timeout. Please try again.';

  @override
  String get networkUnavailableCheckConnection => 'Unable to connect to server. Please check your network.';

  @override
  String get requestCancelled => 'Request cancelled.';

  @override
  String serverErrorTryLater(String statusCode) {
    return 'Server error ($statusCode). Please try again later.';
  }

  @override
  String get unauthorizedRequest => 'Unauthorized request.';

  @override
  String get forbiddenRequest => 'Forbidden request.';

  @override
  String get resourceNotFound => 'Resource not found.';

  @override
  String get invalidRequestData => 'Invalid request data.';

  @override
  String get unexpectedNetworkError => 'Unexpected network error.';

  @override
  String get somethingWentWrongTryAgain => 'Something went wrong. Please try again.';

  @override
  String get continueOfflineButton => 'Use as Guest';

  @override
  String get guestModeBanner => 'You\'re not signed in. Data is saved locally on this device.';

  @override
  String get loginToSyncButton => 'Sign in to Sync';

  @override
  String get exitGuestModeButton => 'Exit Guest Mode';
}
