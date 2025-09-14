import 'dart:async';
import 'dart:io';

import 'package:evento_core/app_event_config.dart';
import 'package:evento_core/core/initial_binding.dart';
import 'package:evento_core/core/res/app_styles.dart';
import 'package:evento_core/core/routes/router.dart';
import 'package:evento_core/core/routes/routes.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/preferences.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/ui/settings/language_controller.dart';
import 'package:evento_core/ui/events/events.dart';
import 'package:evento_core/ui/landing/landing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:evento_core/core/utils/logger.dart';
import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'l10n/app_localizations.dart';

final StreamController<bool> notificationHandlerController =
    StreamController<bool>.broadcast();

bool canRunNotificationHandler = false;

class EventoApp extends StatefulWidget {
  const EventoApp({super.key, required this.appEventConfig});
  final AppEventConfig appEventConfig;

  @override
  State<EventoApp> createState() => _EventoAppState();
}

class _EventoAppState extends State<EventoApp> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
    _handleFirstInstallApiCall();
  }

  void _handleIncomingLinks() {
    Logger.i('Setting up deep link handler');
  }

  void _handleDeepLink(Uri uri) async {
    Logger.i('Processing deep link: $uri');
    // Get event_id which is required for all deep links
    final eventId = uri.queryParameters['event_id'];
    Logger.i('Event ID from deep link: $eventId');
    if (eventId == null) return;

    // Store the selected event ID
    AppGlobals.selEventId = int.parse(eventId);
    await Preferences.setInt(AppKeys.eventId, AppGlobals.selEventId);
    Logger.i('Stored event ID: ${AppGlobals.selEventId}');

    // Navigate to dashboard first for all deep links
    Logger.i('Navigating to dashboard');
    await Get.offAllNamed(Routes.dashboard);

    // Handle athlete deep link if athlete_id is present
    final athleteId = uri.queryParameters['athlete_id'];
    if (athleteId != null) {
      // Get athlete data and navigate to details
      final athlete = await DatabaseHandler.getSingleAthleteOnce(athleteId);
      if (athlete != null) {
        Get.toNamed(
          Routes.athleteDetails,
          arguments: {AppKeys.athlete: athlete},
        );
      }
    }
  }

  void _handleFirstInstallApiCall() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstInstall = prefs.getBool('is_first_install') ?? true;

      Logger.i('First install check - isFirstInstall: $isFirstInstall');
      Logger.i('First install check - app_id: ${widget.appEventConfig.appId}');

      if (isFirstInstall && widget.appEventConfig.appId != null) {
        Logger.i(
            'First install detected, making API call with app_id: ${widget.appEventConfig.appId}');

        // Initialize ApiHandler if not already initialized
        await ApiHandler.init();

        // Get platform
        final platform = Platform.isIOS ? 'ios' : 'android';

        // Get app version
        final packageInfo = await PackageInfo.fromPlatform();
        final installVersion = packageInfo.version;

        // Get device ID (anonymized)
        final deviceInfo = DeviceInfoPlugin();
        String deviceId = '';

        if (Platform.isIOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceId = iosInfo.identifierForVendor ?? '';
        } else {
          final androidInfo = await deviceInfo.androidInfo;
          deviceId = androidInfo.id;
        }

        // Hash the device ID for privacy
        final hashedDeviceId = _hashDeviceId(deviceId);

        final requestBody = {
          'app_id': widget.appEventConfig.appId,
          'platform': platform,
          'install_version': installVersion,
          'device_id': hashedDeviceId,
          'installed_at': DateTime.now().toIso8601String(),
        };

        Logger.i('First install API call - Request body: $requestBody');

        // Make the API call
        final response = await ApiHandler.postHttp(
          endPoint: 'app_install',
          body: requestBody,
        );

        Logger.i(
            'First install API call - Response status: ${response.statusCode}');
        Logger.i('First install API call - Response data: ${response.data}');

        if (response.statusCode == 200) {
          Logger.i('First install API call successful');
        } else {
          Logger.e('First install API call failed: ${response.statusMessage}');
        }

        // Mark as not first install anymore regardless of API call success/failure
        await prefs.setBool('is_first_install', false);
        Logger.i('Marked app as no longer first install');
      } else {
        Logger.i('Not first install or app_id is null, skipping API call');
        Logger.i(
            'Debug - isFirstInstall: $isFirstInstall, appId: ${widget.appEventConfig.appId}');
      }
    } catch (e, stackTrace) {
      Logger.e('Error in first install API call: $e');
      Logger.e('Stack trace: $stackTrace');

      // Even if there's an error, mark as not first install to prevent retries
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_first_install', false);
        Logger.i('Marked app as no longer first install despite API error');
      } catch (prefsError) {
        Logger.e('Error setting first install flag: $prefsError');
      }
    }
  }

  String _hashDeviceId(String deviceId) {
    // Simple hash function for device ID privacy
    int hash = 0;
    for (int i = 0; i < deviceId.length; i++) {
      int char = deviceId.codeUnitAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32bit integer
    }
    return hash.abs().toString();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppGlobals.appEventConfig = widget.appEventConfig;

    GetStorage.init();
    GetStorage().write('scroll_position', 0.0);

    notificationHandlerController.stream.listen((value) {
      if (value) {
        notificationHandlerController.close();
        Logger.i('canRunNotificationHandler $value');
        canRunNotificationHandler = true;
      }
    });

    final controller = Get.put(LanguageController());

    return LayoutBuilder(
      builder: (_, constraints) {
        return OrientationBuilder(
          builder: (_, orientation) {
            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppStyles.light,
              darkTheme: AppStyles.dark,
              themeMode: ThemeMode.system,
              initialRoute: Routes.landing,
              unknownRoute: GetPage(
                name: Routes.landing,
                page: () => const LandingScreen(),
              ),
              getPages: PageRouter.pages,
              supportedLocales:
                  controller.supportedLanguages.map((s) => Locale(s)).toList(),
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              initialBinding: MainBinding(),
              builder: (_, child) {
                return ResponsiveSizer(
                  builder: (context, orientation, screenSize) =>
                      child ?? const SizedBox.shrink(),
                );
              },
            );
          },
        );
      },
    );
  }
}
