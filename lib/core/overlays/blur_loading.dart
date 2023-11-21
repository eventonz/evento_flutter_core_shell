import 'dart:ui';

import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class BlurLoadingOverlay {
  static final BlurLoadingOverlay _instance = BlurLoadingOverlay.internal();
  static bool _isLoading = false;

  BlurLoadingOverlay.internal();

  factory BlurLoadingOverlay() => _instance;

  static void dismiss() {
    if (_isLoading) {
      Get.back();
      _isLoading = false;
    }
  }

  static Future<void> show({String loadingText = 'Please wait...'}) async {
    _isLoading = true;
    await Get.dialog(
        Scaffold(
          backgroundColor: AppColors.black.withOpacity(0.25),
          body: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Center(
              child: Column(
                children: [
                  const Spacer(flex: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 40),
                    decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                            width: 5.w,
                            height: 5.w,
                            child: const CircularProgressIndicator.adaptive(
                              strokeWidth: 3,
                            )),
                        SizedBox(
                          height: 2.h,
                        ),
                        AppText(
                          loadingText,
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
        barrierColor: AppColors.transparent,
        barrierDismissible: false);
  }
}
