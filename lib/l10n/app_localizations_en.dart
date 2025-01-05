import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get language => 'Language';

  @override
  String get askAQuestion => 'Ask a Question';

  @override
  String get defaultAssistantMessage => 'Ask me any questions about the Athlete Guide - I\\\'ll try my best to answer.';

  @override
  String get wouldYouLikeToRemoveAllMessages => 'Would you like to remove all the messages?';

  @override
  String get yes => 'Yes';

  @override
  String get cancel => 'Cancel';

  @override
  String get noResultFound => 'No Result Found';

  @override
  String get noImageFound => 'No Image Found';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get retry => 'Retry';

  @override
  String get splits => 'Splits';

  @override
  String get followNotAvailableUntilRaceNumberIsAssigned => 'Follow not available until Race Number has been assigned';

  @override
  String get follow => 'Follow';

  @override
  String get following => 'Following';

  @override
  String get searchForAthletesUsingNameOrRaceNo => 'Search here for Athletes,\nusing Name or Race\nNumber';

  @override
  String get search => 'Search';

  @override
  String noAthletesBeingFollowed(Object athleteText) {
    return 'No $athleteText being followed';
  }

  @override
  String whenYouFollowAthleteYouWillSeeThemHere(Object athleteText) {
    return 'When you follow $athleteText, you\'ll see them here.';
  }

  @override
  String noAthletesFoundAtPresent(Object athleteText) {
    return 'No $athleteText Found At Present';
  }

  @override
  String noAthleteFound(Object athleteText) {
    return 'No $athleteText Found';
  }

  @override
  String get lastUpdated => 'Last Updated';

  @override
  String get getDirections => 'Get Directions';

  @override
  String get distanceMarkers => 'Distance Markers';

  @override
  String get mapStyle => 'Map Style';

  @override
  String get pointsOfInterest => 'Points of Interest';

  @override
  String get trackingNotAvailable => 'Tracking Not Available';

  @override
  String get loadFailedClickRetry => 'Load Failed!Click retry!';

  @override
  String get releaseToLoadMore => 'release to load more';

  @override
  String get noMoreData => 'No more Data';

  @override
  String get wouldYouLikeToReceiveEventReleatedPushNotificationsForThisEvent => 'Would you like to receive event related push notification for this event';

  @override
  String get noThanks => 'No thanks';

  @override
  String get elevationProfile => 'Elevation Profile';

  @override
  String get all => 'All';

  @override
  String get noInternetConnectionFoundMsg => 'No Internet connection found.\nPlease check your internet settings.';

  @override
  String get reload => 'Reload';

  @override
  String get oops => 'Oops!';

  @override
  String get pleaseTryAgainLater => 'Please try again later';

  @override
  String get gender => 'Gender';

  @override
  String get category => 'Category';

  @override
  String get selectGenderFirst => 'Select Gender First';

  @override
  String get apply => 'Apply';

  @override
  String get clear => 'Clear';

  @override
  String get filter => 'Filter';

  @override
  String get pos => 'Pos';

  @override
  String get name => 'Name';

  @override
  String get result => 'Result';

  @override
  String get noDataFound => 'No Data found';

  @override
  String get noScheduleFound => 'No Schedule found';

  @override
  String get settings => 'Settings';

  @override
  String get general => 'General';

  @override
  String get appTheme => 'App Theme';

  @override
  String get reloadAthletes => 'Reload Athletes';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get eventUpdates => 'Event Updates';

  @override
  String get version => 'Version';

  @override
  String get selectAppTheme => 'Select App Theme';

  @override
  String get system => 'System';

  @override
  String get dark => 'Dark';

  @override
  String get light => 'Light';
}
