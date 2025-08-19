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
