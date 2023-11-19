import 'package:evento_core/core/services/app_one_signal/app_one_signal_service.dart';
import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/models/athlete.dart';
import 'package:evento_core/core/overlays/toast.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/core/utils/preferences.dart';
import 'package:evento_core/ui/common_components/bottom_sheet.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SettingsController extends GetxController {
  final AppOneSignal oneSignalService = Get.find();
  late int eventId;
  final showAthleteInfo = false.obs;
  final eventNotificationstatus = false.obs;
  final themeMode = ThemeMode.system.obs;
  final athletesloading = DataSnapShot.loaded.obs;

  @override
  void onInit() {
    super.onInit();
    getPreferencesDetails();
  }

  void getPreferencesDetails() {
    eventId = Preferences.getInt(AppKeys.eventId, -1);
    showAthleteInfo.value = Preferences.getBool(AppKeys.showAthleteInfo, false);
    final notificationStatus = Preferences.getString(
        AppHelper.notificationPrefenceKey(eventId),
        NotificationStatus.initial.name);
    eventNotificationstatus.value =
        notificationStatus == NotificationStatus.show.name;
    themeMode.value = AppHelper.getAppTheme(
        Preferences.getString(AppKeys.appThemeStyle, ThemeMode.system.name));
  }

  void toggleAthleteInfo() {
    showAthleteInfo.value = !showAthleteInfo.value;
    Preferences.setBool(AppKeys.showAthleteInfo, showAthleteInfo.value);
  }

  void toggleNotificationStatus() {
    eventNotificationstatus.value = !eventNotificationstatus.value;
    oneSignalService.updateNotificationStatus(
        AppGlobals.oneSignalUserId, eventId, eventNotificationstatus.value);
    Preferences.setString(
        AppHelper.notificationPrefenceKey(eventId),
        (eventNotificationstatus.value
                ? NotificationStatus.show
                : NotificationStatus.hidden)
            .name);
  }

  void showThemeModePrompt() {
    AppFixedBottomSheet(
      Get.context!,
    ).show(
        child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Theme.of(Get.context!).bottomSheetTheme.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                  onTap: () {
                    Get.back();
                    showThemeModePrompt();
                  },
                  child: const AppText(
                    'Select App Theme',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )),
              IconButton(onPressed: Get.back, icon: const Icon(FeatherIcons.x))
            ],
          ),
          const Divider(),
          ListTile(
            onTap: () => updateAppTheme(ThemeMode.system),
            minVerticalPadding: 0,
            leading: const AppText(
              'System',
              fontSize: 16,
            ),
            trailing: Icon(
              FeatherIcons.hexagon,
              size: 4.w,
            ),
          ),
          ListTile(
            onTap: () => updateAppTheme(ThemeMode.light),
            minVerticalPadding: 0,
            leading: const AppText(
              'Light',
              fontSize: 16,
            ),
            trailing: Icon(
              FeatherIcons.sun,
              size: 4.w,
            ),
          ),
          ListTile(
            onTap: () => updateAppTheme(ThemeMode.dark),
            minVerticalPadding: 0,
            leading: const AppText(
              'Dark',
              fontSize: 16,
            ),
            trailing: Icon(
              FeatherIcons.moon,
              size: 4.w,
            ),
          ),
        ],
      ),
    ));
  }

  void updateAppTheme(ThemeMode themeMode) {
    Get.back();
    this.themeMode.value = themeMode;
    Preferences.setString(AppKeys.appThemeStyle, themeMode.name);
    Get.changeThemeMode(themeMode);
  }

  IconData getThemeIcon() {
    switch (themeMode.value) {
      case ThemeMode.system:
        return FeatherIcons.hexagon;
      case ThemeMode.light:
        return FeatherIcons.sun;
      case ThemeMode.dark:
        return FeatherIcons.moon;
    }
  }

  Future<void> getAthletes() async {
    if (athletesloading.value == DataSnapShot.loading) {
      return;
    }
    final entrantsList = AppGlobals.appConfig!.athletes!;
    final showAthletes = entrantsList.showAthletes ?? false;
    if (!showAthletes) {
      return;
    }
    try {
      athletesloading.value = DataSnapShot.loading;
      final res = await ApiHandler.genericGetHttp(url: entrantsList.url!);
      final athletesM = AthletesM.fromJson(res.data);
      await DatabaseHandler.insertAthletes(athletesM.entrants!);
      await Future.delayed(const Duration(milliseconds: 500));
      athletesloading.value = DataSnapShot.loaded;
      ToastUtils.show('Reloaded Athletes successfully');
    } catch (e) {
      athletesloading.value = DataSnapShot.error;
      ToastUtils.show('Unbale to reload athletes, please try again later');
    }
  }
}
