import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/logger.dart';
import 'package:evento_core/ui/dashboard/dashboard_controller.dart';
import 'package:evento_core/ui/dashboard/more/more_controller.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/utils/helpers.dart';

class HomeController extends GetxController {
  final imagelink = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadImageLink();
  }

  void loadImageLink() {
    imagelink.value = AppGlobals.appConfig?.home?.image ?? '';
  }

  void openShortcut(String action, int? pageId, {String? url}) {
    Logger.d('Opening shortcut with action: $action');

    if (action == 'openPage') {
      Logger.d('Looking for page with ID: $pageId');
      Logger.d(
          'Available menu items: ${AppGlobals.appConfig?.menu?.items?.map((e) => '${e.id}: ${e.title}')}');

      final controller = Get.put(MoreController());
      var page = AppGlobals.appConfig?.menu?.items
          ?.where((item) => item.id == pageId)
          .firstOrNull;

      if (page == null) {
        Logger.e('Page with ID $pageId not found in menu items');
        return;
      }

      Logger.d('Found page: ${page.title}');
      controller.decideNextView(page);
    }

    if (action == 'openTracking') {
      try {
        final dashboard = Get.find<DashboardController>();
        if (dashboard.menus.isNotEmpty) {
          dashboard.selectMenu(
              dashboard.menus.where((e) => e.label == 'track').first);
        }
      } catch (e) {
        Logger.e('DashboardController not ready for tracking shortcut: $e');
      }
    }

    if (action == 'openAthletes') {
      try {
        final dashboard = Get.find<DashboardController>();
        if (dashboard.menus.isNotEmpty) {
          final entrantsList = AppGlobals.appConfig?.athletes;
          dashboard.selectMenu(dashboard.menus
              .where((e) =>
                  e.label == AppHelper.setAthleteMenuText(entrantsList?.text))
              .first);
        }
      } catch (e) {
        Logger.e('DashboardController not ready for athletes shortcut: $e');
      }
    }

    if (action == 'openResults') {
      try {
        final dashboard = Get.find<DashboardController>();
        if (dashboard.menus.isNotEmpty) {
          dashboard.selectMenu(
              dashboard.menus.where((e) => e.label == 'results').first);
        }
      } catch (e) {
        Logger.e('DashboardController not ready for results shortcut: $e');
      }
    }

    if (action == 'openURL') {
      Logger.d('Attempting to open URL: $url');
      if (url != null) {
        launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault)
            .then((success) {
          Logger.d('URL launch result: $success');
        }).catchError((error) {
          Logger.e('Error launching URL: $error');
        });
      } else {
        Logger.e('No URL provided for openURL action');
      }
    }
  }
}
