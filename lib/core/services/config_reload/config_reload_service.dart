import 'package:dio/dio.dart';
import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/models/athlete.dart';
import 'package:evento_core/core/overlays/blur_loading.dart';
import 'package:evento_core/core/overlays/toast.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/core/utils/preferences.dart';
import 'package:evento_core/ui/dashboard/athletes/athletes_controller.dart';
import 'package:evento_core/ui/dashboard/dashboard_controller.dart';
import 'package:evento_core/ui/dashboard/home/home_controller.dart';
import 'package:evento_core/ui/dashboard/more/more_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../utils/app_global.dart';

class ConfigReload extends GetxController with WidgetsBindingObserver {
  late AppLifecycleState cycleState;

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
      final recentlyUpdated = await checkConfigUpdatedDate();
      if (recentlyUpdated) {
        DashboardController dashboardController = Get.find();
        dashboardController.athleteSnapData.value = DataSnapShot.loading;
        await getAthletes();
        final controller = Get.put(AthletesController());
        controller.update();
        dashboardController.athleteSnapData.value = DataSnapShot.loaded;
      }
    } catch (e) {
      debugPrint(e.toString());
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
    BlurLoadingOverlay.show(loadingText: 'Checking for Updates');

    final res = await ApiHandler.genericGetHttp(
        url: url, apiTimeout: const Duration(seconds: 5));
    if (res.statusMessage == 'Error') {
      BlurLoadingOverlay.dismiss();
      return false;
    }
    AppGlobals.appConfig = AppConfig.fromJson(res.data);
    final newConfigLastUpdated =
        AppGlobals.appConfig?.athletes?.lastUpdated ?? 0;
    final oldConfigLastUpdated =
        Preferences.getInt(AppKeys.configLastUpdated, 0);

    final HomeController homeController = Get.find();
    homeController.loadImageLink();
    final MoreController moreController = Get.find();
    moreController.doRrefresh();

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
      ToastUtils.show(
          'Updating ${AppHelper.setAthleteMenuText(entrantsList.text)} List...');
      final res = await ApiHandler.genericGetHttp(url: entrantsList.url!);
      final athletesM = AthletesM.fromJson(res.data);
      await DatabaseHandler.insertAthletes(athletesM.entrants!);
      await Future.delayed(const Duration(milliseconds: 500));
      ToastUtils.show('List updated');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void onClose() {
    super.onClose();
    WidgetsBinding.instance.removeObserver(this);
  }
}
