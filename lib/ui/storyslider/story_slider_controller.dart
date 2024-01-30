import 'package:evento_core/social_media_widgets/insta_swipe_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../core/models/app_config.dart';
import '../../core/models/storyslider.dart';
import '../../core/utils/api_handler.dart';
import '../../core/utils/keys.dart';

class StorySliderController extends GetxController {

  InstagramSwipeController swipeController = InstagramSwipeController();

  Rx<int> position = Rx(0);

  double d = 0;

  RxList<StorySlider> sliders = RxList([]);



  @override
  void onInit() {
    super.onInit();
    getSlides();
  }

  getSlides() async {
    Items item = Get.arguments[AppKeys.moreItem];
    final res = await ApiHandler.genericGetHttp(url: item.storySlider!.url!);
    sliders.value = (res.data['items'] as List).map((e) => StorySlider.fromJson(e)).toList();
    update();

    Future.delayed(const Duration(milliseconds: 200), () {
      swipeController.pageController.addListener(() {
        double pos = (swipeController.pageController.page ?? 0.0);
        position.value = pos > d ? pos.ceil() : pos.floor();
        d = pos;
        update();
      });
    });
  }

  @override
  void onReady() {
    super.onReady();
  }
}