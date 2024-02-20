import 'dart:async';

import 'package:evento_core/core/services/app_one_signal/app_one_signal_service.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/core/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:uni_links/uni_links.dart';

class AppOneSignalImpl implements AppOneSignal {
  AppOneSignalImpl() {
    init();
    initUniLinks();
  }

  late StreamSubscription _sub;

  Future<void> initUniLinks() async {
    try {
      String? initialLink = await getInitialLink();
      if (initialLink != null) {
        // Handle the initial deep link
        print(initialLink);
      }
    } catch (e) {
      print('Error initializing deep link: $e');
    }

    // Listen for incoming deep links
    _sub = linkStream.listen((String? link) {
      if (link != null) {
        // Handle the incoming deep link
        print(link);
      }
    }, onError: (error) {
      print('Error listening to deep link: $error');
    });
  }

  Future<void> init() async {
    await Future.delayed(const Duration(seconds: 1));
    OneSignal.Debug.setLogLevel(OSLogLevel.debug);
    OneSignal.initialize(AppGlobals.appEventConfig.oneSignalId);
    OneSignal.Notifications.requestPermission(true);

    OneSignal.Notifications.addClickListener((event) {
      debugPrint('NOTIFICATION OPENED HANDLER CALLED WITH: ${event.result}');
    });

    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugPrint('FOREGROUND HANDLER CALLED WITH: $event');
    });

    await setOneSignalUserId();
  }

  @override
  Future<String> setOneSignalUserId() async {
    String userId = '';
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      userId = OneSignal.User.pushSubscription.id ?? '';
      if (userId.isNotEmpty) {
        await Preferences.setString(AppKeys.oneSingleUserId, userId);
        AppGlobals.oneSignalUserId = userId;
      } else {
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
