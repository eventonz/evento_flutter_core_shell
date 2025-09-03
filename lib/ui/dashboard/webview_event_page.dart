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
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: MediaQuery.of(context).padding.top + 4,
                color: Colors.black,
              ),
              Expanded(
                  child:
                      WebViewWidget(controller: controller.webViewController!)),
            ],
          ),
          Visibility(
            visible: true,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.light
                          ? AppColors.white.withOpacity(0.8)
                          : AppColors.black.withOpacity(0.8),
                  child: IconButton(
                    onPressed: controller.goBack,
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.accentLight
                        : AppColors.accentDark,
                    icon: const Icon(Icons.arrow_circle_left_outlined),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
