import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/models/event_info.dart';
import 'package:evento_core/core/overlays/progress_dialog.dart';
import 'package:evento_core/core/overlays/toast.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/routes/routes.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/core/utils/preferences.dart';
import 'package:evento_core/ui/landing/landing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/utils/app_global.dart';
import '../../core/utils/helpers.dart';
import 'subevent_sheet.dart';

class EventsController extends GetxController {
  late int eventId;
  late EventM eventM;
  late List<Event> events;
  late String headerColor;
  late String headerLogo;
  late Event selEvent;

  @override
  void onInit() {
    super.onInit();
    eventM = AppGlobals.eventM!;
    headerLogo = eventM.header!.logo ?? '';
    headerColor = eventM.header!.color ?? '';
    events = eventM.events!;
  }

  void toLanding() async {
    Get.off(() => const LandingScreen(),
        routeName: Routes.landing,
        transition: Transition.topLevel,
        duration: const Duration(milliseconds: 1500),
        arguments: const {'is_prev': true});
  }

  void selectEvent(dynamic event) {
    if (event is Event) {
      if (event.subEvents == null) {
        getConfigDetails(event);
      } else {
        showSubEventList(event);
      }
    } else {
      Get.back();
      getConfigDetails(event);
    }
  }

  void showSubEventList(Event event) {
    selEvent = event;
    Get.dialog(const SubEventSheet());
  }

  Future<void> getConfigDetails(dynamic event) async {
    ProgressDialogUtils.show();
    try {
      final res = await ApiHandler.genericGetHttp(url: event.config!);
      AppGlobals.appConfig = AppConfig.fromJson(res.data);
      final accentColors = AppGlobals.appConfig!.theme!.accent;
      AppColors.primary = AppHelper.hexToColor(accentColors!.light!);
      AppColors.secondary = AppHelper.hexToColor(accentColors.dark!);
      ProgressDialogUtils.dismiss();
      saveEventSelection(event);
      toLanding();
    } catch (e) {
      debugPrint(e.toString());
      ProgressDialogUtils.dismiss();
      ToastUtils.show(null);
    }
  }

  void saveEventSelection(dynamic event) {
    Preferences.setString(AppKeys.eventUrl, event.config!);
    Preferences.setInt(AppKeys.eventId, event.id);
    AppGlobals.selEventId = event.id;
  }
}
