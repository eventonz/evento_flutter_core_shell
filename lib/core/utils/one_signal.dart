import 'dart:io';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

class AppOneSignal {
  static Future<void> init() async {
    await OneSignal.shared.setAppId(AppGlobals.appEventConfig.oneSignalId);

    if (Platform.isIOS) {
      OneSignal.shared.setLaunchURLsInApp(true);
    }

    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.setRequiresUserPrivacyConsent(false);

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      debugPrint('NOTIFICATION OPENED HANDLER CALLED WITH: $result');
    });

    OneSignal.shared.setNotificationWillShowInForegroundHandler(
        (OSNotificationReceivedEvent event) {
      debugPrint('FOREGROUND HANDLER CALLED WITH: $event');

      event.complete(null);
    });

    OneSignal.shared
        .setInAppMessageClickedHandler((OSInAppMessageAction action) {
      debugPrint(
          "In App Message Clicked: \n${action.jsonRepresentation().replaceAll("\\n", "\n")}");
    });

    OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {
      debugPrint("Accepted permission: $accepted");
    });
  }

  static Future<String> setOneSignalUserId() async {
    String userId = '';
    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) {
      userId = changes.to.userId ?? '';
      AppGlobals.oneSignalUserId = userId;
      debugPrint('ONE SIGNAL ID: $userId');
    });

    return userId;
  }

  static Future<void> updateNotificationStatus(
      String userId, int eventId, bool notificationStatus) async {
    final data = {
      "race_id": eventId,
      "player_id": userId,
      "notifications": {"event": notificationStatus}
    };
    await ApiHandler.postHttp(
        baseUrl: 'https://eventotracker.com/api/v3/api.cfm/settings',
        body: data);
  }
}
