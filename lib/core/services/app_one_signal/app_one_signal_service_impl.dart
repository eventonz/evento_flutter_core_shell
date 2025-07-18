import 'dart:async';

import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/routes/routes.dart';
import 'package:evento_core/core/services/app_one_signal/app_one_signal_service.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/core/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:app_links/app_links.dart';

import '../../../evento_app.dart';
import '../../../ui/dashboard/more/more_controller.dart';
import '../../models/app_config.dart';

class AppOneSignalImpl implements AppOneSignal {
  final appLinks = AppLinks();

  AppOneSignalImpl() {
    // Do not call init() here. Initialization will be triggered manually.
    initUniLinks();
  }

  late StreamSubscription _sub;

  Future<void> initUniLinks() async {
    try {
      Uri? initialLink = await appLinks.getInitialLink();
      if (initialLink != null) {
        // Handle the initial deep link
      }
    } catch (e) {
      print('Error initializing deep link: $e');
    }

    // Listen for incoming deep links
    _sub = appLinks.uriLinkStream.listen((Uri? link) {
      if (link != null) {
        // Handle the incoming deep link
        print(link);
      }
    }, onError: (error) {
      print('Error listening to deep link: $error');
    });
  }

  Future<void> initializeOneSignal() async {
    await Future.delayed(const Duration(seconds: 1));
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(AppGlobals.appEventConfig.oneSignalId);
    OneSignal.Notifications.requestPermission(true);

    OneSignal.Notifications.addClickListener((event) async {
      debugPrint(
          'NOTIFICATION OPENED HANDLER CALLED WITH: [33m${event.notification.additionalData?['open']} ${event.result.url} ${event.result.actionId}[0m');
      String? open = event.notification.additionalData?['open'];
      if (open != null) {
        if (canRunNotificationHandler) {
          notificationHandler(open);
        }
        notificationHandlerController.stream.listen((value) {
          if (value) {
            notificationHandlerController.close();
            print('canRunNotificationHandler $value');
            canRunNotificationHandler = true;
            notificationHandler(open);
          }
        });
      }
    });

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugPrint('FOREGROUND HANDLER CALLED WITH: $event');
    });

    await setOneSignalUserId();
  }

  Future<void> notificationHandler(String open) async {
    Future.delayed(const Duration(seconds: 1), () async {
      Get.offNamedUntil(Routes.dashboard, (_) => false);
      String? eventId;
      if (open.contains('event_id/')) {}
      if (open.contains('/athlete/')) {
        eventId = open.substring(
            open.indexOf('event_id/') + 9, open.indexOf('/athlete/'));
        String athleteId = open.split('/athlete/')[1];
        Get.toNamed(Routes.athleteDetails, arguments: {
          AppKeys.athlete: await DatabaseHandler.getSingleAthleteOnce(athleteId)
        });
      }
      if (open.contains('/page/')) {
        eventId = open.substring(
            open.indexOf('event_id/') + 9, open.indexOf('/page/'));
        String menuId = open.split('/page/')[1];
        final MoreController controller = Get.find();
        Items? item = controller.moreDetails.items
            ?.where((element) => element.id == int.parse(menuId))
            .firstOrNull;
        if (item != null) {
          controller.decideNextView(item);
        }
      }
    });
  }

  @override
  Future<String> setOneSignalUserId() async {
    String userId = '';
    await Preferences.init();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Get the actual OneSignal User ID
      userId = OneSignal.User.pushSubscription.id ?? '';
      if (userId.isNotEmpty) {
        await Preferences.setString(AppKeys.oneSingleUserId, userId);
        AppGlobals.oneSignalUserId = userId;
      } else {
        // Fallback to stored user ID if OneSignal ID is not available
        userId = Preferences.getString(AppKeys.oneSingleUserId, '');
        AppGlobals.oneSignalUserId = userId;
      }
    });
    return userId;
  }

  @override
  Future<void> updateNotificationStatus(
      String userId, int eventId, bool notificationStatus) async {
    final data = {
      "race_id": eventId,
      "player_id": userId,
      "notifications": {"event": notificationStatus}
    };
    await ApiHandler.postHttp(
      baseUrl: 'https://eventotracker.com/api/v3/api.cfm/settings',
      body: data,
    );
  }
}
