import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/overlays/toast.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/routes/routes.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/app_global.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:evento_core/core/utils/preferences.dart';
import 'package:evento_core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:evento_core/core/utils/app_global.dart';

import '../../../core/models/storyslider.dart';

class MoreController extends GetxController {
  late Menu moreDetails;
  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  List<StorySlider>? sliders;

  @override
  void onInit() {
    super.onInit();
    moreDetails = AppGlobals.appConfig!.menu!;
    storeCache();
  }

  storeCache() async {
    int i = 0;
    moreDetails.items?.forEach((item) {
      i++;
      if (item.type == 'storyslider') {
        final res = ApiHandler.genericGetHttp(url: item.storySlider!.url!)
            .then((value) {
          print('ss');
          print(value.data);
          sliders = (value.data['items'] as List).map((e) {
            var slider = StorySlider.fromJson(e);
            return slider;
          }).toList();
          if (sliders!.isNotEmpty) {
            for (int x = 0; x < sliders!.length; x++) {
              if ((sliders![x].video ?? sliders![x].image) == null) {
                continue;
              }
              try {
                DefaultCacheManager()
                    .getSingleFile(sliders![x].video ?? sliders![x].image!)
                    .then((value) {
                  print(value.path);
                  print(value.path);
                  sliders![0].videoPlayerController =
                      VideoPlayerController.file(value)
                        ..initialize().then((value) {});
                });
              } catch (e) {}
            }
          }
        });
      }
    });
  }

  void decideNextView(Items item) {
    // Debug: Print item details
    print('Menu item details:');
    print('  Type: ${item.type}');
    print('  Title: ${item.title}');
    print('  SportSplitsRaceId: ${item.sportSplitsRaceId}');
    print('  ID: ${item.id}');

    final itemType = item.type;

    // Fallback: Try to infer type from other fields if type is missing
    String? inferredType;
    if (itemType == null || itemType.isEmpty) {
      if (item.sportSplitsRaceId != null && item.sportSplitsRaceId! > 0) {
        inferredType = 'results';
        print(
            'Inferred type as "results" from sportSplitsRaceId: ${item.sportSplitsRaceId}');
      } else if (item.link != null) {
        inferredType = 'link';
        print('Inferred type as "link" from link field');
      } else if (item.schedule != null) {
        inferredType = 'schedule';
        print('Inferred type as "schedule" from schedule field');
      } else if (item.carousel != null) {
        inferredType = 'carousel';
        print('Inferred type as "carousel" from carousel field');
      }
    }

    final finalType = itemType ?? inferredType;
    if (finalType == null || finalType.isEmpty) {
      ToastUtils.show('Invalid menu item configuration - Type: ${item.type}');
      return;
    }

    if (finalType == 'link') {
      if (item.link?.url == null || item.link!.url!.isEmpty) {
        ToastUtils.show('Link URL not configured');
        return;
      }
      if (item.openExternal == true) {
        launchUrl(Uri.parse(item.link!.url!), mode: LaunchMode.platformDefault);
      } else {
        AppHelper.showWebBottomSheet(
            item.title, item.link!.url!, item.linkType); //
      }
    } else if (finalType == 'pages') {
      Get.toNamed(Routes.eventResults, arguments: {AppKeys.moreItem: item});
    } else if (finalType == 'eventomap') {
      Get.toNamed(Routes.eventoMap, arguments: {'source_id': item.sourceId});
    } else if (finalType == 'carousel') {
      Get.toNamed(Routes.eventOffers, arguments: {AppKeys.moreItem: item});
    } else if (finalType == 'schedule') {
      Get.toNamed(Routes.schedule, arguments: {AppKeys.moreItem: item});
    } else if (finalType == 'open') {
      if (item.open?.url == null || item.open!.url!.isEmpty) {
        ToastUtils.show('Open URL not configured');
        return;
      }
      AppHelper.launchUrlApp(item.open!.url!);
    } else if (finalType == 'actions') {
      Get.toNamed(Routes.userChallenge, arguments: {AppKeys.moreItem: item});
    } else if (finalType == 'assistant') {
      // DatabaseHandler.removeAllChatMessages();
      Get.toNamed(Routes.assistant, arguments: {AppKeys.moreItem: item});
    } else if (finalType == 'assistantv2') {
      // DatabaseHandler.removeAllChatMessages();
      Get.toNamed(Routes.assistantv2, arguments: {AppKeys.moreItem: item});
    } else if (finalType == 'storyslider') {
      // DatabaseHandler.removeAllChatMessages();
      Get.toNamed(Routes.storySlider,
          arguments: {AppKeys.moreItem: item, 'slides': sliders});
    } else if (finalType == 'results') {
      Get.toNamed(Routes.results, arguments: {AppKeys.moreItem: item});
    } else if (finalType == 'leaderboard') {
      Get.toNamed(Routes.leaderboard, arguments: {AppKeys.moreItem: item});
    } else {
      ToastUtils.show(
          '${AppLocalizations.of(Get.context!)!.somethingWentWrong}...');
    }
  }

  void doRrefresh() async {
    await getConfigDetails();
    refreshController.refreshCompleted();
    update();
  }

  Future<void> getConfigDetails() async {
    final config = AppGlobals.appEventConfig;
    String url = Preferences.getString(AppKeys.eventUrl, '');
    if (url.isEmpty) {
      if (config.multiEventListId != null) {
        return;
      } else {
        url =
            AppHelper.createUrl(config.singleEventUrl!, config.singleEventId!);
        Preferences.setString(AppKeys.eventUrl, url);
        AppGlobals.selEventId = int.parse(config.singleEventId!);
        Preferences.setInt(AppKeys.eventId, AppGlobals.selEventId);
      }
    }
    final res = await ApiHandler.genericGetHttp(url: url);
    AppGlobals.appConfig = AppConfig.fromJson(res.data);
    Preferences.setInt(AppKeys.configLastUpdated,
        AppGlobals.appConfig?.athletes?.lastUpdated ?? 0);
    moreDetails = AppGlobals.appConfig!.menu!;
    storeCache();
    final accentColors = AppGlobals.appConfig!.theme!.accent;
    AppColors.accentLight = AppHelper.hexToColor(accentColors!.light!);
    AppColors.accentDark = AppHelper.hexToColor(accentColors.dark!);
    AppColors.primary = Theme.of(Get.context!).brightness == Brightness.light
        ? AppColors.accentDark
        : AppColors.accentLight;
    AppColors.secondary = AppColors.primary == AppColors.accentDark
        ? AppColors.accentLight
        : AppColors.accentDark;

    // Also update accent colors so all UI components use the theme
    AppColors.accentLight = AppColors.primary;
    AppColors.accentDark = AppColors.secondary;

    // Update the app theme to reflect the new colors
    AppHelper.updateAppTheme();
  }

  Future<void> toSettingsScreen() async {
    await FirebaseAnalytics.instance.logEvent(
      name: "opened_settings",
      parameters: {
        "event_id": Preferences.getInt(AppKeys.eventId, 0),
      },
    );
    Get.toNamed(Routes.settings);
  }
}
