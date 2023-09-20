import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/ui/common_components/retry_layout.dart';
import 'package:evento_core/ui/common_components/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'webview_controller.dart';

class WebviewScreen extends StatelessWidget {
  const WebviewScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WebviewController());
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Obx(() {
          final webViewDataSnapshot = controller.webViewDataSnapShot.value;
          if (webViewDataSnapshot == DataSnapShot.loaded) {
            return WebViewWidget(
              controller: controller.webViewController,
            );
          } else if (webViewDataSnapshot == DataSnapShot.error) {
            return Center(
                child: RetryLayout(onTap: controller.setupWebviewController));
          } else {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
        }),
      ),
    );
  }
}
