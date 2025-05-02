import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:evento_core/app_event_config.dart';
import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/models/athlete.dart';
import 'package:evento_core/core/models/event_info.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/routes/routes.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/core/utils/preferences.dart';
import 'package:evento_core/core/utils/logger.dart';
import 'package:evento_core/ui/dashboard/dashboard.dart';
import 'package:evento_core/ui/dashboard/webview_event_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/overlays/toast.dart';
import '../events/events.dart';
import 'landing.dart';

class LandingController extends GetxController {
  bool isPrev = false;

  WebViewController? webViewController;

  RxBool noConnection = false.obs;
  RxBool exception = false.obs;

  Connectivity connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    final res = Get.arguments;
    if (res != null) {
      isPrev = true;
    }
    //setupDeepLinkListener();
  }

  void setupDeepLinkListener() {
    Logger.i('Setting up deep link listener');
    final appLinks = AppLinks();

    // Handle initial deep link
    appLinks.getInitialLink().then((Uri? initialLink) {
      if (initialLink != null) {
        Logger.i('Received initial deep link: ${initialLink.path}');
        handleDeepLink(initialLink);
      }
    }).catchError((e) {
      Logger.e('Error getting initial deep link: $e');
    });

    // Listen for incoming deep links
    appLinks.uriLinkStream.listen((Uri? link) {
      if (link != null) {
        Logger.i('Received deep link: ${link.path}');
        handleDeepLink(link);
      }
    }, onError: (error) {
      Logger.e('Error listening to deep links: $error');
    });
  }

  void handleDeepLink(Uri uri) async {
    Logger.i('Processing deep link: $uri');
    final path = uri.path;

    if (path.contains('/event_id/')) {
      try {
        final eventId = path.substring(
            path.indexOf('event_id/') + 9, path.indexOf('/athlete/'));
        final athleteId = path.split('/athlete/')[1];

        Logger.i(
            'Deep link contains event_id: $eventId and athlete_id: $athleteId');

        // Store the event ID
        AppGlobals.selEventId = int.parse(eventId);
        await Preferences.setInt(AppKeys.eventId, AppGlobals.selEventId);

        // First navigate to dashboard to show event context
        Logger.i('Navigating to dashboard for event: $eventId');
        await Get.offAllNamed(Routes.dashboard);

        // Then navigate to athlete details
        Logger.i('Navigating to athlete details for athlete: $athleteId');
        Get.toNamed(Routes.athleteDetails, arguments: {'id': athleteId});
      } catch (e) {
        Logger.e('Error processing deep link: $e');
      }
    } else {
      Logger.w('Deep link path does not contain expected pattern: $path');
    }
  }

  @override
  void onReady() {
    super.onReady();
    checkConnection();
  }

  checkConnection() async {
    await Future.delayed(const Duration(milliseconds: 300));
    var result = await connectivity.checkConnectivity();
    print(result.map((e) => e.toString()));

    if ((!result.contains(ConnectivityResult.wifi) &&
        !result.contains(ConnectivityResult.mobile) &&
        !result.contains(ConnectivityResult.ethernet))) {
      noConnection.value = true;
      update();
    } else {
      navigate();
    }
  }

  String extractEventId(String url) {
    final startIndex = url.indexOf('event_id/') + 9;
    final endIndex = url.contains('/athlete/')
        ? url.indexOf('/athlete/')
        : url.length;
    return url.substring(startIndex, endIndex);
  }

  void navigate() async {
    try {
      if (!isPrev) {
        await AppGlobals.init();
      }
      isPrev = true;
      await checkLaunchState();
      late String url;
      final config = AppGlobals.appEventConfig;
      if (config.multiEventListId != null) {
        url = Preferences.getString(AppKeys.eventUrl, '');
        await getEvents(config);
      } else {
        url =
            AppHelper.createUrl(config.singleEventUrl!, config.singleEventId!);
        AppGlobals.selEventId = int.parse(config.singleEventId!);
        Preferences.setInt(AppKeys.eventId, AppGlobals.selEventId);
      }
      AppGlobals.selEventId = Preferences.getInt(AppKeys.eventId, 0);
      checkTheme();
      await Future.delayed(const Duration(milliseconds: 1300));

      if(Get.arguments?['athlete_id'] != null) {
        Get.offNamed(Routes.dashboard)?.then((_) {
          Get.toNamed(Routes.athleteDetails, arguments: {'id' : Get.arguments['athlete_id']});
        });
      }

      var appLinks = AppLinks();
      var uri = await appLinks.getInitialLink();
      if(uri != null) {
        var open = uri.path;
        if (open.contains('/event_id/')) {
          var eventId = extractEventId(open);
          print(eventId);
          var event = AppGlobals.eventM?.events?.firstWhereOrNull((e) =>
          e.id == int.parse(eventId));
          if(event != null) {
            if(AppGlobals.appEventConfig.multiEventListId != null) {
              saveEventSelection(event);

              await getConfigDetails(event.config!, null);

              if (uri.path.contains('/athlete/')) {
                String athleteId = open.split('/athlete/')[1];
                Get.off(() => const DashboardScreen(),
                    routeName: Routes.dashboard,
                    transition: Transition.topLevel,
                    duration: const Duration(milliseconds: 1500),
                    arguments: const {'is_prev': true})?.then((_) {
                  Get.offNamed(Routes.athleteDetails, arguments: {'id': (athleteId)});
                });
                return;
              } else {
                Get.off(() => const DashboardScreen(),
                    routeName: Routes.dashboard,
                    transition: Transition.topLevel,
                    duration: const Duration(milliseconds: 1500),
                    arguments: const {'is_prev': true});
                return;
              }
            } else {
              if (uri.path.contains('/athlete/')) {
                String athleteId = open.split('/athlete/')[1];
                Get.off(() => const DashboardScreen(),
                    routeName: Routes.dashboard,
                    transition: Transition.topLevel,
                    duration: const Duration(milliseconds: 1500),
                    arguments: const {'is_prev': true})?.then((_) {
                  Get.offNamed(Routes.athleteDetails, arguments: {'id': (athleteId)});
                });
                return;
              }
            }

          }

        }
      }

      if (url.isEmpty) {
        Get.offNamed(Routes.events);
      } else {
        final webUrl = Preferences.getString(AppKeys.eventLink, '');
        print(webUrl);
        if (webUrl == '') {
          await getConfigDetails(url, config.configUrl);
          // await getAthletes();
        }
        webViewController = WebViewController();
        if (webUrl != '') {
          webViewController!.setJavaScriptMode(JavaScriptMode.unrestricted);
          webViewController!.setOnConsoleMessage((msg) {});
          await webViewController!.loadRequest(Uri.parse(webUrl));
          bool done = false;
          print('loaded');
          await Future.delayed(const Duration(seconds: 1));
          if (isPrev) {
            Get.off(() => const WebViewEventPage(),
                routeName: Routes.webviewEvent,
                transition: Transition.fadeIn,
                duration: const Duration(milliseconds: 1000),
                arguments: webViewController);
          } else {
            Get.offNamed(Routes.webviewEvent, arguments: webViewController);
          }
          return;
          webViewController!
              .setNavigationDelegate(NavigationDelegate(onPageFinished: (val) {
            if (!done) {
              done = true;
            }
          }));
          return;
        }
        if (isPrev) {
          Get.off(
            () => const DashboardScreen(),
            routeName: Routes.dashboard,
            transition: Transition.fadeIn,
            duration: const Duration(milliseconds: 1000),
          );
        } else {
          Get.offNamed(Routes.dashboard);
        }
      }
    } catch (e) {
      ToastUtils.show(e.toString());
      if (AppGlobals.appEventConfig.multiEventListId != null) {
        Preferences.setString(AppKeys.eventUrl, '');
        Get.off(
          () => const EventsScreen(),
          routeName: Routes.events,
          transition: Transition.leftToRightWithFade,
        );
      } else {
        exception.value = true;
        update();
      }
    }
  }

  static void saveEventSelection(dynamic event) {
    Preferences.setString(AppKeys.eventUrl, event.config!);
    Preferences.setString(AppKeys.eventLink, event.link!);
    Preferences.setInt(AppKeys.eventId, event.id);
    AppGlobals.selEventId = event.id;
  }

  Future<void> checkLaunchState() async {
    final isInitiallyLaunched =
        Preferences.getBool(AppKeys.isInitiallyLaunched, false);

    if (!isInitiallyLaunched) {
      //await ApiHandler.postHttp(
      //   baseUrl:
      //      'https://eventotracker.com/api/v3/api.cfm/downloads/${AppGlobals.appEventConfig.oneSignalId}',
      //   body: {});
      Preferences.setBool(AppKeys.isInitiallyLaunched, true);
    }
  }

  void checkTheme() {
    final themeMode = AppHelper.getAppTheme(
        Preferences.getString(AppKeys.appThemeStyle, ThemeMode.system.name));
    Get.changeThemeMode(themeMode);
  }

  Future<void> getEvents(AppEventConfig config) async {
    final res = await ApiHandler.genericGetHttp(
        url: AppHelper.createUrl(
            config.multiEventListUrl!, config.multiEventListId!));
    AppGlobals.eventM = EventM.fromJson(res.data);
  }

  Future<void> getConfigDetails(String url, String? configUrl) async {
    final res = await ApiHandler.genericGetHttp(url: configUrl ?? url);
    AppGlobals.appConfig = AppConfig.fromJson(res.data);
    Preferences.setInt(AppKeys.configLastUpdated,
        AppGlobals.appConfig?.athletes?.lastUpdated ?? 0);
    final accentColors = AppGlobals.appConfig!.theme!.accent;
    AppColors.accentLight = AppHelper.hexToColor(accentColors!.light!);
    AppColors.accentDark = AppHelper.hexToColor(accentColors.dark!);
    AppColors.primary = Theme.of(Get.context!).brightness == Brightness.light
        ? AppColors.accentDark
        : AppColors.accentLight;
    AppColors.secondary = AppColors.primary == AppColors.accentDark
        ? AppColors.accentLight
        : AppColors.accentDark;
  }

  // Future<void> getAthletes() async {
  //   final entrantsList = AppGlobals.appConfig!.athletes!;
  //   final showAthletes = entrantsList.showAthletes ?? false;
  //   if (!showAthletes) {
  //     return;
  //   }
  //   try {
  //     final res = await ApiHandler.genericGetHttp(url: entrantsList.url!);
  //     late Map<String, dynamic> resJsonData;
  //     if (res.data.runtimeType == String) {
  //       resJsonData = jsonDecode(res.data);
  //     } else {
  //       resJsonData = res.data;
  //     }
  //     final athletesM = AthletesM.fromJson(resJsonData);
  //     await DatabaseHandler.insertAthletes(athletesM.entrants!);
  //     await Future.delayed(const Duration(milliseconds: 500));
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }
}
