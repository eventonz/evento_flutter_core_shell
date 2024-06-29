import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/routes/routes.dart';
import '../../core/utils/keys.dart';
import '../../core/utils/preferences.dart';
import '../events/events.dart';

class WebViewEventController extends GetxController {

  WebViewController? webViewController;

  WebViewEventController();

  @override
  void onInit() {
    super.onInit();
    if(Get.arguments != null && Get.arguments is WebViewController) {
      webViewController = Get.arguments;
    }
  }

  void goBack() {
    Preferences.setString(AppKeys.eventUrl, '');
    Get.off(
          () => const EventsScreen(),
      routeName: Routes.events,
      transition: Transition.leftToRightWithFade,
    );
  }
}