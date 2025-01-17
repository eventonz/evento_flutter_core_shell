import 'dart:async';

import 'package:evento_core/app_event_config.dart';
import 'package:evento_core/core/initial_binding.dart';
import 'package:evento_core/core/res/app_styles.dart';
import 'package:evento_core/core/routes/router.dart';
import 'package:evento_core/core/routes/routes.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/ui/settings/language_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'l10n/app_localizations.dart';


final StreamController<bool> notificationHandlerController = StreamController<bool>.broadcast();

bool canRunNotificationHandler = false;

class EventoApp extends StatelessWidget {
  const EventoApp({super.key, required this.appEventConfig});
  final AppEventConfig appEventConfig;

  @override
  Widget build(BuildContext context) {
    AppGlobals.appEventConfig = appEventConfig;

    GetStorage.init();
    GetStorage().write('scroll_position', 0.0);

    print('HHHEELL');

    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    print('okko');

    notificationHandlerController.stream.listen((value) {
      if (value) {
        notificationHandlerController.close();
        print('canRunNotificationHandler $value');
        canRunNotificationHandler = true;
      }
    });

    final controller = Get.put(LanguageController());

    return LayoutBuilder(
      builder: (_, constraints) {
        return OrientationBuilder(
          builder: (_, orientation) {
            return GetBuilder(
              init: controller,
              builder: (c) => GetMaterialApp(
                debugShowCheckedModeBanner: false,
                theme: AppStyles.light,
                darkTheme: AppStyles.dark,
                initialRoute: Routes.landing,
                getPages: PageRouter.pages,
                initialBinding: MainBinding(),
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en'), // English
                  Locale('es'), // spanish
                  Locale('fr'), //French
                  Locale('de'),// Spanish
                ],

                 localeResolutionCallback: (deviceLocale, supportedLocales) {
                      if (deviceLocale != null) {
                        for (var locale in supportedLocales) {
                          if (locale.languageCode == deviceLocale.languageCode) {
                            return locale; // Match base language
                          }
                        }
                      }
                      // Fallback to default locale if no match
                      return supportedLocales.first;
                    },

                
                //locale: controller.locale?.value,
                builder: (_, child) {
                  return ResponsiveSizer(
                      builder: (context, orientation, screenSize) =>
                          child ?? const SizedBox.shrink());
                },
              ),
            );
          },
        );
      },
    );
  }
}
