import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get helloWorld => 'Hallo Welt!';

  @override
  String get language => 'Sprache';

  @override
  String get askAQuestion => 'Stellen Sie eine Frage';

  @override
  String get defaultAssistantMessage => 'Stellen Sie mir Fragen zum Athletenführer - ich werde mein Bestes tun, um zu antworten.';

  @override
  String get wouldYouLikeToRemoveAllMessages => 'Möchten Sie alle Nachrichten entfernen?';

  @override
  String get yes => 'Ja';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get noResultFound => 'Keine Ergebnisse gefunden';

  @override
  String get noImageFound => 'Kein Bild gefunden';

  @override
  String get somethingWentWrong => 'Etwas ist schief gelaufen';

  @override
  String get retry => 'Wiederholen';

  @override
  String get splits => 'Aufteilungen';

  @override
  String get followNotAvailableUntilRaceNumberIsAssigned => 'Verfolgen nicht verfügbar, bis eine Rennnummer zugewiesen wurde';

  @override
  String get follow => 'Folgen';

  @override
  String get following => 'Folgend';

  @override
  String get searchForAthletesUsingNameOrRaceNo => 'Suchen Sie hier nach Athleten,\nnach Name oder Rennnummer';

  @override
  String get search => 'Suchen';

  @override
  String noAthletesBeingFollowed(Object athleteText) {
    return 'Kein \$$athleteText wird verfolgt';
  }

  @override
  String whenYouFollowAthleteYouWillSeeThemHere(Object athleteText) {
    return 'Wenn Sie \$$athleteText folgen, werden Sie sie hier sehen.';
  }

  @override
  String noAthletesFoundAtPresent(Object athleteText) {
    return 'Derzeit kein \$$athleteText gefunden';
  }

  @override
  String noAthleteFound(Object athleteText) {
    return 'Kein \$$athleteText gefunden';
  }

  @override
  String get lastUpdated => 'Zuletzt aktualisiert';

  @override
  String get getDirections => 'Wegbeschreibung erhalten';

  @override
  String get distanceMarkers => 'Entfernungsmarkierungen';

  @override
  String get mapStyle => 'Kartenstil';

  @override
  String get pointsOfInterest => 'Sehenswürdigkeiten';

  @override
  String get trackingNotAvailable => 'Verfolgung nicht verfügbar';

  @override
  String get loadFailedClickRetry => 'Laden fehlgeschlagen! Klicken Sie auf Wiederholen!';

  @override
  String get releaseToLoadMore => 'Loslassen, um mehr zu laden';

  @override
  String get noMoreData => 'Keine weiteren Daten';

  @override
  String get wouldYouLikeToReceiveEventReleatedPushNotificationsForThisEvent => 'Möchten Sie Push-Benachrichtigungen für dieses Ereignis erhalten?';

  @override
  String get noThanks => 'Nein danke';

  @override
  String get elevationProfile => 'Höhenprofil';

  @override
  String get all => 'Alle';

  @override
  String get noInternetConnectionFoundMsg => 'Keine Internetverbindung gefunden.\nBitte überprüfen Sie Ihre Internet-Einstellungen.';

  @override
  String get reload => 'Neu laden';

  @override
  String get oops => 'Ups!';

  @override
  String get pleaseTryAgainLater => 'Bitte versuchen Sie es später noch einmal';

  @override
  String get gender => 'Geschlecht';

  @override
  String get category => 'Kategorie';

  @override
  String get selectGenderFirst => 'Wählen Sie zuerst das Geschlecht aus';

  @override
  String get apply => 'Anwenden';

  @override
  String get clear => 'Löschen';

  @override
  String get filter => 'Filter';

  @override
  String get pos => 'Position';

  @override
  String get name => 'Name';

  @override
  String get result => 'Ergebnis';

  @override
  String get noDataFound => 'Keine Daten gefunden';

  @override
  String get noScheduleFound => 'Kein Zeitplan gefunden';

  @override
  String get settings => 'Einstellungen';

  @override
  String get general => 'Allgemein';

  @override
  String get appTheme => 'App-Thema';

  @override
  String get reloadAthletes => 'Athleten neu laden';

  @override
  String get notificationSettings => 'Benachrichtigungseinstellungen';

  @override
  String get eventUpdates => 'Ereignis-Updates';

  @override
  String get version => 'Version';

  @override
  String get selectAppTheme => 'Wählen Sie das App-Thema aus';

  @override
  String get system => 'System';

  @override
  String get dark => 'Dunkel';

  @override
  String get light => 'Hell';
}
