import 'dart:ui';

import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BlurLoadingOverlay {
  static final BlurLoadingOverlay _instance = BlurLoadingOverlay.internal();
  static bool _isLoading = false;
  static final _loadingText = 'Updating'.obs;

  BlurLoadingOverlay.internal();

  factory BlurLoadingOverlay() => _instance;

  static void dismiss() {
    _loadingText.value = 'Updating';
    if (_isLoading) {
      Get.back();
      _isLoading = false;
    }
  }

  static Future<void> show({String? loadingText}) async {
    if(_isLoading) {
      return;
    }
    // if (_isLoading) {
    //   Get.back();
    //   _isLoading = false;
    // }
    _isLoading = true;
    await Get.dialog(
        Scaffold(
          backgroundColor: AppColors.black.withOpacity(0.15),
          body: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Center(
              child: Column(
                children: [
                  const Spacer(flex: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                    decoration: BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(() => AppText(
                              _loadingText.value,
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            )),
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

  static void updateLoaderText(String text) {
    if (_isLoading) {
      _loadingText.value = text;
    }
  }
}
