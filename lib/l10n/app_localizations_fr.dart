import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get helloWorld => 'Bonjour le Monde!';

  @override
  String get homebutton => 'Accueil';

  @override
  String get athletesbutton => 'Athlètes';

  @override
  String get riderbutton => 'Concurrents';

  @override
  String get participantsbutton => 'Participants';

  @override
  String get trackingbutton => 'Suivi';

  @override
  String get resultsbutton => 'Résultats';

  @override
  String get menubutton => 'Menu';

  @override
  String get language => 'Langue';

  @override
  String get askAQuestion => 'Poser une Question';

  @override
  String get defaultAssistantMessage => 'Posez-moi des questions sur le Guide des Athlètes - je ferai de mon mieux pour y répondre.';

  @override
  String get wouldYouLikeToRemoveAllMessages => 'Voulez-vous supprimer tous les messages?';

  @override
  String get yes => 'Oui';

  @override
  String get cancel => 'Annuler';

  @override
  String get noResultFound => 'Aucun Résultat Trouvé';

  @override
  String get noImageFound => 'Aucune Image Trouvée';

  @override
  String get somethingWentWrong => 'Quelque chose s\'est mal passé';

  @override
  String get retry => 'Réessayer';

  @override
  String get splits => 'Intermédiaires';

  @override
  String get followNotAvailableUntilRaceNumberIsAssigned => 'Suivi non disponible jusqu\'à ce qu\'un numéro de dossard soit attribué';

  @override
  String get follow => 'Suivre';

  @override
  String get following => 'Suivi';

  @override
  String get searchForAthletesUsingNameOrRaceNo => 'Recherchez ici des Athlètes,\nen utilisant le Nom ou le Numéro\nde Dossard';

  @override
  String get search => 'Rechercher';

  @override
  String noAthletesBeingFollowed(Object athleteText) {
    return 'Aucun $athleteText suivi';
  }

  @override
  String whenYouFollowAthleteYouWillSeeThemHere(Object athleteText) {
    return 'Lorsque vous suivez $athleteText, vous les verrez ici.';
  }

  @override
  String noAthletesFoundAtPresent(Object athleteText) {
    return 'Aucun $athleteText Trouvé Pour le Moment';
  }

  @override
  String noAthleteFound(Object athleteText) {
    return 'Aucun $athleteText Trouvé';
  }

  @override
  String get lastUpdated => 'Dernière Mise à Jour';

  @override
  String get getDirections => 'Obtenir l\'Itinéraire';

  @override
  String get distanceMarkers => 'Bornes kilométrique';

  @override
  String get mapStyle => 'Style de Carte';

  @override
  String get pointsOfInterest => 'Points d\'Intérêt';

  @override
  String get trackingNotAvailable => 'Suivi Non Disponible';

  @override
  String get loadFailedClickRetry => 'Échec du Chargement ! Cliquez sur Réessayer!';

  @override
  String get releaseToLoadMore => 'Relâchez pour charger plus';

  @override
  String get noMoreData => 'Plus de Données';

  @override
  String get wouldYouLikeToReceiveEventReleatedPushNotificationsForThisEvent => 'Souhaitez-vous recevoir des notifications liées à cet événement?';

  @override
  String get noThanks => 'Non merci';

  @override
  String get elevationProfile => 'Profil d\'Élévation';

  @override
  String get all => 'Tous';

  @override
  String get noInternetConnectionFoundMsg => 'Aucune connexion Internet trouvée.\nVeuillez vérifier vos paramètres Internet.';

  @override
  String get reload => 'Recharger';

  @override
  String get oops => 'Oups!';

  @override
  String get pleaseTryAgainLater => 'Veuillez réessayer plus tard';

  @override
  String get gender => 'Genre';

  @override
  String get category => 'Catégorie';

  @override
  String get selectGenderFirst => 'Sélectionnez d\'abord le Genre';

  @override
  String get apply => 'Appliquer';

  @override
  String get clear => 'Effacer';

  @override
  String get filter => 'Filtrer';

  @override
  String get pos => 'Pos';

  @override
  String get name => 'Nom';

  @override
  String get result => 'Résultat';

  @override
  String get noDataFound => 'Aucune Donnée Trouvée';

  @override
  String get noScheduleFound => 'Aucun Programme Trouvé';

  @override
  String get settings => 'Paramètres';

  @override
  String get general => 'Général';

  @override
  String get appTheme => 'Thème de l\'Application';

  @override
  String get reloadAthletes => 'Recharger les Athlètes';

  @override
  String get notificationSettings => 'Paramètres de Notification';

  @override
  String get eventUpdates => 'Mises à Jour de l\'Événement';

  @override
  String get version => 'Version';

  @override
  String get selectAppTheme => 'Sélectionnez le Thème de l\'Application';

  @override
  String get system => 'Système';

  @override
  String get dark => 'Sombre';

  @override
  String get light => 'Clair';

  @override
  String get menu => 'Menu';
}
