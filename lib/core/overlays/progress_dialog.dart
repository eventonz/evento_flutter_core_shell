import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProgressDialogUtils {
  static final ProgressDialogUtils _instance = ProgressDialogUtils.internal();
  static bool _isLoading = false;

  ProgressDialogUtils.internal();

  factory ProgressDialogUtils() => _instance;

  static void dismiss() {
    if (_isLoading) {
      Get.back();
      _isLoading = false;
    }
  }

  static Future<void> show() async {
    _isLoading = true;
    await Get.dialog(const Center(child: CircularProgressIndicator.adaptive()),
        barrierDismissible: false);
  }
}
