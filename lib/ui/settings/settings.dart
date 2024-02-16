import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/res/app_styles.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/ui/common_components/checkbox_switch.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:evento_core/ui/common_components/title_divider.dart';
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
          surfaceTintColor: Colors.white,
          shadowColor: Colors.white,
          title: const AppText(
            'Settings',
            style: AppStyles.appBarTitle,
          ),
        ),
        body: Column(
          children: [
            const TitleDivider(title: 'General Settings'),
            ListTile(
              onTap: controller.showThemeModePrompt,
              title: const AppText(
                'App Theme',
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
            const Divider(
              height: 0,
            ),
            ListTile(
              onTap: controller.getAthletes,
              title: const AppText(
                'Reload Athletes',
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
            const Divider(
              height: 0,
            ),
            const TitleDivider(title: 'Notification Settings'),
            ListTile(
              onTap: controller.toggleNotificationStatus,
              title: const AppText(
                'Event Updates',
              ),
              trailing: Obx(() => AppCheckBox(
                  isChecked: controller.eventNotificationstatus.value)),
            ),
            const Divider(),
            ListTile(
              title: AppText(
                'Version ${AppGlobals.appVersion}',
                fontSize: 12,
              ),
            ),
          ],
        ));
  }
}
