class AppSpacing {
  const AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;

  /// Bottom padding to clear the persistent bottom navigation bar.
  static const double bottomNavClearance = 110;
}

class AppRadius {
  const AppRadius._();

  static const double sm = 10;
  static const double md = 12;
  static const double lg = 14;
  static const double xl = 16;
  static const double xxl = 18;
  /// Large rounded corner used for the splash-screen logo container.
  static const double logo = 28;
}

class AppSize {
  const AppSize._();

  static const double authMaxWidth = 460;
  static const double buttonHeight = 50;
  static const double loadingIndicator = 20;
  static const double loadingStroke = 2;
}

class AppIconSize {
  const AppIconSize._();

  static const double sm = 18;
  static const double md = 20;
  static const double lg = 24;
}

class AppContainerSize {
  const AppContainerSize._();

  /// Extra-small icon container (e.g. calendar transaction tile).
  static const double iconXs = 32;
  static const double iconSm = 34;
  static const double iconMd = 42;
  static const double iconLg = 44;
  static const double avatarRadius = 26;
  static const double bottomSheetHandleWidth = 42;
  static const double bottomSheetHandleHeight = 4;
  static const double headerAction = 42;
  /// Splash-screen logo container.
  static const double splashLogo = 100;
}

class AppDurationMs {
  const AppDurationMs._();

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 220);
}

class AppAnimationOffset {
  const AppAnimationOffset._();

  static const double slideEntrance = 36;
}

class AppDateFormat {
  const AppDateFormat._();

  static const String monthYear = 'MMMM yyyy';
  static const String weekdayDayMonth = 'EEE, dd MMM';
  static const String fullDate = 'EEEE, dd MMM yyyy';
  static const String weekdayShort = 'EEE';
  static const String weekdayFull = 'EEEE';
}
