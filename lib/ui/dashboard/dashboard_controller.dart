import 'dart:math';

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
import 'package:evento_core/ui/common_components/text.dart';
import 'package:evento_core/ui/dashboard/athletes_tracking/tracking_controller.dart';
import 'package:evento_core/ui/dashboard/home/home_controller.dart';
import 'package:evento_core/ui/dashboard/more/more_controller.dart';
import 'package:evento_core/ui/events/events.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:evento_core/ui/landing/landing_controller.dart';
import 'package:get/get.dart';
import '../../core/models/advert.dart';
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
  final athleteSnapData = DataSnapShot.loaded.obs;
  late int eventId;

  RxList<BottomNavMenu> menus = RxList([
    BottomNavMenu(
        view: const HomeScreen(), iconData: FeatherIcons.home, label: 'home'),
    BottomNavMenu(
        view: const MoreScreen(), iconData: FeatherIcons.menu, label: 'menu'),
  ]);

  @override
  void onInit() {
    super.onInit();
    eventId = Preferences.getInt(AppKeys.eventId, 0);
    AppGlobals.checkOnUserId();
    Get.put(HomeController());
    Get.put(MoreController());
    entrantsList = AppGlobals.appConfig!.athletes!;
    trackingData = AppGlobals.appConfig!.tracking;
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
            label: 'track'),
      );
    }
    selMenu.value = menus.first;

    advertList = AppGlobals.appConfig!.adverts ?? [];

    var splashImage = advertList.where((element) => element.type == AdvertType.splash).firstOrNull;
    if(splashImage != null) {
      if(splashImage.frequency == AdvertFrequency.daily) {
        String lastOpen = Preferences.getString('last_splash_open', '');
        if(lastOpen != '') {
          DateTime dateTime = DateTime.parse(lastOpen);
          if(dateTime.day == DateTime.now().day) {
            return;
          }
        }
        Preferences.setString('last_splash_open', DateTime.now().toString());
      }
      precacheImage(CachedNetworkImageProvider(splashImage.image!), Get.context!);
      Future.delayed(const Duration(seconds: 1), () {
        Navigator.of(Get.context!).push(MaterialPageRoute(builder: (_) => FullscreenAdvert(splashImage)));
      });
    }

  }

  void reloadMenu() {
    var entrantsList = AppGlobals.appConfig!.athletes!;
    var trackingData = AppGlobals.appConfig!.tracking;
    final showAthletes = entrantsList.showAthletes ?? false;

    if (showAthletes) {
      if(menus.where((element) => ![
        'home',
        'track',
        'menu',
      ].contains(element.label)).isEmpty) {
        menus.insert(
          1,
          BottomNavMenu(
              view: const AthletesScreen(),
              iconData: FeatherIcons.users,
              label: AppHelper.setAthleteMenuText(entrantsList.text)),
        );
      }
    } else {
      menus.removeWhere((element) => ![
        'home',
        'track',
        'menu',
      ].contains(element.label));
    }

      if(trackingData != null) {
        print('trackingData');
        if(menus.where((element) => element.label == 'track').isEmpty) {
          menus.insert(
            showAthletes ? 2 : 1,
            BottomNavMenu(
                view: const TrackingScreen(),
                iconData: FeatherIcons.navigation,
                label: 'track'),
          );
        }
      } else {
        menus.removeWhere((element) => element.label == 'track');
      }
      update();
      //dashboardController.menus.removeAt(1);
  }

  void setMiniPlayerConfig(MiniPlayerConfig? config) {
    miniPlayerConfig.value = config;
    update();
  }

  @override
  void onReady() {
    super.onReady();
    oneSignalService.setOneSignalUserId();
    showNotificationPrompt();
  }

  void showNotificationPrompt() {
    final notificationSettingChanged = Preferences.getString(
        AppHelper.notificationPrefenceKey(eventId),
        NotificationStatus.initial.name);
    if (AppGlobals.appEventConfig.multiEventListId == null) return;
    if (notificationSettingChanged != NotificationStatus.initial.name) return;

    showCupertinoDialog(
      context: Get.context!,
      builder: (context) => CupertinoAlertDialog(
        title: const AppText(
          'Would you like to receive event related push notification for this event',
          textAlign: TextAlign.center,
        ),
        actions: [
          CupertinoDialogAction(
            child: const AppText(
              'No thanks',
                color: AppColors.faceBookColor,
            ),
            onPressed: () => setShowNotification(NotificationStatus.hidden),
          ),
          CupertinoDialogAction(
            child: AppText(
              'Yes',
              color: AppColors.faceBookColor,
            ),
            onPressed: () => setShowNotification(NotificationStatus.show),
          ),
        ],
      ),
    );
  }

  void setShowNotification(NotificationStatus status) {
    oneSignalService.updateNotificationStatus(
        AppGlobals.oneSignalUserId, eventId, status == NotificationStatus.show);
    Preferences.setString(
        AppHelper.notificationPrefenceKey(eventId), status.name);
    Get.back();
  }

  void selectMenu(BottomNavMenu menu) async {
    selMenu.value = menu;
    if (selMenu.value!.label == 'track') {
      await Future.delayed(const Duration(seconds: 1));
      final TrackingController controller = Get.find();
      controller.getAthleteTrackingInfo(firstTime: true);
      controller.updateStream.add(Random().nextInt(100));
    }


    // if (menu == menus.first) {
    //   homeController.startFade();
    // } else {
    //   homeController.stopVideo();
    // }
  }

  void goBack() {
    Preferences.setString(AppKeys.eventUrl, '');
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
      final res = await ApiHandler.genericGetHttp(url: entrantsList.url!);
      final athletesM = AthletesM.fromJson(res.data);
      await DatabaseHandler.insertAthletes(athletesM.entrants!);
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint(e.toString());
    }
  }
  
}

class BottomNavMenu {
  BottomNavMenu(
      {required this.view, required this.iconData, required this.label});
  final Widget view;
  final IconData iconData;
  final String label;
}
