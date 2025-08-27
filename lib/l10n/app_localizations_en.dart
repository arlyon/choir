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
}
