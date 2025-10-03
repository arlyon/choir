// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get person => 'Person';

  @override
  String get workTitle => 'Verk';

  @override
  String get archived => 'Arkivert';

  @override
  String get me => 'Meg';

  @override
  String get noItems => 'Ingen noter er for øyeblikket utlånt.';

  @override
  String get noFilterItems => 'Ingen noter passer med de valgte filtrene.';

  @override
  String get scanMusic => 'Skann QR-koden på notene.';

  @override
  String get scanPerson => 'Skann QR-koden for personen.';

  @override
  String get addPerson => 'Legg til en ny person';

  @override
  String get addWork => 'Legg til et nytt verk';

  @override
  String get reconnected => 'Koblet til nettverket på nytt.';

  @override
  String get disconnected => 'Koblet fra nettverket.';

  @override
  String get continueText => 'Fortsett';

  @override
  String get missingItems =>
      'Enten verk- eller bruker-ID mangler. Gå tilbake og skann begge QR-kodene.';

  @override
  String get errorLoadingSummary =>
      'Feil ved lasting av sammendrag. Prøv igjen.';

  @override
  String get finalize => 'Fullfør';

  @override
  String get checkoutSuccess => 'Utlån vellykket!';

  @override
  String get returnSuccess => 'Retur vellykket!';

  @override
  String get cancel => 'Avbryt';

  @override
  String get apply => 'Bruk';

  @override
  String archivedItems(int count) {
    return 'Arkiverte elementer ($count)';
  }

  @override
  String get archiveEmpty => 'Arkivet er tomt.';

  @override
  String get scanUserBarcode => 'Skann QR-koden for brukeren.';

  @override
  String get emailOptional => 'E-post (valgfritt)';

  @override
  String get composerOptional => 'Komponist (valgfritt)';

  @override
  String get name => 'Navn';

  @override
  String get pleaseEnterName => 'Skriv inn et navn';

  @override
  String get returning => 'returnerer';

  @override
  String get checkingOut => 'låner';

  @override
  String get search => 'Søk';

  @override
  String get returnItem => 'Returner';
}
