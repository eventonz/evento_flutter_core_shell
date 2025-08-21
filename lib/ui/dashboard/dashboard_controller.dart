import 'dart:ffi';
import 'dart:math';
import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evento_core/core/models/miniplayer.dart';
import 'package:evento_core/core/overlays/fullscreen_advert.dart';
import 'package:evento_core/core/services/app_one_signal/app_one_signal_service.dart';
import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/models/athlete.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/routes/routes.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/core/utils/preferences.dart';
import 'package:evento_core/l10n/app_localizations.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:evento_core/ui/dashboard/athletes/athletes_controller.dart';
import 'package:evento_core/ui/dashboard/athletes_tracking/tracking_controller.dart';
import 'package:evento_core/ui/dashboard/home/home_controller.dart';
import 'package:evento_core/ui/dashboard/more/more_controller.dart';
import 'package:evento_core/ui/events/events.dart';
import 'package:evento_core/ui/results/results_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:evento_core/ui/landing/landing_controller.dart';
import 'package:get/get.dart';
//import 'package:new_version_plus/new_version_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/models/advert.dart';
import '../landing/landing.dart';
import 'home/home.dart';
import 'athletes/athletes.dart';
import 'athletes_tracking/tracking.dart';
import 'more/more.dart';

class DashboardController extends GetxController {
  final selMenu = Rx<BottomNavMenu?>(null);
  final AppOneSignal oneSignalService = Get.find();
  late List<Advert> advertList;
  late Athletes entrantsList;
  late Rx<MiniPlayerConfig?> miniPlayerConfig = Rx<MiniPlayerConfig?>(null);
  late Tracking? trackingData;
  late Results? resultsData;
  final athleteSnapData = DataSnapShot.loaded.obs;
  late int eventId;
  WebViewController? webViewController;
  bool isSplashAdvertShowing = false;
  Timer? _notificationTimer;

  RxList<BottomNavMenu> menus = RxList([
    BottomNavMenu(
        view: const HomeScreen(),
        iconData: FeatherIcons.home,
        label: 'home',
        text: AppLocalizations.of(Get.context!)!.homebutton),
    BottomNavMenu(
        view: const MoreScreen(),
        iconData: FeatherIcons.menu,
        label: 'menu',
        text: AppLocalizations.of(Get.context!)!.menubutton),
  ]);

  String extractEventId(String url) {
    final startIndex = url.indexOf('event_id/') + 9;
    final endIndex =
        url.contains('/athlete/') ? url.indexOf('/athlete/') : url.length;
    return url.substring(startIndex, endIndex);
  }

