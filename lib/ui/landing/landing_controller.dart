import 'dart:convert';

import 'package:evento_core/app_event_config.dart';
import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/models/athlete.dart';
import 'package:evento_core/core/models/event_info.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/routes/routes.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/core/utils/preferences.dart';
import 'package:evento_core/ui/dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LandingController extends GetxController {
  bool isPrev = false;

  @override
  void onInit() {
    super.onInit();
    final res = Get.arguments;
    if (res != null) {
      isPrev = true;
    }
  }

  @override
  void onReady() {
    super.onReady();
    navigate();
  }

  void navigate() async {
    if (!isPrev) {
      await AppGlobals.init();
    }
    await checkLaunchState();
    late String url;
    final config = AppGlobals.appEventConfig;
    if (config.multiEventListId != null) {
      url = Preferences.getString(AppKeys.eventUrl, '');
      await getEvents(config);
    } else {
      url = AppHelper.createUrl(config.singleEventUrl!, config.singleEventId!);
      AppGlobals.selEventId = int.parse(config.singleEventId!);
      Preferences.setInt(AppKeys.eventId, AppGlobals.selEventId);
    }
    AppGlobals.selEventId = Preferences.getInt(AppKeys.eventId, 0);
    checkTheme();
    await Future.delayed(const Duration(milliseconds: 1300));
    if (url.isEmpty) {
      Get.offNamed(Routes.events);
    } else {
      await getConfigDetails(url);
      await getAthletes();
      if (isPrev) {
        Get.off(
          () => const DashboardScreen(),
          routeName: Routes.dashboard,
          transition: Transition.fadeIn,
          duration: const Duration(milliseconds: 1000),
        );
      } else {
        Get.offNamed(Routes.dashboard);
      }
    }
  }

  Future<void> checkLaunchState() async {
    final isInitiallyLaunched =
        Preferences.getBool(AppKeys.isInitiallyLaunched, false);

    if (!isInitiallyLaunched) {
      //await ApiHandler.postHttp(
       //   baseUrl:
        //      'https://eventotracker.com/api/v3/api.cfm/downloads/${AppGlobals.appEventConfig.oneSignalId}',
       //   body: {});
      Preferences.setBool(AppKeys.isInitiallyLaunched, true);
    }
  }

  void checkTheme() {
    final themeMode = AppHelper.getAppTheme(
        Preferences.getString(AppKeys.appThemeStyle, ThemeMode.system.name));
    Get.changeThemeMode(themeMode);
  }

  Future<void> getEvents(AppEventConfig config) async {
    final res = await ApiHandler.genericGetHttp(
        url: AppHelper.createUrl(
            config.multiEventListUrl!, config.multiEventListId!));
    AppGlobals.eventM = EventM.fromJson(res.data);
  }

  Future<void> getConfigDetails(String url) async {
    final res = await ApiHandler.genericGetHttp(url: url);
    AppGlobals.appConfig = AppConfig.fromJson(res.data);
    Preferences.setInt(AppKeys.configLastUpdated,
        AppGlobals.appConfig?.athletes?.lastUpdated ?? 0);
    final accentColors = AppGlobals.appConfig!.theme!.accent;
    AppColors.accentLight = AppHelper.hexToColor(accentColors!.light!);
    AppColors.accentDark = AppHelper.hexToColor(accentColors.dark!);
    AppColors.primary = Theme.of(Get.context!).brightness == Brightness.light
        ? AppColors.accentDark
        : AppColors.accentLight;
    AppColors.secondary = AppColors.primary == AppColors.accentDark
        ? AppColors.accentLight
        : AppColors.accentDark;
  }

  Future<void> getAthletes() async {
    final entrantsList = AppGlobals.appConfig!.athletes!;
    final showAthletes = entrantsList.showAthletes ?? false;
    if (!showAthletes) {
      return;
    }
    try {
      final res = await ApiHandler.genericGetHttp(url: entrantsList.url!);
      late Map<String, dynamic> resJsonData;
      if (res.data.runtimeType == String) {
        resJsonData = jsonDecode(res.data);
      } else {
        resJsonData = res.data;
      }
      final athletesM = AthletesM.fromJson(resJsonData);
      await DatabaseHandler.insertAthletes(athletesM.entrants!);
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
