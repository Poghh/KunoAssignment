import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Expense Tracker'**
  String get appTitle;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @tabDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get tabDashboard;

  /// No description provided for @tabCashflow.
  ///
  /// In en, this message translates to:
  /// **'Cashflow'**
  String get tabCashflow;

  /// No description provided for @tabAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get tabAdd;

  /// No description provided for @tabCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get tabCalendar;

  /// No description provided for @tabUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get tabUser;

  /// No description provided for @helloDeveloper.
  ///
  /// In en, this message translates to:
  /// **'Hello, Developer'**
  String get helloDeveloper;

  /// No description provided for @categorySplitTitle.
  ///
  /// In en, this message translates to:
  /// **'Category Split'**
  String get categorySplitTitle;

  /// No description provided for @categorySplitSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Interactive spending chart'**
  String get categorySplitSubtitle;

  /// No description provided for @recentTransactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactionsTitle;

  /// No description provided for @recentTransactionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Latest 5 expenses'**
  String get recentTransactionsSubtitle;

  /// No description provided for @noExpensesYetTitle.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get noExpensesYetTitle;

  /// No description provided for @noExpensesYetDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap Add Expense to track your first spending.'**
  String get noExpensesYetDescription;

  /// No description provided for @totalThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Total this month'**
  String get totalThisMonth;

  /// No description provided for @summaryVsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'{percentage}% vs last month'**
  String summaryVsLastMonth(String percentage);

  /// No description provided for @failedLoadDashboard.
  ///
  /// In en, this message translates to:
  /// **'Failed to load dashboard'**
  String get failedLoadDashboard;

  /// No description provided for @spendingInsightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Spending Insights'**
  String get spendingInsightsTitle;

  /// No description provided for @insightTrendIncreased.
  ///
  /// In en, this message translates to:
  /// **'increased'**
  String get insightTrendIncreased;

  /// No description provided for @insightTrendDecreased.
  ///
  /// In en, this message translates to:
  /// **'decreased'**
  String get insightTrendDecreased;

  /// No description provided for @insightTopCategoryFallback.
  ///
  /// In en, this message translates to:
  /// **'Top category'**
  String get insightTopCategoryFallback;

  /// No description provided for @insightLineOne.
  ///
  /// In en, this message translates to:
  /// **'{categoryName} {trendVerb} by {percentage}%'**
  String insightLineOne(String categoryName, String trendVerb, String percentage);

  /// No description provided for @insightTopDayEmpty.
  ///
  /// In en, this message translates to:
  /// **'No top spending day yet this month'**
  String get insightTopDayEmpty;

  /// No description provided for @insightTopDayText.
  ///
  /// In en, this message translates to:
  /// **'You spend most on {weekday}'**
  String insightTopDayText(String weekday);

  /// No description provided for @avgDailySpendText.
  ///
  /// In en, this message translates to:
  /// **'Avg daily spend: {amount}'**
  String avgDailySpendText(String amount);

  /// No description provided for @otherCategory.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherCategory;

  /// No description provided for @noCategorySpendingYetThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No category spending yet this month'**
  String get noCategorySpendingYetThisMonth;

  /// No description provided for @categoryFallback.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryFallback;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @failedLoadCalendar.
  ///
  /// In en, this message translates to:
  /// **'Failed to load calendar'**
  String get failedLoadCalendar;

  /// No description provided for @expenseLabel.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expenseLabel;

  /// No description provided for @incomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeLabel;

  /// No description provided for @netLabel.
  ///
  /// In en, this message translates to:
  /// **'Net'**
  String get netLabel;

  /// No description provided for @selectedDaySummary.
  ///
  /// In en, this message translates to:
  /// **'Expense: {expense}  |  Income: {income}'**
  String selectedDaySummary(String expense, String income);

  /// No description provided for @noTransactionsForDay.
  ///
  /// In en, this message translates to:
  /// **'No transactions for this day.'**
  String get noTransactionsForDay;

  /// No description provided for @expensesTitle.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesTitle;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All categories'**
  String get allCategories;

  /// No description provided for @filterByDate.
  ///
  /// In en, this message translates to:
  /// **'Filter by date'**
  String get filterByDate;

  /// No description provided for @failedLoadExpenses.
  ///
  /// In en, this message translates to:
  /// **'Failed to load expenses'**
  String get failedLoadExpenses;

  /// No description provided for @noMatchingExpensesTitle.
  ///
  /// In en, this message translates to:
  /// **'No matching expenses'**
  String get noMatchingExpensesTitle;

  /// No description provided for @noMatchingExpensesDescription.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting filters or add a new expense.'**
  String get noMatchingExpensesDescription;

  /// No description provided for @deleteExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete expense?'**
  String get deleteExpenseTitle;

  /// No description provided for @removeExpensePermanently.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{title}\" permanently?'**
  String removeExpensePermanently(String title);

  /// No description provided for @expenseDeleted.
  ///
  /// In en, this message translates to:
  /// **'Expense deleted'**
  String get expenseDeleted;

  /// No description provided for @deleteExpenseFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete expense. Please retry.'**
  String get deleteExpenseFailed;

  /// No description provided for @addTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransactionTitle;

  /// No description provided for @editTransactionTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get editTransactionTitle;

  /// No description provided for @transactionAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Transaction added successfully'**
  String get transactionAddedSuccessfully;

  /// No description provided for @transactionUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Transaction updated successfully'**
  String get transactionUpdatedSuccessfully;

  /// No description provided for @saveTransactionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save transaction. Please retry.'**
  String get saveTransactionFailed;

  /// No description provided for @noCategoriesAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'No categories available'**
  String get noCategoriesAvailableTitle;

  /// No description provided for @noCategoriesAvailableDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your first category to add transactions.'**
  String get noCategoriesAvailableDescription;

  /// No description provided for @transactionTypeExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get transactionTypeExpense;

  /// No description provided for @transactionTypeIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get transactionTypeIncome;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @titleValidationError.
  ///
  /// In en, this message translates to:
  /// **'Title must have at least 2 characters'**
  String get titleValidationError;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @amountValidationError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get amountValidationError;

  /// No description provided for @categoryValidationError.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get categoryValidationError;

  /// No description provided for @addCategoryButton.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategoryButton;

  /// No description provided for @createCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Category'**
  String get createCategoryTitle;

  /// No description provided for @createCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get createCategoryLabel;

  /// No description provided for @createCategoryIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get createCategoryIconLabel;

  /// No description provided for @createCategoryColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get createCategoryColorLabel;

  /// No description provided for @createCategoryValidationError.
  ///
  /// In en, this message translates to:
  /// **'Category name must have at least 2 characters'**
  String get createCategoryValidationError;

  /// No description provided for @createCategoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createCategoryConfirm;

  /// No description provided for @createCategoryFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create category. Please retry.'**
  String get createCategoryFailed;

  /// No description provided for @deleteCategoryButton.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get deleteCategoryButton;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category?'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete category \"{name}\"?'**
  String deleteCategoryConfirmMessage(String name);

  /// No description provided for @deleteCategorySuccess.
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get deleteCategorySuccess;

  /// No description provided for @deleteCategoryFailed.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete category. Please retry.'**
  String get deleteCategoryFailed;

  /// No description provided for @deleteCategoryInUse.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete category because it has existing transactions.'**
  String get deleteCategoryInUse;

  /// No description provided for @categoryCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Category \"{name}\" created'**
  String categoryCreatedSuccessfully(String name);

  /// No description provided for @categoryManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Category Management'**
  String get categoryManagementTitle;

  /// No description provided for @categoryManagementSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create categories and delete ones that are no longer used.'**
  String get categoryManagementSubtitle;

  /// No description provided for @manageCategoriesButton.
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get manageCategoriesButton;

  /// No description provided for @manageCategoriesDescription.
  ///
  /// In en, this message translates to:
  /// **'View all categories and clean up unused ones.'**
  String get manageCategoriesDescription;

  /// No description provided for @categoryUsageEmpty.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get categoryUsageEmpty;

  /// No description provided for @categoryUsageCount.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions'**
  String categoryUsageCount(String count);

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @locationLabel.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get locationLabel;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @saveTransactionButton.
  ///
  /// In en, this message translates to:
  /// **'Save Transaction'**
  String get saveTransactionButton;

  /// No description provided for @updateTransactionButton.
  ///
  /// In en, this message translates to:
  /// **'Update Transaction'**
  String get updateTransactionButton;

  /// No description provided for @userTitle.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue tracking your expenses'**
  String get loginSubtitle;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// No description provided for @loginEmailValidationError.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get loginEmailValidationError;

  /// No description provided for @loginPasswordValidationError.
  ///
  /// In en, this message translates to:
  /// **'Password must have at least 6 characters'**
  String get loginPasswordValidationError;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged in successfully'**
  String get loginSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get loginFailed;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use username and password to continue'**
  String get registerSubtitle;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @registerSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registered successfully. Please login.'**
  String get registerSuccess;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Please check your input.'**
  String get registerFailed;

  /// No description provided for @registerUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get registerUsernameLabel;

  /// No description provided for @registerUsernameValidationError.
  ///
  /// In en, this message translates to:
  /// **'Username must have at least 2 characters'**
  String get registerUsernameValidationError;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordValidationError.
  ///
  /// In en, this message translates to:
  /// **'Confirm password does not match'**
  String get confirmPasswordValidationError;

  /// No description provided for @noAccountPrompt.
  ///
  /// In en, this message translates to:
  /// **'No account yet?'**
  String get noAccountPrompt;

  /// No description provided for @registerNowButton.
  ///
  /// In en, this message translates to:
  /// **'Register now'**
  String get registerNowButton;

  /// No description provided for @loginNowButton.
  ///
  /// In en, this message translates to:
  /// **'Back to login'**
  String get loginNowButton;

  /// No description provided for @logoutButton.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButton;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout?'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Do you want to logout from this device?'**
  String get logoutConfirmMessage;

  /// No description provided for @logoutSuccess.
  ///
  /// In en, this message translates to:
  /// **'Logged out'**
  String get logoutSuccess;

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Before you start'**
  String get setupTitle;

  /// No description provided for @setupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Setup your preferences'**
  String get setupSubtitle;

  /// No description provided for @setupLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get setupLanguageLabel;

  /// No description provided for @setupCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get setupCurrencyLabel;

  /// No description provided for @setupThemeLabel.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get setupThemeLabel;

  /// No description provided for @setupThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get setupThemeLight;

  /// No description provided for @setupThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get setupThemeDark;

  /// No description provided for @setupNextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get setupNextButton;

  /// No description provided for @setupContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get setupContinueButton;

  /// No description provided for @setupSaved.
  ///
  /// In en, this message translates to:
  /// **'Preferences saved'**
  String get setupSaved;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Language, currency and appearance'**
  String get settingsSubtitle;

  /// No description provided for @currencyFormatUpdated.
  ///
  /// In en, this message translates to:
  /// **'Currency format updated'**
  String get currencyFormatUpdated;

  /// No description provided for @darkModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Dark mode enabled'**
  String get darkModeEnabled;

  /// No description provided for @lightModeEnabled.
  ///
  /// In en, this message translates to:
  /// **'Light mode enabled'**
  String get lightModeEnabled;

  /// No description provided for @monthlySummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly Summary'**
  String get monthlySummaryTitle;

  /// No description provided for @monthlySummarySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Simple overview of current month'**
  String get monthlySummarySubtitle;

  /// No description provided for @syncingData.
  ///
  /// In en, this message translates to:
  /// **'Syncing data...'**
  String get syncingData;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @userDefaultDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Your Account'**
  String get userDefaultDisplayName;

  /// No description provided for @displayNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayNameLabel;

  /// No description provided for @displayNameSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'What should we call you?'**
  String get displayNameSetupTitle;

  /// No description provided for @displayNameSetupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set your display name to personalize your experience.'**
  String get displayNameSetupSubtitle;

  /// No description provided for @displayNameSetupHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your display name'**
  String get displayNameSetupHint;

  /// No description provided for @displayNameSetupValidationError.
  ///
  /// In en, this message translates to:
  /// **'Display name must have at least 2 characters'**
  String get displayNameSetupValidationError;

  /// No description provided for @displayNameSetupButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get displayNameSetupButton;

  /// No description provided for @displayNameSaved.
  ///
  /// In en, this message translates to:
  /// **'Display name saved'**
  String get displayNameSaved;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @saveProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfileButton;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated'**
  String get profileUpdated;

  /// No description provided for @editProfileTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTooltip;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// No description provided for @languageCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Language / Currency'**
  String get languageCurrencyLabel;

  /// No description provided for @languageEnglishUsd.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglishUsd;

  /// No description provided for @languageVietnameseVnd.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get languageVietnameseVnd;

  /// No description provided for @currencyUnitLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency Unit'**
  String get currencyUnitLabel;

  /// No description provided for @currencyUnitUsd.
  ///
  /// In en, this message translates to:
  /// **'US Dollar (USD)'**
  String get currencyUnitUsd;

  /// No description provided for @currencyUnitVnd.
  ///
  /// In en, this message translates to:
  /// **'Vietnamese Dong (VND)'**
  String get currencyUnitVnd;

  /// No description provided for @languageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Language updated'**
  String get languageUpdated;

  /// No description provided for @currencyUnitUpdated.
  ///
  /// In en, this message translates to:
  /// **'Currency unit updated'**
  String get currencyUnitUpdated;

  /// No description provided for @darkModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkModeTitle;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use dark appearance for the app'**
  String get darkModeSubtitle;

  /// No description provided for @summaryTotalThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Total this month'**
  String get summaryTotalThisMonth;

  /// No description provided for @summaryAvgDaily.
  ///
  /// In en, this message translates to:
  /// **'Avg daily'**
  String get summaryAvgDaily;

  /// No description provided for @requestFailed.
  ///
  /// In en, this message translates to:
  /// **'Request failed'**
  String get requestFailed;

  /// No description provided for @requestTimeoutTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Request timeout. Please try again.'**
  String get requestTimeoutTryAgain;

  /// No description provided for @networkUnavailableCheckConnection.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to server. Please check your network.'**
  String get networkUnavailableCheckConnection;

  /// No description provided for @requestCancelled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled.'**
  String get requestCancelled;

  /// No description provided for @serverErrorTryLater.
  ///
  /// In en, this message translates to:
  /// **'Server error ({statusCode}). Please try again later.'**
  String serverErrorTryLater(String statusCode);

  /// No description provided for @unauthorizedRequest.
  ///
  /// In en, this message translates to:
  /// **'Unauthorized request.'**
  String get unauthorizedRequest;

  /// No description provided for @forbiddenRequest.
  ///
  /// In en, this message translates to:
  /// **'Forbidden request.'**
  String get forbiddenRequest;

  /// No description provided for @resourceNotFound.
  ///
  /// In en, this message translates to:
  /// **'Resource not found.'**
  String get resourceNotFound;

  /// No description provided for @invalidRequestData.
  ///
  /// In en, this message translates to:
  /// **'Invalid request data.'**
  String get invalidRequestData;

  /// No description provided for @unexpectedNetworkError.
  ///
  /// In en, this message translates to:
  /// **'Unexpected network error.'**
  String get unexpectedNetworkError;

  /// No description provided for @somethingWentWrongTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrongTryAgain;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'vi': return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
