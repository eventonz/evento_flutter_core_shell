import 'dart:async';

import 'package:evento_core/app_event_config.dart';
import 'package:evento_core/core/initial_binding.dart';
import 'package:evento_core/core/res/app_styles.dart';
import 'package:evento_core/core/routes/router.dart';
import 'package:evento_core/core/routes/routes.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/preferences.dart';
import 'package:evento_core/ui/settings/language_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:evento_core/core/utils/logger.dart';
import 'package:uni_links/uni_links.dart';
import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/utils/keys.dart';

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
  }

  void _handleIncomingLinks() {
    Logger.i('Setting up deep link handler');
    _sub = uriLinkStream.listen(
      (Uri? uri) {
        Logger.i('Received deep link: $uri');
        if (uri != null) {
          _handleDeepLink(uri);
        }
      },
      onError: (err) {
        Logger.e('Deep link error: $err');
      },
    );
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
              initialRoute: Routes.landing,
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
                  builder:
                      (context, orientation, screenSize) =>
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
