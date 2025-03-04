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
import 'package:get/get.dart';

import '../../utils/app_global.dart';

class ConfigReload extends GetxController with WidgetsBindingObserver {
  late AppLifecycleState cycleState;

  bool reloaded = false;

  @override
  void onInit() {
    super.onInit();
    checkAthletesUpdate();
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
      final recentlyUpdated = await checkConfigUpdatedDate();
      if (true || (recentlyUpdated)) {
        DashboardController dashboardController = Get.find();
        dashboardController.athleteSnapData.value = DataSnapShot.loading;
        //await getAthletes();
        Get.put(AthletesController());
        dashboardController.athleteSnapData.value = DataSnapShot.loaded;

        var edition = AppGlobals.appConfig?.athletes?.edition ?? '';

        var raceId = AppGlobals.selEventId;

        List<String> athletes = (await DatabaseHandler.getAthletesOnce('', true)).map((e) => e.raceno ?? '').toList();


        var data = await ApiHandler.patchHttp(endPoint: 'athletes/$raceId', body: {
          'edition' : edition,
          'athletes' : athletes,
        });

        print('athletesData ${data.data}');


        var list = (data.data['patchedathletes'] as List).map((e) => Entrants.fromJson(e)).toList();

        print('oklist');
        print(list.map((e) => e.toJson()));
        
        await DatabaseHandler.removeAllAthletes();

        await DatabaseHandler.insertAthletes(list);


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
        url: config.configUrl ?? url, apiTimeout: const Duration(seconds: 5));
    if (res.statusMessage == 'Error') {
      return false;
    }
    AppGlobals.appConfig = AppConfig.fromJson(res.data);

    //AppGlobals.oldAppConfig ??= AppConfig.fromJson(res.data);

    final newConfigLastUpdated =
        AppGlobals.appConfig?.athletes?.lastUpdated ?? 0;
    final oldConfigLastUpdated =
    Preferences.getInt(AppKeys.configLastUpdated, 0);

    if(AppGlobals.oldAppConfig?.home?.image != AppGlobals.appConfig?.home?.image) {
      try {
        BlurLoadingOverlay.show(loadingText: 'Checking for Updates');
        final HomeController homeController = Get.find();
        homeController.loadImageLink();
      } catch (e) {
        print(e.toString());
        BlurLoadingOverlay.dismiss();
      }
    }

    if(AppGlobals.oldAppConfig?.tracking != AppGlobals.appConfig?.tracking) {
      try {
        BlurLoadingOverlay.show(loadingText: 'Checking for Updates');
        final TrackingController trackingController = Get.find();
        trackingController.onInit();
        await trackingController.getRoutePaths();
      } catch (e) {
        print(e.toString());
        BlurLoadingOverlay.dismiss();
      }
    }

    reloaded = true;

    if(!AppHelper.listsAreEqual(AppGlobals.oldAppConfig?.menu?.items ?? [], AppGlobals.appConfig?.menu?.items ?? [])) {
      try {
        BlurLoadingOverlay.show(loadingText: 'Checking for Updates');
        final MoreController moreController = Get.find();
        moreController.doRrefresh();
      } catch (e) {
        print(e.toString());
        BlurLoadingOverlay.dismiss();
      }
    }

    //testing new branch

    if(AppGlobals.oldAppConfig?.athletes != AppGlobals.appConfig?.athletes || AppGlobals.oldAppConfig?.tracking != AppGlobals.appConfig?.tracking) {
      try {
        BlurLoadingOverlay.show(loadingText: 'Checking for Updates');
        final DashboardController dashboardController = Get.find();
        dashboardController.reloadMenu();
      } catch (e) {
        print(e.toString());
        BlurLoadingOverlay.dismiss();
      }
    }


    await Future.delayed(const Duration(seconds: 1));
    BlurLoadingOverlay.dismiss();
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
      //final res = await ApiHandler.genericGetHttp(url: entrantsList.url!);
      //final athletesM = AthletesM.fromJson(res.data);
      //await DatabaseHandler.insertAthletes(athletesM.entrants!);
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
