import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'dashboard_controller.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find();

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.white
                : AppColors.darkBlack,
            boxShadow: [
              BoxShadow(
                  color: AppColors.black.withOpacity(0.08),
                  spreadRadius: 0.05,
                  blurRadius: 8,
                  offset: const Offset(0, -10))
            ]),
        height: 7.5.h,
        child: Obx(
          () => Row(
            children: [
              for (BottomNavMenu menu in controller.menus)
                Visibility(
                  visible: true,
                  child: Expanded(
                      child: Visibility(
                    visible: true,
                    child: InkWell(
                      onTap: () {
                        controller.selectMenu(menu);
                      },
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            menu.image == null
                                ? Icon(menu.iconData,
                                    color: controller.selMenu.value == menu
                                        ? (Theme.of(context).brightness ==
                                                Brightness.light
                                            ? AppColors.primary
                                            : AppColors.secondary)
                                        : Theme.of(context).brightness ==
                                                Brightness.light
                                            ? AppColors.grey.withOpacity(0.8)
                                            : AppColors.greyLight
                                                .withOpacity(0.4))
                                : Image.asset(menu.image!,
                                    color: controller.selMenu.value == menu
                                        ? (Theme.of(context).brightness ==
                                                Brightness.light
                                            ? AppColors.primary
                                            : AppColors.secondary)
                                        : Theme.of(context).brightness ==
                                                Brightness.light
                                            ? AppColors.grey.withOpacity(0.8)
                                            : AppColors.greyLight
                                                .withOpacity(0.4)),
                            const SizedBox(
                              height: 4,
                            ),
                            AppText(menu.text ?? menu.label.capitalize!,
                                fontSize: 10,
                                color: controller.selMenu.value == menu
                                    ? (Theme.of(context).brightness ==
                                            Brightness.light
                                        ? AppColors.primary
                                        : AppColors.secondary)
                                    : Theme.of(context).brightness ==
                                            Brightness.light
                                        ? AppColors.grey.withOpacity(0.8)
                                        : AppColors.greyLight.withOpacity(0.4))
                          ],
                        ),
                      ),
                    ),
                  )),
                )
            ],
          ),
        ),
      ),
    );
  }
}
