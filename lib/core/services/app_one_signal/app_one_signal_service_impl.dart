import 'dart:async';

import 'dart:convert';

import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/routes/routes.dart';
import 'package:evento_core/core/services/app_one_signal/app_one_signal_service.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/core/utils/preferences.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:app_links/app_links.dart';

import '../../../evento_app.dart';
import '../../../ui/dashboard/more/more_controller.dart';
import '../../models/app_config.dart';

class AppOneSignalImpl implements AppOneSignal {
  final appLinks = AppLinks();
  bool _isInitialized = false;

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
    if (_isInitialized) {
      print('🔔 OneSignal already initialized, skipping...');
      return;
    }

    print('🔔 Starting OneSignal initialization...');
    print('🔔 OneSignal ID: ${AppGlobals.appEventConfig.oneSignalId}');

    await Future.delayed(const Duration(seconds: 1));

    print('🔔 Setting OneSignal log level to verbose');
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    print(
        '🔔 Initializing OneSignal with ID: ${AppGlobals.appEventConfig.oneSignalId}');
    OneSignal.initialize(AppGlobals.appEventConfig.oneSignalId);

    print('🔔 Requesting notification permission (fallback: false)');
    OneSignal.Notifications.requestPermission(false);

    _isInitialized = true;
    print('🔔 OneSignal initialization complete');

