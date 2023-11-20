import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/models/athlete.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/core/utils/preferences.dart';
import 'package:evento_core/ui/dashboard/athletes/athletes_controller.dart';
import 'package:evento_core/ui/dashboard/dashboard_controller.dart';
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
      DashboardController dashboardController = Get.find();
      final recentlyUpdated = await checkConfigUpdatedDate();
      if (recentlyUpdated) {
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
    final res = await ApiHandler.genericGetHttp(
        url: Preferences.getString(AppKeys.eventUrl, ''));
    AppGlobals.appConfig = AppConfig.fromJson(res.data);
    final newConfigLastUpdated =
        AppGlobals.appConfig?.athletes?.lastUpdated ?? 0;
    final oldConfigLastUpdated =
        Preferences.getInt(AppKeys.configLastUpdated, 0);

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
      final res = await ApiHandler.genericGetHttp(url: entrantsList.url!);
      final athletesM = AthletesM.fromJson(res.data);
      await DatabaseHandler.insertAthletes(athletesM.entrants!);
      await Future.delayed(const Duration(milliseconds: 500));
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
