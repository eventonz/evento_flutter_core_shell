import 'dart:convert';

import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/models/event_info.dart';
import 'package:evento_core/core/overlays/progress_dialog.dart';
import 'package:evento_core/core/overlays/toast.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/routes/routes.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/core/utils/preferences.dart';
import 'package:evento_core/ui/dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../core/utils/app_global.dart';
import '../../core/utils/helpers.dart';
import 'subevent_sheet.dart';

class EventsController extends GetxController {
  late int eventId;
  late EventM eventM;
  late List<Event> allEvents;
  late RxList<Event> events;
  late String headerColor;
  late String headerLogo;
  late bool searchBar;
  late Event selEvent;
  RxBool loading = false.obs;
  int page = 1;

  final PageStorageBucket bucket = PageStorageBucket();

  TextEditingController searchController = TextEditingController();

  late ScrollController scrollController;

  final storage = GetStorage();

  @override
  void onInit() {
    super.onInit();

    // Check if eventM is available
    if (AppGlobals.eventM == null) {
      print('❌ ERROR: AppGlobals.eventM is null in EventsController.onInit()');
      // Set default values to prevent crashes
      headerLogo = '';
      headerColor = '';
      searchBar = false; // Default to false for bool
      allEvents = [];
      events = <Event>[].obs;
      return;
    }

    eventM = AppGlobals.eventM!;
    headerLogo = eventM.header?.logo ?? '';
    headerColor = eventM.header?.color ?? '';
    searchBar = eventM.searchBar ?? false; // Default to false if null
    allEvents = eventM.events ?? [];

    double? savedPosition = storage.read<double>('scroll_position');

    if (savedPosition != null) {
      scrollController = ScrollController(
        initialScrollOffset: savedPosition,
      );
      Future.delayed(const Duration(seconds: 2), () {
        scrollController.addListener(scrollListener);
      });
    } else {
      scrollController = ScrollController();
      scrollController.addListener(scrollListener);
    }
    // events = eventM.events!.obs.sublist(0, (savedPosition ?? 0.0) == 0.0 ? 20 : ((savedPosition!/100).toInt()+6) >= allEvents.length ? allEvents.length : ((savedPosition/100).toInt()+6)).obs;
    events = eventM.events!.obs
        .sublist(
            0,
            (savedPosition ?? 0.0) == 0.0
                ? (eventM.events!.length < 20 ? eventM.events!.length : 20)
                : (((savedPosition! / 100).toInt() + 6) >= eventM.events!.length
                    ? eventM.events!.length
                    : ((savedPosition! / 100).toInt() + 6)))
        .obs;
  }

  scrollListener() {
    if (scrollController.offset >=
            (scrollController.position.maxScrollExtent - 200) &&
        !loading.value &&
        events.length != allEvents.length) {
      loading.value = true;
      page += 1;
      update();
      Future.delayed(const Duration(milliseconds: 300), () {
        loading.value = false;
        events.addAll(allEvents.sublist(
            (page - 1) * 20,
            (((page - 1) * 20) + 20) > allEvents.length
                ? allEvents.length
                : (((page - 1) * 20) + 20)));
        update();
      });
    }
  }

  void onSearch(String val) {
    page = 1;
    // Trim the search value to remove any leading or trailing whitespace
    String trimmedVal = val.trim();

    if (trimmedVal.isNotEmpty) {
      // Filter events based on the trimmed search value
      events.value = allEvents
          .where((element) =>
              element.title.toLowerCase().contains(trimmedVal.toLowerCase()))
          .toList();
    } else {
      // Ensure the range for sublist is within bounds
      int endIndex = allEvents.length < 20 ? allEvents.length : 20;
      events.value = allEvents.sublist(0, endIndex).toList();
    }

    update();
    events.refresh();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void toDashboard() async {
    print('🔵 STEP 4: toDashboard() called - navigating to DashboardScreen');
    Get.off(() => const DashboardScreen(),
        routeName: Routes.dashboard,
        transition: Transition.topLevel,
        duration: const Duration(milliseconds: 1500),
        arguments: const {'is_prev': true});
  }

  void selectEvent(dynamic event) {
    print('🔵 STEP 1: Event selected - ${event.title ?? event.id}');
    storage.write('scroll_position', scrollController.position.pixels);
    if (event is Event) {
      if (event.subEvents == null) {
        print('🔵 STEP 1: Single event, calling getConfigDetails');
        getConfigDetails(event);
      } else {
        print('🔵 STEP 1: Event has sub-events, showing sub-event list');
        showSubEventList(event);
      }
    } else {
      print(
          '🔵 STEP 1: Non-Event object, going back and calling getConfigDetails');
      Get.back();
      getConfigDetails(event);
    }
  }

  void showSubEventList(Event event) {
    selEvent = event;
    Get.dialog(const SubEventSheet());
  }

  Future<void> getConfigDetails(dynamic event) async {
    print(
        '🔵 STEP 2: getConfigDetails started for event: ${event.title ?? event.id}');
    ProgressDialogUtils.show();
    try {
      print('🔵 STEP 2: Downloading config from: ${event.config}');
      final res = await ApiHandler.genericGetHttp(url: event.config);
      print('🔵 STEP 2: Config downloaded successfully, parsing...');

      AppGlobals.appConfig = AppConfig.fromJson(res.data);
      print('🔵 STEP 2: Config parsed successfully');

      // Save event selection and config to SharedPrefs immediately
      print('🔵 STEP 2: Saving event selection and config to SharedPrefs');
      saveEventSelection(event);

      // Ensure SharedPrefs is initialized before saving
      await Preferences.init();
      Preferences.setString(
          AppKeys.localConfig, jsonEncode(AppGlobals.appConfig?.toJson()));
      Preferences.setInt(AppKeys.configLastUpdated,
          AppGlobals.appConfig?.athletes?.lastUpdated ?? 0);
      print('🔵 STEP 2: Config saved to SharedPrefs successfully');

      final accentColors = AppGlobals.appConfig!.theme!.accent;
      AppColors.primary = AppHelper.hexToColor(accentColors!.light!);
      AppColors.secondary = AppHelper.hexToColor(accentColors.dark!);
      print('🔵 STEP 2: Theme colors applied');

      ProgressDialogUtils.dismiss();
      print('🔵 STEP 2: Progress dialog dismissed, calling toDashboard()');
      toDashboard();
    } catch (e) {
      print('❌ STEP 2 ERROR: ${e.toString()}');
      debugPrint(e.toString());
      ProgressDialogUtils.dismiss();
      ToastUtils.show(null);
    }
  }

  void saveEventSelection(dynamic event) {
    print('🔵 STEP 3: saveEventSelection started');
    Preferences.setString(AppKeys.eventUrl, event.config!);
    Preferences.setString(AppKeys.eventLink, event.link!);
    Preferences.setInt(AppKeys.eventId, event.id);
    AppGlobals.selEventId = event.id;
    print(
        '🔵 STEP 3: Event selection saved - EventId: ${event.id}, Config: ${event.config}');
  }
}
