import 'dart:io';

import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/ui/landing/landing_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(LandingController());
    return Scaffold(
      body: Stack(
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
    );
  }
}
