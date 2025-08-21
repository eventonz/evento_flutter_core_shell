import 'dart:convert';

import 'package:evento_core/core/services/app_one_signal/app_one_signal_service.dart';
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
    print('🔵 STEP 5: LandingController.onInit() started');
    final res = Get.arguments;
    if (res != null) {
      isPrev = true;
      print('🔵 STEP 5: Arguments found, isPrev set to true');
    } else {
      print('🔵 STEP 5: No arguments, isPrev remains false');
    }
    print('🔵 STEP 5: LandingController.onInit() completed');
  }

  @override
  void onReady() {
    super.onReady();
    print('🔵 STEP 5.5: LandingController.onReady() started');

    final isMultiEvent = AppGlobals.appEventConfig.multiEventListId != null;
    print('🔵 STEP 5.5: Is multi-event: $isMultiEvent');

    if (isMultiEvent) {
      print('🔵 STEP 5.5: Multi-event app, initializing OneSignal');
      Preferences.init().then((_) {
        final oneSignalService = Get.find<AppOneSignal>();
        // Don't show notification prompt here - let DashboardController handle it
        // when user reaches the home page
        oneSignalService.initializeOneSignal();
      });
    }

    print('🔵 STEP 5.5: Calling checkConnection()');
    checkConnection();
    print('🔵 STEP 5.5: LandingController.onReady() completed');
  }

  checkConnection() async {
    print('🔵 STEP 5.6: checkConnection() started');
    await Future.delayed(const Duration(milliseconds: 300));
    print('🔵 STEP 5.6: 300ms delay completed');

    var result = await connectivity.checkConnectivity();
    print(
        '🔵 STEP 5.6: Connectivity result: ${result.map((e) => e.toString())}');

    if ((!result.contains(ConnectivityResult.wifi) &&
        !result.contains(ConnectivityResult.mobile) &&
        !result.contains(ConnectivityResult.ethernet))) {
      print('🔵 STEP 5.6: No internet connection detected');
      await Preferences.init();
      if (Preferences.getString(AppKeys.localConfig, '{}') == '{}') {
        print('🔵 STEP 5.6: No local config, setting noConnection to true');
        noConnection.value = true;
      } else {
        print('🔵 STEP 5.6: Local config found, calling navigate()');
        navigate();
      }
      update();
    } else {
      print('🔵 STEP 5.6: Internet connection detected, calling navigate()');
      navigate();
    }
    print('🔵 STEP 5.6: checkConnection() completed');
  }

  String extractEventId(String url) {
    final startIndex = url.indexOf('event_id/') + 9;
    final endIndex =
        url.contains('/athlete/') ? url.indexOf('/athlete/') : url.length;
    return url.substring(startIndex, endIndex);
  }

  Future<void> _navigateToAthleteDetails(
      String athleteId, String url, AppEventConfig config) async {
    await getConfigDetails(url, config.configUrl);

    Get.offAll(
      () => const DashboardScreen(),
      routeName: Routes.dashboard,
      transition: Transition.topLevel,
      duration: const Duration(milliseconds: 1500),
      arguments: const {'is_prev': true, 'is_deeplink': true},
    );
    await Future.delayed(const Duration(milliseconds: 2000));
    Get.toNamed(Routes.athleteDetails, arguments: {'id': athleteId});
  }

  Future<void> _navigateToDashboard() async {
    Get.offAll(
      () => const DashboardScreen(),
      routeName: Routes.dashboard,
      transition: Transition.topLevel,
      duration: const Duration(milliseconds: 1500),
      arguments: const {'is_prev': true},
    );
  }

  Future<void> _handleWebViewNavigation(
      String url, String? configUrl, bool isPrev) async {
    print(
        '🔵 STEP 7: _handleWebViewNavigation started - URL: $url, isPrev: $isPrev');

    final webUrl = Preferences.getString(AppKeys.eventLink, '');
    if (webUrl.isNotEmpty) {
      print('🔵 STEP 7: Web URL found, showing WebViewEventPage');
      webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(webUrl));

      Get.offAll(
        () => WebViewEventPage(),
        routeName: Routes.webviewEvent,
        arguments: webViewController,
      );
      return;
    }

    print(
        '🔵 STEP 7: No web URL, getting config details and showing DashboardScreen');
    await getConfigDetails(url, configUrl);
    Get.offAll(
      () => isPrev ? const DashboardScreen() : WebViewEventPage(),
      routeName: isPrev ? Routes.dashboard : Routes.webviewEvent,
    );
  }

  void navigate() async {
    print('🔵 STEP 6: LandingController.navigate() started');
    try {
      // Always initialize SharedPrefs first
      print('🔵 STEP 6: Initializing SharedPrefs');
      await Preferences.init();
      print('🔵 STEP 6: SharedPrefs initialized successfully');

      // Initialize AppGlobals if first time
      if (!isPrev) {
        print('🔵 STEP 6: First time launch, initializing AppGlobals');
        await AppGlobals.init();
      }

      // Load AppConfig from SharedPrefs
      print('🔵 STEP 6: Loading AppConfig from SharedPrefs');
      var savedConfig = Preferences.getString(AppKeys.localConfig, '{}');
      if (savedConfig != '{}') {
        AppGlobals.appConfig = AppConfig.fromJson(jsonDecode(savedConfig));
        print('🔵 STEP 6: AppConfig loaded successfully from SharedPrefs');
      } else {
        print('🔵 STEP 6: No saved config found, creating empty config');
        // Create an empty config to prevent crashes
        AppGlobals.appConfig = AppConfig();
        print('🔵 STEP 6: Empty AppConfig created');
      }

      isPrev = true;
      print('🔵 STEP 6: Checking launch state');
      await checkLaunchState();

      late String url;
      final eventConfig = AppGlobals.appEventConfig;
      if (eventConfig.multiEventListId != null) {
        print('🔵 STEP 6: Multi-event app, getting URL from preferences');
        url = Preferences.getString(AppKeys.eventUrl, '');
        await getEvents(eventConfig);
      } else {
        print('🔵 STEP 6: Single event app, creating URL from config');
        url = AppHelper.createUrl(
            eventConfig.singleEventUrl!, eventConfig.singleEventId!);
        AppGlobals.selEventId = int.parse(eventConfig.singleEventId!);
        Preferences.setInt(AppKeys.eventId, AppGlobals.selEventId);
      }
      AppGlobals.selEventId = Preferences.getInt(AppKeys.eventId, 0);
      print('🔵 STEP 6: Event ID set to: ${AppGlobals.selEventId}');

      checkTheme();
      print('🔵 STEP 6: Theme checked, waiting 1.3 seconds');
      await Future.delayed(const Duration(milliseconds: 1300));

      if (Get.arguments?['athlete_id'] != null) {
        Get.offNamed(Routes.dashboard)?.then((_) {
          Get.toNamed(Routes.athleteDetails,
              arguments: {'id': Get.arguments['athlete_id']});
        });
      }

      final appLinks = AppLinks();
      final uri = await appLinks.getInitialLink();

      if (uri != null) {
        final path = uri.path;
        if (path.contains('/event_id/')) {
          final eventId = extractEventId(path);
          final event = AppGlobals.eventM?.events
              ?.firstWhereOrNull((e) => e.id == int.parse(eventId));

          if (event != null ||
              AppGlobals.appEventConfig.multiEventListId == null) {
            // Handle multi-event case
            if (AppGlobals.appEventConfig.multiEventListId != null) {
              saveEventSelection(event);
              await getConfigDetails(event!.config!, null);
            }

            // Handle athlete deep link
            if (path.contains('/athlete/')) {
              final athleteId = path.split('/athlete/')[1];
              await _navigateToAthleteDetails(athleteId, url, eventConfig);
              return; // This will prevent further execution
            } else {
              await _navigateToDashboard();
              return;
            }
          }
        }
      }

// Handle non-deep link cases
      if (url.isEmpty) {
        print('🔵 STEP 6: No URL found, going back to events');
        Get.offNamed(Routes.events);
      } else {
        print('🔵 STEP 6: URL found: $url, calling _handleWebViewNavigation');
        await _handleWebViewNavigation(url, eventConfig.configUrl, isPrev);
      }

// Helper methods
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
    var savedConfig = Preferences.getString(AppKeys.localConfig, '{}');
    AppGlobals.appConfig = AppConfig.fromJson(jsonDecode(savedConfig));
    try {
      final res = await ApiHandler.genericGetHttp(url: configUrl ?? url);
      if (res.statusCode != 200) {
        throw Exception('error');
      }
      AppGlobals.appConfig = AppConfig.fromJson(res.data);
      Preferences.setString(
          AppKeys.localConfig, jsonEncode(AppGlobals.appConfig?.toJson()));
    } catch (e) {
      print(e);
    }

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

    // Update the app theme to reflect the new colors
    AppHelper.updateAppTheme();
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
