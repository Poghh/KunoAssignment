import '../../l10n/app_localizations.dart';

extension CategoryLocalizationExtension on AppLocalizations {
  /// Returns the localized display name for a category.
  /// Default (seeded) categories are translated; user-created categories
  /// keep their original name unchanged.
  String localizeCategory(String? name) {
    switch ((name ?? '').trim().toLowerCase()) {
      case 'food':
        return categoryNameFood;
      case 'transport':
        return categoryNameTransport;
      case 'shopping':
        return categoryNameShopping;
      case 'utilities':
        return categoryNameUtilities;
      case 'entertainment':
        return categoryNameEntertainment;
      case 'health':
        return categoryNameHealth;
      case 'bills':
        return categoryNameBills;
      case 'salary':
        return categoryNameSalary;
      default:
        return name ?? categoryFallback;
    }
  }
}
