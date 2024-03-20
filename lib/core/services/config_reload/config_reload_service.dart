import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/models/athlete.dart';
import 'package:evento_core/core/overlays/blur_loading.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/core/utils/preferences.dart';
import 'package:evento_core/ui/dashboard/athletes/athletes_controller.dart';
import 'package:evento_core/ui/dashboard/dashboard_controller.dart';
import 'package:evento_core/ui/dashboard/home/home_controller.dart';
import 'package:evento_core/ui/dashboard/more/more_controller.dart';
import 'package:evento_core/ui/dashboard/athletes_tracking/tracking_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';

import '../../../ui/dashboard/athletes/athletes.dart';
import '../../../ui/dashboard/athletes_tracking/tracking.dart';
import '../../utils/app_global.dart';

class ConfigReload extends GetxController with WidgetsBindingObserver {
  late AppLifecycleState cycleState;

  bool reloaded = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    cycleState = state;
    if (state == AppLifecycleState.resumed) {
      checkAthletesUpdate();
    }
  }

  void checkAthletesUpdate() async {
    try {
      BlurLoadingOverlay.show(loadingText: 'Checking for Updates');
      final recentlyUpdated = await checkConfigUpdatedDate();
      if (recentlyUpdated && AppGlobals.oldAppConfig != AppGlobals.appConfig) {
        DashboardController dashboardController = Get.find();
        dashboardController.athleteSnapData.value = DataSnapShot.loading;
        await getAthletes();
        Get.put(AthletesController());
        dashboardController.athleteSnapData.value = DataSnapShot.loaded;
      }
      AppGlobals.oldAppConfig = AppGlobals.appConfig;
      BlurLoadingOverlay.dismiss();
    } catch (e) {
      debugPrint(e.toString());
      BlurLoadingOverlay.dismiss();
    }
  }

  Future<bool> checkConfigUpdatedDate() async {
    final config = AppGlobals.appEventConfig;
    String url = Preferences.getString(AppKeys.eventUrl, '');
    if (url.isEmpty) {
      if (config.multiEventListId != null) {
        return false;
      } else {
        url =
            AppHelper.createUrl(config.singleEventUrl!, config.singleEventId!);
        Preferences.setString(AppKeys.eventUrl, url);
        AppGlobals.selEventId = int.parse(config.singleEventId!);
        Preferences.setInt(AppKeys.eventId, AppGlobals.selEventId);
      }
    }
    // tries to check for updates for 5 sec then returns false
    final res = await ApiHandler.genericGetHttp(
        url: url, apiTimeout: const Duration(seconds: 5));
    if (res.statusMessage == 'Error') {
      return false;
    }
    AppGlobals.appConfig = AppConfig.fromJson(res.data);

    AppGlobals.oldAppConfig ??= AppConfig.fromJson(res.data);

    final newConfigLastUpdated =
        AppGlobals.appConfig?.athletes?.lastUpdated ?? 0;
    final oldConfigLastUpdated =
        Preferences.getInt(AppKeys.configLastUpdated, 0);

    if(AppGlobals.oldAppConfig?.home?.image != AppGlobals.appConfig?.home?.image) {
      final HomeController homeController = Get.find();
      homeController.loadImageLink();
    }

    if(AppGlobals.oldAppConfig?.tracking != AppGlobals.appConfig?.tracking) {
      final TrackingController trackingController = Get.find();
      trackingController.onInit();
      trackingController.getRoutePaths();
    }

    reloaded = true;

    if(!AppHelper.listsAreEqual(AppGlobals.oldAppConfig?.menu?.items ?? [], AppGlobals.appConfig?.menu?.items ?? [])) {
      final MoreController moreController = Get.find();
      moreController.doRrefresh();
    }



    if(AppGlobals.oldAppConfig?.athletes != AppGlobals.appConfig?.athletes || AppGlobals.oldAppConfig?.tracking != AppGlobals.appConfig?.tracking) {
      final DashboardController dashboardController = Get.find();
      dashboardController.reloadMenu();
    }


    await Future.delayed(const Duration(seconds: 1));
    if (newConfigLastUpdated != oldConfigLastUpdated) {
      Preferences.setInt(AppKeys.configLastUpdated, newConfigLastUpdated);
      return true;
    } else {
      return false;
    }
  }

  Future<void> getAthletes() async {
    final entrantsList = AppGlobals.appConfig!.athletes!;
    final showAthletes = entrantsList.showAthletes ?? false;
    if (!showAthletes) {
      return;
    }
    try {
      BlurLoadingOverlay.updateLoaderText(
          'Updating ${AppHelper.setAthleteMenuText(entrantsList.text)} List');
      final res = await ApiHandler.genericGetHttp(url: entrantsList.url!);
      final athletesM = AthletesM.fromJson(res.data);
      await DatabaseHandler.insertAthletes(athletesM.entrants!);
    } catch (e) {
      debugPrint(e.toString());
      BlurLoadingOverlay.dismiss();
    }
  }

  @override
  void onClose() {
    super.onClose();
    WidgetsBinding.instance.removeObserver(this);
  }
}
