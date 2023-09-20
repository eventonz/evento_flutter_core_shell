import 'package:evento_core/app_event_config.dart';
import 'package:evento_core/core/db/app_db.dart';
import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/overlays/toast.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/routes/routes.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/core/utils/preferences.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MoreController extends GetxController {
  late Menu moreDetails;
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  @override
  void onInit() {
    super.onInit();
    moreDetails = AppGlobals.appConfig!.menu!;
  }

  void decideNextView(Items item) {
    final itemType = item.type!;
    if (itemType == 'link') {
      AppHelper.showWebBottomSheet(item.title, item.link!.url!); //
    } else if (itemType == 'pages') {
      Get.toNamed(Routes.eventResults, arguments: {AppKeys.moreItem: item});
    } else if (itemType == 'carousel') {
      Get.toNamed(Routes.eventOffers, arguments: {AppKeys.moreItem: item});
    } else if (itemType == 'schedule') {
      Get.toNamed(Routes.schedule, arguments: {AppKeys.moreItem: item});
    } else if (itemType == 'open') {
      AppHelper.launchUrlApp(item.open?.url ?? '');
    } else if (itemType == 'actions') {
      Get.toNamed(Routes.userChallenge, arguments: {AppKeys.moreItem: item});
    } else if (itemType == 'assistant') {
      // DatabaseHandler.removeAllChatMessages();
      Get.toNamed(Routes.assistant, arguments: {AppKeys.moreItem: item});
    } else {
      ToastUtils.show('Something went wrong...');
    }
  }

  void onRefresh() async {
    await getConfigDetails();
    refreshController.refreshCompleted();
    update();
  }

  Future<void> getConfigDetails() async {
    final config = AppGlobals.appEventConfig;
    String url = Preferences.getString(AppKeys.eventUrl, '');
    if (url.isEmpty && config.multiEventListId == null) {
      url = AppHelper.createUrl(config.singleEventUrl!, config.singleEventId!);
      Preferences.setString(AppKeys.eventUrl, url);
      AppGlobals.selEventId = int.parse(config.singleEventId!);
      Preferences.setInt(AppKeys.eventId, AppGlobals.selEventId);
    } else {
      return;
    }
    final res = await ApiHandler.genericGetHttp(url: url);
    AppGlobals.appConfig = AppConfig.fromJson(res.data);
    moreDetails = AppGlobals.appConfig!.menu!;
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

  void toSettingsScreen() {
    Get.toNamed(Routes.settings);
  }
}
