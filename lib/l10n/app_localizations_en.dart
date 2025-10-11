// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get person => 'Person';

  @override
  String get workTitle => 'Work Title';

  @override
  String get archived => 'Archived';

  @override
  String get me => 'Me';

  @override
  String get noItems => 'No items currently checked out.';

  @override
  String get noFilterItems => 'No items match the selected filters.';

  @override
  String get scanMusic => 'Scan the QR code on the music booklet.';

  @override
  String get scanPerson => 'Scan the QR code for the person.';

  @override
  String get addPerson => 'Add a new person';

  @override
  String get addWork => 'Add a new work';

  @override
  String get reconnected => 'Reconnected to network.';

  @override
  String get disconnected => 'Disconnected from network.';

  @override
  String get continueText => 'Continue';

  @override
  String get missingItems =>
      'Either the work or user ID is missing. Please go back and scan both QR codes.';

  @override
  String get errorLoadingSummary =>
      'Error loading summary details. Please try again.';

  @override
  String get finalize => 'Finalize';

  @override
  String get checkoutSuccess => 'Checkout successful!';

  @override
  String get returnSuccess => 'Return successful!';

  @override
  String get cancel => 'Cancel';

  @override
  String get apply => 'Apply';

  @override
  String archivedItems(int count) {
    return 'Archived Items ($count)';
  }

  @override
  String get archiveEmpty => 'Archive is empty.';

  @override
  String get scanUserBarcode => 'Scan the QR code for the user.';

  @override
  String get emailOptional => 'Email (optional)';

  @override
  String get composerOptional => 'Composer (optional)';

  @override
  String get name => 'Name';

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String get returning => 'is returning';

  @override
  String get checkingOut => 'is checking out';

  @override
  String get search => 'Search';

  @override
  String get returnItem => 'Return';

  @override
  String get appTitle => 'SSKor Note App';

  @override
  String get failedToRefresh =>
      'Failed to refresh data. Check connection or logs.';

  @override
  String failedToExportUsers(String error) {
    return 'Failed to export users: $error';
  }

  @override
  String get addNewUser => 'Add New User';

  @override
  String get userId => 'User ID';

  @override
  String get userIdHelper => 'Unique identifier for the user';

  @override
  String get userIdHelperMaxLength =>
      'Unique identifier for the user (max 15 characters)';

  @override
  String get nameOptional => 'Name (optional)';

  @override
  String get nameHelper => 'If empty, will use User ID as name';

  @override
  String get userIdRequired => 'User ID is required';

  @override
  String userCreatedSuccess(String userId) {
    return 'User \"$userId\" created successfully';
  }

  @override
  String failedToCreateUser(String error) {
    return 'Failed to create user: $error';
  }

  @override
  String get addUserButton => 'Add User';

  @override
  String get addNewWork => 'Add New Work';

  @override
  String get workId => 'Work ID';

  @override
  String get workIdHelper => 'Unique identifier for the work';

  @override
  String get workIdHelperMaxLength =>
      'Unique identifier for the work (max 15 characters)';

  @override
  String get titleOptional => 'Title (optional)';

  @override
  String get titleHelper => 'If empty, will use Work ID as title';

  @override
  String get workIdRequired => 'Work ID is required';

  @override
  String workCreatedSuccess(String workId) {
    return 'Work \"$workId\" created successfully';
  }

  @override
  String failedToCreateWork(String error) {
    return 'Failed to create work: $error';
  }

  @override
  String get addWorkButton => 'Add Work';

  @override
  String get scanQrCode => 'Scan QR Code';

  @override
  String get printUsersList => 'Print Users List';

  @override
  String get addUserTooltip => 'Add User';

  @override
  String get generateBarcodeSheet => 'Generate Barcode Sheet';

  @override
  String get addWorkTooltip => 'Add Work';

  @override
  String get checkouts => 'Checkouts';

  @override
  String get users => 'Users';

  @override
  String get works => 'Works';

  @override
  String get searchWorks => 'Search works...';

  @override
  String instances(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count instances',
      one: '1 instance',
    );
    return '$_temp0';
  }

  @override
  String pages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return '$_temp0';
  }

  @override
  String get unknownTitle => 'Unknown Title';

  @override
  String get unknownUser => 'Unknown User';

  @override
  String get unknownComposer => 'Unknown Composer';

  @override
  String get unknownDate => 'Unknown date';

  @override
  String get invalidDate => 'Invalid Date';

  @override
  String get unknown => 'Unknown';

  @override
  String idLabel(String id) {
    return 'ID: $id';
  }

  @override
  String emailLabel(String email) {
    return 'Email: $email';
  }

  @override
  String composerLabel(String composer) {
    return 'Composer: $composer';
  }

  @override
  String get deleteUser => 'Delete User';

  @override
  String confirmDeleteUser(String name) {
    return 'Are you sure you want to delete \"$name\"?';
  }

  @override
  String get userDeletionNotImplemented => 'User deletion not implemented yet';

  @override
  String failedToDeleteUser(String error) {
    return 'Failed to delete user: $error';
  }

  @override
  String get delete => 'Delete';

  @override
  String get deleteWork => 'Delete Work';

  @override
  String confirmDeleteWork(String title) {
    return 'Are you sure you want to delete \"$title\"?';
  }

  @override
  String get workDeletionNotImplemented => 'Work deletion not implemented yet';

  @override
  String failedToDeleteWork(String error) {
    return 'Failed to delete work: $error';
  }

  @override
  String barcodeForTitle(String title) {
    return 'Barcode for \"$title\"';
  }

  @override
  String workIdLabel(String workId) {
    return 'Work ID: $workId';
  }

  @override
  String get barcodeComingSoon => 'Barcode generation feature coming soon!';

  @override
  String get close => 'Close';

  @override
  String get enterPassword => 'Enter Password';

  @override
  String get passwordPrompt => 'Enter your password to access the application:';

  @override
  String get password => 'Password';

  @override
  String get unlock => 'Unlock';

  @override
  String get passwordRequired => 'Password cannot be empty';

  @override
  String get confirmMusic => 'Confirm Music';

  @override
  String get confirmPerson => 'Confirm Person';

  @override
  String get summary => 'Summary';

  @override
  String get enterWorkDetails => 'Enter Work Details';

  @override
  String get enterUserId => 'Enter User ID';

  @override
  String get workIdExample => 'e.g. WORK123';

  @override
  String get instanceNumber => 'Instance Number';

  @override
  String get instanceExample => 'e.g. 1';

  @override
  String get userIdExample => 'e.g. USER123';

  @override
  String get instanceRequired => 'Instance number is required';

  @override
  String get instanceInvalidNumber => 'Instance number must be a valid number';

  @override
  String get ok => 'OK';

  @override
  String get manualInput => 'Manual Input';

  @override
  String errorFetchingWork(String error) {
    return 'Error fetching work details: $error';
  }

  @override
  String checkoutFailed(String error) {
    return 'Checkout failed: $error';
  }

  @override
  String get title => 'Title';

  @override
  String get pleaseEnterTitle => 'Please enter a title';

  @override
  String scannedUserId(String userId) {
    return 'Scanned User ID: $userId';
  }

  @override
  String pdfSavedTo(String path) {
    return 'PDF saved to $path';
  }

  @override
  String failedToGeneratePdf(String error) {
    return 'Failed to generate PDF: $error';
  }
}
