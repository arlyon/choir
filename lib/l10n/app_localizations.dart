import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nb.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nb'),
  ];

  /// The user
  ///
  /// In en, this message translates to:
  /// **'Person'**
  String get person;

  /// The name of a work
  ///
  /// In en, this message translates to:
  /// **'Work Title'**
  String get workTitle;

  /// The archived state of a work
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// The user (first person)
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// No items currently checked out.
  ///
  /// In en, this message translates to:
  /// **'No items currently checked out.'**
  String get noItems;

  /// No items match the selected filters.
  ///
  /// In en, this message translates to:
  /// **'No items match the selected filters.'**
  String get noFilterItems;

  /// Scan the QR code on the music booklet.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code on the music booklet.'**
  String get scanMusic;

  /// Scan the QR code for the person.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code for the person.'**
  String get scanPerson;

  /// Add a new person
  ///
  /// In en, this message translates to:
  /// **'Add a new person'**
  String get addPerson;

  /// No description provided for @addWork.
  ///
  /// In en, this message translates to:
  /// **'Add a new work'**
  String get addWork;

  /// Reconnected to network.
  ///
  /// In en, this message translates to:
  /// **'Reconnected to network.'**
  String get reconnected;

  /// Disconnected from network.
  ///
  /// In en, this message translates to:
  /// **'Disconnected from network.'**
  String get disconnected;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @missingItems.
  ///
  /// In en, this message translates to:
  /// **'Either the work or user ID is missing. Please go back and scan both QR codes.'**
  String get missingItems;

  /// No description provided for @errorLoadingSummary.
  ///
  /// In en, this message translates to:
  /// **'Error loading summary details. Please try again.'**
  String get errorLoadingSummary;

  /// No description provided for @finalize.
  ///
  /// In en, this message translates to:
  /// **'Finalize'**
  String get finalize;

  /// Checkout successful!
  ///
  /// In en, this message translates to:
  /// **'Checkout successful!'**
  String get checkoutSuccess;

  /// Return successful!
  ///
  /// In en, this message translates to:
  /// **'Return successful!'**
  String get returnSuccess;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Archived Items ({count})
  ///
  /// In en, this message translates to:
  /// **'Archived Items ({count})'**
  String archivedItems(int count);

  /// No description provided for @archiveEmpty.
  ///
  /// In en, this message translates to:
  /// **'Archive is empty.'**
  String get archiveEmpty;

  /// No description provided for @scanUserBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code for the user.'**
  String get scanUserBarcode;

  /// No description provided for @emailOptional.
  ///
  /// In en, this message translates to:
  /// **'Email (optional)'**
  String get emailOptional;

  /// No description provided for @composerOptional.
  ///
  /// In en, this message translates to:
  /// **'Composer (optional)'**
  String get composerOptional;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @pleaseEnterName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get pleaseEnterName;

  /// No description provided for @returning.
  ///
  /// In en, this message translates to:
  /// **'is returning'**
  String get returning;

  /// No description provided for @checkingOut.
  ///
  /// In en, this message translates to:
  /// **'is checking out'**
  String get checkingOut;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @returnItem.
  ///
  /// In en, this message translates to:
  /// **'Return'**
  String get returnItem;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SSKor Note App'**
  String get appTitle;

  /// No description provided for @failedToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh data. Check connection or logs.'**
  String get failedToRefresh;

  /// No description provided for @failedToExportUsers.
  ///
  /// In en, this message translates to:
  /// **'Failed to export users: {error}'**
  String failedToExportUsers(String error);

  /// No description provided for @addNewUser.
  ///
  /// In en, this message translates to:
  /// **'Add New User'**
  String get addNewUser;

  /// No description provided for @userId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userId;

  /// No description provided for @userIdHelper.
  ///
  /// In en, this message translates to:
  /// **'Unique identifier for the user'**
  String get userIdHelper;

  /// No description provided for @userIdHelperMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Unique identifier for the user (max 15 characters)'**
  String get userIdHelperMaxLength;

  /// No description provided for @nameOptional.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get nameOptional;

  /// No description provided for @nameHelper.
  ///
  /// In en, this message translates to:
  /// **'If empty, will use User ID as name'**
  String get nameHelper;

  /// No description provided for @userIdRequired.
  ///
  /// In en, this message translates to:
  /// **'User ID is required'**
  String get userIdRequired;

  /// No description provided for @userCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'User \"{userId}\" created successfully'**
  String userCreatedSuccess(String userId);

  /// No description provided for @failedToCreateUser.
  ///
  /// In en, this message translates to:
  /// **'Failed to create user: {error}'**
  String failedToCreateUser(String error);

  /// No description provided for @addUserButton.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUserButton;

  /// No description provided for @addNewWork.
  ///
  /// In en, this message translates to:
  /// **'Add New Work'**
  String get addNewWork;

  /// No description provided for @workId.
  ///
  /// In en, this message translates to:
  /// **'Work ID'**
  String get workId;

  /// No description provided for @workIdHelper.
  ///
  /// In en, this message translates to:
  /// **'Unique identifier for the work'**
  String get workIdHelper;

  /// No description provided for @workIdHelperMaxLength.
  ///
  /// In en, this message translates to:
  /// **'Unique identifier for the work (max 15 characters)'**
  String get workIdHelperMaxLength;

  /// No description provided for @titleOptional.
  ///
  /// In en, this message translates to:
  /// **'Title (optional)'**
  String get titleOptional;

  /// No description provided for @titleHelper.
  ///
  /// In en, this message translates to:
  /// **'If empty, will use Work ID as title'**
  String get titleHelper;

  /// No description provided for @workIdRequired.
  ///
  /// In en, this message translates to:
  /// **'Work ID is required'**
  String get workIdRequired;

  /// No description provided for @workCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Work \"{workId}\" created successfully'**
  String workCreatedSuccess(String workId);

  /// No description provided for @failedToCreateWork.
  ///
  /// In en, this message translates to:
  /// **'Failed to create work: {error}'**
  String failedToCreateWork(String error);

  /// No description provided for @addWorkButton.
  ///
  /// In en, this message translates to:
  /// **'Add Work'**
  String get addWorkButton;

  /// No description provided for @scanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get scanQrCode;

  /// No description provided for @printUsersList.
  ///
  /// In en, this message translates to:
  /// **'Print Users List'**
  String get printUsersList;

  /// No description provided for @addUserTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add User'**
  String get addUserTooltip;

  /// No description provided for @generateBarcodeSheet.
  ///
  /// In en, this message translates to:
  /// **'Generate Barcode Sheet'**
  String get generateBarcodeSheet;

  /// No description provided for @addWorkTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Work'**
  String get addWorkTooltip;

  /// No description provided for @checkouts.
  ///
  /// In en, this message translates to:
  /// **'Checkouts'**
  String get checkouts;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @works.
  ///
  /// In en, this message translates to:
  /// **'Works'**
  String get works;

  /// No description provided for @searchWorks.
  ///
  /// In en, this message translates to:
  /// **'Search works...'**
  String get searchWorks;

  /// No description provided for @instances.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 instance} other{{count} instances}}'**
  String instances(int count);

  /// No description provided for @pages.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 page} other{{count} pages}}'**
  String pages(int count);

  /// No description provided for @unknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Unknown Title'**
  String get unknownTitle;

  /// No description provided for @unknownUser.
  ///
  /// In en, this message translates to:
  /// **'Unknown User'**
  String get unknownUser;

  /// No description provided for @unknownComposer.
  ///
  /// In en, this message translates to:
  /// **'Unknown Composer'**
  String get unknownComposer;

  /// No description provided for @unknownDate.
  ///
  /// In en, this message translates to:
  /// **'Unknown date'**
  String get unknownDate;

  /// No description provided for @invalidDate.
  ///
  /// In en, this message translates to:
  /// **'Invalid Date'**
  String get invalidDate;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @idLabel.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String idLabel(String id);

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email: {email}'**
  String emailLabel(String email);

  /// No description provided for @composerLabel.
  ///
  /// In en, this message translates to:
  /// **'Composer: {composer}'**
  String composerLabel(String composer);

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @confirmDeleteUser.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"?'**
  String confirmDeleteUser(String name);

  /// No description provided for @userDeletionNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'User deletion not implemented yet'**
  String get userDeletionNotImplemented;

  /// No description provided for @failedToDeleteUser.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete user: {error}'**
  String failedToDeleteUser(String error);

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteWork.
  ///
  /// In en, this message translates to:
  /// **'Delete Work'**
  String get deleteWork;

  /// No description provided for @confirmDeleteWork.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String confirmDeleteWork(String title);

  /// No description provided for @workDeletionNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Work deletion not implemented yet'**
  String get workDeletionNotImplemented;

  /// No description provided for @failedToDeleteWork.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete work: {error}'**
  String failedToDeleteWork(String error);

  /// No description provided for @barcodeForTitle.
  ///
  /// In en, this message translates to:
  /// **'Barcode for \"{title}\"'**
  String barcodeForTitle(String title);

  /// No description provided for @workIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Work ID: {workId}'**
  String workIdLabel(String workId);

  /// No description provided for @barcodeComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Barcode generation feature coming soon!'**
  String get barcodeComingSoon;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter Password'**
  String get enterPassword;

  /// No description provided for @passwordPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter your password to access the application:'**
  String get passwordPrompt;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @unlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get unlock;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password cannot be empty'**
  String get passwordRequired;

  /// No description provided for @confirmMusic.
  ///
  /// In en, this message translates to:
  /// **'Confirm Music'**
  String get confirmMusic;

  /// No description provided for @confirmPerson.
  ///
  /// In en, this message translates to:
  /// **'Confirm Person'**
  String get confirmPerson;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @enterWorkDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter Work Details'**
  String get enterWorkDetails;

  /// No description provided for @enterUserId.
  ///
  /// In en, this message translates to:
  /// **'Enter User ID'**
  String get enterUserId;

  /// No description provided for @workIdExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. WORK123'**
  String get workIdExample;

  /// No description provided for @instanceNumber.
  ///
  /// In en, this message translates to:
  /// **'Instance Number'**
  String get instanceNumber;

  /// No description provided for @instanceExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. 1'**
  String get instanceExample;

  /// No description provided for @userIdExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. USER123'**
  String get userIdExample;

  /// No description provided for @instanceRequired.
  ///
  /// In en, this message translates to:
  /// **'Instance number is required'**
  String get instanceRequired;

  /// No description provided for @instanceInvalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Instance number must be a valid number'**
  String get instanceInvalidNumber;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @manualInput.
  ///
  /// In en, this message translates to:
  /// **'Manual Input'**
  String get manualInput;

  /// No description provided for @errorFetchingWork.
  ///
  /// In en, this message translates to:
  /// **'Error fetching work details: {error}'**
  String errorFetchingWork(String error);

  /// No description provided for @checkoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Checkout failed: {error}'**
  String checkoutFailed(String error);

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @pleaseEnterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get pleaseEnterTitle;

  /// No description provided for @scannedUserId.
  ///
  /// In en, this message translates to:
  /// **'Scanned User ID: {userId}'**
  String scannedUserId(String userId);

  /// No description provided for @pdfSavedTo.
  ///
  /// In en, this message translates to:
  /// **'PDF saved to {path}'**
  String pdfSavedTo(String path);

  /// No description provided for @failedToGeneratePdf.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate PDF: {error}'**
  String failedToGeneratePdf(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'nb'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nb':
      return AppLocalizationsNb();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
