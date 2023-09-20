import 'dart:io';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewController extends GetxController {
  late String url;
  late WebViewController webViewController;
  final webViewDataSnapShot = DataSnapShot.loading.obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    final res = Get.arguments;
    url = res[AppKeys.url];
    setupWebviewController();
  }

  void setupWebviewController() {
    webViewDataSnapShot.value = DataSnapShot.loading;
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {
          if (progress == 100) {
            webViewDataSnapShot.value = DataSnapShot.loaded;
          }
        },
        onWebResourceError: (WebResourceError error) {
          webViewDataSnapShot.value = DataSnapShot.error;
        },
      ))
      ..setBackgroundColor(AppColors.white)
      ..loadRequest(Uri.parse(url));
  }
}
