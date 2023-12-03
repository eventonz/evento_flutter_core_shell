import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/ui/dashboard/athletes_tracking/tracking_controller.dart';
import 'package:evento_core/ui/dashboard/bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());
    Get.put(TrackingController());
    return Scaffold(
        body: Stack(
          children: [
            Obx(() => controller.selMenu.value!.view),
            Obx(() => Visibility(
                  visible: controller.selMenu.value == controller.menus.first &&
                      AppGlobals.appEventConfig.multiEventListId != null,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: CircleAvatar(
                        radius: 5.5.w,
                        backgroundColor:
                            Theme.of(context).brightness == Brightness.light
                                ? AppColors.black.withOpacity(0.8)
                                : AppColors.white.withOpacity(0.8),
                        child: IconButton(
                          onPressed: controller.goBack,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? AppColors.accentDark
                                  : AppColors.accentLight,
                          icon: const Icon(Icons.arrow_circle_left_outlined),
                        ),
                      ),
                    ),
                  ),
                )),
          ],
        ),
        bottomNavigationBar: const AppBottomNav());
  }
}