  @override
  void onInit() {
    super.onInit();

    eventId = Preferences.getInt(AppKeys.eventId, 0);

    AppGlobals.checkOnUserId();

    Get.put(HomeController());

    Get.put(MoreController());

    entrantsList = AppGlobals.appConfig!.athletes!;
    trackingData = AppGlobals.appConfig!.tracking;
    resultsData = AppGlobals.appConfig!.results;
    miniPlayerConfig.value = AppGlobals.appConfig!.miniPlayerConfig;
    final showAthletes = entrantsList.showAthletes ?? false;
    if (showAthletes) {
      menus.insert(
        1,
        BottomNavMenu(
            view: const AthletesScreen(),
            iconData: FeatherIcons.users,
            label: AppHelper.setAthleteMenuText(entrantsList.text)),
      );
    }
    if (trackingData != null) {
      menus.insert(
        showAthletes ? 2 : 1,
        BottomNavMenu(
            view: const TrackingScreen(),
            iconData: FeatherIcons.navigation,
            label: 'track',
            text: AppLocalizations.of(Get.context!)!.trackingbutton),
      );
    }
    if (resultsData != null && resultsData?.showResults == true) {
      menus.insert(
        1,
        BottomNavMenu(
            view: const ResultsScreen(),
            image: AppHelper.getImage('trophy.png'),
            label: 'results',
            text: AppLocalizations.of(Get.context!)!.resultsbutton),
      );
    }
    selMenu.value = menus.first;

    advertList = AppGlobals.appConfig!.adverts ?? [];

    var splashImage = advertList
        .where((element) => element.type == AdvertType.splash)
        .firstOrNull;
    if (splashImage != null && Get.arguments?['is_deeplink'] != true) {
      if (splashImage.frequency == AdvertFrequency.daily) {
        String lastOpen = Preferences.getString('last_splash_open', '');
        if (lastOpen != '') {
          DateTime dateTime = DateTime.parse(lastOpen);
          if (dateTime.day == DateTime.now().day) {
            // If daily splash already shown today, no splash will be shown
            return;
          }
        }
        Preferences.setString('last_splash_open', DateTime.now().toString());
      }
      // Splash advert will be shown
      isSplashAdvertShowing = true;
      precacheImage(
          CachedNetworkImageProvider(splashImage.image!), Get.context!);
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(Get.context!).push(MaterialPageRoute(
            builder: (_) => FullscreenAdvert(
                  splashImage,
                  onDismissed: () {
                    // Show notification prompt after splash advert is dismissed
                    oneSignalService.initializeOneSignal().then((_) {
                      showNotificationPrompt();
                    });
                  },
                )));
      });
    } else {
      // No splash advert will be shown
      isSplashAdvertShowing = false;
      // Notification prompt will be scheduled in onReady via _scheduleNotificationPrompt()
    }

    if (AppGlobals.appConfig?.menu?.items?.length == 0) {
      menus.removeLast();
    }

    if (Get.arguments != null && Get.arguments is WebViewController) {
      webViewController = Get.arguments;
    }

    var appLinks = AppLinks();
    final sub = appLinks.uriLinkStream.listen((uri) async {
      var open = uri.path;
      if (open.contains('/event_id/')) {
        var eventId = extractEventId(open);
        if (AppGlobals.appEventConfig.multiEventListId != null) {
          var event = AppGlobals.eventM?.events
              ?.firstWhereOrNull((e) => e.id == int.parse(eventId));
          if (eventId != AppGlobals.selEventId.toString()) {
            saveEventSelection(event);
            String? athleteId = uri.path.contains('/athlete/')
                ? open.split('/athlete/')[1]
                : null;
            Get.offAll(() => const LandingScreen(),
                routeName: Routes.landing,
                transition: Transition.topLevel,
                duration: const Duration(milliseconds: 1500),
                arguments: {'is_prev': true, 'athlete_id': athleteId});
          } else {
            if (uri.path.contains('/athlete/')) {
              String athleteId = open.split('/athlete/')[1];
              Get.toNamed(Routes.athleteDetails, arguments: {
                'id': (athleteId),
                'can_follow': true,
                'on_follow': onFollow
              });
            }
          }
        } else {
          if (uri.path.contains('/athlete/')) {
            String athleteId = open.split('/athlete/')[1];
            Get.toNamed(Routes.athleteDetails, arguments: {
              'id': (athleteId),
              'can_follow': true,
              'on_follow': onFollow
            });
          }
        }
      }
    });
  }

  onFollow(entrant) async {
    AthletesController controller = Get.isRegistered<AthletesController>()
        ? Get.find<AthletesController>()
        : Get.put(AthletesController());
    await controller.insertAthlete(entrant, !entrant.isFollowed);
    if (!entrant.isFollowed) {
      controller.followAthlete(entrant);
    } else {
      controller.unfollowAthlete(entrant);
    }
    //controller.update();
  }

  static void saveEventSelection(dynamic event) {
    Preferences.setString(AppKeys.eventUrl, event.config!);
    Preferences.setString(AppKeys.eventLink, event.link!);
    Preferences.setInt(AppKeys.eventId, event.id);
    AppGlobals.selEventId = event.id;
  }

  void reloadMenu() {
    var entrantsList = AppGlobals.appConfig!.athletes!;
    var trackingData = AppGlobals.appConfig!.tracking;
    var resultsData = AppGlobals.appConfig!.results;
    final showAthletes = entrantsList.showAthletes ?? false;

    // Handle Athletes tab
    if (showAthletes) {
      if (menus
          .where((element) =>
              !['home', 'track', 'results', 'menu'].contains(element.label))
          .isEmpty) {
        menus.insert(
          1,
          BottomNavMenu(
              view: const AthletesScreen(),
              iconData: FeatherIcons.users,
              label: AppHelper.setAthleteMenuText(entrantsList.text)),
        );
      }
    } else {
      menus.removeWhere((element) =>
          !['home', 'track', 'results', 'menu'].contains(element.label));
    }

    // Handle Tracking tab
    if (trackingData != null) {
      if (menus.where((element) => element.label == 'track').isEmpty) {
        menus.insert(
          showAthletes ? 2 : 1,
          BottomNavMenu(
              view: const TrackingScreen(),
              iconData: FeatherIcons.navigation,
              label: 'track',
              text: AppLocalizations.of(Get.context!)!.trackingbutton),
        );
      }
    } else {
      menus.removeWhere((element) => element.label == 'track');
    }

    // Handle Results tab independently
    if (resultsData != null && resultsData?.showResults == true) {
      if (menus.where((element) => element.label == 'results').isEmpty) {
        menus.insert(
          1, // Always second position
          BottomNavMenu(
              view: const ResultsScreen(),
              image: AppHelper.getImage('trophy.png'),
              label: 'results',
              text: AppLocalizations.of(Get.context!)!.resultsbutton),
        );
      }
    } else {
      menus.removeWhere((element) => element.label == 'results');
    }

    update();

    if (AppGlobals.appConfig?.menu?.items?.length == 0) {
      menus.removeWhere((element) => element.label == 'menu');
    }
  }

  void setMiniPlayerConfig(MiniPlayerConfig? config) {
    miniPlayerConfig.value = config;
    update();
  }

  @override
  void onReady() {
    super.onReady();

    final isMultiEvent = AppGlobals.appEventConfig.multiEventListId != null;
    final isSingleEvent = AppGlobals.appEventConfig.singleEventId != null;

    if (isSingleEvent && isSplashAdvertShowing) {
      // Single event mode and splash advert is showing: delay OneSignal init
      // OneSignal will be initialized in splash advert onDismissed callback
    } else {
      // Multi event mode or no splash advert: initialize OneSignal immediately
      oneSignalService.initializeOneSignal().then((_) {
        _scheduleNotificationPrompt();
      });
    }
  }

  void _scheduleNotificationPrompt() {
    // Cancel any existing timer
    _notificationTimer?.cancel();

    // Schedule the notification prompt with a delay
    _notificationTimer = Timer(const Duration(seconds: 2), () {
      if (!isSplashAdvertShowing) {
        showNotificationPrompt();
      }
    });
  }

  void showNotificationPrompt() {
    // Safety check: don't show if splash advert is still showing
    if (isSplashAdvertShowing) {
      return;
    }
    AppHelper.showNotificationOptInPrompt(
      context: Get.context!,
      eventId: eventId,
      onResult: (allow) {
        // Call API in background without waiting
        oneSignalService.updateNotificationStatus(
            AppGlobals.oneSignalUserId, eventId, allow);
      },
    );
  }

  void selectMenu(BottomNavMenu menu) async {
    selMenu.value = menu;
    if (selMenu.value!.label == 'track') {
      await Future.delayed(const Duration(seconds: 0));
      final TrackingController controller = Get.find();
      controller.getAthleteTrackingInfo(firstTime: true);
      //controller.pointAnnotationManager?.deleteAll();
      //controller.polylineAnnotationManager?.deleteAll();
    }

    // if (menu == menus.first) {
    //   homeController.startFade();
    // } else {
    //   homeController.stopVideo();
    // }
  }

  void goBack() {
    Preferences.setString(AppKeys.eventUrl, '');
    Preferences.setString(AppKeys.localConfig, '{}');
    Get.off(
      () => const EventsScreen(),
      routeName: Routes.events,
      transition: Transition.leftToRightWithFade,
    );
  }

  Future<void> getConfigDetails() async {
    final config = AppGlobals.appEventConfig;
    String url = Preferences.getString(AppKeys.eventUrl, '');
    if (url.isEmpty && config.multiEventListId == null) {
      url = AppHelper.createUrl(config.singleEventUrl!, config.singleEventId!);
      Preferences.setString(AppKeys.eventUrl, url);
      AppGlobals.selEventId = int.parse(config.singleEventId!);
      Preferences.setInt(AppKeys.eventId, AppGlobals.selEventId);
    } else {
      return;
    }
    final res = await ApiHandler.genericGetHttp(
        url: Preferences.getString(AppKeys.eventUrl, ''));
    AppGlobals.appConfig = AppConfig.fromJson(res.data);
    Preferences.setInt(AppKeys.configLastUpdated,
        AppGlobals.appConfig?.athletes?.lastUpdated ?? 0);
  }

  Future<void> getAthletes() async {
    final entrantsList = AppGlobals.appConfig!.athletes!;
    final showAthletes = entrantsList.showAthletes ?? false;
    if (!showAthletes) {
      return;
    }

    try {
      // final res = await ApiHandler.genericGetHttp(url: entrantsList.url!);
      // final athletesM = AthletesM.fromJson(res.data);
      // await DatabaseHandler.insertAthletes(athletesM.entrants!);
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void onClose() {
    _notificationTimer?.cancel();
    super.onClose();
  }
}

class BottomNavMenu {
  BottomNavMenu(
      {required this.view,
      this.iconData,
      required this.label,
      this.image,
      this.text});
  final Widget view;
  final IconData? iconData;
  final String? image;
  final String label;
  final String? text;
}