    OneSignal.Notifications.addClickListener((event) async {
      debugPrint(
          'NOTIFICATION OPENED HANDLER CALLED WITH: \u001b[33m${event.notification.additionalData?['open']} ${event.result.url} ${event.result.actionId}\u001b[0m');
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
      String? eventId;

      if (open.contains('event_id/')) {
        eventId = open.substring(
            open.indexOf('event_id/') + 9, open.indexOf('/athlete/'));
        print('Extracted eventId: $eventId');

        // Switch to the correct event if different from current
        if (eventId.isNotEmpty) {
          final currentEventId = AppGlobals.selEventId.toString();
          if (currentEventId != eventId) {
            print('Switching to event: $eventId');
            await _switchToEvent(eventId);
          }
        }
      }

      // Navigate to dashboard after event switch is complete
      Get.offNamedUntil(Routes.dashboard, (_) => false);

      if (open.contains('/athlete/')) {
        String athleteId = open.split('/athlete/')[1];
        print('Looking for athlete: $athleteId');

        // Wait a bit more if we just switched events to ensure data is loaded
        if (eventId != null && eventId.isNotEmpty) {
          await Future.delayed(const Duration(seconds: 1));
        }

        // Try to find athlete in current event first
        AppAthleteDb? athlete =
            await DatabaseHandler.getSingleAthleteOnce(athleteId);

        if (athlete == null) {
          print('Athlete not found in current event, passing ID for lookup');
          // If not found, pass the ID for the athlete details screen to handle
          Get.toNamed(Routes.athleteDetails, arguments: {'id': athleteId});
        } else {
          print('Athlete found: ${athlete.name}');
          Get.toNamed(Routes.athleteDetails,
              arguments: {AppKeys.athlete: athlete});
        }
      }

      if (open.contains('/page/')) {
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

  Future<void> _switchToEvent(String eventId) async {
    try {
      print('Loading event configuration for event: $eventId');

      // Update the selected event ID
      AppGlobals.selEventId = int.parse(eventId);
      await Preferences.setInt(AppKeys.eventId, AppGlobals.selEventId);

      // Get the event configuration URL
      final eventConfig = AppGlobals.appEventConfig;
      String configUrl;

      if (eventConfig.multiEventListId != null) {
        // For multi-event apps, we need to get the event URL from the events list
        // This is a simplified approach - in production you might want to cache this
        configUrl = '${eventConfig.configUrl}?event_id=$eventId';
      } else {
        // For single event apps, use the single event URL
        configUrl = AppHelper.createUrl(eventConfig.singleEventUrl!, eventId);
      }

      print('Loading config from: $configUrl');

      // Load the event configuration
      final res = await ApiHandler.genericGetHttp(url: configUrl);
      AppGlobals.appConfig = AppConfig.fromJson(res.data);

      // Save the configuration
      await Preferences.setString(
          AppKeys.localConfig, jsonEncode(AppGlobals.appConfig?.toJson()));
      await Preferences.setInt(AppKeys.configLastUpdated,
          AppGlobals.appConfig?.athletes?.lastUpdated ?? 0);

      // Update theme colors
      final accentColors = AppGlobals.appConfig!.theme!.accent;
      AppColors.primary = AppHelper.hexToColor(accentColors!.light!);
      AppColors.secondary = AppHelper.hexToColor(accentColors.dark!);
      AppColors.accentLight = AppColors.primary;
      AppColors.accentDark = AppColors.secondary;
      AppHelper.updateAppTheme();

      print('Successfully switched to event: $eventId');
    } catch (e) {
      print('Error switching to event $eventId: $e');
      // If switching fails, we'll still try to navigate to the athlete
      // but it might not work if the event is wrong
    }
  }

  @override
  Future<String> setOneSignalUserId() async {
    print('🔔 USER ID: Starting setOneSignalUserId');
    String userId = '';
    await Preferences.init();

    // Try to get OneSignal ID with retries
    for (int attempt = 1; attempt <= 5; attempt++) {
      print(
          '🔔 USER ID: Attempt $attempt to get OneSignal push subscription ID');

      // Wait a bit for OneSignal to initialize
      await Future.delayed(Duration(seconds: attempt));

      userId = OneSignal.User.pushSubscription.id ?? '';
      print('🔔 USER ID: OneSignal push subscription ID: $userId');

      if (userId.isNotEmpty) {
        print(
            '🔔 USER ID: OneSignal ID found on attempt $attempt, saving to preferences');
        await Preferences.setString(AppKeys.oneSingleUserId, userId);
        AppGlobals.oneSignalUserId = userId;
        print('🔔 USER ID: OneSignal ID saved and set in AppGlobals: $userId');
        return userId;
      }

      print(
          '🔔 USER ID: OneSignal ID still empty on attempt $attempt, retrying...');
    }

    // If all attempts failed, use fallback
    print('🔔 USER ID: All attempts failed, using fallback from preferences');
    userId = Preferences.getString(AppKeys.oneSingleUserId, '');
    AppGlobals.oneSignalUserId = userId;
    print('🔔 USER ID: Using fallback ID: $userId');

    return userId;
  }

  @override
  Future<void> updateNotificationStatus(
      String userId, int eventId, bool notificationStatus) async {
    print('🔔 API CALL: Starting notification status update');
    print('🔔 API CALL: userId: $userId');
    print('🔔 API CALL: eventId: $eventId');
    print('🔔 API CALL: notificationStatus: $notificationStatus');

    // Ensure we have a valid player ID
    String playerId = userId;
    if (playerId.isEmpty) {
      print('🔔 API CALL: userId is empty, getting player ID from helper');
      // Use the helper method to get a player ID with fallbacks
      playerId = await AppHelper.getPlayerId();
      print('🔔 API CALL: Got player ID from helper: $playerId');
    }

    final data = {
      "race_id": eventId,
      "player_id": playerId,
      "notifications": {"event": notificationStatus}
    };

    print('🔔 API CALL: Sending data to OneSignal API: $data');

    try {
      var response = await ApiHandler.postHttp(
        baseUrl: 'https://eventotracker.com/api/v3/api.cfm/settings',
        body: data,
      );
      print('🔔 API CALL: OneSignal API response: ${response.statusCode}');
      print('🔔 API CALL: OneSignal API data: ${response.data}');
    } catch (e) {
      print('🔔 API CALL: Error calling OneSignal API: $e');
      rethrow;
    }
  }
}
