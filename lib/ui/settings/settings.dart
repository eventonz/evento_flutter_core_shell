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
          backgroundColor: Theme.of(context).brightness == Brightness.light
              ? AppColors.greyLighter
              : AppColors.darkBlack,
          surfaceTintColor: Theme.of(context).brightness == Brightness.light
              ? AppColors.greyLighter
              : AppColors.darkBlack,
          shadowColor: Theme.of(context).brightness == Brightness.light
              ? Colors.black.withOpacity(0.1)
              : Colors.transparent,
          title: AppText(
            AppLocalizations.of(context)!.settings,
            style: AppStyles.appBarTitle,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // General Settings Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: AppText(
                          '${AppLocalizations.of(context)!.general} ${AppLocalizations.of(context)!.settings}',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                        thickness: 0.5,
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppColors.darkgrey.withOpacity(0.2)
                            : AppColors.greyLight.withOpacity(0.2),
                      ),
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
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Notification Settings Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: AppText(
                          AppLocalizations.of(context)!.notificationSettings,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ListTile(
                        onTap: controller.toggleNotificationStatus,
                        title: AppText(
                          AppLocalizations.of(context)!.eventUpdates,
                        ),
                        trailing: Obx(() => AppCheckBox(
                            isChecked:
                                controller.eventNotificationstatus.value)),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // App Info Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: AppText(
                          'App Information',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      ListTile(
                        title: AppText(
                          '${AppLocalizations.of(context)!.version} ${AppGlobals.appVersion}',
                          fontSize: 14,
                          color: AppColors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ));
  }
}
