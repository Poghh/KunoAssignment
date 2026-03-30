// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Quản Lý Chi Tiêu';

  @override
  String get commonRetry => 'Thử lại';

  @override
  String get commonCancel => 'Hủy';

  @override
  String get commonDelete => 'Xóa';

  @override
  String get tabDashboard => 'Tổng quan';

  @override
  String get tabCashflow => 'Thu - Chi';

  @override
  String get tabAdd => 'Thêm';

  @override
  String get tabCalendar => 'Lịch';

  @override
  String get tabUser => 'Người dùng';

  @override
  String get helloDeveloper => 'Xin chào bạn';

  @override
  String helloName(String name) => 'Xin chào, $name';

  @override
  String get categorySplitTitle => 'Phân bổ danh mục';

  @override
  String get categorySplitSubtitle => 'Biểu đồ chi tiêu theo danh mục';

  @override
  String get recentTransactionsTitle => 'Giao dịch gần đây';

  @override
  String get recentTransactionsSubtitle => '5 khoản chi tiêu mới nhất';

  @override
  String get noExpensesYetTitle => 'Chưa có giao dịch';

  @override
  String get noExpensesYetDescription => 'Nhấn Thêm để bắt đầu theo dõi chi tiêu.';

  @override
  String get totalThisMonth => 'Tổng tháng này';

  @override
  String summaryVsLastMonth(String percentage) {
    return '$percentage% so với tháng trước';
  }

  @override
  String get failedLoadDashboard => 'Không tải được tổng quan';

  @override
  String get spendingInsightsTitle => 'Thông tin chi tiêu';

  @override
  String get insightTrendIncreased => 'tăng';

  @override
  String get insightTrendDecreased => 'giảm';

  @override
  String get insightTopCategoryFallback => 'Danh mục nổi bật';

  @override
  String insightLineOne(String categoryName, String trendVerb, String percentage) {
    return '$categoryName $trendVerb $percentage%';
  }

  @override
  String get insightTopDayEmpty => 'Chưa có ngày chi tiêu nổi bật trong tháng';

  @override
  String insightTopDayText(String weekday) {
    return 'Bạn chi tiêu nhiều nhất vào $weekday';
  }

  @override
  String avgDailySpendText(String amount) {
    return 'Chi tiêu trung bình/ngày: $amount';
  }

  @override
  String get categoryNameFood => 'Ăn uống';

  @override
  String get categoryNameTransport => 'Di chuyển';

  @override
  String get categoryNameShopping => 'Mua sắm';

  @override
  String get categoryNameUtilities => 'Tiện ích';

  @override
  String get categoryNameEntertainment => 'Giải trí';

  @override
  String get categoryNameHealth => 'Sức khỏe';

  @override
  String get categoryNameBills => 'Hóa đơn';

  @override
  String get categoryNameSalary => 'Lương';

  @override
  String get otherCategory => 'Khác';

  @override
  String get noCategorySpendingYetThisMonth => 'Tháng này chưa có dữ liệu chi theo danh mục';

  @override
  String get categoryFallback => 'Danh mục';

  @override
  String get calendarTitle => 'Lịch';

  @override
  String get failedLoadCalendar => 'Không tải được lịch';

  @override
  String get expenseLabel => 'Chi';

  @override
  String get incomeLabel => 'Thu';

  @override
  String get netLabel => 'Ròng';

  @override
  String selectedDaySummary(String expense, String income) {
    return 'Chi: $expense  |  Thu: $income';
  }

  @override
  String get noTransactionsForDay => 'Không có giao dịch trong ngày này.';

  @override
  String get expensesTitle => 'Chi tiêu';

  @override
  String get clearFilters => 'Xóa bộ lọc';

  @override
  String get categoryLabel => 'Danh mục';

  @override
  String get allCategories => 'Tất cả danh mục';

  @override
  String get filterByDate => 'Lọc theo ngày';

  @override
  String get sortByLabel => 'Sắp xếp';

  @override
  String get sortLatest => 'Mới nhất trước';

  @override
  String get sortOldest => 'Cũ nhất trước';

  @override
  String get sortAmountHigh => 'Số tiền (cao → thấp)';

  @override
  String get sortAmountLow => 'Số tiền (thấp → cao)';

  @override
  String get failedLoadExpenses => 'Không tải được danh sách chi tiêu';

  @override
  String get noMatchingExpensesTitle => 'Không có giao dịch phù hợp';

  @override
  String get noMatchingExpensesDescription => 'Hãy đổi bộ lọc hoặc thêm giao dịch mới.';

  @override
  String get deleteExpenseTitle => 'Xóa giao dịch?';

  @override
  String removeExpensePermanently(String title) {
    return 'Xóa \"$title\" vĩnh viễn?';
  }

  @override
  String get expenseDeleted => 'Đã xóa giao dịch';

  @override
  String get deleteExpenseFailed => 'Xóa giao dịch thất bại. Vui lòng thử lại.';

  @override
  String get addTransactionTitle => 'Thêm giao dịch';

  @override
  String get editTransactionTitle => 'Sửa giao dịch';

  @override
  String get transactionAddedSuccessfully => 'Thêm giao dịch thành công';

  @override
  String get transactionUpdatedSuccessfully => 'Cập nhật giao dịch thành công';

  @override
  String get saveTransactionFailed => 'Lưu giao dịch thất bại. Vui lòng thử lại.';

  @override
  String get noCategoriesAvailableTitle => 'Chưa có danh mục';

  @override
  String get noCategoriesAvailableDescription => 'Hãy tạo danh mục đầu tiên để thêm giao dịch.';

  @override
  String get transactionTypeExpense => 'Chi';

  @override
  String get transactionTypeIncome => 'Thu';

  @override
  String get titleLabel => 'Tiêu đề';

  @override
  String get titleValidationError => 'Tiêu đề phải có ít nhất 2 ký tự';

  @override
  String get amountLabel => 'Số tiền';

  @override
  String get amountValidationError => 'Vui lòng nhập số tiền hợp lệ';

  @override
  String get categoryValidationError => 'Vui lòng chọn danh mục';

  @override
  String get addCategoryButton => 'Thêm danh mục';

  @override
  String get createCategoryTitle => 'Tạo danh mục';

  @override
  String get createCategoryLabel => 'Tên danh mục';

  @override
  String get createCategoryIconLabel => 'Biểu tượng';

  @override
  String get createCategoryColorLabel => 'Màu sắc';

  @override
  String get createCategoryValidationError => 'Tên danh mục phải có ít nhất 2 ký tự';

  @override
  String get createCategoryConfirm => 'Tạo';

  @override
  String get createCategoryFailed => 'Không tạo được danh mục. Vui lòng thử lại.';

  @override
  String get deleteCategoryButton => 'Xóa danh mục';

  @override
  String get deleteCategoryTitle => 'Xóa danh mục?';

  @override
  String deleteCategoryConfirmMessage(String name) {
    return 'Xóa danh mục \"$name\"?';
  }

  @override
  String get deleteCategorySuccess => 'Đã xóa danh mục';

  @override
  String get deleteCategoryFailed => 'Không thể xóa danh mục. Vui lòng thử lại.';

  @override
  String get deleteCategoryInUse => 'Không thể xóa danh mục vì đang có giao dịch.';

  @override
  String categoryCreatedSuccessfully(String name) {
    return 'Đã tạo danh mục \"$name\"';
  }

  @override
  String get categoryManagementTitle => 'Quản lý danh mục';

  @override
  String get categoryManagementSubtitle => 'Tạo danh mục mới và xóa các danh mục chưa có giao dịch.';

  @override
  String get manageCategoriesButton => 'Quản lý danh mục';

  @override
  String get manageCategoriesDescription => 'Xem toàn bộ danh mục và dọn dẹp danh mục không còn dùng.';

  @override
  String get categoryUsageEmpty => 'Chưa có giao dịch';

  @override
  String categoryUsageCount(String count) {
    return '$count giao dịch';
  }

  @override
  String get dateLabel => 'Ngày';

  @override
  String get locationLabel => 'Địa điểm';

  @override
  String get notesLabel => 'Ghi chú';

  @override
  String get saveTransactionButton => 'Lưu giao dịch';

  @override
  String get updateTransactionButton => 'Cập nhật giao dịch';

  @override
  String get userTitle => 'Người dùng';

  @override
  String get loginTitle => 'Chào mừng quay lại';

  @override
  String get loginSubtitle => 'Đăng nhập để tiếp tục quản lý thu chi';

  @override
  String get loginPasswordLabel => 'Mật khẩu';

  @override
  String get loginButton => 'Đăng nhập';

  @override
  String get loginEmailValidationError => 'Vui lòng nhập email hợp lệ';

  @override
  String get loginPasswordValidationError => 'Mật khẩu phải có ít nhất 6 ký tự';

  @override
  String get loginSuccess => 'Đăng nhập thành công';

  @override
  String get loginFailed => 'Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin.';

  @override
  String get registerTitle => 'Tạo tài khoản';

  @override
  String get registerSubtitle => 'Nhập email và mật khẩu để tiếp tục';

  @override
  String get registerButton => 'Đăng ký';

  @override
  String get registerSuccess => 'Đăng ký thành công. Vui lòng đăng nhập.';

  @override
  String get registerFailed => 'Đăng ký thất bại. Vui lòng kiểm tra lại thông tin.';

  @override
  String get registerUsernameLabel => 'Tên người dùng';

  @override
  String get registerUsernameValidationError => 'Tên người dùng phải có ít nhất 2 ký tự';

  @override
  String get confirmPasswordLabel => 'Xác nhận mật khẩu';

  @override
  String get confirmPasswordValidationError => 'Mật khẩu xác nhận không khớp';

  @override
  String get noAccountPrompt => 'Chưa có tài khoản?';

  @override
  String get registerNowButton => 'Đăng ký ngay';

  @override
  String get loginNowButton => 'Quay lại đăng nhập';

  @override
  String get logoutButton => 'Đăng xuất';

  @override
  String get logoutConfirmTitle => 'Đăng xuất?';

  @override
  String get logoutConfirmMessage => 'Bạn có muốn đăng xuất khỏi thiết bị này không?';

  @override
  String get logoutSuccess => 'Đã đăng xuất';

  @override
  String get setupTitle => 'Trước khi bắt đầu';

  @override
  String get setupSubtitle => 'Chọn ngôn ngữ và đơn vị tiền tệ mặc định';

  @override
  String get setupLanguageLabel => 'Ngôn ngữ ưu tiên';

  @override
  String get setupCurrencyLabel => 'Tiền tệ mặc định';

  @override
  String get setupThemeLabel => 'Giao diện';

  @override
  String get setupThemeLight => 'Sáng';

  @override
  String get setupThemeDark => 'Tối';

  @override
  String get setupNextButton => 'Tiếp theo';

  @override
  String get setupContinueButton => 'Tiếp tục';

  @override
  String get setupSaved => 'Đã lưu tùy chọn';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String get settingsSubtitle => 'Ngôn ngữ, tiền tệ và giao diện';

  @override
  String get currencyFormatUpdated => 'Đã cập nhật định dạng tiền tệ';

  @override
  String get darkModeEnabled => 'Đã bật chế độ tối';

  @override
  String get lightModeEnabled => 'Đã bật chế độ sáng';

  @override
  String get monthlySummaryTitle => 'Tổng kết tháng';

  @override
  String get monthlySummarySubtitle => 'Tóm tắt đơn giản trong tháng hiện tại';

  @override
  String get syncingData => 'Đang đồng bộ dữ liệu...';

  @override
  String get editProfileTitle => 'Chỉnh sửa hồ sơ';

  @override
  String get userDefaultDisplayName => 'Tài khoản của bạn';

  @override
  String get displayNameLabel => 'Tên hiển thị';

  @override
  String get displayNameSetupTitle => 'Chúng tôi sẽ gọi bạn là gì?';

  @override
  String get displayNameSetupSubtitle => 'Thiết lập tên hiển thị để cá nhân hóa trải nghiệm của bạn.';

  @override
  String get displayNameSetupHint => 'Nhập tên hiển thị';

  @override
  String get displayNameSetupValidationError => 'Tên hiển thị phải có ít nhất 2 ký tự';

  @override
  String get displayNameSetupButton => 'Tiếp tục';

  @override
  String get displayNameSaved => 'Đã lưu tên hiển thị';

  @override
  String get emailLabel => 'Email';

  @override
  String get saveProfileButton => 'Lưu hồ sơ';

  @override
  String get profileUpdated => 'Đã cập nhật hồ sơ';

  @override
  String get editProfileTooltip => 'Chỉnh sửa hồ sơ';

  @override
  String get languageLabel => 'Ngôn ngữ';

  @override
  String get languageCurrencyLabel => 'Ngôn ngữ / Tiền tệ';

  @override
  String get languageEnglishUsd => 'English';

  @override
  String get languageVietnameseVnd => 'Tiếng Việt';

  @override
  String get currencyUnitLabel => 'Đơn vị tiền tệ';

  @override
  String get currencyUnitUsd => 'Đô la Mỹ (USD)';

  @override
  String get currencyUnitVnd => 'Đồng Việt Nam (VND)';

  @override
  String get languageUpdated => 'Đã cập nhật ngôn ngữ';

  @override
  String get currencyUnitUpdated => 'Đã cập nhật đơn vị tiền tệ';

  @override
  String get darkModeTitle => 'Chế độ tối';

  @override
  String get darkModeSubtitle => 'Sử dụng giao diện tối cho ứng dụng';

  @override
  String get summaryTotalThisMonth => 'Tổng tháng này';

  @override
  String get summaryAvgDaily => 'TB mỗi ngày';

  @override
  String get requestFailed => 'Yêu cầu thất bại';

  @override
  String get requestTimeoutTryAgain => 'Yêu cầu quá thời gian. Vui lòng thử lại.';

  @override
  String get networkUnavailableCheckConnection => 'Không thể kết nối tới máy chủ. Vui lòng kiểm tra mạng.';

  @override
  String get requestCancelled => 'Yêu cầu đã bị hủy.';

  @override
  String serverErrorTryLater(String statusCode) {
    return 'Lỗi máy chủ ($statusCode). Vui lòng thử lại sau.';
  }

  @override
  String get unauthorizedRequest => 'Yêu cầu chưa được xác thực.';

  @override
  String get forbiddenRequest => 'Bạn không có quyền truy cập.';

  @override
  String get resourceNotFound => 'Không tìm thấy dữ liệu.';

  @override
  String get invalidRequestData => 'Dữ liệu gửi lên không hợp lệ.';

  @override
  String get unexpectedNetworkError => 'Lỗi mạng không xác định.';

  @override
  String get somethingWentWrongTryAgain => 'Có lỗi xảy ra. Vui lòng thử lại.';

  @override
  String get continueOfflineButton => 'Dùng với chế độ khách';

  @override
  String get guestModeBanner => 'Bạn chưa đăng nhập. Dữ liệu được lưu trên thiết bị này.';

  @override
  String get loginToSyncButton => 'Đăng nhập để đồng bộ';

  @override
  String get exitGuestModeButton => 'Thoát chế độ khách';
}
