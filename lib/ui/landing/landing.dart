import 'dart:io';

import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/l10n/app_localizations.dart';
import 'package:evento_core/ui/landing/landing_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LandingController());
    return Obx(
      () => Scaffold(
        body: controller.noConnection.value ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon representing no internet connection
              Icon(
                Icons.wifi_off,
                size: 80,
                color: AppColors.primary,
              ),
              SizedBox(height: 20),

              // "Whoops!" text
              Text(
                'Whoops!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 10),

              // No internet connection message
              Text(
                AppLocalizations.of(context)!.noInternetConnectionFoundMsg,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 30),

              // Reload button
              ElevatedButton(
                onPressed: () {
                  // Add your reload functionality here
                  controller.noConnection.value = false;
                  controller.noConnection.refresh();
                  controller.checkConnection();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  AppLocalizations.of(context)!.reload,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ) : controller.exception.value ?  Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon representing no internet connection
              Icon(
                Icons.error,
                size: 80,
                color: Colors.redAccent,
              ),
              SizedBox(height: 20),

              // "Whoops!" text
              Text(
                AppLocalizations.of(context)!.oops,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(height: 10),

              // No internet connection message
              Text(
                '${AppLocalizations.of(context)!.somethingWentWrong}.\n${AppLocalizations.of(context)!.pleaseTryAgainLater}.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 30),

              // Reload button
              ElevatedButton(
                onPressed: () async {
                  // Add your reload functionality here
                  controller.exception.value = false;
                  controller.exception.refresh();
                  await Future.delayed(const Duration(milliseconds: 300));
                  controller.navigate();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  AppLocalizations.of(context)!.reload,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ) : Stack(
          children: [
            Image.asset(
              AppGlobals.appEventConfig.splashImage ??
                  AppHelper.getImage('splash_image.png'),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(bottom: Platform.isAndroid ? 24 : 12),
                  child: CircleAvatar(
                      backgroundColor: AppColors.white.withOpacity(0.8),
                      radius: 5.w,
                      child: SizedBox(
                          width: 5.w,
                          height: 5.w,
                          child: const CircularProgressIndicator.adaptive(
                            strokeWidth: 3,
                          ))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
