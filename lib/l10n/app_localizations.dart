import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr')
  ];

  /// No description provided for @helloWorld.
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @askAQuestion.
  ///
  /// In en, this message translates to:
  /// **'Ask a Question'**
  String get askAQuestion;

  /// No description provided for @defaultAssistantMessage.
  ///
  /// In en, this message translates to:
  /// **'Ask me any questions about the Athlete Guide - I\\\'ll try my best to answer.'**
  String get defaultAssistantMessage;

  /// No description provided for @wouldYouLikeToRemoveAllMessages.
  ///
  /// In en, this message translates to:
  /// **'Would you like to remove all the messages?'**
  String get wouldYouLikeToRemoveAllMessages;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @noResultFound.
  ///
  /// In en, this message translates to:
  /// **'No Result Found'**
  String get noResultFound;

  /// No description provided for @noImageFound.
  ///
  /// In en, this message translates to:
  /// **'No Image Found'**
  String get noImageFound;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @splits.
  ///
  /// In en, this message translates to:
  /// **'Splits'**
  String get splits;

  /// No description provided for @followNotAvailableUntilRaceNumberIsAssigned.
  ///
  /// In en, this message translates to:
  /// **'Follow not available until Race Number has been assigned'**
  String get followNotAvailableUntilRaceNumberIsAssigned;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @searchForAthletesUsingNameOrRaceNo.
  ///
  /// In en, this message translates to:
  /// **'Search here for Athletes,\nusing Name or Race\nNumber'**
  String get searchForAthletesUsingNameOrRaceNo;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @noAthletesBeingFollowed.
  ///
  /// In en, this message translates to:
  /// **'No {athleteText} being followed'**
  String noAthletesBeingFollowed(Object athleteText);

  /// No description provided for @whenYouFollowAthleteYouWillSeeThemHere.
  ///
  /// In en, this message translates to:
  /// **'When you follow {athleteText}, you\'ll see them here.'**
  String whenYouFollowAthleteYouWillSeeThemHere(Object athleteText);

  /// No description provided for @noAthletesFoundAtPresent.
  ///
  /// In en, this message translates to:
  /// **'No {athleteText} Found At Present'**
  String noAthletesFoundAtPresent(Object athleteText);

  /// No description provided for @noAthleteFound.
  ///
  /// In en, this message translates to:
  /// **'No {athleteText} Found'**
  String noAthleteFound(Object athleteText);

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last Updated'**
  String get lastUpdated;

  /// No description provided for @getDirections.
  ///
  /// In en, this message translates to:
  /// **'Get Directions'**
  String get getDirections;

  /// No description provided for @distanceMarkers.
  ///
  /// In en, this message translates to:
  /// **'Distance Markers'**
  String get distanceMarkers;

  /// No description provided for @mapStyle.
  ///
  /// In en, this message translates to:
  /// **'Map Style'**
  String get mapStyle;

  /// No description provided for @pointsOfInterest.
  ///
  /// In en, this message translates to:
  /// **'Points of Interest'**
  String get pointsOfInterest;

  /// No description provided for @trackingNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Tracking Not Available'**
  String get trackingNotAvailable;

  /// No description provided for @loadFailedClickRetry.
  ///
  /// In en, this message translates to:
  /// **'Load Failed!Click retry!'**
  String get loadFailedClickRetry;

  /// No description provided for @releaseToLoadMore.
  ///
  /// In en, this message translates to:
  /// **'release to load more'**
  String get releaseToLoadMore;

  /// No description provided for @noMoreData.
  ///
  /// In en, this message translates to:
  /// **'No more Data'**
  String get noMoreData;

  /// No description provided for @wouldYouLikeToReceiveEventReleatedPushNotificationsForThisEvent.
  ///
  /// In en, this message translates to:
  /// **'Would you like to receive event related push notification for this event'**
  String get wouldYouLikeToReceiveEventReleatedPushNotificationsForThisEvent;

  /// No description provided for @noThanks.
  ///
  /// In en, this message translates to:
  /// **'No thanks'**
  String get noThanks;

  /// No description provided for @elevationProfile.
  ///
  /// In en, this message translates to:
  /// **'Elevation Profile'**
  String get elevationProfile;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @noInternetConnectionFoundMsg.
  ///
  /// In en, this message translates to:
  /// **'No Internet connection found.\nPlease check your internet settings.'**
  String get noInternetConnectionFoundMsg;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @oops.
  ///
  /// In en, this message translates to:
  /// **'Oops!'**
  String get oops;

  /// No description provided for @pleaseTryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later'**
  String get pleaseTryAgainLater;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @selectGenderFirst.
  ///
  /// In en, this message translates to:
  /// **'Select Gender First'**
  String get selectGenderFirst;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @pos.
  ///
  /// In en, this message translates to:
  /// **'Pos'**
  String get pos;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'No Data found'**
  String get noDataFound;

  /// No description provided for @noScheduleFound.
  ///
  /// In en, this message translates to:
  /// **'No Schedule found'**
  String get noScheduleFound;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @appTheme.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get appTheme;

  /// No description provided for @reloadAthletes.
  ///
  /// In en, this message translates to:
  /// **'Reload Athletes'**
  String get reloadAthletes;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @eventUpdates.
  ///
  /// In en, this message translates to:
  /// **'Event Updates'**
  String get eventUpdates;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @selectAppTheme.
  ///
  /// In en, this message translates to:
  /// **'Select App Theme'**
  String get selectAppTheme;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @homebutton.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homebutton;

  /// No description provided for @athletesbutton.
  ///
  /// In en, this message translates to:
  /// **'Athletes'**
  String get athletesbutton;

  /// No description provided for @riderbutton.
  ///
  /// In en, this message translates to:
  /// **'Riders'**
  String get riderbutton;

  /// No description provided for @participantsbutton.
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get participantsbutton;

  /// No description provided for @trackingbutton.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get trackingbutton;

  /// No description provided for @resultsbutton.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get resultsbutton;

  /// No description provided for @menubutton.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menubutton;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
