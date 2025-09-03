import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/res/app_styles.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/l10n/app_localizations.dart';
import 'package:evento_core/ui/common_components/checkbox_switch.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:evento_core/ui/common_components/title_divider.dart';
import 'package:evento_core/ui/settings/language_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    return Scaffold(
        appBar: AppBar(
          surfaceTintColor: Theme.of(context).brightness == Brightness.light
              ? Colors.white
              : Colors.black,
          shadowColor: Theme.of(context).brightness == Brightness.light
              ? Colors.black.withOpacity(0.1)
              : Colors.white,
          title: AppText(
            AppLocalizations.of(context)!.settings,
            style: AppStyles.appBarTitle,
          ),
        ),
        body: Column(
          children: [
            TitleDivider(
                title:
                    '${AppLocalizations.of(context)!.general} ${AppLocalizations.of(context)!.settings}'),
            ListTile(
              onTap: controller.showThemeModePrompt,
              title: AppText(
                AppLocalizations.of(context)!.appTheme,
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Obx(() => Icon(
                      controller.getThemeIcon(),
                      size: 6.w,
                      color: AppColors.grey,
                    )),
              ),
            ),
            Divider(
                height: 1,
                thickness: .5,
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.greyLight
                    : AppColors.darkgrey),
            /* ListTile(
              onTap: controller.getAthletes,
              title: AppText(
                AppLocalizations.of(context)!.reloadAthletes,
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Obx(() =>
                    controller.athletesloading.value == DataSnapShot.loading
                        ? const Padding(
                            padding: EdgeInsets.only(right: 6.0),
                            child: SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                backgroundColor: AppColors.greyLight,
                                strokeWidth: 3,
                                color: AppColors.grey,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.refresh,
                            size: 6.w,
                            color: AppColors.grey,
                          )),
              ),
            ),*/
            Divider(
                height: 1,
                thickness: .5,
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.greyLight
                    : AppColors.darkgrey),
            ListTile(
              onTap: () {
                Get.to(LanguageScreen());
              },
              title: AppText(
                AppLocalizations.of(context)!.language,
              ),
              trailing: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.language,
                  size: 6.w,
                  color: AppColors.grey,
                ),
              ),
            ),
            /*
            const Divider(
              height: 0,
            ),
            ListTile(
              onTap: controller.toggleAthleteInfo,
              title: const AppText(
                'Athlete Information',
              ),
              trailing: Obx(() =>
                  AppCheckBox(isChecked: controller.showAthleteInfo.value)),
            ),
            */
            Divider(
                height: 1,
                thickness: .5,
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.greyLight
                    : AppColors.darkgrey),
            TitleDivider(
                title: AppLocalizations.of(context)!.notificationSettings),
            ListTile(
              onTap: controller.toggleNotificationStatus,
              title: AppText(
                AppLocalizations.of(context)!.eventUpdates,
              ),
              trailing: Obx(() => AppCheckBox(
                  isChecked: controller.eventNotificationstatus.value)),
            ),
            Divider(
                height: 1,
                thickness: .5,
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.greyLight
                    : AppColors.darkgrey),
            ListTile(
              title: AppText(
                '${AppLocalizations.of(context)!.version} ${AppGlobals.appVersion}',
                fontSize: 12,
              ),
            ),
          ],
        ));
  }
}
