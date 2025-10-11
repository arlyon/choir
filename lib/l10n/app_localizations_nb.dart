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

  @override
  String get appTitle => 'SSKor Note App';

  @override
  String get failedToRefresh =>
      'Kunne ikke oppdatere data. Sjekk tilkobling eller logger.';

  @override
  String failedToExportUsers(String error) {
    return 'Kunne ikke eksportere brukere: $error';
  }

  @override
  String get addNewUser => 'Legg til ny bruker';

  @override
  String get userId => 'Bruker-ID';

  @override
  String get userIdHelper => 'Unik identifikator for brukeren';

  @override
  String get userIdHelperMaxLength =>
      'Unik identifikator for brukeren (maks 15 tegn)';

  @override
  String get nameOptional => 'Navn (valgfritt)';

  @override
  String get nameHelper => 'Hvis tom, vil bruker-ID bli brukt som navn';

  @override
  String get userIdRequired => 'Bruker-ID er påkrevd';

  @override
  String userCreatedSuccess(String userId) {
    return 'Bruker \"$userId\" opprettet';
  }

  @override
  String failedToCreateUser(String error) {
    return 'Kunne ikke opprette bruker: $error';
  }

  @override
  String get addUserButton => 'Legg til bruker';

  @override
  String get addNewWork => 'Legg til nytt verk';

  @override
  String get workId => 'Verk-ID';

  @override
  String get workIdHelper => 'Unik identifikator for verket';

  @override
  String get workIdHelperMaxLength =>
      'Unik identifikator for verket (maks 15 tegn)';

  @override
  String get titleOptional => 'Tittel (valgfritt)';

  @override
  String get titleHelper => 'Hvis tom, vil verk-ID bli brukt som tittel';

  @override
  String get workIdRequired => 'Verk-ID er påkrevd';

  @override
  String workCreatedSuccess(String workId) {
    return 'Verk \"$workId\" opprettet';
  }

  @override
  String failedToCreateWork(String error) {
    return 'Kunne ikke opprette verk: $error';
  }

  @override
  String get addWorkButton => 'Legg til verk';

  @override
  String get scanQrCode => 'Skann QR-kode';

  @override
  String get printUsersList => 'Skriv ut brukerliste';

  @override
  String get addUserTooltip => 'Legg til bruker';

  @override
  String get generateBarcodeSheet => 'Generer strekkodeark';

  @override
  String get addWorkTooltip => 'Legg til verk';

  @override
  String get checkouts => 'Utlån';

  @override
  String get users => 'Brukere';

  @override
  String get works => 'Verk';

  @override
  String get searchWorks => 'Søk verk...';

  @override
  String instances(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count eksemplarer',
      one: '1 eksemplar',
    );
    return '$_temp0';
  }

  @override
  String pages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sider',
      one: '1 side',
    );
    return '$_temp0';
  }

  @override
  String get unknownTitle => 'Ukjent tittel';

  @override
  String get unknownUser => 'Ukjent bruker';

  @override
  String get unknownComposer => 'Ukjent komponist';

  @override
  String get unknownDate => 'Ukjent dato';

  @override
  String get invalidDate => 'Ugyldig dato';

  @override
  String get unknown => 'Ukjent';

  @override
  String idLabel(String id) {
    return 'ID: $id';
  }

  @override
  String emailLabel(String email) {
    return 'E-post: $email';
  }

  @override
  String composerLabel(String composer) {
    return 'Komponist: $composer';
  }

  @override
  String get deleteUser => 'Slett bruker';

  @override
  String confirmDeleteUser(String name) {
    return 'Er du sikker på at du vil slette \"$name\"?';
  }

  @override
  String get userDeletionNotImplemented =>
      'Sletting av bruker er ikke implementert ennå';

  @override
  String failedToDeleteUser(String error) {
    return 'Kunne ikke slette bruker: $error';
  }

  @override
  String get delete => 'Slett';

  @override
  String get deleteWork => 'Slett verk';

  @override
  String confirmDeleteWork(String title) {
    return 'Er du sikker på at du vil slette \"$title\"?';
  }

  @override
  String get workDeletionNotImplemented =>
      'Sletting av verk er ikke implementert ennå';

  @override
  String failedToDeleteWork(String error) {
    return 'Kunne ikke slette verk: $error';
  }

  @override
  String barcodeForTitle(String title) {
    return 'Strekkode for \"$title\"';
  }

  @override
  String workIdLabel(String workId) {
    return 'Verk-ID: $workId';
  }

  @override
  String get barcodeComingSoon => 'Strekkodegenerering kommer snart!';

  @override
  String get close => 'Lukk';

  @override
  String get enterPassword => 'Skriv inn passord';

  @override
  String get passwordPrompt =>
      'Skriv inn passordet ditt for å få tilgang til applikasjonen:';

  @override
  String get password => 'Passord';

  @override
  String get unlock => 'Lås opp';

  @override
  String get passwordRequired => 'Passord kan ikke være tomt';

  @override
  String get confirmMusic => 'Bekreft noter';

  @override
  String get confirmPerson => 'Bekreft person';

  @override
  String get summary => 'Sammendrag';

  @override
  String get enterWorkDetails => 'Skriv inn verkdetaljer';

  @override
  String get enterUserId => 'Skriv inn bruker-ID';

  @override
  String get workIdExample => 'f.eks. VERK123';

  @override
  String get instanceNumber => 'Eksemplarnummer';

  @override
  String get instanceExample => 'f.eks. 1';

  @override
  String get userIdExample => 'f.eks. BRUKER123';

  @override
  String get instanceRequired => 'Eksemplarnummer er påkrevd';

  @override
  String get instanceInvalidNumber => 'Eksemplarnummer må være et gyldig tall';

  @override
  String get ok => 'OK';

  @override
  String get manualInput => 'Manuell inndata';

  @override
  String errorFetchingWork(String error) {
    return 'Feil ved henting av verkdetaljer: $error';
  }

  @override
  String checkoutFailed(String error) {
    return 'Utlån mislyktes: $error';
  }

  @override
  String get title => 'Tittel';

  @override
  String get pleaseEnterTitle => 'Skriv inn en tittel';

  @override
  String scannedUserId(String userId) {
    return 'Skannet bruker-ID: $userId';
  }

  @override
  String pdfSavedTo(String path) {
    return 'PDF lagret til $path';
  }

  @override
  String failedToGeneratePdf(String error) {
    return 'Kunne ikke generere PDF: $error';
  }
}
