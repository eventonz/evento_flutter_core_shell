import 'package:evento_core/ui/dashboard/webview_event_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/res/app_colors.dart';

class WebViewEventPage extends StatelessWidget {
  const WebViewEventPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WebViewEventController());

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: controller.goBack,
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 20,
            ),
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: WebViewWidget(controller: controller.webViewController!),
      ),
    );
  }
}
