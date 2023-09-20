import 'package:evento_core/core/models/app_config.dart';
import 'package:evento_core/core/models/event_offer.dart';
import 'package:evento_core/core/res/app_colors.dart';
import 'package:evento_core/core/utils/api_handler.dart';
import 'package:evento_core/core/utils/enums.dart';
import 'package:evento_core/core/utils/helpers.dart';
import 'package:evento_core/core/utils/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:get/get.dart';

class EventOffersController extends GetxController {
  late Items item;
  List<EventOffer> eventOffers = [];
  final dataSnapshot = DataSnapShot.loading.obs;
  final PageController pageController = PageController();
  final currentPageIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final res = Get.arguments;
    item = res[AppKeys.moreItem];
    getEventOffers();
  }

  void getEventOffers() async {
    dataSnapshot.value = DataSnapShot.loading;
    try {
      final res = await ApiHandler.genericGetHttp(url: item.carousel!.url!);
      final eventResultM = EventOffersM.fromJson(res.data);
      eventOffers.clear();
      eventOffers.addAll(eventResultM.eventOffer!);
      dataSnapshot.value = DataSnapShot.loaded;
    } catch (e) {
      debugPrint(e.toString());
      eventOffers.clear();
      dataSnapshot.value = DataSnapShot.error;
    }
  }

  void changePage(int pageIndex) {
    currentPageIndex.value = pageIndex;
    pageController.animateToPage(pageIndex,
        duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
  }

  void showWebSheet(String? title, String url) {
    AppHelper.showWebBottomSheet(title, url);
  }

  Color getSocialMediaButtonColor(Buttons button) {
    final type = button.socialMedia!.medium!;
    if (type == 'facebook') {
      return AppColors.faceBookColor;
    } else if (type == 'instagram') {
      return AppColors.instagramColor;
    } else {
      return AppColors.primary;
    }
  }

  IconData getSocialMediaButtonIcon(Buttons button) {
    final type = button.socialMedia!.medium!;
    if (type == 'facebook') {
      return Icons.facebook;
    } else if (type == 'instagram') {
      return FeatherIcons.instagram;
    } else {
      return FeatherIcons.codepen;
    }
  }
}
